#!/usr/bin/env bash
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
server() { tmux -S "$scratch/socket" "$@"; }
cleanup() {
  server kill-server 2>/dev/null || true
  rm -rf "$scratch"
}
trap cleanup EXIT

# Exclude TPM startup so plugins cannot restore sessions or change login items.
sed '/^run .*plugins\/tpm\/tpm/d' "$repo/.config/.tmux.conf" > "$scratch/config"
git init -q -b smoke "$scratch/project with spaces"
git -C "$scratch/project with spaces" -c user.name=Smoke -c user.email=smoke@example.invalid -c commit.gpgsign=false commit -q --allow-empty -m smoke
export CODEX_CI=1 NO_COLOR=1
server -f "$scratch/config" new-session -d -c "$scratch/project with spaces" 'sleep 60'
[[ $(server show-environment -g NO_COLOR) == '-NO_COLOR' ]]
[[ $(server show-options -gv default-terminal) == tmux-256color ]]
for key in Left Right Up Down M-Left M-Right M-Up M-Down; do
  [[ $(server list-keys -T prefix "$key") == *resize-pane* ]]
done
[[ $(server list-keys -T prefix j) == *join-pane* ]]
[[ $(server list-keys -T prefix k) == *k9s* ]]
# Execute the configured Git segment with tmux's own format expansion.
segment=$(server show-options -gv status-left)
segment=${segment#*'#('}
segment=${segment%%')'*}
server run-shell "($segment) > '$scratch/branch'"
[[ $(cat "$scratch/branch") == smoke ]]

# Exercise the install manifests with a disposable home, including glob links.
mkdir "$scratch/home"
ruby -ryaml -e '
  entries = ARGV.flat_map { |file| YAML.load_file(file) }
  links = entries.map { |entry| entry["link"] }.compact.reduce({}, :merge)
  puts [{"link" => links.select { |path, _| path.include?("tmux") }}].to_yaml
' "$repo/install/bin.yml" "$repo/install/terminal.yml" > "$scratch/links.yml"
HOME="$scratch/home" "$repo/dotbot/bin/dotbot" -d "$repo" -c "$scratch/links.yml"
[[ -x "$scratch/home/.bin/tmux-kube-context" ]]
for template in rails rust node k8s project; do
  [[ "$scratch/home/.config/tmuxinator/$template.yml" -ef "$repo/.config/tmuxinator/$template.yml" ]]
done
