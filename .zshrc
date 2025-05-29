# Created by newuser for 5.9

# NVM does not work on this system anyways.
# Added automatically after nvm install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# For python3 pip scripts
export PATH="$PATH:/var/mobile/.local/bin"
alias pip="pip3"

# for better ls
alias ls="ls -a --color=auto"

# Added automatically after theos install
export THEOS=~/theos

alias newtheos="$THEOS/bin/nic.pl"

alias editrc="nano /var/mobile/.zshrc && source /var/mobile/.zshrc"

alias please="sudo"

alias noprompt="export PS1='> '"