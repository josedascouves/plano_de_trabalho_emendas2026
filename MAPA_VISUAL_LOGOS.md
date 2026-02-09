# 🎨 MAPA VISUAL - Onde Cada Imagem Será Exibida

## 🖼️ Logo Colorida (logo-colorida.png)

### 1. Tela de Login
```
┌────────────────────────────────────────────┐
│                                            │
│        ┌──────────────────────────┐       │
│        │                          │       │
│        │  [LOGO COLORIDA OFICIAL] │       │  ← Centralizada
│        │  Mantém cores originais  │       │     Sem filtros
│        │  (Vermelho, Preto)       │       │
│        │                          │       │
│        └──────────────────────────┘       │
│                                            │
│     Plano de Trabalho 2026                │
│     Secretaria de Estado da Saúde         │
│                                            │
│     ┌────────────────────────────┐        │
│     │ Email: [         ]         │        │
│     │ Senha: [●●●●●●●●]        │        │
│     │                            │        │
│     │  [ ENTRAR ]  Botão Vermelho│        │
│     └────────────────────────────┘        │
│                                            │
└────────────────────────────────────────────┘
```

### 2. Documento PDF (Gerado no Passo 6)
```
╔════════════════════════════════════════════════════════════╗
║  ┌──────────────────────────────────────────────────────┐  ║
║  │ ┌─────────┐  Governo de São Paulo                    │  ║
║  │ │  LOGO   │  Secretaria de Estado da Saúde           │  ║
║  │ │COLORIDA │                                          │  ║
║  │ │OFICIAL  │     PLANO DE TRABALHO 2026               │  ║
║  │ │ No Topo │     Referência: PT-12340001/2026        │  ║
║  │ └─────────┘                                          │  ║
║  │                                                       │  ║
║  └──────────────────────────────────────────────────────┘  ║
║                                                             ║
║  01 - IDENTIFICAÇÃO GERAL                                  ║
║  ─────────────────────────────                            ║
║  Programa: CUSTEIO MAC – 2E90                             ║
║  Parlamentar: [dados preenchidos]                         ║
║  ...                                                       ║
║                                                             ║
║  02 - METAS QUANTITATIVAS                                  ║
║  ...                                                       ║
║                                                             ║
╚════════════════════════════════════════════════════════════╝
```

### 3. Tela de Conclusão/Sucesso (Passo 6)
```
┌────────────────────────────────────────────┐
│                                            │
│     ┌──────────────────────────────┐      │
│     │                              │      │
│     │   [LOGO COLORIDA OFICIAL]    │      │
│     │   ← Reforço Institucional    │      │
│     │                              │      │
│     └──────────────────────────────┘      │
│                                            │
│            ✅ SUCESSO!                     │
│                                            │
│   O plano foi salvo com sucesso            │
│   no banco de dados.                       │
│                                            │
│  [NOVO CADASTRO] (Botão Vermelho)         │
│                                            │
└────────────────────────────────────────────┘
```

---

## ⚪ Logo Branca (logo-branca.png)

### 4. Cabeçalho do Sistema (Todas as telas internas)
```
┌────────────────────────────────────────────────────────────────┐
│ ⬜[LOGO BRANCO]  Plano de Trabalho 2026  │ [Novo] [Meus] [Dashboard]
│   MONOCROMÁTICO  Secretaria de Estado... │ [User] [Sair]            │
│   À esquerda     (Sem filtros)           ├──────────────────────────┤
│   ✓ Na cor branca                        │                          │
│   ✓ Sem efeitos                          │                          │
│   ✓ Resolução original                   │     CONTEÚDO DA PÁGINA   │
│                                          │                          │
│                                          │                          │
│                                          │                          │
└────────────────────────────────────────────────────────────────┘
```

### 5. Tela de Carregamento
```
┌────────────────────────────────────┐
│                                    │
│    ⬜ [LOGO BRANCO OFICIAL]        │
│       (Tela de Splash)             │
│       Monocromático                │
│                                    │
│       Sincronizando Banco...       │
│       ⟳ (Loading spinner)          │
│                                    │
└────────────────────────────────────┘
```

---

## 📊 Tabela de Uso

| Localização | Imagem | Versão | Tamanho | Efeitos |
|---|---|---|---|---|
| **Tela Login** | logo-colorida.png | Colorida Original | h-20 | ❌ Nenhum |
| **PDF Header** | logo-colorida.png | Colorida Original | h-24 | ❌ Nenhum |
| **Conclusão** | logo-colorida.png | Colorida Original | h-20 | ❌ Nenhum |
| **Cabeçalho Sistema** | logo-branca.png | Branca Monocromática | h-16 | ❌ Nenhum |
| **Tela Carregamento** | logo-branca.png | Branca Monocromática | h-20 | ❌ Nenhum |

---

## ✅ Checklist de Implementação

- [ ] **Arquivo 1**: logo-colorida.png salvo em `/public`
  - [ ] Contém cores vermelha, preta, branca
  - [ ] Sem filtros ou efeitos
  - [ ] Resolução original mantida
  - [ ] Sem distorções

- [ ] **Arquivo 2**: logo-branca.png salvo em `/public`
  - [ ] Monocromático (branco)
  - [ ] Sem filtros ou efeitos
  - [ ] Resolução original mantida
  - [ ] Perfeitamente alinhável

- [ ] **Verificações**:
  - [ ] Servidor rodando: http://localhost:3004
  - [ ] Login exibe logo colorida centralizada
  - [ ] Header interno exibe logo branca
  - [ ] PDF inclui logo colorida
  - [ ] Nenhuma distorção ou pixelização
  - [ ] Cores mantidas perfeitamente

---

## 🔄 Ordem de Renderização

```
Usuário Acessa Sistema
        ↓
┌─────────────────┐
│ Loading Screen  │  ← Logo branca (h-20)
│   Logo Branca   │
└─────────────────┘
        ↓
  Não Autenticado?
        ↓
┌─────────────────┐
│ Login Screen    │  ← Logo colorida (h-20)
│  Logo Colorida  │
└─────────────────┘
        ↓
  Login Bem-Sucedido?
        ↓
┌──────────────────────────────────┐
│ Header: Logo Branca + Menu       │  ← Logo branca (h-16)
├──────────────────────────────────┤
│ Conteúdo (Formulário/Dashboard)  │
│                                  │
│ Passo 6: Finalização             │
│ ✓ Gerar PDF (com Logo Colorida)  │  ← Logo colorida em PDF (h-24)
│ ✓ Sucesso (Logo Colorida)        │  ← Logo colorida (h-20)
└──────────────────────────────────┘
```

---

## 🎯 Resultado Final Esperado

Após adicionar as imagens em `/public`, o sistema exibirá:

✅ **Login**: Logotipo colorido oficial, centralizado, sem efeitos
✅ **Sistema Interno**: Logo branca no topo (header fixo)
✅ **Documentos**: Logos coloridas em PDFs
✅ **Carregamento**: Logo branca durante sincronização
✅ **Sucesso**: Logo colorida como reforço institucional

**Tudo mantendo 100% da identidade visual oficial!**

