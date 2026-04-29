#!/bin/bash
# Obsidian vault wiki/를 Quartz content/로 동기화하고 GitHub Pages에 배포

VAULT_WIKI="$HOME/Obsidian Vault/wiki"
QUARTZ_CONTENT="$HOME/wiki-site/content"
SITE_DIR="$HOME/wiki-site"

echo "Syncing wiki..."
rm -rf "$QUARTZ_CONTENT"
cp -r "$VAULT_WIKI" "$QUARTZ_CONTENT"

echo "Committing..."
cd "$SITE_DIR"
git add content/
git commit -m "docs: update wiki $(date +%Y-%m-%d)" 2>/dev/null || echo "Nothing to commit"
git push origin main

echo "Done. Check: https://jannchoi.github.io/wiki/"
