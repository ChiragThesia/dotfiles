# Global Guidelines

<!-- ============================================================
     HARDWIRED REFLEXES
     These override Claude's trained defaults. Check this table
     BEFORE reaching for any tool. No exceptions.
     ============================================================ -->

## Hardwired Reflexes

Substitutions always active. Reach for default tool, check table first:

| Instead of... | Always use... | Why |
|---|---|---|
| `grep` / `egrep` | `rg` (ripgrep) | Faster, .gitignore-aware, better defaults |
| `grep` in Bash commands | `rg` in Bash commands | Same — even inside shell pipelines |
| `python3 -m json.tool` | `jq` | Consistent, composable, macOS-native |
| `cat CLAUDE.md` to recall rules | Trust loaded context | CLAUDE.md already injected at session start |
| bash/sed/awk to edit files | Edit tool (default) | Visible diffs, read-first safety, auditable |
| `pnpm test -- <file>` / `npm test -- <file>` to run one spec | `pnpm exec vitest run <file>` (or `npx vitest run <file>`) | The `--` is passed through to `vitest run`, which **defeats the path filter** and runs the WHOLE suite. With no worker cap that fans out to one fork per CPU (e.g. 14), and memory-heavy specs OOM the machine (exit 137). |
| plain `gh ...` for SN repos (dcg-*, wdf-*, etc.) | `GH_HOST=code.devsnc.com gh ...` | SN code lives on the enterprise GHE at `code.devsnc.com`; bare `gh` defaults to github.com and fails with "Could not resolve to a Repository". Set `GH_HOST=code.devsnc.com` (already authed there) for `pr create`, `pr view`, `api`, etc. `--repo dev/<name>` still needs the host set. |

**Not suggestions.** Catch self about to type `grep`, `python -m json.tool` — stop, use correct tool.

**Running a single test file:** Never isolate via the package `test` script with `--` (`pnpm/npm test -- <file>`) — that separator reaches the underlying runner and is ignored as a filter, so the entire suite runs in parallel and can exhaust RAM. Always invoke the runner directly: `pnpm exec vitest run <path>` / `npx vitest run <path>` / `pnpm exec jest <path>`. For a deliberate FULL run on a repo with no `poolOptions`/`maxWorkers` config, cap concurrency first: `pnpm exec vitest run --poolOptions.forks.maxForks=2` (or `--no-file-parallelism`). Exit code 137 = OOM kill; suspect runaway parallelism.

**File editing default:** Default Edit for file mods — visible diffs, requires reading first. Use bash/sed/awk only for mechanical, uniform ops where shell expression materially simpler + lower-risk than Edit (mass find-replace across many files, whitespace normalization, bulk renames). Doubt → Edit.

---

## Execution Standards

**Verification Before Done** — Never mark complete without proving works. Diff behavior before/after when relevant. Ask: "Would staff engineer approve?" Run tests, check logs, demonstrate correctness.

**Demand Elegance** — Non-trivial changes, pause before presenting: "More elegant way?" Fix feels hacky: *"Knowing everything I know now, implement the elegant solution."* Skip for simple obvious changes.

**Autonomous Bug Fixing** — Given bug: fix it. Point at logs, errors, failing tests — resolve. No hand-holding.

**No Bugs** — Root causes. No temp fixes. Senior dev standards.

**Minimal Impact** — Changes only touch necessary. No unrelated mods or side effects.

**Verify Capability Claims Before Answering** — Never answer "can X access Y" / "does X support Z" from tool-list descriptions or names alone. Check actual config/env (MCP server env vars in `~/.claude.json` `mcpServers.<name>.env`, config files, source) before saying no. A tool's description not mentioning something is not proof it can't — most MCP servers have generic/parameterized tools whose real target is set by config, not visible in the tool name.

**TypeScript Code Quality** — Three hard rules:
1. **No IIFEs in JSX** — never `{(() => { ... })()}`. Extract computed values into variables above `return`.
2. **No `!` assertions or `as` casts** — handle nullability with conditionals or safe defaults; never assert away types.
3. **No `any` types** — use proper types, `unknown`, or generics.

---

## Planning Protocol

**Creating any implementation plan, ALWAYS:**

1. Write initial plan
2. Run `/combat:murphyjitsu` on plan to surface failure modes via pre-mortem
3. Incorporate failure analysis into plan (preventive measures, adjust estimates, flag high-risk areas)
4. Present final plan with murphyjitsu findings included

**Additional sanity checks:**
- `/combat:goalfactor` — "What really trying to achieve? Better paths?"
- `/combat:noticing` — "What glossing over or avoiding?"

All 10 rationalist skills live under the `combat:` namespace (`combat:taboo`, `combat:doublecrux`, `combat:steelman`, `combat:referenceclass`, `combat:hamming`, `combat:innerloop`, `combat:aversionfactor`). Installed as a skills-dir plugin at `~/.claude/skills/combat/`.

Goal: catch planning fallacies, optimism bias, hidden failure modes BEFORE execution.

Use plan mode for any task 3+ steps or architectural decisions — including verification steps, not just building. Write specs upfront to reduce ambiguity. Mid-task goes sideways, stop + re-plan — don't keep pushing.

---

## Subagent Strategy

Keep main context clean. Offload research, exploration, parallel analysis to subagents. One task per subagent for focused execution. Complex problems → throw more compute — don't solve everything in main thread.

---

## Agent Teams

**After completing team work:** Always ask user about cleaning up team before finishing.

Cleanup steps:
1. Send shutdown requests to all teammates
2. Run `TeamDelete` to remove team configs + task data

Creating multi-agent teams, ensure all phases (investigation, design, review) complete
within single session. Workflow too large → break into sequential sessions with
clear handoff artifacts saved to files.

---

## PR & Code Review

**No em dashes in PR comments or replies.** They read as AI-generated and reveal authorship. Use commas or periods instead. Short sentences, casual tone.

**PR reviews: issues only.** Leave a comment only when there is an important, actionable issue. Zero inline comments is the correct answer for a solid PR — do not pad to look thorough. Do not post affirmations, concurrences, speculative future risks, or minor wording nitpicks. If nothing clears the bar, post nothing.

**Setup/onboarding walkthroughs:** On failures, tell the user what's missing and what to do — don't diagnose and auto-fix. Setup decisions (which Java version, new instance vs existing) belong to the engineer.

---

## Browser Tools (chrome-devtools MCP)

**Close what you open.** Call `close_page` on every page/tab opened once the task is done. Tabs accumulate across a long session and each renderer holds real memory (measured: 22 renderers ≈ 1 GB).

Know the limits so you report accurately instead of claiming a clean shutdown:
- The toolset has **no tool to quit the browser** — `close_page` closes a tab, nothing closes Chrome itself. Chrome is reaped when the owning session's MCP server exits, which can lag well behind the last tool call.
- Chrome runs on a dedicated profile (`~/.cache/chrome-devtools-mcp/chrome-profile`, ~357 MB) — it is NOT the user's daily browser. Arc listening on port 9222 is unrelated; never kill it.
- Each Claude session spawns its own `chrome-devtools-mcp` server (~370 MB) at startup whether browser tools are used or not. Many concurrent sessions = GBs idle. That's config, not something a tool call can fix — mention it rather than trying to work around it.

Never kill Chrome or MCP processes belonging to *another* live Claude session without asking — that session may be mid-task.

---

## ServiceNow MCP (`servicenow-mcp`)

Config lives in `~/.claude.json` under `mcpServers.servicenow-mcp.env`, not in `~/.config/servicenow-mcp/` (that dir only holds an installation-id).

- **Generic tools** (`get_table_data`, `get_table_record`, `create_table_record`, `get_table_record_count`, etc. — no `_bt1`/`_support` suffix) hit `SNC_BASE_URL` by default (basic auth via `SNC_USER`/`SNC_PASS`). In this env `SNC_BASE_URL=http://localhost:8080`, `SNC_USER=admin`, `SNC_PASS=admin` — **these tools already reach the local dev instance on :8080** unless an `instanceUrl` param is passed.
- **`instanceUrl` param** (present on the generic tools) overrides the target to any `https?://<origin>` — credentials auto-fetched/browser-auth'd via the SuperNow store. Use this to hit a third instance beyond BT1/Support.
- **`_bt1`/`_support` suffixed tools** are hardcoded to `https://buildtools1.service-now.com` / `https://support.servicenow.com` (`BT1_URL`/`SUPPORT_URL` env vars) — they ignore `SNC_BASE_URL` and cannot be redirected to localhost or any other instance.
- `check_servicenow_auth_status` reports BT1/Support browser-auth state only; it does not reflect the generic tools' basic-auth path to `SNC_BASE_URL`.

Installed via Homebrew (`servicenow-mcp-installer` tap `prakhar-yadav/servicenow-mcp-installer`), source at `code.devsnc.com/prakhar-yadav/servicenow-mcp`. No need to clone the repo to answer config/capability questions — read `~/.claude.json`'s env block first.

---

## Ticket Creation (BT1)

Create/update stories via `claude_ai_BT1_MCP` (`create_update_story`), not `servicenow-mcp`'s `_bt1` tools — the latter needs a manual `refresh_connection` + browser SSO round-trip most sessions won't have done.
Resolve any sys_ids in a pasted BT1 URL (sprint, assignment_group, assigned_to) via `query_bt1_table` first — don't guess names from the sys_id alone.

---

## Git Commits

Complete all work and verify end-to-end before committing. Do not commit after each implementation step — commit once when everything works and the user confirms.

---

## Git Worktrees

Create worktrees as sibling directories named `<repo-name>.<branch-name>` (slashes → hyphens).

Standard branch prefixes:
- `maint/` — maintenance/cleanup (e.g. `maint/dcg-cart-cleanup`)
- `scratch/` — experimental, no ticket (e.g. `scratch/execution-run`)
- `STRY<number>/` — story work (e.g. `STRY12345/add-filter`)

Always ask the user for the branch name before creating the worktree.

---

## Environment

All scripts must work on macOS first and foremost.

**Tool substitutions (enforced — see Hardwired Reflexes above):**
- `jq` instead of `python3 -m json.tool`
- `rg` instead of `grep` / `egrep`

---

## Knowledge Base

Compiled SN/DCG wiki at `~/Desktop/sn-wiki/wiki/`. Contains synthesized knowledge about DCG (assets, search, domains, catalog, relationships, ACL, UI patterns, KOS, toolchain) + platform (Fluent SDK, AIS, design system, Seismic, Tectonic, WDF/Now Assist).

Working any SN/DCG task, read `~/Desktop/sn-wiki/wiki/INDEX.md` for orientation, then pull relevant topic articles. Topic articles in `wiki/topics/`, concept articles in `wiki/concepts/`.
