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

This repo includes a Codex marketplace at `.agents/plugins/marketplace.json` and a root-level Codex plugin manifest at `.codex-plugin/plugin.json`.

To register the local marketplace with Codex:

```bash
codex plugin marketplace add Codagent-AI/agent-skills
```

Then restart Codex, open the plugin directory with `/plugins`, choose the `Codagent` marketplace, and enable/install the `codagent` plugin.

Codex skills are not slash commands. Invoke them by name in chat, for example:

```text
use the codagent:propose skill
```

For marketplace development, re-add or upgrade the marketplace after changing `.agents/plugins/marketplace.json`:

```bash
codex plugin marketplace remove codagent
codex plugin marketplace add Codagent-AI/agent-skills
```

Then restart Codex so the plugin directory reloads the local marketplace and plugin metadata.

The marketplace uses a Git-backed root plugin source. This avoids duplicating `skills/`, but it means the marketplace entry resolves from GitHub rather than from the local checkout. For local root plugin testing, use a Git branch or commit that contains the root `.codex-plugin/plugin.json`; local `source.path: "./"` is currently rejected by Codex.
