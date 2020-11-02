# configs to install dependencies (and track where they are)
DOTFILES_INSTALLS_DIR="$DOTFILES_HOME_DIR/.installs" ;

## simple (brittle!) function to install latest release from a repo
function install_from_github_repo() {
    local repo_name="$1";
    local desired_suffix="$2";
    curl -s https://api.github.com/repos/"$repo_name"/releases/latest \
    | grep "browser_download_url.*""$desired_suffix"\
    | cut -d : -f 2,3\
    | tr -d \" \
    | wget -qi - -P "$DOTFILES_INSTALLS_DIR" ;
}

## install google-java-format, which is useful for vim-codefmt
if [ -f "$DOTFILES_INSTALLS_DIR""/*google-java-format*all-deps*jar" ];
then : ;
else
    install_from_github_repo "google/google-java-format" "all-deps.jar";
fi

GOOGLE_JAVA_FMT_PATH=$(ls $DOTFILES_INSTALLS_DIR/*google-java-format*all-deps*jar | head -n 1) ;
alias google-java="java -jar $GOOGLE_JAVA_FMT_PATH ";
