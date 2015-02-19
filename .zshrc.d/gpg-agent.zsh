# https://github.com/chazy/zsh-config/blob/master/plugins/gpg-agent/gpg-agent.plugin.zsh
local GPG_ENV="${HOME}/.gnupg/gpg-agent.env"

function start_agent {
  /usr/bin/env gpg-agent --daemon --write-env-file "${GPG_ENV}" > /dev/null
  chmod 600 "${GPG_ENV}"
  source "${GPG_ENV}" > /dev/null
}

function kick-gpg-agent {
  if [[ "$1" == "-f" ]]; then
    echo "killing gpg-agent"
    killall -9 gpg-agent
  fi
  if [[ -f "${GPG_ENV}" ]]; then
    source "${GPG_ENV}" > /dev/null
    ps -ef | grep "${SSH_AGENT_PID}" | grep "gpg-agent" > /dev/null || {
      start_agent
    }
  else
    start_agent
  fi

  export GPG_AGENT_INFO
  export SSH_AUTH_SOCK
  export SSH_AGENT_PID

  GPG_TTY=$(tty)
  export GPG_TTY
}
kick-gpg-agent

