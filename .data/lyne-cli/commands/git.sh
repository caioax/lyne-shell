# lyne git - Passthrough to git in the dotfiles repo

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: lyne git <args...>"
    echo ""
    echo "Run git commands scoped to the dotfiles repository."
    echo ""
    echo "Examples:"
    echo "  lyne git status"
    echo "  lyne git log --oneline -5"
    echo "  lyne git diff"
    return 0
fi

git -C "$DOTS_DIR" "$@"
