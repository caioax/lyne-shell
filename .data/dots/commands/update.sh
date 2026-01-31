# dots update - Pull latest changes and sync state.json

echo ":: Resetting local changes..."
git -C "$DOTS_DIR" reset --hard

echo ":: Pulling latest changes..."
git -C "$DOTS_DIR" pull

if [[ $? -ne 0 ]]; then
    echo "dots update: git pull failed"
    return 1
fi

echo ":: Syncing state.json..."
source "$DOTS_DIR/.data/dots/lib/sync-state.sh"
