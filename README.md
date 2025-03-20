# maud-fmt.nvim

A Neovim plugin for formatting [Maud](https://maud.lambda.xyz/) HTML templates in Rust.

## Features

- Automatically formats Maud HTML templates
- Properly indents nested elements, attributes, and content
- Handles Maud-specific syntax like `@match`, `@if`, etc.
- Correctly indents text content expressions like `(variable_name)`
- Works with any Rust file containing Maud templates

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "eboody/maud-fmt.nvim",
  config = function()
    require("maud-fmt").setup()
  end,
  ft = "rust",  -- Only load for Rust files
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "eboody/maud-fmt.nvim",
  config = function()
    require("maud-fmt").setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'eboody/maud-fmt.nvim'

" In your init.vim/init.lua after plug#end():
lua require('maud-fmt').setup()
```

## Usage

After installation, you can format Maud HTML templates in Rust files using:

- Command: `:MaudFormat`
- Default keybinding: `<leader>mf` (in normal mode)

### Example

Before formatting:

```rust
impl Render for Button<'_> {
    fn render(&self) -> Markup {
        html! {
        @match self {
        Button::Primary {
        href, text
        } => {
        button.primary href=[href] download=(text) type="submit" {
        (text)
        }
        },
        Button::Secondary {
        href, text
        } => {
        button.secondary href=[href] download=(text) {
        (text)
        }
        }
        }
        (css())
        }
    }
}
```

After formatting:

```rust
impl Render for Button<'_> {
    fn render(&self) -> Markup {
        html! {
          @match self {
            Button::Primary {
              href, text
            } => {
              button.primary href=[href] download=(text) type="submit" {
                (text)
              }
            },
            Button::Secondary {
              href, text
            } => {
              button.secondary href=[href] download=(text) {
                (text)
              }
            }
          }
          (css())
        }
    }
}
```

## Configuration

You can customize the formatter with the following options:

```lua
require('maud-fmt').setup({
  indent_size = 2,  -- Default indentation size (spaces)
  keymaps = {
    format = '<leader>mf',  -- Keymap to format the current buffer
  },
})
```

## How It Works

The formatter:

1. Identifies `html!` blocks in your Rust code
2. Analyzes the structure of your Maud HTML markup
3. Applies consistent indentation with proper nesting
4. Handles Maud-specific syntax like class selectors (`.content`), ID selectors (`#main`), and tag elements
5. Properly formats control structures like `@match`, `@if`, etc.
6. Adds extra indentation for text content expressions

## Additional Tips

Checkout maud-extensions for easily working with js and css in maud templates: [maud-extensions](eboody/maud-extensions)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
