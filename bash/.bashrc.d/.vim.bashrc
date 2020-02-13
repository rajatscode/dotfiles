# configs to make vim nicer

## swap caps lock and escape
setxkbmap -option caps:swapescape &> /dev/null || true

## enable register-sharing between all vim instances
alais vim="vim --servername ${USER} "

## manage declared vundle plugins - quiety, in a hacky way
(echo | echo | vim +PluginInstall! +PluginClean +qall &> /dev/null &) || true
