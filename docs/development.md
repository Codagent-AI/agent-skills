# Development

## Local Plugin Testing

To test the plugin from another project on the same machine:

```bash
claude plugin uninstall codagent
claude plugin marketplace add /path/to/agent-skills
claude plugin install codagent
```

### Refreshing after changes

Installed plugins are cached at `~/.claude/plugins/cache/`. Edits to your local source files are **not** picked up automatically. After making changes, clear the cache and reinstall:

```bash
rm -rf ~/.claude/plugins/cache/codagent
```

Then start a new Claude session — the plugin will be re-cached from your local directory.

## Codex local testing

This repo includes a Codex marketplace at `.agents/plugins/marketplace.json` and a packaged Codex plugin at `plugins/codagent/`.

To register the local marketplace with Codex:

```bash
codex plugin marketplace add /path/to/agent-skills
```

Then restart Codex, open the plugin directory with `/plugins`, choose the `Codagent` marketplace, and enable/install the `codagent` plugin.

Codex skills are not slash commands. Invoke them by name in chat, for example:

```text
use the codagent:propose skill
```

For local marketplace development, `codex plugin marketplace upgrade` is not the refresh path; the current CLI only supports `upgrade` for Git-backed marketplaces. Remove and re-add the local marketplace after changing `.agents/plugins/marketplace.json`:

```bash
codex plugin marketplace remove codagent
codex plugin marketplace add /path/to/agent-skills
```

Then restart Codex so the plugin directory reloads the local marketplace and plugin metadata.

The root `skills/` directory is the source used by Claude and Cursor. The Codex package mirrors those files under `plugins/codagent/skills/`; refresh that mirror when changing skill content.
