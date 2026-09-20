let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {
        if ($in | path exists) and ($in | str contains ' ') {
            $'"($in | str replace "\"" "\\\"" )"'
        } else {
            $in
        }
    }
}

# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false # true or false to enable or disable the welcome banner at startup

    table: {
        mode: light # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    }

    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true    # set this to false to prevent auto-selecting completions when only one remains
        partial: true    # set this to false to prevent partial filling of the prompt
        algorithm: "prefix"    # prefix or fuzzy
        sort: "smart" # "smart" (alphabetical for prefix matching, fuzzy score for fuzzy matching) or "alphabetical"
        external: {
            enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: $fish_completer
        }
        use_ls_colors: true # set this to true to enable file/path/directory completions using LS_COLORS
    }

    shell_integration: {
        # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
        osc2: true
        # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
        osc7: true
        # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
        osc8: true
        # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
        osc9_9: false
        # osc133 is several escapes invented by Final Term which include the supported ones below.
        # 133;A - Mark prompt start
        # 133;B - Mark prompt end
        # 133;C - Mark pre-execution
        # 133;D;exit - Mark execution finished with exit code
        # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
        osc133: true
        # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
        # 633;A - Mark prompt start
        # 633;B - Mark prompt end
        # 633;C - Mark pre-execution
        # 633;D;exit - Mark execution finished with exit code
        # 633;E - Explicitly set the command line with an optional nonce
        # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
        # and also helps with the run recent menu in vscode
        osc633: true
        # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
        reset_application_mode: true
    }
}

def ll [dir?:string] {
    if $dir != null {
        cd $dir
    }
    ls -a | update name {|n| eza --color=always --icons=always --hyperlink -d $n.name } | rename filename
}
