# Working Standards (all projects)

I'm Michael Battista. Employer-specific context, if any, is imported from `CLAUDE.work.md` at the end of this file.

## How I work — match this

- **Plan before code on anything non-trivial.** I use plan mode heavily. Present a phased plan with explicit ordering; I will edit phases (merge, reorder, make destructive) — incorporate my edits exactly, don't re-litigate.
- **I steer with short corrections mid-flight.** When I interrupt or send a one-liner ("the filter is on name, not ID"), that's a spec refinement — apply it, verify nothing else depended on the old assumption, move on. No apologies, no restating.
- **Show data as one compact table.** When I ask "show me how X will look", I want one table, one example row per provider/case, each cell annotated with its source field. Blank cells marked `—` with a note on what owns them.
- **Answer first, detail after.** Lead with the outcome. Terse is fine; ambiguous is not.

## Quality bar — non-negotiable

- **Verify counts and names against the code, not memory.** Endpoint counts, field names, model lists: grep them before stating them. If you estimated earlier and the real number differs, correct it explicitly.
- **Never present unvalidated schema assumptions as fact.** If you infer field names for an external API (boto3, a vendor REST API), say so and propose a dry-run to confirm.
- **ACL/permission code is data-leak territory.** Any endpoint or queryset change touching org scoping gets tests for both the privileged-bypass and the scoped path, including the 403 branches.
- **Field ownership between sync jobs is sacred.** Multiple commands write the same models; a sync only touches the fields it owns and never clobbers another's. State ownership when adding writes.
- **Docs are part of the change.** Commands/endpoints/models/env-vars changed → CLAUDE.md and README updated in the same change set.
- **Destructive DB operations get validated on a throwaway database first** — never against shared dev. See the safe-migration skill.

## Dependency & Container Version Rules

- **Latest Versions Default:** Always install and specify the absolute latest stable versions for all package manager dependencies (e.g., npm, pip, go modules, cargo) and Docker images unless a pre-existing configuration file explicitly locks a version.
- **Verification Rule:** Before modifying any `package.json`, `pyproject.toml`, `Dockerfile`, or dependency manifest, use the terminal to actively check the registry (e.g., `npm info`, `uv pip index versions`, or Docker Hub) to confirm the latest stable release. Do not guess versions based on static knowledge.
- **Exception handling:** You may only use an older version if there is an explicit technical conflict (e.g., breaking changes, security advisory, or environment incompatibility). If an exception is made, document the specific technical reason as a comment next to the dependency or inside the commit message.

## Toolchain defaults

- `uv`, never pip (`uv sync`, `uv run pytest`, `uv run python ...`).
- pytest + pytest-django + factory_boy; black/isort, line-length 120, skip-string-normalization; `pre-commit run --all-files` before done.
- Commits: gitmoji + imperative subject, ticket reference in the body when one exists. Subject line: aim for ≤50 chars, never over 72 (excluding the gitmoji). Commit only when asked; never push unasked.

## Gitmoji reference

Pick from the category that matches your commit intent. [Full reference](https://gitmoji.dev).

| Emoji | Code | Purpose |
|-------|------|---------|
| **Core Development** | | |
| ✨ | `:sparkles:` | Introduce new features |
| 🐛 | `:bug:` | Fix a bug |
| ♻️ | `:recycle:` | Refactor code |
| 🔥 | `:fire:` | Remove code or files |
| 💥 | `:boom:` | Introduce breaking changes |
| 🩹 | `:adhesive_bandage:` | Simple fix for a non-critical issue |
| ⚰️ | `:coffin:` | Remove dead code |
| 🎨 | `:art:` | Improve structure / format of the code |
| **Testing & Quality** | | |
| ✅ | `:white_check_mark:` | Add, update, or pass tests |
| 🧪 | `:test_tube:` | Add a failing test |
| 📸 | `:camera_flash:` | Add or update snapshots |
| 🤡 | `:clown_face:` | Mock things |
| 🧐 | `:monocle_face:` | Data exploration / inspection |
| 🚨 | `:rotating_light:` | Fix compiler / linter warnings |
| **Data & Infrastructure** | | |
| 🗃️ | `:card_file_box:` | Perform database related changes |
| 🧱 | `:bricks:` | Infrastructure related changes |
| 🏗️ | `:building_construction:` | Make architectural changes |
| 👔 | `:necktie:` | Add or update business logic |
| 🌱 | `:seedling:` | Add or update seed files |
| **Security & Access Control** | | |
| 🔒️ | `:lock:` | Fix security or privacy issues |
| 🔐 | `:closed_lock_with_key:` | Add or update secrets |
| 🛂 | `:passport_control:` | Work on authorization, roles, permissions |
| 🥅 | `:goal_net:` | Catch errors |
| 🦺 | `:safety_vest:` | Add or update validation |
| **Dependencies & Configuration** | | |
| ⬆️ | `:arrow_up:` | Upgrade dependencies |
| ⬇️ | `:arrow_down:` | Downgrade dependencies |
| 📌 | `:pushpin:` | Pin dependencies to specific versions |
| ➕ | `:heavy_plus_sign:` | Add a dependency |
| ➖ | `:heavy_minus_sign:` | Remove a dependency |
| 🔧 | `:wrench:` | Add or update configuration files |
| 🔨 | `:hammer:` | Add or update development scripts |
| 📦️ | `:package:` | Add or update compiled files or packages |
| **Operations & Monitoring** | | |
| 🚀 | `:rocket:` | Deploy stuff |
| 💚 | `:green_heart:` | Fix CI build |
| 👷 | `:construction_worker:` | Add or update CI build system |
| 🔊 | `:loud_sound:` | Add or update logs |
| 🔇 | `:mute:` | Remove logs |
| 🩺 | `:stethoscope:` | Add or update healthcheck |
| ⚡️ | `:zap:` | Improve performance |
| **Metadata & Workflow** | | |
| 📝 | `:memo:` | Add or update documentation |
| 🔖 | `:bookmark:` | Release / Version tags |
| 🚧 | `:construction:` | Work in progress |
| 🔀 | `:twisted_rightwards_arrows:` | Merge branches |
| ⏪️ | `:rewind:` | Revert changes |
| 👽️ | `:alien:` | Update code due to external API changes |
| 🚚 | `:truck:` | Move or rename resources (files, paths, routes) |
| **Specialized** | | |
| 🏷️ | `:label:` | Add or update types |
| 🚩 | `:triangular_flag_on_post:` | Add, update, or remove feature flags |
| 🦖 | `:t-rex:` | Code that adds backwards compatibility |
| ✏️ | `:pencil2:` | Fix typos |
| 💬 | `:speech_balloon:` | Add or update text and literals |
| 🌐 | `:globe_with_meridians:` | Internationalization and localization |
| 🔍️ | `:mag:` | Improve SEO |
| 📱 | `:iphone:` | Work on responsive design |
| 💄 | `:lipstick:` | Add or update UI and style files |
| 💡 | `:bulb:` | Add or update comments in source code |

## Definition of done (every repo)

1. `uv run pytest` green (full suite).
2. Framework check clean (Django: `manage.py check` under test settings).
3. `pre-commit run --all-files` passes.
4. Docs match reality.
5. Report failures verbatim — never call unverified work finished.
6. If there is a JIRA ticket, offer to update its status (ask before transitioning it) and add comments if necessary.

## Work context

@~/.claude/CLAUDE.work.md
