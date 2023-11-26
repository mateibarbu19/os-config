let GHCUP_PATH = $env.HOME ++ "/.ghcup/bin" 
if ($GHCUP_PATH | path exists) and (not $GHCUP_PATH in $env.PATH) {
    $env.PATH = ($env.PATH | split row (char esep) | append $GHCUP_PATH)
}

let CABAL_PATH = $env.HOME ++ "/.cabal/bin" 
if ($CABAL_PATH | path exists) and (not $CABAL_PATH in $env.PATH) {
    $env.PATH = ($env.PATH | split row (char esep) | append $CABAL_PATH)
}

$env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
