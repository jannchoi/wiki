---
topic: ai
created: 2026-04-28
updated: 2026-04-28
confidence: high
sources: [현재 세션 구성 기반]
verified-by: human
verified-at: 2026-04-28
---

# Claude Code 설정 — commands, skills, hooks

## 요약
현재 구성된 Claude Code 커스텀 설정 목록. 새 세션에서 재설명 불필요.

---

## Slash Commands (`~/.claude/commands/`)

| 커맨드 | 파일 | 기능 |
|---|---|---|
| `/wiki-write` | `wiki-write.md` | Writer 역할: raw/ → wiki 초안 작성 |
| `/wiki-verify` | `wiki-verify.md` | Verifier 역할: confidence 점수 + ⚠️ 플래그 |
| `/wiki-lint` | `wiki-lint.md` | wiki 전체 정기 점검 |
| `/wiki-ingest` | `wiki-ingest.md` | 새 raw/ 파일 처리 |
| `/wiki-stale` | `wiki-stale.md` | 오래된 페이지 감지 |
| `/wiki-publish` | `wiki-publish.md` | Quartz로 웹 배포 |

---

## Hooks

현재 설정된 hook 없음.

---

## Settings (`~/.claude/settings.json`)

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

## MCP Servers

| 서버 | 커맨드 | 용도 |
|---|---|---|
| `wiki` | `qmd mcp` | `~/Obsidian Vault/wiki` 전체 시맨틱 검색 |

---

## Skills (`~/.claude/plugins/`)

`superpowers` 플러그인 활성화됨. 포함 skills:
- `brainstorming`, `writing-plans`, `executing-plans`
- `systematic-debugging`, `requesting-code-review`
- `test-driven-development`, `verification-before-completion`
- 기타

---

## Global CLAUDE.md (`~/CLAUDE.md`) 핵심 규칙

- 공식 문서 없이 추측 금지
- 근본 원인 → 공식 문서 확인된 해결책까지 반드시 제시
- 메서드 시그니처 변경 전 모든 호출부 grep 먼저
- 패키지 교체 전 실제 네이티브 소스 코드에서 버그 확인

---

## 관련 페이지
- [[../index|전체 인덱스]]

## References
- [Claude Code Docs](https://docs.anthropic.com/en/claude-code)
- [Claude Code Hooks](https://docs.anthropic.com/en/claude-code/hooks)
- [Claude Code Slash Commands](https://docs.anthropic.com/en/claude-code/slash-commands)
- [MCP Docs](https://modelcontextprotocol.io/docs)
