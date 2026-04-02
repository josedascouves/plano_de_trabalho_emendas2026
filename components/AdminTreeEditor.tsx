import React, { useState, useEffect, useCallback } from 'react';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  X, Plus, Pencil, ChevronRight, ChevronDown,
  Eye, EyeOff, Check, Loader2, RefreshCw,
  BarChart3, DollarSign, Target, Database,
  AlertCircle, CheckCircle2, Save, XCircle
} from 'lucide-react';
import {
  PROGRAMAS as DEFAULT_PROGRAMAS,
  ACOES_SERVICOS_POR_PROGRAMA as DEFAULT_ACOES,
  METAS_QUANTITATIVAS_OPTIONS as DEFAULT_METAS_QUANT,
  NATUREZAS_DESPESA as DEFAULT_NATUREZAS,
  NATUREZAS_POR_PROGRAMA as DEFAULT_NATUREZAS_POR_PROGRAMA
} from '../constants';

// ─── Types ───────────────────────────────────────────────────────────────────

interface ProgramaDB {
  id: string;
  nome: string;
  ordem: number;
  ativo: boolean;
}

interface AcaoServicoDB {
  id: string;
  programa_id: string;
  categoria: string;
  item: string;
  ordem: number;
  ativo: boolean;
}

interface MetaQuantitativaDB {
  id: string;
  categoria: string;
  item: string;
  ordem: number;
  ativo: boolean;
}

interface NaturezaDespesaDB {
  id: string;
  codigo: string;
  descricao: string;
  ordem: number;
  ativo: boolean;
}

interface ProgramaNaturezaDB {
  id: string;
  programa_id: string;
  codigo: string;
  descricao: string;
  ordem: number;
  ativo: boolean;
}

type ActiveTab = 'programas' | 'metas' | 'naturezas';

interface Props {
  supabaseClient: SupabaseClient;
  onClose: () => void;
  onDataChanged?: () => void;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function groupBy<T>(arr: T[], key: (item: T) => string): Record<string, T[]> {
  return arr.reduce((acc, item) => {
    const k = key(item);
    if (!acc[k]) acc[k] = [];
    acc[k].push(item);
    return acc;
  }, {} as Record<string, T[]>);
}

// ─── Component ───────────────────────────────────────────────────────────────

export const AdminTreeEditor: React.FC<Props> = ({ supabaseClient, onClose, onDataChanged }) => {
  const [activeTab, setActiveTab] = useState<ActiveTab>('programas');
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [isSeeding, setIsSeeding] = useState(false);
  const [toast, setToast] = useState<{ type: 'success' | 'error'; msg: string } | null>(null);

  // Data
  const [programas, setProgramas] = useState<ProgramaDB[]>([]);
  const [acoes, setAcoes] = useState<AcaoServicoDB[]>([]);
  const [metasQuant, setMetasQuant] = useState<MetaQuantitativaDB[]>([]);
  const [naturezas, setNaturezas] = useState<NaturezaDespesaDB[]>([]);

  // Per-program naturezas
  const [programaNaturezas, setProgramaNaturezas] = useState<ProgramaNaturezaDB[]>([]);

  // Expand / Collapse
  const [expandedProgramas, setExpandedProgramas] = useState<Set<string>>(new Set());
  const [expandedCatAcoes, setExpandedCatAcoes] = useState<Set<string>>(new Set());
  const [expandedNaturezasSec, setExpandedNaturezasSec] = useState<Set<string>>(new Set());
  const [expandedCatMetas, setExpandedCatMetas] = useState<Set<string>>(new Set());

  const [editKey, setEditKey] = useState<string | null>(null);
  const [editValue, setEditValue] = useState('');
  const [addKey, setAddKey] = useState<string | null>(null);
  const [addValues, setAddValues] = useState<Record<string, string>>({});

  // ─── Data loading ───────────────────────────────────────────────────────

  const loadAll = useCallback(async () => {
    setIsLoading(true);
    setLoadError(null);
    try {
      // Queries simples sem duplo .order() para evitar erros de cache
      const [p, a, m, n, pn] = await Promise.all([
        supabaseClient.from('programas_orcamentarios').select('id,nome,ordem,ativo').order('ordem'),
        supabaseClient.from('acoes_servicos_catalogo').select('id,programa_id,categoria,item,ordem,ativo').order('ordem'),
        supabaseClient.from('metas_quantitativas_catalogo').select('id,categoria,item,ordem,ativo').order('ordem'),
        supabaseClient.from('naturezas_despesa').select('id,codigo,descricao,ordem,ativo').order('ordem'),
        supabaseClient.from('programa_naturezas_catalogo').select('id,programa_id,codigo,descricao,ordem,ativo').order('ordem'),
      ]);

      if (p.error) { setLoadError(`programas_orcamentarios: ${p.error.message}`); setIsLoading(false); return; }
      if (a.error) { setLoadError(`acoes_servicos_catalogo: ${a.error.message}`); setIsLoading(false); return; }
      if (m.error) { setLoadError(`metas_quantitativas: ${m.error.message}`); setIsLoading(false); return; }
      if (n.error) { setLoadError(`naturezas_despesa: ${n.error.message}`); setIsLoading(false); return; }
      if (pn.error) { setLoadError(`programa_naturezas_catalogo: ${pn.error.message}`); setIsLoading(false); return; }

      setProgramas(p.data || []);
      setAcoes(a.data || []);
      setMetasQuant(m.data || []);
      setNaturezas(n.data || []);
      setProgramaNaturezas(pn.data || []);
    } catch (e: any) {
      setLoadError(e.message || 'Erro desconhecido ao carregar dados');
    } finally {
      setIsLoading(false);
    }
  }, [supabaseClient]);

  useEffect(() => { loadAll(); }, [loadAll]);

  // ─── Toast ──────────────────────────────────────────────────────────────

  const showToast = (type: 'success' | 'error', msg: string) => {
    setToast({ type, msg });
    setTimeout(() => setToast(null), 3500);
  };

  // ─── Seed from constants ─────────────────────────────────────────────────

  const seedData = async (target: ActiveTab) => {
    setIsSeeding(true);
    try {
      if (target === 'programas') {
        const programaRows = DEFAULT_PROGRAMAS.map((nome, i) => ({ nome, ordem: i, ativo: true }));
        const { data: insertedProgramas, error: pe } = await supabaseClient
          .from('programas_orcamentarios')
          .upsert(programaRows, { onConflict: 'nome' })
          .select();
        if (pe) throw pe;

        const acaoRows: any[] = [];
        (insertedProgramas || []).forEach((prog: any) => {
          const progAcoes = DEFAULT_ACOES[prog.nome] || [];
          progAcoes.forEach((cat, ci) => {
            cat.itens.forEach((item, ii) => {
              acaoRows.push({
                programa_id: prog.id,
                categoria: cat.categoria,
                item,
                ordem: ci * 1000 + ii,
                ativo: true,
              });
            });
          });
        });
        if (acaoRows.length) {
          const { error: ae } = await supabaseClient
            .from('acoes_servicos_catalogo')
            .upsert(acaoRows, { onConflict: 'programa_id,categoria,item' });
          if (ae) throw ae;
        }

        // Seed naturezas por programa usando mapeamento de DEFAULT_NATUREZAS_POR_PROGRAMA
        // Se o programa estiver no mapeamento: insere apenas as naturezas listadas
        // Caso contrário: insere todas as naturezas do catálogo global
        const natRows: any[] = [];
        (insertedProgramas || []).forEach((prog: any) => {
          const allowedCodigos = DEFAULT_NATUREZAS_POR_PROGRAMA[prog.nome];
          const natsForProg = allowedCodigos
            ? DEFAULT_NATUREZAS.filter(n => allowedCodigos.includes(n.codigo))
            : DEFAULT_NATUREZAS;
          natsForProg.forEach((nat, ni) => {
            natRows.push({ programa_id: prog.id, codigo: nat.codigo, descricao: nat.descricao, ordem: ni, ativo: true });
          });
        });
        if (natRows.length) {
          const { error: pne } = await supabaseClient
            .from('programa_naturezas_catalogo')
            .upsert(natRows, { onConflict: 'programa_id,codigo' });
          if (pne) throw pne;
        }
      } else if (target === 'metas') {
        const metaRows: any[] = [];
        Object.entries(DEFAULT_METAS_QUANT).forEach(([categoria, itens], ci) => {
          itens.forEach((item, ii) => {
            metaRows.push({ categoria, item, ordem: ci * 1000 + ii, ativo: true });
          });
        });
        const { error: me } = await supabaseClient
          .from('metas_quantitativas_catalogo')
          .upsert(metaRows, { onConflict: 'categoria,item' });
        if (me) throw me;
      } else if (target === 'naturezas') {
        const natRows = DEFAULT_NATUREZAS.map((n, i) => ({
          codigo: n.codigo,
          descricao: n.descricao,
          ordem: i,
          ativo: true,
        }));
        const { error: ne } = await supabaseClient
          .from('naturezas_despesa')
          .upsert(natRows, { onConflict: 'codigo' });
        if (ne) throw ne;
      }
      showToast('success', 'Dados importados com sucesso!');
      await loadAll();
      onDataChanged?.();
    } catch (e: any) {
      showToast('error', e.message || 'Erro ao importar padrões');
    } finally {
      setIsSeeding(false);
    }
  };

  // ─── Generic helpers ─────────────────────────────────────────────────────

  const startEdit = (key: string, currentValue: string) => {
    setEditKey(key);
    setEditValue(currentValue);
    setAddKey(null);
  };

  const cancelEdit = () => {
    setEditKey(null);
    setEditValue('');
  };

  const startAdd = (key: string, defaults: Record<string, string> = {}) => {
    setAddKey(key);
    setAddValues(defaults);
    setEditKey(null);
  };

  const cancelAdd = () => {
    setAddKey(null);
    setAddValues({});
  };

  // ─── PROGRAMAS operations ────────────────────────────────────────────────

  const savePrograma = async (id: string) => {
    if (!editValue.trim()) return;
    const { error } = await supabaseClient
      .from('programas_orcamentarios')
      .update({ nome: editValue.trim(), updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Programa atualizado!');
  };

  const togglePrograma = async (id: string, current: boolean) => {
    const { error } = await supabaseClient
      .from('programas_orcamentarios')
      .update({ ativo: !current, updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addPrograma = async () => {
    const nome = (addValues['nome'] || '').trim();
    if (!nome) return;
    const { error } = await supabaseClient
      .from('programas_orcamentarios')
      .insert({ nome, ordem: programas.length, ativo: true });
    if (error) { showToast('error', error.message); return; }
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Programa adicionado!');
  };

  // ─── ACOES operations (categoria-level) ──────────────────────────────────

  const saveCategoriaAcao = async (programaId: string, oldCat: string) => {
    const newCat = editValue.trim();
    if (!newCat) return;
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .update({ categoria: newCat, updated_at: new Date().toISOString() })
      .eq('programa_id', programaId)
      .eq('categoria', oldCat);
    if (error) { showToast('error', error.message); return; }
    const oldKey = `${programaId}:${oldCat}`;
    const newKey = `${programaId}:${newCat}`;
    setExpandedCatAcoes(prev => {
      const next = new Set(prev);
      if (next.has(oldKey)) { next.delete(oldKey); next.add(newKey); }
      return next;
    });
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Categoria renomeada!');
  };

  const toggleCategoriaAcao = async (programaId: string, categoria: string, currentAtivo: boolean) => {
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .update({ ativo: !currentAtivo, updated_at: new Date().toISOString() })
      .eq('programa_id', programaId)
      .eq('categoria', categoria);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addCategoriaAcao = async (programaId: string) => {
    const categoria = (addValues['categoria'] || '').trim();
    const item = (addValues['item'] || '').trim();
    if (!categoria || !item) return;
    const maxOrdem = acoes
      .filter(a => a.programa_id === programaId)
      .reduce((m, a) => Math.max(m, a.ordem), -1);
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .insert({ programa_id: programaId, categoria, item, ordem: maxOrdem + 1, ativo: true });
    if (error) { showToast('error', error.message); return; }
    setExpandedProgramas(prev => new Set(prev).add(programaId));
    setExpandedCatAcoes(prev => new Set(prev).add(`${programaId}:${categoria}`));
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Categoria e item adicionados!');
  };

  // ─── ACOES operations (item-level) ───────────────────────────────────────

  const saveAcaoItem = async (id: string) => {
    if (!editValue.trim()) return;
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .update({ item: editValue.trim(), updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Item atualizado!');
  };

  const toggleAcaoItem = async (id: string, current: boolean) => {
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .update({ ativo: !current, updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addAcaoItem = async (programaId: string, categoria: string) => {
    const item = (addValues['item'] || '').trim();
    if (!item) return;
    const maxOrdem = acoes
      .filter(a => a.programa_id === programaId && a.categoria === categoria)
      .reduce((m, a) => Math.max(m, a.ordem), -1);
    const { error } = await supabaseClient
      .from('acoes_servicos_catalogo')
      .insert({ programa_id: programaId, categoria, item, ordem: maxOrdem + 1, ativo: true });
    if (error) { showToast('error', error.message); return; }
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Item adicionado!');
  };

  // ─── METAS operations ────────────────────────────────────────────────────

  const saveCategoriaMeta = async (oldCat: string) => {
    const newCat = editValue.trim();
    if (!newCat) return;
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .update({ categoria: newCat, updated_at: new Date().toISOString() })
      .eq('categoria', oldCat);
    if (error) { showToast('error', error.message); return; }
    setExpandedCatMetas(prev => {
      const next = new Set(prev);
      if (next.has(oldCat)) { next.delete(oldCat); next.add(newCat); }
      return next;
    });
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Categoria renomeada!');
  };

  const toggleCategoriaMeta = async (categoria: string, currentAtivo: boolean) => {
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .update({ ativo: !currentAtivo, updated_at: new Date().toISOString() })
      .eq('categoria', categoria);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addCategoriaMeta = async () => {
    const categoria = (addValues['categoria'] || '').trim();
    const item = (addValues['item'] || '').trim();
    if (!categoria || !item) return;
    const maxOrdem = metasQuant.reduce((m, a) => Math.max(m, a.ordem), -1);
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .insert({ categoria, item, ordem: maxOrdem + 1, ativo: true });
    if (error) { showToast('error', error.message); return; }
    setExpandedCatMetas(prev => new Set(prev).add(categoria));
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Categoria e item adicionados!');
  };

  const saveMetaItem = async (id: string) => {
    if (!editValue.trim()) return;
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .update({ item: editValue.trim(), updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Item atualizado!');
  };

  const toggleMetaItem = async (id: string, current: boolean) => {
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .update({ ativo: !current, updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addMetaItem = async (categoria: string) => {
    const item = (addValues['item'] || '').trim();
    if (!item) return;
    const maxOrdem = metasQuant
      .filter(m => m.categoria === categoria)
      .reduce((m, a) => Math.max(m, a.ordem), -1);
    const { error } = await supabaseClient
      .from('metas_quantitativas_catalogo')
      .insert({ categoria, item, ordem: maxOrdem + 1, ativo: true });
    if (error) { showToast('error', error.message); return; }
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Item adicionado!');
  };

  // ─── PROGRAMA NATUREZAS operations (per-program) ──────────────────────────

  const addProgramaNatureza = async (programaId: string) => {
    const selectedId = addValues['pn_select'] || '';
    let codigo = (addValues['pn_codigo'] || '').trim();
    let descricao = (addValues['pn_descricao'] || '').trim();

    if (selectedId && selectedId !== '__custom__') {
      const master = naturezas.find(n => n.id === selectedId);
      if (!master) return;
      codigo = master.codigo;
      descricao = master.descricao;
    }
    if (!codigo || !descricao) return;

    const existing = programaNaturezas.filter(pn => pn.programa_id === programaId);
    const maxOrdem = existing.reduce((m, pn) => Math.max(m, pn.ordem), -1);

    const { error } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .insert({ programa_id: programaId, codigo, descricao, ordem: maxOrdem + 1, ativo: true });
    if (error) { showToast('error', error.message); return; }
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Natureza adicionada ao programa!');
  };

  const toggleProgramaNatureza = async (id: string, current: boolean) => {
    const { error } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .update({ ativo: !current, updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const saveProgramaNatureza = async (id: string, field: 'codigo' | 'descricao') => {
    if (!editValue.trim()) return;
    const { error } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .update({ [field]: editValue.trim(), updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Natureza atualizada!');
  };

  const deleteProgramaNatureza = async (id: string) => {
    const { error } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .delete()
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Natureza removida do programa!');
  };

  const copyAllNaturezasToPrograma = async (programaId: string) => {
    if (naturezas.length === 0) {
      showToast('error', 'Nenhuma natureza no catálogo global. Importe as naturezas primeiro na aba "Natureza de Despesa".');
      return;
    }
    const usedCodigos = new Set(programaNaturezas.filter(pn => pn.programa_id === programaId).map(pn => pn.codigo));
    const toInsert = naturezas
      .filter(n => !usedCodigos.has(n.codigo))
      .map((n, i) => ({ programa_id: programaId, codigo: n.codigo, descricao: n.descricao, ordem: i, ativo: true }));
    if (toInsert.length === 0) {
      showToast('success', 'Todas as naturezas já estão configuradas para este programa.');
      return;
    }
    const { error } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .insert(toInsert);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
    showToast('success', `${toInsert.length} naturezas adicionadas ao programa!`);
  };

  const resetNaturezasPadrao = async (programaId: string, programaNome: string) => {
    const allowedCodigos = DEFAULT_NATUREZAS_POR_PROGRAMA[programaNome];
    if (!allowedCodigos?.length) {
      showToast('error', 'Este programa não tem configuração padrão definida.');
      return;
    }
    // Delete all then insert only the allowed ones
    const { error: delErr } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .delete()
      .eq('programa_id', programaId);
    if (delErr) { showToast('error', delErr.message); return; }
    const natToInsert = DEFAULT_NATUREZAS
      .filter(n => allowedCodigos.includes(n.codigo))
      .map((n, i) => ({ programa_id: programaId, codigo: n.codigo, descricao: n.descricao, ordem: i, ativo: true }));
    const { error: insErr } = await supabaseClient
      .from('programa_naturezas_catalogo')
      .insert(natToInsert);
    if (insErr) { showToast('error', insErr.message); return; }
    await loadAll();
    onDataChanged?.();
    showToast('success', `Padrão restaurado: ${natToInsert.length} naturezas configuradas.`);
  };

  // ─── NATUREZAS operations ─────────────────────────────────────────────────

  const saveNatureza = async (id: string, field: 'codigo' | 'descricao') => {
    if (!editValue.trim()) return;
    const { error } = await supabaseClient
      .from('naturezas_despesa')
      .update({ [field]: editValue.trim(), updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    cancelEdit();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Natureza atualizada!');
  };

  const toggleNatureza = async (id: string, current: boolean) => {
    const { error } = await supabaseClient
      .from('naturezas_despesa')
      .update({ ativo: !current, updated_at: new Date().toISOString() })
      .eq('id', id);
    if (error) { showToast('error', error.message); return; }
    await loadAll();
    onDataChanged?.();
  };

  const addNatureza = async () => {
    const codigo = (addValues['codigo'] || '').trim();
    const descricao = (addValues['descricao'] || '').trim();
    if (!codigo || !descricao) return;
    const { error } = await supabaseClient
      .from('naturezas_despesa')
      .insert({ codigo, descricao, ordem: naturezas.length, ativo: true });
    if (error) { showToast('error', error.message); return; }
    cancelAdd();
    await loadAll();
    onDataChanged?.();
    showToast('success', 'Natureza adicionada!');
  };

  // ─── Render helpers ───────────────────────────────────────────────────────

  const InlineInput: React.FC<{
    value: string;
    onChange: (v: string) => void;
    onSave: () => void;
    onCancel: () => void;
    placeholder?: string;
    className?: string;
  }> = ({ value, onChange, onSave, onCancel, placeholder, className }) => (
    <div className={`flex items-center gap-1 flex-1 ${className || ''}`}>
      <input
        autoFocus
        type="text"
        value={value}
        onChange={e => onChange(e.target.value)}
        onKeyDown={e => { if (e.key === 'Enter') onSave(); if (e.key === 'Escape') onCancel(); }}
        placeholder={placeholder}
        className="flex-1 px-2 py-1 text-sm border border-red-400 rounded-lg outline-none focus:ring-2 focus:ring-red-400/30 bg-white"
      />
      <button onClick={onSave} className="p-1 text-green-600 hover:text-green-700 flex-shrink-0" title="Salvar"><Check className="w-4 h-4" /></button>
      <button onClick={onCancel} className="p-1 text-gray-400 hover:text-gray-600 flex-shrink-0" title="Cancelar"><XCircle className="w-4 h-4" /></button>
    </div>
  );

  const RowActions: React.FC<{
    onEdit: () => void;
    ativo: boolean;
    onToggle: () => void;
    addLabel?: string;
    onAdd?: () => void;
  }> = ({ onEdit, ativo, onToggle, addLabel, onAdd }) => (
    <div className="flex items-center gap-1 flex-shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
      <button onClick={onEdit} className="p-1 text-gray-400 hover:text-blue-600 rounded" title="Editar"><Pencil className="w-3.5 h-3.5" /></button>
      <button onClick={onToggle} className={`p-1 rounded ${ativo ? 'text-gray-400 hover:text-orange-500' : 'text-orange-400 hover:text-orange-600'}`} title={ativo ? 'Desativar' : 'Ativar'}>
        {ativo ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}
      </button>
      {onAdd && (
        <button onClick={onAdd} className="p-1 text-gray-400 hover:text-green-600 rounded" title={addLabel || 'Adicionar'}>
          <Plus className="w-3.5 h-3.5" />
        </button>
      )}
    </div>
  );

  // ─── Tab content: Programas ───────────────────────────────────────────────

  const renderProgramasTab = () => {
    const acoesGrouped: Record<string, AcaoServicoDB[]> = groupBy(acoes, a => a.programa_id);

    return (
      <div className="space-y-1">
        {programas.length === 0 && (
          <EmptyState onSeed={() => seedData('programas')} isSeeding={isSeeding} label="Programas Orçamentários" />
        )}

        {programas.map(prog => {
          const isExpanded = expandedProgramas.has(prog.id);
          const progAcoes: AcaoServicoDB[] = acoesGrouped[prog.id] || [];
          const cats = Object.keys(groupBy(progAcoes, a => a.categoria)).sort();
          const isEditingThis = editKey === `programa:${prog.id}`;

          return (
            <div key={prog.id} className={`rounded-xl border ${prog.ativo ? 'border-gray-200 bg-white' : 'border-orange-200 bg-orange-50/40'}`}>
              {/* Program row */}
              <div className="group flex items-center gap-2 px-3 py-2.5">
                <button
                  onClick={() => setExpandedProgramas(prev => {
                    const n = new Set(prev);
                    n.has(prog.id) ? n.delete(prog.id) : n.add(prog.id);
                    return n;
                  })}
                  className="flex-shrink-0 text-gray-400 hover:text-gray-600"
                >
                  {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                </button>

                {isEditingThis ? (
                  <InlineInput
                    value={editValue}
                    onChange={setEditValue}
                    onSave={() => savePrograma(prog.id)}
                    onCancel={cancelEdit}
                    placeholder="Nome do programa"
                  />
                ) : (
                  <span className={`flex-1 text-sm font-semibold ${prog.ativo ? 'text-gray-800' : 'text-gray-400 line-through'}`}>
                    {prog.nome}
                    <span className="ml-2 text-xs font-normal text-gray-400">({progAcoes.length} itens)</span>
                  </span>
                )}

                {!isEditingThis && (
                  <RowActions
                    onEdit={() => startEdit(`programa:${prog.id}`, prog.nome)}
                    ativo={prog.ativo}
                    onToggle={() => togglePrograma(prog.id, prog.ativo)}
                    addLabel="Nova categoria"
                    onAdd={() => { setExpandedProgramas(prev => new Set(prev).add(prog.id)); startAdd(`cat_acao:${prog.id}`); }}
                  />
                )}
              </div>

              {/* Categories (Ações) */}
              {isExpanded && (
                <>
                  {/* ── AÇÕES / SERVIÇOS section ── */}
                  <div className="border-t border-gray-100 ml-6 mb-0">
                    <div className="px-3 py-1.5 bg-gray-50 border-b border-gray-100">
                      <span className="text-xs font-bold uppercase tracking-wider text-gray-400">Ações / Serviços</span>
                    </div>
                    {cats.map((categoria: string) => {
                      const catKey = `${prog.id}:${categoria}`;
                      const catExpanded = expandedCatAcoes.has(catKey);
                      const catItems: AcaoServicoDB[] = progAcoes.filter(a => a.categoria === categoria);
                      const allInactive = catItems.every(i => !i.ativo);
                      const isEditingCat = editKey === `cat_acao:${catKey}`;

                      return (
                        <div key={catKey} className="border-b border-gray-50 last:border-0">
                          <div className="group flex items-center gap-2 px-3 py-2">
                            <button
                              onClick={() => setExpandedCatAcoes(prev => {
                                const n = new Set(prev);
                                n.has(catKey) ? n.delete(catKey) : n.add(catKey);
                                return n;
                              })}
                              className="flex-shrink-0 text-gray-300 hover:text-gray-500"
                            >
                              {catExpanded ? <ChevronDown className="w-3.5 h-3.5" /> : <ChevronRight className="w-3.5 h-3.5" />}
                            </button>

                            {isEditingCat ? (
                              <InlineInput
                                value={editValue}
                                onChange={setEditValue}
                                onSave={() => saveCategoriaAcao(prog.id, categoria)}
                                onCancel={cancelEdit}
                                placeholder="Nome da categoria"
                              />
                            ) : (
                              <span className={`flex-1 text-xs font-bold uppercase tracking-wider ${allInactive ? 'text-gray-300 line-through' : 'text-gray-600'}`}>
                                {categoria}
                                <span className="ml-2 normal-case tracking-normal font-normal text-gray-400">({catItems.length})</span>
                              </span>
                            )}

                            {!isEditingCat && (
                              <RowActions
                                onEdit={() => startEdit(`cat_acao:${catKey}`, categoria)}
                                ativo={!allInactive}
                                onToggle={() => toggleCategoriaAcao(prog.id, categoria, allInactive)}
                                addLabel="Novo item"
                                onAdd={() => { setExpandedCatAcoes(prev => new Set(prev).add(catKey)); startAdd(`acao_item:${prog.id}:${categoria}`); }}
                              />
                            )}
                          </div>

                          {/* Items */}
                          {catExpanded && (
                            <div className="ml-6 pb-1">
                              {catItems.map((acao: AcaoServicoDB) => {
                                const isEditingItem = editKey === `acao_item:${acao.id}`;
                                return (
                                  <div key={acao.id} className="group flex items-center gap-2 px-3 py-1.5">
                                    <span className="text-gray-300 text-xs">—</span>
                                    {isEditingItem ? (
                                      <InlineInput
                                        value={editValue}
                                        onChange={setEditValue}
                                        onSave={() => saveAcaoItem(acao.id)}
                                        onCancel={cancelEdit}
                                      />
                                    ) : (
                                      <span className={`flex-1 text-sm ${acao.ativo ? 'text-gray-700' : 'text-gray-300 line-through'}`}>
                                        {acao.item}
                                      </span>
                                    )}
                                    {!isEditingItem && (
                                      <RowActions
                                        onEdit={() => startEdit(`acao_item:${acao.id}`, acao.item)}
                                        ativo={acao.ativo}
                                        onToggle={() => toggleAcaoItem(acao.id, acao.ativo)}
                                      />
                                    )}
                                  </div>
                                );
                              })}

                              {/* Add item inline form */}
                              {addKey === `acao_item:${prog.id}:${categoria}` && (
                                <AddItemRow
                                  fields={[{ key: 'item', placeholder: 'Nome do novo item...' }]}
                                  values={addValues}
                                  onChange={setAddValues}
                                  onSave={() => addAcaoItem(prog.id, categoria)}
                                  onCancel={cancelAdd}
                                />
                              )}
                            </div>
                          )}
                        </div>
                      );
                    })}

                    {/* Add category inline form */}
                    {addKey === `cat_acao:${prog.id}` && (
                      <div className="px-3 py-2">
                        <AddItemRow
                          fields={[
                            { key: 'categoria', placeholder: 'Nome da nova categoria...' },
                            { key: 'item', placeholder: 'Primeiro item da categoria...' },
                          ]}
                          values={addValues}
                          onChange={setAddValues}
                          onSave={() => addCategoriaAcao(prog.id)}
                          onCancel={cancelAdd}
                        />
                      </div>
                    )}
                  </div>

                  {/* ── NATUREZAS DE DESPESA section ── */}
                  {(() => {
                    const progNats = programaNaturezas.filter(pn => pn.programa_id === prog.id);
                    const natSecExpanded = expandedNaturezasSec.has(prog.id);
                    const addingNat = addKey === `prog_nat:${prog.id}`;
                    const isCustom = addValues['pn_select'] === '__custom__' || (!addValues['pn_select'] && naturezas.length === 0);
                    // Available naturezas not yet in this program
                    const usedCodigos = new Set(progNats.map(pn => pn.codigo));
                    const availableMaster = naturezas.filter(n => !usedCodigos.has(n.codigo));

                    return (
                      <div className="border-t border-blue-100 bg-blue-50/20 pb-1">
                        {/* Section header */}
                        <div
                          className="flex items-center gap-2 px-3 py-1.5 cursor-pointer hover:bg-blue-50/50 transition-colors"
                          onClick={() => setExpandedNaturezasSec(prev => {
                            const n = new Set(prev);
                            n.has(prog.id) ? n.delete(prog.id) : n.add(prog.id);
                            return n;
                          })}
                        >
                          {natSecExpanded ? <ChevronDown className="w-3.5 h-3.5 text-blue-400" /> : <ChevronRight className="w-3.5 h-3.5 text-blue-400" />}
                          <DollarSign className="w-3.5 h-3.5 text-blue-500" />
                          <span className="text-xs font-bold uppercase tracking-wider text-blue-600">Naturezas de Despesa</span>
                          <span className="text-xs text-blue-400">
                            ({progNats.length} {progNats.length === 0 ? '— todas as naturezas aparecem' : 'configuradas'})
                          </span>
                          {naturezas.length > 0 && availableMaster.length > 0 && !addingNat && (
                            <button
                              onClick={e => { e.stopPropagation(); copyAllNaturezasToPrograma(prog.id); }}
                              className="ml-auto flex items-center gap-1 text-xs text-green-700 bg-green-100 hover:bg-green-200 px-2 py-0.5 rounded-lg transition-colors font-semibold"
                              title="Adicionar todas as naturezas do catálogo a este programa"
                            >
                              <Database className="w-3 h-3" /> Copiar todas ({availableMaster.length})
                            </button>
                          )}
                          {DEFAULT_NATUREZAS_POR_PROGRAMA[prog.nome] && !addingNat && (
                            <button
                              onClick={e => { e.stopPropagation(); resetNaturezasPadrao(prog.id, prog.nome); }}
                              className="flex items-center gap-1 text-xs text-amber-700 bg-amber-100 hover:bg-amber-200 px-2 py-0.5 rounded-lg transition-colors font-semibold"
                              title="Restaurar configuração padrão para este programa"
                            >
                              <RefreshCw className="w-3 h-3" /> Restaurar padrão
                            </button>
                          )}
                        </div>

                        {natSecExpanded && (
                          <div className="ml-6">
                            {progNats.length === 0 && !addingNat && (
                              <p className="px-3 py-2 text-xs text-blue-400 italic">
                                Nenhuma natureza configurada — o formulário exibirá todas as naturezas disponíveis.
                                Adicione naturezas específicas para restringir a lista a este programa.
                              </p>
                            )}

                            {progNats.map(pn => {
                              const isEditCod = editKey === `pn_codigo:${pn.id}`;
                              const isEditDesc = editKey === `pn_descricao:${pn.id}`;
                              return (
                                <div key={pn.id} className={`group flex items-center gap-2 px-3 py-1.5 border-b border-blue-50 last:border-0 ${!pn.ativo ? 'opacity-50' : ''}`}>
                                  <div className="flex-1 flex items-center gap-2 min-w-0">
                                    {isEditCod ? (
                                      <InlineInput value={editValue} onChange={setEditValue} onSave={() => saveProgramaNatureza(pn.id, 'codigo')} onCancel={cancelEdit} placeholder="Código" className="w-24" />
                                    ) : (
                                      <span
                                        className="font-mono text-xs font-semibold text-blue-700 bg-blue-100 px-1.5 py-0.5 rounded cursor-pointer hover:bg-blue-200 flex-shrink-0"
                                        onClick={() => startEdit(`pn_codigo:${pn.id}`, pn.codigo)}
                                        title="Clique para editar código"
                                      >{pn.codigo}</span>
                                    )}
                                    {isEditDesc ? (
                                      <InlineInput value={editValue} onChange={setEditValue} onSave={() => saveProgramaNatureza(pn.id, 'descricao')} onCancel={cancelEdit} placeholder="Descrição" />
                                    ) : (
                                      <span
                                        className={`flex-1 text-xs truncate cursor-pointer hover:text-blue-600 ${pn.ativo ? 'text-gray-700' : 'text-gray-400 line-through'}`}
                                        onClick={() => startEdit(`pn_descricao:${pn.id}`, pn.descricao)}
                                        title="Clique para editar descrição"
                                      >{pn.descricao}</span>
                                    )}
                                  </div>
                                  <div className="flex items-center gap-1 flex-shrink-0">
                                    <button onClick={() => toggleProgramaNatureza(pn.id, pn.ativo)} className={`p-1 rounded ${pn.ativo ? 'text-orange-400 hover:text-orange-600' : 'text-gray-300 hover:text-green-600'}`} title={pn.ativo ? 'Desativar' : 'Ativar'}>
                                      {pn.ativo ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}
                                    </button>
                                    <button onClick={() => deleteProgramaNatureza(pn.id)} className="p-1 text-gray-300 hover:text-red-500 rounded" title="Remover">
                                      <XCircle className="w-3.5 h-3.5" />
                                    </button>
                                  </div>
                                </div>
                              );
                            })}

                            {/* Add natureza form */}
                            {addingNat ? (
                              <div className="px-3 py-2 space-y-2">
                                {availableMaster.length > 0 && (
                                  <select
                                    className="w-full px-2 py-1.5 text-xs border border-blue-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-400/30"
                                    value={addValues['pn_select'] || ''}
                                    onChange={e => setAddValues({ ...addValues, pn_select: e.target.value, pn_codigo: '', pn_descricao: '' })}
                                  >
                                    <option value="">Selecione da lista global...</option>
                                    {availableMaster.map(n => (
                                      <option key={n.id} value={n.id}>{n.codigo} — {n.descricao}</option>
                                    ))}
                                    <option value="__custom__">+ Digitar código/descrição personalizados</option>
                                  </select>
                                )}
                                {isCustom && (
                                  <div className="flex gap-2">
                                    <input
                                      type="text"
                                      placeholder="Código (ex: 339039)"
                                      value={addValues['pn_codigo'] || ''}
                                      onChange={e => setAddValues({ ...addValues, pn_codigo: e.target.value })}
                                      className="w-28 px-2 py-1 text-xs border border-blue-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-400/30"
                                    />
                                    <input
                                      type="text"
                                      placeholder="Descrição da natureza de despesa..."
                                      value={addValues['pn_descricao'] || ''}
                                      onChange={e => setAddValues({ ...addValues, pn_descricao: e.target.value })}
                                      className="flex-1 px-2 py-1 text-xs border border-blue-300 rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-blue-400/30"
                                    />
                                  </div>
                                )}
                                <div className="flex gap-2">
                                  <button
                                    onClick={() => addProgramaNatureza(prog.id)}
                                    className="flex items-center gap-1 px-3 py-1 bg-blue-600 text-white text-xs font-semibold rounded-lg hover:bg-blue-700 transition-colors"
                                  >
                                    <Check className="w-3 h-3" /> Adicionar
                                  </button>
                                  <button onClick={cancelAdd} className="px-3 py-1 text-xs text-gray-500 hover:text-gray-700 border border-gray-200 rounded-lg">Cancelar</button>
                                </div>
                              </div>
                            ) : (
                              <div className="mx-3 my-1.5 flex items-center gap-3 flex-wrap">
                                <button
                                  onClick={() => startAdd(`prog_nat:${prog.id}`, { pn_select: availableMaster.length > 0 ? '' : '__custom__' })}
                                  className="flex items-center gap-1 text-xs text-blue-500 hover:text-blue-700 transition-colors"
                                >
                                  <Plus className="w-3.5 h-3.5" /> Adicionar natureza
                                </button>
                                {naturezas.length > 0 && availableMaster.length > 0 && (
                                  <button
                                    onClick={() => copyAllNaturezasToPrograma(prog.id)}
                                    className="flex items-center gap-1 text-xs text-green-600 hover:text-green-800 border border-green-200 bg-green-50 hover:bg-green-100 px-2 py-0.5 rounded-lg transition-colors"
                                  >
                                    <Database className="w-3 h-3" /> Copiar todas do catálogo ({availableMaster.length})
                                  </button>
                                )}
                              </div>
                            )}
                          </div>
                        )}
                      </div>
                    );
                  })()}
                </>
              )}
            </div>
          );
        })}

        {/* Add program inline form */}
        {addKey === 'programa' && (
          <AddItemRow
            fields={[{ key: 'nome', placeholder: 'Nome do novo programa orçamentário...' }]}
            values={addValues}
            onChange={setAddValues}
            onSave={addPrograma}
            onCancel={cancelAdd}
          />
        )}

        {addKey !== 'programa' && (
          <button
            onClick={() => startAdd('programa')}
            className="w-full mt-2 flex items-center justify-center gap-2 py-2.5 border-2 border-dashed border-gray-200 rounded-xl text-sm text-gray-400 hover:border-red-300 hover:text-red-500 transition-colors"
          >
            <Plus className="w-4 h-4" /> Novo Programa Orçamentário
          </button>
        )}
      </div>
    );
  };

  // ─── Tab content: Metas Quantitativas ────────────────────────────────────

  const renderMetasTab = () => {
    const grouped: Record<string, MetaQuantitativaDB[]> = groupBy(metasQuant, m => m.categoria);
    const cats = Object.keys(grouped).sort();

    return (
      <div className="space-y-1">
        {metasQuant.length === 0 && (
          <EmptyState onSeed={() => seedData('metas')} isSeeding={isSeeding} label="Metas Quantitativas" />
        )}

        {cats.map(categoria => {
          const isExpanded = expandedCatMetas.has(categoria);
          const items: MetaQuantitativaDB[] = grouped[categoria];
          const allInactive = items.every(i => !i.ativo);
          const isEditingCat = editKey === `cat_meta:${categoria}`;

          return (
            <div key={categoria} className={`rounded-xl border ${allInactive ? 'border-orange-200 bg-orange-50/40' : 'border-gray-200 bg-white'}`}>
              <div className="group flex items-center gap-2 px-3 py-2.5">
                <button
                  onClick={() => setExpandedCatMetas(prev => {
                    const n = new Set(prev);
                    n.has(categoria) ? n.delete(categoria) : n.add(categoria);
                    return n;
                  })}
                  className="flex-shrink-0 text-gray-400 hover:text-gray-600"
                >
                  {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                </button>

                {isEditingCat ? (
                  <InlineInput
                    value={editValue}
                    onChange={setEditValue}
                    onSave={() => saveCategoriaMeta(categoria)}
                    onCancel={cancelEdit}
                    placeholder="Nome da categoria"
                  />
                ) : (
                  <span className={`flex-1 text-sm font-bold uppercase tracking-wide ${allInactive ? 'text-gray-300 line-through' : 'text-gray-700'}`}>
                    {categoria}
                    <span className="ml-2 normal-case tracking-normal font-normal text-gray-400">({items.length} itens)</span>
                  </span>
                )}

                {!isEditingCat && (
                  <RowActions
                    onEdit={() => startEdit(`cat_meta:${categoria}`, categoria)}
                    ativo={!allInactive}
                    onToggle={() => toggleCategoriaMeta(categoria, allInactive)}
                    addLabel="Novo item"
                    onAdd={() => { setExpandedCatMetas(prev => new Set(prev).add(categoria)); startAdd(`meta_item:${categoria}`); }}
                  />
                )}
              </div>

              {isExpanded && (
                <div className="border-t border-gray-100 ml-6 mb-1">
                  {items.map((meta: MetaQuantitativaDB) => {
                    const isEditingItem = editKey === `meta_item:${meta.id}`;
                    return (
                      <div key={meta.id} className="group flex items-center gap-2 px-3 py-1.5">
                        <span className="text-gray-300 text-xs">—</span>
                        {isEditingItem ? (
                          <InlineInput
                            value={editValue}
                            onChange={setEditValue}
                            onSave={() => saveMetaItem(meta.id)}
                            onCancel={cancelEdit}
                          />
                        ) : (
                          <span className={`flex-1 text-sm ${meta.ativo ? 'text-gray-700' : 'text-gray-300 line-through'}`}>
                            {meta.item}
                          </span>
                        )}
                        {!isEditingItem && (
                          <RowActions
                            onEdit={() => startEdit(`meta_item:${meta.id}`, meta.item)}
                            ativo={meta.ativo}
                            onToggle={() => toggleMetaItem(meta.id, meta.ativo)}
                          />
                        )}
                      </div>
                    );
                  })}

                  {addKey === `meta_item:${categoria}` && (
                    <AddItemRow
                      fields={[{ key: 'item', placeholder: 'Nome do novo item...' }]}
                      values={addValues}
                      onChange={setAddValues}
                      onSave={() => addMetaItem(categoria)}
                      onCancel={cancelAdd}
                    />
                  )}
                </div>
              )}
            </div>
          );
        })}

        {addKey === 'cat_meta' && (
          <AddItemRow
            fields={[
              { key: 'categoria', placeholder: 'Nome da nova categoria...' },
              { key: 'item', placeholder: 'Primeiro item da categoria...' },
            ]}
            values={addValues}
            onChange={setAddValues}
            onSave={addCategoriaMeta}
            onCancel={cancelAdd}
          />
        )}

        {addKey !== 'cat_meta' && (
          <button
            onClick={() => startAdd('cat_meta')}
            className="w-full mt-2 flex items-center justify-center gap-2 py-2.5 border-2 border-dashed border-gray-200 rounded-xl text-sm text-gray-400 hover:border-red-300 hover:text-red-500 transition-colors"
          >
            <Plus className="w-4 h-4" /> Nova Categoria
          </button>
        )}
      </div>
    );
  };

  // ─── Tab content: Naturezas ───────────────────────────────────────────────

  const renderNaturezasTab = () => (
    <div>
      {naturezas.length === 0 && (
        <EmptyState onSeed={() => seedData('naturezas')} isSeeding={isSeeding} label="Naturezas de Despesa" />
      )}

      <div className="overflow-hidden rounded-xl border border-gray-200">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-4 py-2.5 text-left text-xs font-bold text-gray-500 uppercase w-32">Código</th>
              <th className="px-4 py-2.5 text-left text-xs font-bold text-gray-500 uppercase">Descrição</th>
              <th className="px-4 py-2.5 text-center text-xs font-bold text-gray-500 uppercase w-20">Status</th>
              <th className="px-4 py-2.5 text-center text-xs font-bold text-gray-500 uppercase w-20">Ações</th>
            </tr>
          </thead>
          <tbody>
            {naturezas.map((nat, idx) => {
              const isEditingCod = editKey === `natureza_codigo:${nat.id}`;
              const isEditingDesc = editKey === `natureza_descricao:${nat.id}`;
              return (
                <tr key={nat.id} className={`group border-b border-gray-100 last:border-0 ${idx % 2 === 0 ? 'bg-white' : 'bg-gray-50/50'} ${!nat.ativo ? 'opacity-50' : ''}`}>
                  <td className="px-4 py-2">
                    {isEditingCod ? (
                      <InlineInput
                        value={editValue}
                        onChange={setEditValue}
                        onSave={() => saveNatureza(nat.id, 'codigo')}
                        onCancel={cancelEdit}
                        placeholder="Código"
                      />
                    ) : (
                      <span className={`font-mono font-semibold text-gray-700 ${!nat.ativo ? 'line-through' : ''}`}>{nat.codigo}</span>
                    )}
                  </td>
                  <td className="px-4 py-2">
                    {isEditingDesc ? (
                      <InlineInput
                        value={editValue}
                        onChange={setEditValue}
                        onSave={() => saveNatureza(nat.id, 'descricao')}
                        onCancel={cancelEdit}
                        placeholder="Descrição"
                      />
                    ) : (
                      <span className={`text-gray-700 ${!nat.ativo ? 'line-through' : ''}`}>{nat.descricao}</span>
                    )}
                  </td>
                  <td className="px-4 py-2 text-center">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${nat.ativo ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}`}>
                      {nat.ativo ? 'Ativo' : 'Inativo'}
                    </span>
                  </td>
                  <td className="px-4 py-2">
                    <div className="flex items-center justify-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => startEdit(`natureza_codigo:${nat.id}`, nat.codigo)}
                        className="p-1 text-gray-400 hover:text-blue-600 rounded"
                        title="Editar código"
                      >
                        <Pencil className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => startEdit(`natureza_descricao:${nat.id}`, nat.descricao)}
                        className="p-1 text-gray-400 hover:text-blue-600 rounded"
                        title="Editar descrição"
                      >
                        <Pencil className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => toggleNatureza(nat.id, nat.ativo)}
                        className={`p-1 rounded ${nat.ativo ? 'text-gray-400 hover:text-orange-500' : 'text-orange-400 hover:text-orange-600'}`}
                        title={nat.ativo ? 'Desativar' : 'Ativar'}
                      >
                        {nat.ativo ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {addKey === 'natureza' ? (
        <div className="mt-2">
          <AddItemRow
            fields={[
              { key: 'codigo', placeholder: 'Código (ex: 339039)' },
              { key: 'descricao', placeholder: 'Descrição da natureza de despesa...' },
            ]}
            values={addValues}
            onChange={setAddValues}
            onSave={addNatureza}
            onCancel={cancelAdd}
          />
        </div>
      ) : (
        <button
          onClick={() => startAdd('natureza')}
          className="w-full mt-2 flex items-center justify-center gap-2 py-2.5 border-2 border-dashed border-gray-200 rounded-xl text-sm text-gray-400 hover:border-red-300 hover:text-red-500 transition-colors"
        >
          <Plus className="w-4 h-4" /> Nova Natureza de Despesa
        </button>
      )}
    </div>
  );

  // ─── Main render ──────────────────────────────────────────────────────────

  const tabs: { key: ActiveTab; label: string; icon: React.ReactNode; count: number }[] = [
    { key: 'programas', label: 'Programas Orçamentários', icon: <BarChart3 className="w-4 h-4" />, count: programas.length },
    { key: 'metas', label: 'Metas Quantitativas', icon: <Target className="w-4 h-4" />, count: metasQuant.length },
    { key: 'naturezas', label: 'Natureza de Despesa', icon: <DollarSign className="w-4 h-4" />, count: naturezas.length },
  ];

  return (
    <div className="fixed inset-0 z-[110] bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl w-full max-w-4xl shadow-2xl flex flex-col max-h-[95vh] overflow-hidden animate-slideUp">

        {/* Header */}
        <div className="bg-gradient-to-r from-gray-900 via-gray-800 to-gray-900 px-8 py-6 flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-4">
            <div className="p-3 rounded-xl bg-red-600/20">
              <Database className="text-red-500 w-7 h-7" />
            </div>
            <div>
              <h2 className="text-2xl font-black text-white">Configuração de Listas</h2>
              <p className="text-xs text-gray-400 mt-1">Gerencie os programas, metas e naturezas disponíveis no formulário</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button onClick={loadAll} className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors" title="Recarregar">
              <RefreshCw className="w-5 h-5 text-gray-400 hover:text-white" />
            </button>
            <button onClick={onClose} className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors" title="Fechar">
              <X className="w-6 h-6 text-gray-400 hover:text-white" />
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-gray-200 bg-gray-50 flex-shrink-0">
          {tabs.map(tab => (
            <button
              key={tab.key}
              onClick={() => { setActiveTab(tab.key); cancelEdit(); cancelAdd(); }}
              className={`flex items-center gap-2 px-5 py-3.5 text-sm font-semibold transition-colors border-b-2 ${
                activeTab === tab.key
                  ? 'border-red-600 text-red-600 bg-white'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:bg-gray-100'
              }`}
            >
              {tab.icon}
              <span className="hidden sm:inline">{tab.label}</span>
              {tab.count > 0 && (
                <span className={`text-xs px-1.5 py-0.5 rounded-full font-bold ${activeTab === tab.key ? 'bg-red-100 text-red-600' : 'bg-gray-200 text-gray-500'}`}>
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {isLoading ? (
            <div className="flex items-center justify-center h-40 gap-3 text-gray-500">
              <Loader2 className="w-6 h-6 animate-spin text-red-500" />
              <span>Carregando dados...</span>
            </div>
          ) : loadError ? (
            <div className="rounded-xl border border-red-200 bg-red-50 p-6 space-y-4">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="font-bold text-red-800">Erro ao conectar ao banco de dados</p>
                  <p className="text-sm text-red-700 mt-1">As tabelas ainda não existem. Execute o SQL abaixo no <strong>Supabase SQL Editor</strong> e clique em Recarregar.</p>
                  <code className="block mt-3 p-3 bg-red-100 rounded-lg text-xs text-red-900 font-mono break-all">{loadError}</code>
                </div>
              </div>
              <div className="pl-9 space-y-2 text-sm text-red-700">
                <p className="font-semibold">Passos:</p>
                <ol className="list-decimal ml-4 space-y-1">
                  <li>Acesse <strong>supabase.com → SQL Editor</strong> do seu projeto</li>
                  <li>Cole e execute o conteúdo do arquivo <code className="bg-red-100 px-1 rounded">sql/create-admin-tree-tables.sql</code></li>
                  <li>Clique no botão <strong>Recarregar ↻</strong> acima</li>
                </ol>
              </div>
              <button
                onClick={loadAll}
                className="ml-9 inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-semibold hover:bg-red-700 transition-colors"
              >
                <RefreshCw className="w-4 h-4" /> Tentar novamente
              </button>
            </div>
          ) : (
            <>
              {activeTab === 'programas' && renderProgramasTab()}
              {activeTab === 'metas' && renderMetasTab()}
              {activeTab === 'naturezas' && renderNaturezasTab()}
            </>
          )}
        </div>

        {/* Toast */}
        {toast && (
          <div className={`absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 px-5 py-3 rounded-xl shadow-lg text-sm font-medium animate-fadeIn ${
            toast.type === 'success' ? 'bg-green-600 text-white' : 'bg-red-600 text-white'
          }`}>
            {toast.type === 'success' ? <CheckCircle2 className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
            {toast.msg}
          </div>
        )}
      </div>
    </div>
  );
};

// ─── Sub-components ───────────────────────────────────────────────────────────

const EmptyState: React.FC<{ onSeed: () => void; isSeeding: boolean; label: string }> = ({ onSeed, isSeeding, label }) => (
  <div className="py-12 text-center">
    <Database className="w-12 h-12 text-gray-200 mx-auto mb-4" />
    <p className="text-gray-500 font-medium">Nenhum dado encontrado para {label}</p>
    <p className="text-gray-400 text-sm mt-1 mb-5">O banco de dados está vazio. Importe os valores padrão para começar.</p>
    <button
      onClick={onSeed}
      disabled={isSeeding}
      className="inline-flex items-center gap-2 px-5 py-2.5 bg-red-600 text-white rounded-xl text-sm font-semibold hover:bg-red-700 disabled:opacity-60 disabled:cursor-not-allowed transition-colors"
    >
      {isSeeding ? <Loader2 className="w-4 h-4 animate-spin" /> : <Database className="w-4 h-4" />}
      {isSeeding ? 'Importando...' : `Importar padrões de ${label}`}
    </button>
  </div>
);

const AddItemRow: React.FC<{
  fields: { key: string; placeholder: string }[];
  values: Record<string, string>;
  onChange: (v: Record<string, string>) => void;
  onSave: () => void;
  onCancel: () => void;
}> = ({ fields, values, onChange, onSave, onCancel }) => (
  <div className="flex items-start gap-2 p-2 bg-green-50 rounded-xl border border-green-200 mt-1">
    <div className="flex-1 space-y-1.5">
      {fields.map(f => (
        <input
          key={f.key}
          autoFocus={fields[0].key === f.key}
          type="text"
          value={values[f.key] || ''}
          onChange={e => onChange({ ...values, [f.key]: e.target.value })}
          onKeyDown={e => { if (e.key === 'Enter' && fields[fields.length - 1].key === f.key) onSave(); if (e.key === 'Escape') onCancel(); }}
          placeholder={f.placeholder}
          className="w-full px-3 py-2 text-sm border border-green-300 rounded-lg outline-none focus:ring-2 focus:ring-green-300/30 bg-white"
        />
      ))}
    </div>
    <div className="flex gap-1 pt-1 flex-shrink-0">
      <button onClick={onSave} className="p-2 bg-green-600 text-white rounded-lg hover:bg-green-700" title="Salvar">
        <Check className="w-4 h-4" />
      </button>
      <button onClick={onCancel} className="p-2 text-gray-500 hover:bg-gray-100 rounded-lg" title="Cancelar">
        <XCircle className="w-4 h-4" />
      </button>
    </div>
  </div>
);
