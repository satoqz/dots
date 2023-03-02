export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
    if ! test -d "${XDG_RUNTIME_DIR}"; then
        mkdir "${XDG_RUNTIME_DIR}"
        chmod 0700 "${XDG_RUNTIME_DIR}"
    fi
fi

export DOCKER_CONFIG="$XDG_DATA_HOME/docker"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GOPATH="$XDG_DATA_HOME/go"
export DENO_INSTALL_ROOT="$XDG_DATA_HOME/deno/bin"

export EDITOR="vim"
export VISUAL="$EDITOR"

export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

[ -d "/opt/homebrew" ] && export HOMEBREW_NO_ENV_HINTS=1

add_path() {
	[ -d "$1" ] && export PATH="$1:$PATH"
}

bins=(
	"/opt/homebrew/bin"
	"$HOME/.local/bin"
	"$DENO_INSTALL_ROOT"
	"$CARGO_HOME/bin"
	"$GOPATH/bin"
)

for bin in "${bins[@]}"; do
	add_path "$bin"
done
