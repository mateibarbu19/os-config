# Configuration files for Nushell

See the offical [website](https://www.nushell.sh) for documentation.

Please install the following packages before proceeding:
    - starship 
        - is a cross-shell promt
        - needs a Nerd font
    - eza
        - alterantive ls
        - also needs a Nerd font
    - batcat
        - alternative `cat`
    - fish
        - for command completions
        - or carapace (please edit the scripts for this)

1. Pull the configuration files.
    ```sh
    git clone https://github.com/mateibarbu19/os-config ~/os-config
    ```
2. In each of the following files, reference these scripts to:
    - add defintions and aliases
        ```nu
        # $nu.config-path
        source ~/os-config/nushell/my-config.nu
        ```
    - or define environment variables.
        ```nu
        # $nu.env-path
        source ~/os-config/nushell/my-env.nu
        ```
