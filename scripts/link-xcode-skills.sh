#!/bin/zsh
# Exposes the agent skills bundled inside Xcode as Claude Code project skills.
#
# Links go through /var/db/xcode_select_link (the symlink `xcode-select -s` maintains),
# so they always follow the selected Xcode. Re-run after an Xcode update in case the
# set of skills or reference files changed.
#
# The links point into this Mac's Xcode, so each skill folder ignores itself in git.
#
# Usage: scripts/link-xcode-skills.sh [skill-name ...]
set -euo pipefail

SKILLS=("$@")
(( $#SKILLS )) || SKILLS=(swiftui-specialist swiftui-whats-new-27)
SELECT_LINK=/var/db/xcode_select_link
RESOURCES=PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources
SRC="$SELECT_LINK/../$RESOURCES"
DEST="${0:A:h:h}/.claude/skills"

[[ -d $SRC ]] || { echo "No Xcode agent resources at $SRC ($(xcode-select -p))" >&2; exit 1; }

for name in $SKILLS; do
  template="$SRC/$name.idechatprompttemplate"
  [[ -f $template ]] || { echo "skip $name: not in $(xcode-select -p)" >&2; continue; }

  dir="$DEST/$name"
  rm -rf "$dir"
  mkdir -p "$dir/references" "$dir/scripts"
  print '*' > "$dir/.gitignore"
  ln -s "$template" "$dir/SKILL.md"

  # Xcode flattens references/foo.md to <name>-ref-foo.md.packaged and scripts/foo to <name>-script-foo.
  for ref in "$SRC/$name"-ref-*.md.packaged(N); do
    base=${ref:t}; base=${base#$name-ref-}
    ln -s "$SRC/${ref:t}" "$dir/references/${base%.packaged}"
  done
  for script in "$SRC/$name"-script-*(N); do
    ln -s "$SRC/${script:t}" "$dir/scripts/${${script:t}#$name-script-}"
  done
  rmdir "$dir/scripts" 2>/dev/null || true

  echo "linked $name ($(ls "$dir/references" | wc -l | tr -d ' ') references)"
done
