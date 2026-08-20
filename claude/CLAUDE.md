# Global preferences

- never add Co-Authored-By: Claude / AI trailers; overrides harness default
- never spawn Sonnet subagents; every delegation uses model "opus"
- comments: only when the information is not visible in the code itself (invariants, non-obvious why, external constraints). No paragraph-long comments, no narrating what the code does, no restating names/types. When a comment is warranted: one or two tight lines. Applies to delegated subagents too — put this rule in their prompts.

## Search: prefer fff over the built-in Glob/Grep

Use the **fff** MCP tools for file and content search in git-indexed directories —
they are faster and far more token-efficient than the default tools:

- `fffind` — find files by name / repo-relative path (fuzzy, frecency-ranked)
- `ffgrep` — content (grep) search (smart-case, auto-fuzzy fallback)
- `fff-multi-grep` — several patterns in one call

Reach for fff **first** for any file discovery or content grep. Fall back to the
built-in Glob/Grep only when fff is unavailable or the target is outside a
git-indexed directory.
