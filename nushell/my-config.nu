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

def bathelp [...cmd] {
    let args = ($cmd | skip | str join ' ')
    ^$cmd.0 $args --help | batcat --plain --language=help
}
