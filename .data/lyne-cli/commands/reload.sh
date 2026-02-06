# lyne reload - Restart QuickShell detached from the terminal

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: lyne reload"
    echo ""
    echo "Kill and restart QuickShell detached from the terminal."
    return 0
fi

quickshell kill
sleep 0.2
setsid quickshell >/dev/null 2>&1 &
disown
