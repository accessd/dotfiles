# fzf shell integration.
# Homebrew keeps the scripts under its own prefix. Debian ships them in
# /usr/share/doc/fzf/examples. fzf 0.48+ can print them itself, but bookworm
# still packages 0.38, so all three paths have to be handled.
if command -v brew >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix)/opt/fzf"
  [[ "$PATH" == *"$fzf_prefix/bin"* ]] || export PATH="$PATH:$fzf_prefix/bin"
  [[ $- == *i* ]] && source "$fzf_prefix/shell/completion.zsh" 2>/dev/null
  source "$fzf_prefix/shell/key-bindings.zsh" 2>/dev/null
  unset fzf_prefix
elif command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    [[ $- == *i* ]] && [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] \
      && source /usr/share/doc/fzf/examples/completion.zsh
    [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] \
      && source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
fi
