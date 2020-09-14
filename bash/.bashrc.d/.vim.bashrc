# configs to make vim nicer

## swap caps lock and escape
setxkbmap -option caps:swapescape &> /dev/null || true

## enable register-sharing between all vim instances
alias vim="vim --servername ${USER} "

## manage declared vundle plugins - in a hacky way
## (this quietly runs vim in the background just to autorun vundle)
(echo | echo | vim +PluginInstall! +PluginClean +qall &> /dev/null &) || true
