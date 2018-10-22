---
title: "My Local Development Setup"
date: 2018-10-21T12:00:00-06:00
draft: false
description: This article provides a comprehensive walk through of the tools and productivity modifications that I use.
---

I like my local development setup to be lean and automated. This allows me to get up and running with a new machine in under an hour. The following is a comprehensive walk through of the tools and productivity modifications that I use.

This walk through references several configuration files. These configuration files (typically referred to as *dotfiles*) can be found [here](https://github.com/NickolasHKraus/dotfiles)

## MacOS

### Rebind Caps Lock to Control
To rebind Caps Lock (⇪) to Control (⌃) go to **System Preferences** > **Keyboard** > **Modifier Keys…** and change **Caps Lock (⇪) Key:** to **^ Control**.

### Configure shortcuts
To configure MacOS shortcuts, go to **System Preferences** > **Keyboard** > **Shortcuts**.

For MacOS, my shortcuts are as follows:

| | |
|-----------------------|-----------|
| Show Spotlight search | `^Space`  |

To configure application shortcuts, go to **App Shortcuts** > **+** and enter the **Menu Title** as given in the application and the desired keyboard shortcut.

For Chrome, my shortcuts are as follows:

| Menu Title          |  Shortcut   |
|---------------------|-------------|
| New Tab             |  `^T`       |
| Select Next Tab     |  `^K`       |
| Select Previous Tab |  `^J`       |
| Close Tab           |  `^W`       |
| Find...             |  `^F`       |
| Find Next           |  `^G`       |
| Find Previous       |  `^B`       |
| New Window          |  `^N`       |
| Close Window        |  `^Q`       |
| Open Location...    |  `^L`       |
| Reload This Page    |  `^R`       |

### Remove dock auto-hide delay
On the off chance that I use the dock, this ensures that it appears without a delay:

```bash
defaults write com.apple.dock autohide-time-modifier -int 0
defaults write com.apple.dock autohide-delay -int 0
```

## Git
[Git](https://git-scm.com/) is a version-control system for tracking changes in computer files and coordinating work on those files among multiple people.

### Installation
The easiest way to install Git on MacOs is to install the Xcode Command Line Tools:

```bash
xcode-select --install
```

### Configuration
* [.gitconfig](https://github.com/NickolasHKraus/dotfiles/blob/master/.gitconfig)

```bash
ln -s ~/path/to/remote/.gitconfig ~/.gitconfig
```

## iTerm2
[iTerm2](https://www.iterm2.com/) is a replacement for the standard MacOS terminal.

### Installation

```bash
curl -LOk https://iterm2.com/downloads/stable/iTerm2-3_2_3.zip
unzip -q iTerm2-3_2_3.zip
mv iTerm.app /Applications
rm iTerm2-3_2_3.zip
```

### Configuration
* [com.googlecode.iterm2.plist](https://github.com/NickolasHKraus/dotfiles/blob/master/com.googlecode.iterm2.plist)
* [colorscheme.itermcolors](https://github.com/NickolasHKraus/dotfiles/blob/master/colorscheme.itermcolors)

To set the [plist](https://en.wikipedia.org/wiki/Property_list), go to **Preferences** > **General**. Under **Preferences**, set *Load preferences from a custom folder of URL* to the location of `com.googlecode.iterm2.plist`.

To set the color scheme, go to **Preferences** > **Profiles** > **Color Presets…** > **Import…** and import `colorscheme.itermcolors`. *colorscheme* will then appear under **Color Presets…**.

## Zsh
[Oh My Zsh](https://ohmyz.sh/) is an open source, community-driven framework for managing your Zsh configuration. I use a [fork](https://github.com/NickolasHKraus/oh-my-zsh) containing my custom amuse theme.

### Installation

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Configuration
* [.zshrc](https://github.com/NickolasHKraus/dotfiles/blob/master/.zshrc)

```bash
ln -s ~/path/to/remote/.zshrc ~/.zsrhc
```

## Powerline
[Powerline](https://github.com/powerline/powerline) is a statusline plugin for Vim, and provides statuslines and prompts for several other applications including tmux.

### Installation

```bash
pip install --user powerline-status
```

This will install Powerline to the Python user install directory for your platform. On MacOS, this is typically `~/.local/`.

**Note**: If you use a virtualenv, you will need to install `powerline-status` to it as well.

### Configuration
I am currently using the default configuration of Powerline.

## Powerline fonts
[Powerline fonts](https://github.com/powerline/fonts) are pre-patched and adjusted fonts for usage with the Powerline statusline plugin.

### Installation

```bash
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
```

### Configuration
There is no further configuration needed for Powerline fonts.

## Homebrew
[Homebrew](https://brew.sh/) is an exceptional package manager for MacOS.

### Installation

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Configuration
There is no further configuration needed for Homebrew.

## tmux
[tmux](https://github.com/tmux/tmux) is a terminal multiplexer. It enables a number of terminals to be created, accessed, and controlled from a single screen.

### Installation

```bash
brew install tmux
```

### Configuration
* [.tmux.conf](https://github.com/NickolasHKraus/dotfiles/blob/master/.tmux.conf)

```bash
ln -s ~/path/to/remote/.tmux.conf ~/.tmux.conf
```

## Vim
[Vim](https://www.vim.org/) is an enhanced clone of the vi editor. It is highly configurable and extremely useful for productive, efficient programming.

### Installation

```bash
 brew install vim --with-override-system-vi
```

### Configuration
* [.vimrc](https://github.com/NickolasHKraus/dotfiles/blob/master/.vimrc)

```bash
ln -s ~/path/to/remote/.vimrc ~/.vimrc
```

## Vundle
[Vundle](https://github.com/VundleVim/Vundle.vim) is a Vim plugin manager. It allows you to install, update, and  configure Vim plugins all from within your `.vimrc`.

### Installation

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

### Configuration
To install Vim plugins, execute:

```bash
vim +PluginInstall +qall
```

## mpv
[mpv](https://mpv.io/) is a free, open source, and cross-platform media player.

### Installation

```bash
brew install mpv
```

### Configuration files
* [mpv.conf](https://github.com/NickolasHKraus/dotfiles/blob/master/mpv.conf)

```bash
ln -s ~/path/to/remote/mpv.conf ~/.config/mpv/mpv.conf
```

## Spectacle
[Spectacle](https://www.spectacleapp.com/) is a simple, customizable application for moving and resizing windows.

### Installation

```bash
curl -LOk https://s3.amazonaws.com/spectacle/downloadsSpectacle+1.2.zip
unzip -q Spectacle+1.2.zip
mv Spectacle.app /Applications
rm Spectacle+1.2.zip
```

### Configuration
* [Shortcuts.json](https://github.com/NickolasHKraus/dotfiles/blob/master/Shortcuts.json)

```bash
ln -s ~/path/to/remote/Shortcuts.json ~/Library/Application\ Support/Spectacle/Shortcuts.json
```

## Ag
[ag](https://github.com/ggreer/the_silver_searcher) (The Silver Searcher) is a code searching tool similar to `ack`, with a focus on speed.

### Installation

```bash
brew install ag
```

### Configuration
* [.agignore](https://github.com/NickolasHKraus/dotfiles/blob/master/.agignore)

```bash
ln -s ~/path/to/remote/.agignore ~/.agignore
```

Once you have Ag installed, you can use it with [ack.vim](https://github.com/mileszs/ack.vim) by adding the following line to your `.vimrc`:

`.vimrc`

```vim
let g:ackprg = 'ag --nogroup --nocolor --column'
```

## fzf
[fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder.

### Installation

```bash
brew install fzf
$(brew --prefix)/opt/fzf/install
```

### Configuration
Once you have fzf installed, you can enable it inside Vim simply by adding the directory to `&runtimepath` in your `.vimrc`:

`.vimrc`

```vim
" if installed using Homebrew
set rtp+=/usr/local/opt/fzf
```

## Other Applications

### Bear
[Bear](https://bear.app/) is a beautiful, flexible writing app for crafting notes and prose. I love this application because it allows me to write in Markdown.

### Gifox
[Gifox](https://gifox.io/) is a delightful GIF recording and sharing app. It is great for quickly creating GIFs.

### Trello
[Trello](https://trello.com/) is simple and effective project management tool. I use Trello for organizing all my personal projects.

There you have it, a complete list of the tools and productivity modifications that I use. I am always looking for new ways to increase my effectiveness and will update this article with any new applications or utilities that I find.
