set exrc
set guicursor=
set relativenumber
set number
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
"set shiftwidth=4
"set expandtab
set smartindent
set ignorecase
set nowrap
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set scrolloff=8
set signcolumn=yes
set encoding=UTF-8

set ttyfast
set lazyredraw

let mapleader = " "

nnoremap <Leader>sv :source $MYVIMRC<CR>

" themeing {{{

" wal-vim -> colorscheme wal: reading the colorscheme as generated by pywal
" nvim-base16 -> colorscheme base16-*: many base16 colorschemes
" lualine-nvim -> lualine: statusbar
" dashboard-nvim -> : nvim welcome screen

colorscheme base16-onedark
if (has("termguicolors"))
  set termguicolors
endif

lua << EOF
require('plenary.reload').reload_module('lualine', true)
require('lualine').setup({
  options = {
    theme = 'onedark',
    -- disabled_types = { 'NvimTree' },
  },
  sections = {
    lualine_x = {},
  },
})
EOF

lua require('colorizer').setup()
lua require('nvim-autopairs').setup()

let g:dashboard_default_executive = 'telescope'

lua << EOF
vim.api.nvim_exec([[let $KITTY_WINDOW_ID=0]], true)
require("bufferline").setup{
  highlights = {
    fill = {
      guibg = "#282828"
    },
    separator_selected = {
      guifg = "#282828"
    },
    separator_visible = {
      guifg = "#282828"
    },
    separator = {
      guifg = "#282828"
    }
  },
  options = {
    modified_icon = "●",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 25,
    max_prefix_length = 25,
    enforce_regular_tabs = false,
    view = "multiwindow",
    show_buffer_close_icons = true,
    show_close_icon = false,
    separator_style = "slant",
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,
    offsets = {
      {
        filetype = "coc-explorer",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "center"
      }
    }
  }
}
EOF

" }}}

" motions, vim remaps, misc {{{

" vim-sneak
" vim-commentary

let g:sneak#label = 1
let g:sneak#s_next = 1

call wilder#setup({'modes': [':', '/', '?']})

nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>

" Escape terminal mode
tnoremap <Esc> <C-\><C-n>

" resize current buffer by +/- 5 
nnoremap <M-Right> :vertical resize -5<cr>
nnoremap <M-Up> :resize +5<cr>
nnoremap <M-Down> :resize -5<cr>
nnoremap <M-Left> :vertical resize +5<cr>

" clear and redraw screen, de-highlight, fix syntax highlighting
nnoremap <leader>l :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

set listchars=tab:▸\ ,trail:·,precedes:←,extends:→,eol:↲,nbsp:␣
autocmd InsertEnter * set list
autocmd VimEnter,BufEnter,InsertLeave * set nolist
autocmd BufNewFile,BufRead *.md,*.mdx,*.markdown :set filetype=markdown

nnoremap <leader>cheat :Cheatsheet<cr>

lua require('gitsigns').setup({})

" }}}

" file navigation {{{

" harpoon
" telescope

" harpoon
nnoremap <leader>a :lua require("harpoon.mark").add_file()<CR>
nnoremap <leader>, :lua require("harpoon.ui").toggle_quick_menu()<CR>
nnoremap <leader>j :lua require("harpoon.ui").nav_file(1)<CR>
nnoremap <leader>k :lua require("harpoon.ui").nav_file(2)<CR>
nnoremap <leader>d :lua require("harpoon.ui").nav_file(3)<CR>
nnoremap <leader>f :lua require("harpoon.ui").nav_file(4)<CR>

" telescope
lua << EOF
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "yarn.lock" }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = false,
      override_file_sorter = true,
      case_mode = "smart_case"
    },
  },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      -- theme = "dropdown",
      -- previewer = false,
      mappings = {
        i = {
          ["<M-d>"] = "delete_buffer",
        }
      }
    }
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('file_browser')
EOF

nnoremap <leader>ps :lua require('telescope.builtin').grep_string( { search = vim.fn.input("Grep for > ") } )<cr>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <leader>ff :lua require('telescope.builtin').find_files{ hidden = true }<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fs <cmd>lua require('telescope').extensions.file_browser.file_browser( { path = vim.fn.expand('%:p:h') } )<CR>
nnoremap <Leader>fc :lua require('telescope.builtin').git_status{}<cr>
nnoremap <Leader>cb :lua require('telescope.builtin').git_branches{}<cr>
nnoremap <leader>fr :lua require('telescope.builtin').resume{}<CR>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep( { file_ignore_patterns = { '**/*.spec.js' } } )<cr>

" }}}

" lsp {{{

" nvim-lspconfig -> lspconfig: neovim's language server client configuration
" lspkind-nvim -> lspkind: pictograms displayed alongside types in completion menu
" nvim-cmp -> cmp: completion engine
" cmp-path -> 'path': filesystem path autocompletion
" cmp-buffer -> 'buffer': buffer words autocompletion
" cmp-nvim-lsp -> 'nvim_lsp': lsp provided autocompletion
" cmp-npm -> 'npm': npm autocompletion
" luasnip, cmp_luasnip -> 'luasnip': snippets as provided by luasnip
" trouble -> 

" Trigger linter on buffer write
" autocmd TextChanged * lua require('lint').try_lint()

lua << EOF
require('lspkind').init({})

-- luasnip setup
local luasnip = require('luasnip')

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')
local lspconfig_util = require('lspconfig/util')

local servers = { 'clangd', 'rust_analyzer', 'pyright' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup ({
    capabilities = capabilities,
  })
end

lspconfig.hls.setup({
  capabilities = capabilities,
  settings = {
    haskell = {
      hlintOn = true,
      formattingProvider = 'fourmolu',
    }
  }
})

lspconfig.tsserver.setup({
  capabilities = capabilities,
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
  end,
  root_dir = lspconfig_util.root_pattern('.git', 'tsconfig.json', 'jsconfig.json'),
})
EOF

lua << EOF

local null_ls = require("null-ls")

null_ls.setup({
  debug = true,
  sources = {
    -- python
    null_ls.builtins.formatting.autopep8,
    null_ls.builtins.diagnostics.flake8,

    -- rust
    null_ls.builtins.formatting.rustfmt,

    -- javascript typescript
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.code_actions.eslint_d,

    -- lua
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.luacheck,

    -- C/C++
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.diagnostics.cppcheck,

    -- writing
    -- null_ls.builtins.diagnostics.markdownlint,
    -- null_ls.builtins.diagnostics.proselint,
    -- null_ls.builtins.code_actions.proselint,
    -- null_ls.builtins.formatting.codespell,
    -- null_ls.builtins.diagnostics.misspell,
    -- null_ls.builtins.hover.dictionary,
    -- null_ls.builtins.completion.spell,

    -- misc
    null_ls.builtins.code_actions.gitsigns,
  },

  -- you can reuse a shared lspconfig on_attach callback here
  on_attach = function(client)
      if client.resolved_capabilities.document_formatting then
          vim.cmd([[
          augroup LspFormatting
              autocmd! * <buffer>
              autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
          augroup END
          ]])
      end
  end,
})

EOF

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gh    <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gca   <cmd>:Telescope lsp_code_actions<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gR    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent><leader>fo <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent><leader>fr <cmd>lua vim.lsp.buf.range_formatting()<CR>

" trouble
lua << EOF
require 'trouble'.setup {}
EOF
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
"nnoremap gR <cmd>TroubleToggle lsp_references<cr>

" }}}

" nvim-treesitter {{{

" nvim-treesitter -> nvim-treesitter: 

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
  },
}
EOF
" }}}
