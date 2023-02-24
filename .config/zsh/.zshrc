source_optional() {
	[ -f "$1" ] && source "$1"
}

add_path() {
	[ -d "$1" ] && export PATH="$1:$PATH"
}

has_command() {
	command -v "$1" >/dev/null 2>&1
}

bins=(
	/opt/homebrew/bin
	~/.local/bin
	~/.deno/bin
	~/.cargo/bin
	~/go/bin
)

shares=(
	/usr/share
	/usr/local/share
	/opt/homebrew/share
)

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="vim"
export VISUAL="$EDITOR"

[ -d "/opt/homebrew" ] && export HOMEBREW_NO_ENV_HINTS=1

typeset -U path cdpath fpath manpath

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

HISTSIZE=10000
SAVEHIST=10000

HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p $(dirname $HISTFILE)

setopt autocd

for bin in "${bins[@]}"; do
	add_path "$bin"
done

for share in "${shares[@]}"; do
	[ -d "$share/zsh" ] &&
		fpath+=("$share/zsh/site-functions" "$share/zsh/$ZSH_VERSION/functions" "/usr/share/zsh/vendor-completions")

	source_optional "$share/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source_optional "$share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source_optional "$share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source_optional "$share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

	source_optional "$share/fzf/completion.zsh"
	source_optional "$share/fzf/key-binddings.zsh"

	[ -d "$share/man" ] && export MANPATH="$MANPATH:$share/man"
done

autoload -U compinit && compinit

has_command less &&
	export PAGER="less" &&
	export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

has_command bat &&
	alias cat="bat -p --theme 'Visual Studio Dark+'" &&
	has_command col >/dev/null 2>&1 &&
	export MANPAGER="sh -c \"col -bx | bat --theme 'Visual Studio Dark+' -l man -p\""

has_command lsd &&
	alias ls="lsd --icon never --almost-all" &&
	alias la="ls -l"

has_command htop &&
	alias top="htop"

has_command tmux &&
	alias tmux="env TERM=screen-256color tmux"

alias cp="cp -v"
alias rm="rm -v"
alias mv="mv -v"

if [ "$EUID" = 0 ]; then
	PROMPT="%F{red}%n%f@%m %F{green}%16<..<%~%<<% %f # "
else
	PROMPT="%n@%m %F{green}%16<..<%~%<<% %f $ "
fi

autoload -Uz vcs_info
precmd_vcs_info() {
	vcs_info
}
precmd_functions+=(precmd_vcs_info)
setopt prompt_subst

RPROMPT='${vcs_info_msg_0_}'
zstyle ":vcs_info:git:*" check-for-changes true
zstyle ":vcs_info:git:*" formats "%F{red}%u%c%f %F{blue}(%b)%f"
