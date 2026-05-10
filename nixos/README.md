```bash
# Rebuild. Switch. And active on next login.
sudo nixos-rebuild switch --flake .#

# Rebuild. Switch. Ephemeral.
sudo nixos-rebuild switch --flake .#

# List Generations
nix profile history --profile /nix/var/nix/profiles/system

# Delete all but the current generation:
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system

# Only keep generations from the last 7 days:
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d
```
