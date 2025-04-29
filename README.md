# ColorHighlighter

<img align="left" height="100" src="https://github.com/user-attachments/assets/28316820-de2a-4b2c-9fb9-218ee75fd4df" alt="ColorHighlighter Logo" />

A Vim plugin that highlights color codes with their actual colors in your code. Supports various color formats including HEX, RGB, RGBA, HSL, HSLA, and named colors.

*Actively maintained - Last update: April 2025*

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Supported Color Formats](#supported-color-formats)
- [Performance Considerations](#performance-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

- Highlights color codes in your actual colors
- Supports multiple color formats:
  - HEX colors: `#RGB`, `#RRGGBB`, `#RGBA`, `#RRGGBBAA`
  - RGB/RGBA colors: `rgb(255, 0, 0)`, `rgba(255, 0, 0, 0.5)`
  - HSL/HSLA colors: `hsl(0, 100%, 50%)`, `hsla(0, 100%, 50%, 0.5)`
  - Named colors: `red`, `green`, `blue`, etc.
- Auto-enables for supported file types
- Automatic contrast adjustment for text (white or black based on background color)
- Works in various syntax contexts (CSS, HTML, JavaScript, etc.)
- Real-time updates as you type with performance-optimized debouncing
- Lightweight with minimal performance impact
- Cross-platform compatible (works on Linux, macOS, Windows)

## Requirements

- Vim 9.1+ or Neovim 0.8+
- `termguicolors` support for terminal Vim (for best results)

## Installation

### Using Plugin Managers

#### [vim-plug](https://github.com/junegunn/vim-plug)

Add the following to your vimrc:

```vim
Plug 'SilentGlasses/colorhighlighter'
```

Then run `:PlugInstall`

#### [Vundle](https://github.com/VundleVim/Vundle.vim)

Add the following to your vimrc:

```vim
Plugin 'SilentGlasses/colorhighlighter'
```

Then run `:PluginInstall`

#### [packer.nvim](https://github.com/wbthomason/packer.nvim) (for Neovim)

```lua
use 'SilentGlasses/colorhighlighter'
```

### Manual Installation

Clone the repository directly to your Vim plugin directory:

- For Vim
```bash
git clone https://github.com/SilentGlasses/colorhighlighter.git ~/.vim/pack/plugins/start/colorhighlighter
```
- For Neovim
```bash
git clone https://github.com/SilentGlasses/colorhighlighter.git ~/.local/share/nvim/site/pack/plugins/start/colorhighlighter
```

## Quick Start

1. After installation, the plugin will automatically activate for supported file types
2. Open a CSS, HTML, or JavaScript file containing color codes
3. Colors will be automatically highlighted in the background
4. Use `:ColorHighlightToggle` to turn highlighting on/off
5. Use `:ColorHighlightList` to see all detected colors

For true color support in terminal Vim, add to your vimrc:

```vim
if has('termguicolors')
  set termguicolors
endif
```

## Usage

The plugin automatically activates for supported file types. Colors in your code will be highlighted with their actual colors as background.

### Commands

- `:ColorHighlight` - Enable color highlighting in current buffer
- `:ColorHighlightToggle` - Toggle color highlighting in current buffer
- `:ColorHighlightEnable` - Enable color highlighting (same as `:ColorHighlight`)
- `:ColorHighlightDisable` - Disable color highlighting in current buffer
- `:ColorHighlightList` - List all colors found in current buffer
- `:ColorHighlightClean` - Clean up all highlighting

## Configuration

### Default Settings

```vim
" Highlight group prefix
let g:colorhighlighter_hl_prefix = 'ColorHL_'

" Supported filetypes (auto-enables for these)
let g:colorhighlighter_filetypes = [
      \ 'css', 'scss', 'sass', 'less', 'stylus', 
      \ 'html', 'javascript', 'typescript', 
      \ 'jsx', 'tsx', 'json', 'yaml'
      \ ] 

" Excluded filetypes
let g:colorhighlighter_excluded_filetypes = []

" Named colors mapping
let g:colorhighlighter_named_colors = {
      \ 'black': '#000000',
      \ 'white': '#ffffff',
      \ 'red': '#ff0000',
      \ 'green': '#008000',
      \ 'blue': '#0000ff',
      \ 'yellow': '#ffff00',
      \ 'orange': '#ffa500',
      \ 'purple': '#800080',
      \ 'pink': '#ffc0cb',
      \ 'gray': '#808080',
      \ 'grey': '#808080'
      \ }

" Enable plugin by default
let g:colorhighlighter_enable = 1

" Debounce delay for real-time updates (milliseconds)
let g:colorhighlighter_update_delay = 500
```
### Customizing Named Colors

You can add your own named colors or override defaults:

```vim
" Add custom named colors
let g:colorhighlighter_named_colors = {
      \ 'primary': '#4285f4',
      \ 'secondary': '#34a853',
      \ 'danger': '#ea4335',
      \ 'warning': '#fbbc05',
      \ 'black': '#000000',
      \ 'white': '#ffffff',
      \ }
```

### Excluding File Types

To prevent ColorHighlighter from activating on certain file types:

```vim
let g:colorhighlighter_excluded_filetypes = ['markdown', 'text', 'help']
```

### Real-time Update Settings

The plugin updates color highlighting as you type. You can adjust how responsive these updates are:

```vim
" Set update delay in milliseconds (higher values improve performance)
let g:colorhighlighter_update_delay = 1000  " 1 second delay
```

The default delay is 500ms, which provides a good balance between responsiveness and performance. 
For slower machines, you might want to increase this value.

## Supported Color Formats

### HEX Colors

- 3-digit: `#RGB` (e.g., `#f00`)
- 6-digit: `#RRGGBB` (e.g., `#ff0000`)
- 8-digit: `#RRGGBBAA` (e.g., `#ff0000ff`)

### RGB Colors

- RGB: `rgb(r, g, b)` (e.g., `rgb(255, 0, 0)`)
- RGBA: `rgba(r, g, b, a)` (e.g., `rgba(255, 0, 0, 0.5)`)

### HSL Colors

- HSL: `hsl(h, s%, l%)` (e.g., `hsl(0, 100%, 50%)`)
- HSLA: `hsla(h, s%, l%, a)` (e.g., `hsla(0, 100%, 50%, 0.5)`)

### Named Colors

Standard named colors like `red`, `green`, `blue`, etc. You can extend this with custom colors by modifying `g:colorhighlighter_named_colors`.

## Performance Considerations

- The plugin is designed to have minimal performance impact
- Real-time updates use debouncing to avoid processing during rapid typing
- The update delay (500ms by default) can be increased for better performance
- For very large files, you may want to disable auto-highlighting
- If you experience performance issues, try:
  - Increasing `g:colorhighlighter_update_delay` to 1000 or higher
  - Disabling the plugin for specific file types
  - Using manual updates with `:ColorHighlight` instead of auto-updates

## Troubleshooting

### Colors not showing in terminal Vim

Make sure your terminal and Vim support true colors. Add this to your vimrc:

```vim
if has('termguicolors')
  set termguicolors
endif
```

### Conflicts with other plugins

If you're experiencing conflicts with other syntax highlighting plugins, try loading ColorHighlighter last in your plugin list.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Real-time Usage Example

The plugin automatically highlights colors as you type:

1. Create a new CSS file: `vim new-styles.css`
2. Start typing: `body { background-color: #ff0000; }`
3. As soon as you finish typing `#ff0000`, it will be highlighted in red
4. Try other formats: `rgb(0, 255, 0)` or `hsl(240, 100%, 50%)`

This makes it much easier to visualize colors while coding without needing to save or manually refresh.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
