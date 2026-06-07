# .dotfiles
## Recommended fonts:
- [Meslo Nerd Font](https://github.com/romkatv/powerlevel10k/blob/master/font.md)
- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)
- [Commit Mono](https://github.com/eigilnikolajsen/commit-mono)

## Install
```sh
curl -o- https://raw.githubusercontent.com/fcolic89/.dotfiles/main/setup.sh | bash
```
### Install dotfiles with additional packages
```sh
curl -o- https://raw.githubusercontent.com/fcolic89/.dotfiles/main/setup.sh | bash -s -- --packages
```
### Install dotfiles from a different branch
```sh
curl -o- https://raw.githubusercontent.com/fcolic89/.dotfiles/main/setup.sh | bash -s -- --branch example
```
### Install dotfiles from a custom directory
```sh
curl -o- https://raw.githubusercontent.com/fcolic89/.dotfiles/main/setup.sh | bash -s -- --install ~/custom/path
```
