# configs to make vim nicer

## swap caps lock and escape
setxkbmap -option caps:swapescape &> /dev/null || true

## enable register-sharing between all vim instances
## (only if vim was compiled with +clientserver)
if (($(vim --version | grep "+clientserver" | wc -l) > 0)); then
  alias vim="vim --servername ${USER} "
fi

## manage declared vundle plugins - in a hacky way
## (this quietly runs vim in the background just to autorun vundle)
(echo | echo | vim +PluginInstall! +PluginClean! +qall &> /dev/null &) || true
