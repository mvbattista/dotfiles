---
name: safe-migration
description: Plan and validate Django schema/data migrations, especially destructive ones (clearing tables, renaming models, dropping models). Use for any migration touching existing data, model renames, or when the user mentions clearing/resetting tables.
---

# Safe Django Migration Playbook

## Hard rules
- **Never run a destructive migration against the shared dev database.** Validate on a throwaway DB: `docker exec <db> psql -U postgres -c "CREATE DATABASE <name>_migtest;"`, migrate with `DB_NAME=<name>_migtest`, verify, then DROP it.
- Model renames keep the physical table: `class Meta: db_table = '<old_table>'` + `RenameModel` — metadata-only, no table rename.
- pytest runs with `--no-migrations` (schema from models) — a migration can be broken while tests pass. Postgres-only raw SQL (e.g. `DROP TABLE ... CASCADE`) in a migration will not surface in the SQLite test run; that's WHY the throwaway-Postgres step exists.

## Steps
1. Sequence explicitly: schema ops first (Add/Remove/Rename/Delete), data ops (`RunPython`) last. Name each phase.
2. Clearing tables: delete children before parents (through-tables/memberships before the FK target); prefer `.delete()` over `TRUNCATE ... CASCADE` when other tables FK into the target (CASCADE truncates them too).
3. After clearing, reset auto-increment ids with the vendor-aware helper:
   ```python
   from django.core.management.color import no_style
   reset_sql = connection.ops.sequence_reset_sql(no_style(), [ModelA, ModelB])
   ```
4. State the data-loss consequences in the migration docstring: what rebuilds automatically (from which sync/source-of-truth) and what is gone forever (e.g. user↔org memberships not in the upstream system — export first).
5. `makemigrations` prompts interactively on renames — pipe `yes |` or answer, then READ the generated file before editing it.
6. Validate: throwaway-DB migrate → inspect schema (`\dt`, `\d table`, sequence `last_value`) → drop DB → run pytest → `manage.py check` with test settings.

## Output
The migration file + a verification transcript (what was checked on the throwaway DB) + explicit statement of irreversible data loss, if any.
