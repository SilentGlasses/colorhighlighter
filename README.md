# ColorHighlighter.vim

**ColorHighlighter** is a lightweight Vim plugin that highlights color values like hex codes, `rgb()`, `rgba()`, `hsl()`, and `hsla()` directly inside your buffers.

When editing CSS, HTML, YAML, JSON, or any file containing color values, ColorHighlighter shows the actual color as background in-place, making it easier to work with styles, themes, or frontend design.

## ✨ Features

- Highlights:
  - `#RRGGBB`, `#RGB` hex codes
  - `rgb(r, g, b)` and `rgba(r, g, b, a)`
  - `hsl(h, s%, l%)` and `hsla(h, s%, l%, a)`
- Supports `CSS`, `SCSS`, `HTML`, `JSON`, `YAML`, `JS`, `TS`, `JSX`, `TSX`, and more
- Extremely minimal and fast (pure Vimscript, no external dependencies)
- Automatic updates on file open or edit

## 📦 Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'silentglasses/colorhighlighter.vim'
```

## Configuration

No configuration required!

However, make sure your Vim settings include:

```
set termguicolors
```

This enables true color support needed for proper rendering.

## 🛠 Supported Filetypes

- `.css`
- `.scss`
- `.html`
- `.json`
- `.yaml`, `.yml`
- `.js`, `.ts`
- `.jsx`, `.tsx`

You can easily extend filetype matching inside the plugin if needed.

## 🔥 Example

Editing a CSS file like:

```
div {
  color: #ff00ff;
  background: rgb(200, 50, 90);
  border: 1px solid hsl(180, 70%, 60%);
}
```

ColorHighlighter will highlight the color codes directly with their corresponding color backgrounds.

## 📖 License

MIT License

## 📢 Notes

- ColorHighlighter uses Vim's matchaddpos() and highlight to render inline colors.
- For best results, use a GUI Vim (Neovim, MacVim, gVim, etc.) or a terminal that supports true colors.

Enjoy better color editing with ColorHighlighter! 🎨


