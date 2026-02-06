# lyne update - Pull latest changes, sync state and run migrations

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: lyne update"
    echo ""
    echo "Pull latest dotfiles changes, sync state.json with defaults,"
    echo "and run any pending migrations."
    return 0
fi

echo ":: Resetting local changes..."
git -C "$DOTS_DIR" reset --hard

echo ":: Pulling latest changes..."
git -C "$DOTS_DIR" pull

if [[ $? -ne 0 ]]; then
    echo "lyne update: git pull failed"
    return 1
fi

echo ":: Syncing state.json..."
source "$DOTS_DIR/.data/lyne-cli/lib/sync-state.sh"

echo ":: Checking migrations..."
source "$DOTS_DIR/.data/lyne-cli/lib/run-migrations.sh"
