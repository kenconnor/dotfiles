# Dot Files
# LSP Settings
- Run the following script in the project root to create a `.clangd` file:
  ```
  echo "CompileFlags:" >> .clangd
  echo "  Add:" >> .clangd
  echo "    - -std=c++17" >> .clangd
  ```
- Reference
  - [clangdの設定ファイル](https://zenn.dev/tkcd/articles/clangd-config)
  - [CocInstallをnon-interactiveに実行](https://github.com/neoclide/coc.nvim/issues/450#issuecomment-632482922)
