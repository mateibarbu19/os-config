$env.config.show_banner = false
$env.config.shell_integration = true

use ~/.cache/starship/init.nu

# Use one of two completers: carapace or fish
# See: https://www.nushell.sh/cookbook/external_completers.html

# Uncomment to use carapace after intalling it
# source ~/.cache/carapace/init.nu


let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | $"value(char tab)description(char newline)" + $in
    | from tsv --flexible --no-infer
}

# Comment if you don't want to use fish
$env.config.completions.external.completer = $fish_completer

alias pls = eza -l --icons --git

alias bat = ^(
    if (which ^bat | is-empty) and (not (which ^batcat | is-empty)) {
        (which ^batcat).path | get 0
    } else if not (which ^bat | is-empty) { 
        (which ^bat).path | get 0 
    } else {
        error make {msg: "Executable was not found" }
    })

def bathelp [...cmd] {
    let args = ($cmd | skip | str join ' ')
    ^$cmd.0 $args --help | bat --plain --language=help
}
