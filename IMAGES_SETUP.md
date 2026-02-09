# 📋 Setup das Imagens Oficiais - Identidade Visual SES-SP

## ⚠️ IMPORTANTE - Imagens Oficiais Do Governo

As imagens utilizadas neste sistema são **ativos gráficos oficiais** da Secretaria de Estado da Saúde de São Paulo / Governo do Estado de São Paulo.

Estas imagens são **imutáveis** e não podem ser alteradas, reinterpretadas ou substituídas.

---

## 📍 Localização das Imagens

Coloque os seguintes arquivos no diretório `/public` da raiz do projeto:

```
plano-de-trabalho-ses-sp-2026/
├── public/
│   ├── logo-colorida.png          ← Imagem colorida oficial
│   └── logo-branca.png             ← Imagem branca oficial
├── App.tsx
├── index.tsx
└── ...
```

---

## 🎨 Especificações de Cada Imagem

### 1️⃣ **logo-colorida.png**
- **Formato**: PNG com transparência (recomendado)
- **Versão**: Original colorida com cores vermelha, preta e branca
- **Uso no Sistema**:
  - ✅ Tela de Login (centralizada)
  - ✅ Documento PDF Final (header do documento)
  - ✅ Formulário de Conclusão
- **Restrições**:
  - ❌ Sem filtros
  - ❌ Sem transparência adicional
  - ❌ Sem alteração de cores ou proporções
  - ❌ Sem recortes

### 2️⃣ **logo-branca.png**
- **Formato**: PNG com transparência (recomendado)
- **Versão**: Monocromática branca
- **Uso no Sistema**:
  - ✅ Header fixo (topo do sistema)
  - ✅ Todas as telas internas após login
- **Alinhamento**: À esquerda (conforme design estabelecido)
- **Restrições**:
  - ❌ Não converter para SVG ou texto
  - ❌ Não centralizar automaticamente
  - ❌ Não aplicar efeitos visuais

---

## 🔧 Processamento Recomendado

### Opção 1: Exportar de Arquivo Original (Melhor)
Se tiver acesso ao arquivo original:
1. Abrir em Adobe Illustrator, Figma ou similar
2. Exportar como PNG 1600x400px (manter proporção)
3. Salvar como `logo-colorida.png`
4. Duplicar e aplicar efeito de branco/monocromático
5. Salvar como `logo-branca.png`

### Opção 2: Converter Imagem Existente
Se tiver imagem JPG/PNG:
1. Abrir em Photoshop, GIMP ou online converter
2. Para versão branca: Desaturar →_Threshold ou ajustar níveis
3. Manter resolução alta (mínimo 1200x300)
4. Salvar com fundo transparente

---

## ✅ Verificação

Após adicionar as imagens:
1. O servidor deve fazer hot-reload automático
2. Acessar http://localhost:3004
3. Verificar:
   - ✅ Logo colorida visível na tela de login
   - ✅ Logo branca visível no cabeçalho (após login)
   - ✅ Logo colorida no PDF gerado
   - ✅ Sem distorções ou problemas de renderização

---

## 📎 Referências no Código

As imagens são referenciadas em `App.tsx`:

```tsx
const LOGO_URL_COLORIDA = "/logo-colorida.png";  // Para login e PDF
const LOGO_URL_BRANCA = "/logo-branca.png";      // Para header
```

**Não altere estes nomes** sem atualizar também os arquivos PNG.

---

## 🚫 Proibições Explícitas

- ❌ Não recriar logotipos com texto SVG
- ❌ Não reorganizar elementos gráficos
- ❌ Não aplicar filtros, sombras ou transparência
- ❌ Não redimensionar distorcendo proporções
- ❌ Não substituir por ícones ou representações
- ❌ Não alterar paleta de cores
- ❌ Não usar versão gerada por IA

---

## ❓ Dúvidas?

Caso tenha dúvidas sobre as imagens:
- Consult a Secretaria de Comunicação da SES-SP
- Mantenha os arquivos exatamente como fornecidos
- Em caso de dúvida, use a imagem original sem qualquer modificação
