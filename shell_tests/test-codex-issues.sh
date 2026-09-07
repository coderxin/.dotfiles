#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/bin/codex-issues"

bash -n "$script"
"$script" --help | grep -q 'codex-issues start'

state_root="$(mktemp -d /tmp/codex-issues-test-state-XXXXXX)"
test_root="$(mktemp -d /tmp/codex-issues-test-repo-XXXXXX)"
cleanup() {
  rm -r "$state_root" "$test_root"
}
trap cleanup EXIT

if CODEX_ISSUES_STATE_ROOT="$state_root" "$script" status '../bad' >/dev/null 2>&1; then
  printf 'unsafe run name was accepted\n' >&2
  exit 1
fi

mkdir -p "$test_root/bin" "$test_root/worktrees"
cat > "$test_root/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
  'repo view')
    if [[ "$*" == *nameWithOwner* ]]; then
      printf 'owner/repo\n'
    else
      printf 'main\n'
    fi
    ;;
  'issue view')
    issue="$3"
    printf '{"number":%s,"title":"Test issue","body":"Do the work","url":"https://github.com/owner/repo/issues/%s"}\n' "$issue" "$issue"
    ;;
esac
EOF
cat > "$test_root/bin/codex" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${CODEX_TEST_LOG:?}"
exit 0
EOF
cat > "$test_root/bin/tmux" <<'EOF'
#!/usr/bin/env bash
state="${TMUX_TEST_STATE:?}"
printf '%s\n' "$*" >> "$state/tmux.log"
case "$1" in
  new-session|new-window)
    count=0
    [[ ! -f "$state/count" ]] || read -r count < "$state/count"
    count=$((count + 1))
    printf '%s\n' "$count" > "$state/count"
    printf '@%s\t%%%s\n' "$count" "$count"
    ;;
  display-message)
    [[ ! -f "$state/closed" ]] || exit 1
    printf 'codex\n'
    ;;
  capture-pane) printf 'captured output\n' ;;
  *) exit 0 ;;
esac
EOF
chmod +x "$test_root/bin/gh" "$test_root/bin/codex" "$test_root/bin/tmux"

git init --bare -q "$test_root/origin.git"
git init -q -b main "$test_root/repo"
git -C "$test_root/repo" config user.name Test
git -C "$test_root/repo" config user.email test@example.com
touch "$test_root/repo/README.md"
git -C "$test_root/repo" add README.md
git -C "$test_root/repo" commit -qm init
git -C "$test_root/repo" remote add origin "$test_root/origin.git"
git -C "$test_root/repo" push -qu origin main

output="$(
  cd "$test_root/repo"
  env -u TMUX PATH="$test_root/bin:$PATH" \
    TMUX_TEST_STATE="$test_root" \
    CODEX_ISSUES_STATE_ROOT="$state_root" \
    CODEX_ISSUES_WORKTREE_ROOT="$test_root/worktrees" \
    "$script" start 12 34
)"
run="$(printf '%s\n' "$output" | awk '/^run: / { print $2 }')"
[[ -n "$run" ]]
grep -q 'Title: Test issue' "$state_root/$run/prompts/issue-12.txt"
grep -q '<github_issue>' "$state_root/$run/prompts/issue-12.txt"

listed="$(CODEX_ISSUES_STATE_ROOT="$state_root" "$script" list)"
grep -q "$run" <<< "$listed"

status="$(PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" "$script" status "$run")"
grep -q '#12' <<< "$status"
grep -q '#34' <<< "$status"

shown="$(PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" "$script" show "$run" 12)"
grep -q 'captured output' <<< "$shown"

env -u TMUX PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" \
  "$script" attach "$run" 12
grep -Fq 'attach-session -t cx-' "$test_root/tmux.log"

# shellcheck disable=SC2016 # Verify intervention text is sent literally.
PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" \
  "$script" send "$run" 12 'Please check $HOME and `uname` literally' >/dev/null
# shellcheck disable=SC2016 # Expected literal text from the command above.
grep -Fq 'send-keys -t %1 -l -- Please check $HOME and `uname` literally' "$test_root/tmux.log"

if PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" \
  "$script" cleanup "$run" >/dev/null 2>&1; then
  printf 'cleanup removed active workers\n' >&2
  exit 1
fi

prompt="$test_root/worker-prompt.txt"
printf 'Initial prompt\n' > "$prompt"
CODEX_TEST_LOG="$test_root/codex.log" "$script" worker "$prompt" "$test_root/bin/codex"
grep -Fxq -- '--yolo Initial prompt' "$test_root/codex.log"

touch "$test_root/closed"
touch "$test_root/worktrees/$run/issue-12/uncommitted.txt"
if PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" \
  "$script" cleanup "$run" >/dev/null 2>&1; then
  printf 'cleanup removed a dirty worktree\n' >&2
  exit 1
fi
rm "$test_root/worktrees/$run/issue-12/uncommitted.txt"
PATH="$test_root/bin:$PATH" TMUX_TEST_STATE="$test_root" CODEX_ISSUES_STATE_ROOT="$state_root" "$script" cleanup "$run" >/dev/null
[[ ! -e "$state_root/$run" ]]
[[ ! -e "$test_root/worktrees/$run" ]]
git -C "$test_root/repo" show-ref --verify --quiet "refs/heads/codex/issue-12-${run#repo-}" || {
  printf 'issue branch was not retained\n' >&2
  exit 1
}

printf 'codex-issues smoke test passed\n'
