echo "tree-sitter generate"
tree-sitter generate       # génère src/parser.c

echo "CC=gcc tree-sitter test"
CC=gcc tree-sitter test    # nécessite 'cc' dans le PATH (gcc-toolchain sous Guix
