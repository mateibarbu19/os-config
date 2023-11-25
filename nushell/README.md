# Configuration files for Nushell

See the offical [website](https://www.nushell.sh) for documentation.

1. Install the following packages before proceeding:
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
        - or carapace (please edit [my-config.nu](my-config.nu) for this)
1. Pull the configuration files.
    ```sh
    git clone https://github.com/mateibarbu19/os-config ~/os-config
    ```
1. In each of the following files, reference these scripts to:
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
