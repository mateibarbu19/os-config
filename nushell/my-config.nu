alias pls = eza -l --icons --git

def bathelp [...cmd] {
    let args = ($cmd | skip | str join ' ')
    ^$cmd.0 $args --help | batcat --plain --language=help
}

use ~/.cache/starship/init.nu
source ~/.cache/carapace/init.nu
