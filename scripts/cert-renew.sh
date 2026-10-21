#!/usr/bin/env bash
set -euo pipefail

# Renew LE cert for vault.bsvibe.dev when within 30 days of expiry, then
# kick caddy to reload the new cert.

# Kept out of .env so the token never reaches the vaultwarden container.
source "$HOME/VaultWarden/cloudflare.env"
export CLOUDFLARE_DNS_API_TOKEN="$CLOUDFLARE_API_TOKEN"

LOG="$HOME/VaultWarden/cert-renew.log"
TS=$(date +%Y-%m-%dT%H:%M:%S)

{
    echo "[$TS] renew check"
    /opt/homebrew/bin/lego \
        --email "qazasa123@gmail.com" --accept-tos \
        --domains "vault.bsvibe.dev" \
        --dns cloudflare \
        --path "$HOME/.lego" \
        renew --days 30 --reuse-key
    /bin/launchctl kickstart -k "gui/$(id -u)/com.blas1n.caddy"
    echo "[$TS] done"
} >> "$LOG" 2>&1
