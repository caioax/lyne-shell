# ⚡ Neovim Cheat Sheet

| Core Config        | Valor                     |
| :----------------- | :------------------------ |
| **Leader Key**     | `Space` (Espaço)          |
| **Plugin Manager** | `lazy.nvim`               |
| **LSP/Format**     | `Mason` + `Conform`       |
| **Engine**         | `Smart Splits` + `Snacks` |

---

## 🧭 Navegação & Janelas (Smart Splits)

Integração fluida com o Tmux. Não requer Leader.

| Atalho                 | Ação              | Descrição                                          |
| :--------------------- | :---------------- | :------------------------------------------------- |
| **`Ctrl` + `h j k l`** | **Navegar**       | Move o foco entre splits do Vim e Painéis do Tmux. |
| **`Alt` + `h j k l`**  | **Redimensionar** | Aumenta/Diminui o tamanho do split atual.          |

---

## 📋 Clipboard & Copiar/Colar

Fluxo de trabalho onde do Yank e Clipboard do sistema

| Atalho              | Ação                 | Descrição                                                               |
| :------------------ | :------------------- | :---------------------------------------------------------------------- |
| **`y`** / **`p`**   | **Interno (Seguro)** | `p` cola sempre o último **Yank** (`0`), ignorando deletes recentes.    |
| **`Space` + `y`**   | Copiar p/ Sistema    | Copia a seleção para o clipboard do **Sistema** (Ctrl+V funciona fora). |
| **`Space` + `p`**   | Colar do Sistema     | Cola o conteúdo vindo do clipboard do **Sistema**.                      |
| **`Space` + `d`**   | Colar Deletado       | Cola o que foi realmente apagado/cortado (`dd` / `x` etc).              |
| **`Space` + `"`**   | **Ver Gavetas**      | Abre menu visual (`Telescope`) com histórico de cópias.                 |
| **`Space` + `y c`** | Exportar             | Envia um registro específico (`0`, `a`...) para o Sistema.              |

---

## ⌨️ Comandos do Leader (`Space` + Tecla)

### 📂 Arquivos e Busca (Telescope)

|  Atalho   | Ação       | Descrição                                    |
| :-------: | :--------- | :------------------------------------------- |
| **`f f`** | Find Files | Busca arquivos pelo nome (ignora gitignore). |
| **`f g`** | Live Grep  | Busca por texto dentro de todos os arquivos. |
| **`f b`** | Buffers    | Lista arquivos abertos na memória.           |
|  **`e`**  | Explorer   | Abre/Fecha a árvore lateral (`NeoTree`).     |

### 🛠️ Ferramentas (Snacks.nvim)

|      Atalho      | Ação           | Descrição                                 |
| :--------------: | :------------- | :---------------------------------------- |
|    **`l g`**     | **LazyGit**    | Abre interface gráfica do Git flutuante.  |
|    **`g l`**     | Git Log        | Histórico de commits do arquivo atual.    |
|    **`s f`**     | Scratch        | Bloco de notas temporário flutuante.      |
|     **`S`**      | Select Scratch | Seleciona entre notas temporárias salvas. |
|    **`u n`**     | Dismiss        | Limpa todas as notificações da tela.      |
| **`Ctrl` + `/`** | Terminal       | Abre/Fecha terminal flutuante rápido.     |

### 💾 Sessões (Persistence)

O Neovim grava sessões automaticamente.

|  Atalho   | Ação         | Descrição                              |
| :-------: | :----------- | :------------------------------------- |
| **`q s`** | Restore Dir  | Restaura a sessão da pasta atual.      |
| **`q l`** | Restore Last | Restaura a última sessão global usada. |
| **`q d`** | Stop         | Para de gravar a sessão atual.         |

---

## 🧠 Código e Inteligência (LSP)

Atalhos disponíveis quando um arquivo de código está aberto.

### ⚡ Ações Rápidas

|  Atalho   | Comando     | Descrição                                       |
| :-------: | :---------- | :---------------------------------------------- |
|  **`K`**  | Hover       | Abre documentação da função sob o cursor.       |
| **`g d`** | Definition  | Pula para a definição da variável/função.       |
| **`r n`** | Rename      | Renomeia variável no projeto todo.              |
| **`c a`** | Code Action | Menu de correções rápidas (Fix/Import).         |
| **`m p`** | **Format**  | Formata o arquivo (`Conform`: Prettier/Stylua). |

### 🤖 Autocomplete (CMP)

|        Tecla         | Ação                                                   |
| :------------------: | :----------------------------------------------------- |
| **`Ctrl` + `Space`** | Força aparecer o menu de sugestões.                    |
|      **`Tab`**       | Próxima sugestão / Pula para próximo campo do snippet. |
|     **`Enter`**      | Confirma a sugestão selecionada.                       |

### 📝 Git (Gitsigns)

|  Atalho   | Ação                                                    |
| :-------: | :------------------------------------------------------ |
| **`] c`** | Pula para a próxima alteração (Hunk).                   |
| **`[ c`** | Pula para a alteração anterior.                         |
| **`g p`** | **Preview**: Mostra o que mudou na linha atual (popup). |
| **`g b`** | **Blame**: Mostra quem editou a linha atual.            |

---

## ⚙️ Manutenção e Instalação

### Estrutura de Pastas

```text
~/.config/nvim/
├── init.lua            # Boot
├── lazy-lock.json      # Versões travadas (Não mexa)
├── lua/
│   ├── config/         # Options, Keymaps, Commands
│   ├── mytheme/        # Seu tema local (Palette/Highlights)
│   └── plugins/        # Módulos (LSP, Snacks, CMP, etc)
```

### Como instalar...

**1. Novos Plugins:**
Crie um arquivo em `lua/plugins/nome.lua` e cole o código `return { ... }`. O `lazy` instala sozinho no restart.

**2. Novas Linguagens (LSP/Formatters):**

1. Digite `:Mason`.
2. Busque com `/` (ex: `python`, `gopls`).
3. Aperte `i` para instalar.
4. **Obrigatório:** Adicione na lista `ensure_installed` em:
   - `lua/plugins/lsp.lua` (para Servidores)
   - `lua/plugins/formatting.lua` (para Formatadores)

**3. Atualizações:**

- Atualizar Plugins: `:Lazy sync`
- Atualizar Ferramentas: `:MasonUpdate`
- Recarregar Tema: `<Space>rt` (Reload Theme)
