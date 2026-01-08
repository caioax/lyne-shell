# ⚡ Tmux Cheat Sheet

| Core Config | Valor                            |
| :---------- | :------------------------------- |
| **Prefixo** | `Ctrl` + `Space`                 |
| **Mouse**   | Ativado (Click, Scroll, Resize)  |
| **Índices** | Começam em 1 (Janelas e Painéis) |
| **Engine**  | Vi Mode + Smart Splits           |

---

## 🧭 Navegação & Layout (Sem Prefixo)

Ações rápidas integradas ao teclado, sem necessidade de acionar o prefixo.

| Atalho                           | Ação                 | Contexto                                                   |
| :------------------------------- | :------------------- | :--------------------------------------------------------- |
| **`Ctrl` + `h j k l`**           | **Navegar (Foco)**   | Move entre splits do Tmux e janelas do Neovim fluidamente. |
| **`Alt` + `h j k l`**            | **Redimensionar**    | Ajusta o tamanho do painel atual (ou split do Neovim).     |
| **`Ctrl` + `Shift` + `h j k l`** | **Reordenar Splits** | Troca o painel atual de lugar com o vizinho (Swap).        |
| **`Ctrl` + `Alt` + `h l`**       | **Trocar Aba**       | Navega para a Janela (Tab) anterior ou próxima.            |

---

## ⌨️ Comandos Padrão (Requer Prefixo)

Aperte `Ctrl`+`Space`, solte, e digite a tecla abaixo.

### 🪟 Gestão de Painéis (Splits)

|     Tecla     | Ação             | Descrição                                           |
| :-----------: | :--------------- | :-------------------------------------------------- |
|    **`│`**    | Split Vertical   | Divide a tela lado a lado (mantém diretório).       |
|    **`-`**    | Split Horizontal | Divide a tela cima/baixo (mantém diretório).        |
|    **`x`**    | Fechar           | Fecha o painel atual (kill-pane).                   |
|    **`z`**    | Zoom             | Maximiza/Restaura o painel atual.                   |
| **`{` / `}`** | Swap             | Troca painéis de lugar (alternativa ao Ctrl+Shift). |

### 📑 Gestão de Janelas (Abas)

|     Tecla     | Ação     | Descrição                                            |
| :-----------: | :------- | :--------------------------------------------------- |
|    **`c`**    | Criar    | Nova aba limpa.                                      |
| **`1` - `9`** | Ir para  | Pula direto para o número da aba.                    |
|    **`,`**    | Renomear | Altera o nome da aba na barra de status.             |
|    **`w`**    | Listar   | Mostra lista interativa de todas as janelas/sessões. |

### 🚀 Popups & Ferramentas

|    Tecla    | Ferramenta                                       |
| :---------: | :----------------------------------------------- |
| **`Enter`** | **Terminal Flutuante** (Zsh no diretório atual). |
|   **`N`**   | Abre o README do **Neovim** (Modo Leitura).      |
|   **`T`**   | Abre este README do **Tmux** (Modo Leitura).     |

---

## 💾 Persistência de Sessão

O Tmux salva tudo automaticamente a cada 15 min (Continuum).

| Prefixo + Tecla  | Ação                                  |
| :--------------: | :------------------------------------ |
| **`Ctrl` + `s`** | **Salvar** estado agora (Manual).     |
| **`Ctrl` + `r`** | **Restaurar** último save (Manual).   |
|     **`s`**      | Menu de Sessões (Árvore interativa).  |
|     **`d`**      | Detach (Sai do Tmux, mantém rodando). |

---

## 📋 Modo de Cópia (Vim Style)

1. **`Prefix` + `[`**: Entra no modo.
2. **`v`**: Visual select (selecionar texto).
3. **`y`**: Yank (copiar para o clipboard do sistema).
4. **`q`**: Sair.

---

## 📦 Plugins (TPM)

|  Prefixo + Tecla  | Ação                                          |
| :---------------: | :-------------------------------------------- |
| **`I`** (shift+i) | **Instalar** novos plugins listados no conf.  |
| **`U`** (shift+u) | **Atualizar** plugins existentes.             |
|      **`r`**      | **Recarregar** configurações (`source-file`). |

### Como adicionar plugins

Edite `~/.tmux.conf` e adicione na lista:

```tmux
set -g @plugin 'usuario/plugin'
```

---
