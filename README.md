# CodeBox.nvim

This is a simple neovim plugin that helps keeping blocks of code and reusing them as needed.

## Installation

Packer:
```
use({
    'FabrizioPerria/CodeBox.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
    }
})

```

N.B.: Remember to call `require('codebox').setup({})`.

## Usage

### Store a snippet

Enter visual mode and select the snippet you wish to store. 
Then, run `:CodeBox` command; it will prompt for a snippet title so you can easily retrieve it later.

### Retrieve a snippet
Run `:CodeUnbox`; you will get a telescope window asking to select the snippet. Pressing `Enter` will write the snippet in the line next to the cursor.
Pressing `<C-d>(insert mode) / d(normal mode)` will delete the snippet.

### Advanced
I suggest to map those commands with keys; using whick_key you can map to something like:
```
...
["c"]
{
    ['B'] = { ':CodeBox<CR>', 'Store code snippet', mode = { 'x' } },
    ['b'] = { ':CodeUnbox<CR>', 'Restore code snippet', mode = { 'n' } },
}
...
```
## Notes

This is my first plugin :) i know it's not optimized, but it does what i need it to do. Feel free to file issues and send suggestions if you
want.
