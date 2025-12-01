# knoxOS



### NixOS configuration

```bash
nixos-rebuild switch --use-remote-sudo --flake path://
```


To create an installer iso that will destructively autoinstall NixOS on the first disk it sees after boot:

```bash
nix build .#destructive-installer-iso
```

Then after booting this iso and waiting five minutes for the reboot,
you should be able to `ssh` in using the public key defined in `./hosts/minimal-remote/default.nix`.