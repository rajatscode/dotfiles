# configs to install dependencies (and track where they are)
DOTFILES_INSTALLS_DIR="$DOTFILES_HOME_DIR/.installs"

## install Vundle (used by vim dotfiles for package management)
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim &> /dev/null

## simple (brittle!) function to install latest release from a repo
function install_from_github_repo() {
  local repo_name="$1"
  local desired_suffix="$2"
  curl -s https://api.github.com/repos/"$repo_name"/releases/latest |
    grep "browser_download_url.*""$desired_suffix" |
    cut -d : -f 2,3 | tr -d \" |
    wget -qi - -P "$DOTFILES_INSTALLS_DIR"
}

## install google-java-format, which is useful for vim-codefmt
if [ "$(uname -s)" == "Darwin" ]; then
  :
elif compgen -G "${DOTFILES_INSTALLS_DIR}""/*google-java-format*all-deps*jar" &> /dev/null; then
  :
  GOOGLE_JAVA_FMT_PATH=$(ls $DOTFILES_INSTALLS_DIR/*google-java-format*all-deps*jar | head -n 1)
  export GOOGLE_JAVA_FMT_PATH=$GOOGLE_JAVA_FMT_PATH
else
  install_from_github_repo "google/google-java-format" "all-deps.jar"
  GOOGLE_JAVA_FMT_PATH=$(ls $DOTFILES_INSTALLS_DIR/*google-java-format*all-deps*jar | head -n 1)
  export GOOGLE_JAVA_FMT_PATH=$GOOGLE_JAVA_FMT_PATH
fi

## install shfmt, which is useful for vim-codefmt
if ! command -v shfmt &> /dev/null; then
  if command -v snap &> /dev/null; then
    echo "Installing shfmt for formatting shell files..."
    snap install shfmt
  fi
fi

## make sure pip3 is installed
if ! command -v pip3 &> /dev/null; then
  if ! command -v python3 &> /dev/null; then
    (curl -s https://bootstrap.pypa.io/get-pip.py | python) &> /dev/null
  else
    (curl -s https://bootstrap.pypa.io/get-pip.py | python3) &> /dev/null
  fi
fi

## install black for code formatting (vim-codefmt compatible)
(python3 -m pip install black &> /dev/null &)

## install isort for sorting
(python3 -m pip install isort &> /dev/null &)

## install flake8 for linting
(python3 -m pip install flake8 &> /dev/null &)

## install yfinance for the `stonks` alias
(python3 -m pip install yfinance &> /dev/null &)
