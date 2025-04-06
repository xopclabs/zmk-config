# ZMK Config

Simple ZMK keyboard firmware configuration with Nix build system.

## Commands

### Update ZMK

```bash
nix run .#update
```

> **Warning**
> Don't delete branch name comments in west.yml!

### Build Firmware

```bash
nix build .#${keyboard_name}-firmware
```

### Flash Firmware

1. Connect keyboard half
2. Double-tap reset button
3. Run:

```bash
nix run .#${keyboard_name}-flash
```

4. Repeat for the other half

### Development

```bash
nix develop
```

## Troubleshooting

- Check connections and bootloader mode
- Try manual copy of .uf2 files from result/ directory
- Reset both halves if needed

## References

- [ZMK Documentation](https://zmk.dev/docs)
- [ZMK-Nix](https://github.com/lilyinstarlight/zmk-nix) 