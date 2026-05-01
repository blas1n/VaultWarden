# Vaultwarden (self-hosted)

1Password 대체용 개인 패스워드 매니저. Mac Mini(`bsserver`)에서 docker compose로 운영.

## 진입점

| 경로 | 호스트명 | 사용 기기 |
|---|---|---|
| Tailscale 직접 | `https://vault.bsvibe.dev` | 개인 노트북/데스크톱/폰 (Tailscale 연결) |
| Cloudflare Tunnel | `https://vault-cf.bsvibe.dev` | 회사 PC (Tailscale 미연결) |

DOMAIN 환경변수는 `vault-cf.bsvibe.dev`로 통일 — attachment 등 self-referential URL은 항상 CF 경유.

## 운영

```bash
cd ~/VaultWarden
docker compose up -d        # 시작
docker compose logs -f      # 로그
docker compose down         # 정지 (데이터는 vw-data/ 유지)
```

이미지 업그레이드:
```bash
# docker-compose.yml의 image 태그 수정 후
docker compose pull
docker compose up -d
```

## 백업

매일 03:30 launchd로 자동:
- 위치: `~/backups/vaultwarden/`
- 보관: 14일
- 스크립트: `scripts/backup.sh`

수동 실행: `bash ~/VaultWarden/scripts/backup.sh`

## ADMIN 패널

운영 중에는 `.env`의 `ADMIN_TOKEN`을 주석 처리 → `/admin` 404. 필요할 때만 임시 활성:
```bash
# .env에서 ADMIN_TOKEN 주석 해제
docker compose up -d
# 작업 완료 후 다시 주석 + up -d
```

## 1Password 마이그레이션

- 일반 항목: 1Password → File → Export → `.1pux` → 웹볼트 `vault.bsvibe.dev` → Tools → Import data → "1Password (1pux)"
- 패스키: `~/Docs/passkey-migration.md` 체크리스트 참조 (사이트별 재등록, 4-8주 1P 병행)

## 관련 파일

- 본 디렉터리: `~/VaultWarden/`
- Caddy: `/opt/homebrew/etc/Caddyfile` — `vault.bsvibe.dev` vhost
- Cloudflare Tunnel: `~/.cloudflared/config.yml`
- 백업 launchd: `~/Library/LaunchAgents/com.blas1n.vaultwarden-backup.plist`
- cloudflared launchd: `~/Library/LaunchAgents/com.blas1n.cloudflared.plist`
