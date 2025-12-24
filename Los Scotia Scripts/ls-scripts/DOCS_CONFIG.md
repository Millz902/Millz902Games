# Los Scotia Configuration & Utilities Guide

## Module Pattern
Each domain module lives in its own `ls-<name>` folder with a `config.lua` that defines a global table:

```
LS_<UPPERNAME> = LS_<UPPERNAME> or {}
```
Populate domain sections (tables) under that global. Avoid returning values; the loader executes for side-effects.

## Loader (`config-fix.lua`)
Responsible for:
- Reading each module config file.
- Stripping UTF-8 BOM if present.
- Classifying errors (missing file / compile / runtime).
- Summarizing successes vs failures.
- Preventing nil globals (can extend with defaults).

## Aggregated Namespace (`ls-utils.lua`)
Builds a single `LS` table containing available module globals:
```
LS.Economy, LS.Farming, LS.Nightlife, ...
```
Adds helpers:
- `LS.WithinWindow(hour, windowTable)` – supports ranges that wrap past midnight.
- `LS.Validation.CheckNonEmpty()` – warns for empty module tables.
- Load timing metrics now displayed (top 5 slowest) via enhanced loader.
- Access full namespace server-side: `local ls = exports['ls-scripts']:GetLSNamespace()`

## Hot Reload Commands
Two server console (or permission-restricted) commands:
- `/ls_reload <LABEL>` (e.g. `LS-GYM`) – reload just one config file.
- `/ls_reload_all` – attempt reload of every config.

Notes:
- Does not re-run module-specific runtime side-effects beyond config re-execution.
- Add permission logic inside command handlers if exposing to players / staff.

## Schema Validation
A lightweight schema map in `config-fix.lua` validates presence of critical keys:

Toggle auto-validation by editing `AUTO_VALIDATE` in `ls-utils.lua`.

## Naming Conventions
| Concept | Convention | Example |
|---------|------------|---------|
| Global module table | `LS_<UPPER>` | `LS_FARMING` |
| Aggregated namespace | `LS.<Pascal>` | `LS.Farming` |
| Time window keys | `start_hour`, `end_hour` | `{start_hour=6,end_hour=18}` |
| Boolean flags | snake_case | `enabled = true` |
| Collections | plural table names | `Companies`, `Farms`, `Members` |

Avoid Lua reserved words as keys (e.g. `end`, `repeat`, `for`). If unavoidable, quote them or rename.

## Adding a New Module
1. Create folder: `ls-newmodule/`
2. Add `config.lua` with:
```
Config = {}
-- define Config sections
LS_NEWMODULE = LS_NEWMODULE or {}
LS_NEWMODULE.Section = Config.Section
return LS_NEWMODULE
```
3. Append its entry to the loader list in `config-fix.lua`.
4. (Optional) Add to `ls-utils.lua` attach list for inclusion in `LS`.

## Validation Ideas (Future)
- Schema expectations (e.g., required keys per module).
- Type assertions for numeric fields (prices, durations).
- Cross-module references (e.g., Government roles used in Police config).

## Time Window Helper
```
if LS.WithinWindow(os.date('*t').hour, someConfig.operating_hours) then
    -- open logic
end
```
Supports overnight windows (e.g., 18 -> 6). If start == end, treated as always-open.

## Troubleshooting
| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `unexpected symbol near '<\239>'` | UTF-8 BOM | Loader already strips; ensure file saved UTF-8 w/o BOM |
| `compile error: ... near 'end'` | Reserved word key unquoted | Rename key (`end_hour`) |
| Empty module table warning | Module defined but no sections copied | Check export alias at file end |

## Roadmap Suggestions
- Hot reload command for a single module.
- Version tagging per module (`LS_<MOD>.version`).
- Performance metrics (load time per module).
- Optional JSON export for admin UI.

Already Implemented (remove from future planning if desired):
- Hot reload commands.
- Load-time metrics summary.
- Schema-based key presence validation.
- Aggregated namespace export.

---
Maintainers: Keep this updated when introducing new structural conventions.
