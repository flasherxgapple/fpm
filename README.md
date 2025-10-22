# FPM - Flasher Package Manager

FPM is a user-friendly command-line wrapper for various package managers, providing a unified interface for package management across different Linux distributions. (inspired by me when distro hopping always create an alias in shell configuration file :3)

## Features

| Feature                           | Status       |
|-----------------------------------|--------------|
| Search packages (excluding lib*)  | ✅ Supported |
| Sort search results by similarity | ✅ Supported |
| Install packages with confirmation| ✅ Supported |
| Remove packages                   | ✅ Supported |
| Upgrade specific packages         | ✅ Supported |
| Show package groups/sections      | ✅ Supported |
| Show installed status             | ✅ Supported |
| Autoclean unused packages         | ✅ Supported |
| Clean package cache               | ✅ Supported |
| Update system packages            | ✅ Supported |
| Add repositories                  | ✅ Supported |
| Toggle show details               | ✅ Supported |
| Dry-run mode                      | ✅ Supported |
| Persistent configuration          | ✅ Supported |
| Failsafe                          | 🔄 Planned   |

## Supported Package Managers

| Package Manager    | Status          |
|--------------------|-----------------|
| apt (Debian/Ubuntu)| ✅ Supported    |
| pacman (Arch)      | ✅ Untested     |
| dnf (Fedora)       | ✅ Untested     |
| xbps (Void)        | 🔄 Indev (alpha)|
| nix (NixOS)        | 🔄 Indev (alpha)|
| zypper (Opensuse)  | 🔄 Concept      |
| AUR (Arch)         | 🔄 Concept      |
| Flatpak            | 🔄 Concept      |
| Snap               | 🔄 Concept      |


## Installation

Run the install script directly:
   ```bash
   curl -s https://raw.githubusercontent.com/flasherxgapple/fpm/main/install_fpm.sh | bash
   ```

   This will download FPM, set it up in `~/.local/bin`, and add it to your PATH.

## Usage

```bash
fpm -h  # Show help
fpm -i  # Show info
fpm <query>  # Search and install packages
fpm -I <package>  # Install specific package
fpm -R <package>  # Remove specific package
fpm -U <package>  # Upgrade specific package
fpm -A <repo>  # Add repository
fpm -u  # Update system
fpm -c  # Clean cache
fpm -a  # Autoclean
fpm -d  # Toggle show details
fpm -D  # Dry-run mode (No changes applied)
```

## Configuration

FPM uses `~/.fpm_config` for persistent settings:
- `limit`: Number of packages to show
- `mode`: Default mode (list/install)
- `show_details`: Show package details before actions

## Contributing

To add support for a new package manager:
1. Add detection in `p()` function
2. Define command variables at the top
3. Add cases in relevant functions

Or became a tester by using this package manager and report issues

## Contributor
- @flasherxgapple Creator & Active developer

## License

MIT License
