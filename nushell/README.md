# Configuration files for Nushell

See the offical [website](https://www.nushell.sh) for documentation.

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
