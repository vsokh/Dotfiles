-- ============================================================================
-- Neovim config: focused, AI-free, treesitter-driven syntax highlighting
-- Theme matches Windows Terminal (Catppuccin Mocha) for visual coherence
-- ============================================================================

-- ===== leader (set BEFORE lazy.nvim loads) =====
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ===== options =====
local o = vim.opt
o.number = true
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.expandtab = true
o.smartindent = true
o.autoindent = true
o.wrap = true
o.linebreak = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.scrolloff = 7
o.sidescrolloff = 8
o.signcolumn = 'yes'
o.colorcolumn = '80'
o.cursorline = true
o.termguicolors = true
o.background = 'dark'
o.list = true
o.listchars = { tab = '| ', trail = '~', extends = '>', precedes = '<' }
o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.completeopt = { 'menu', 'menuone', 'noselect' }
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.timeoutlen = 400
o.showmode = false  -- lualine shows it
o.laststatus = 3    -- one global statusline
o.fillchars = { eob = ' ' }

-- ===== keymaps (your vim muscle memory, ported) =====
local map = vim.keymap.set
local opts = { silent = true }

-- saving / search clear
map('n', '<leader>w', ':w!<cr>', opts)
map('n', '<leader><cr>', ':noh<cr>', opts)
map('n', '<Esc>', ':noh<cr><Esc>', opts)

-- window navigation (matches your <C-h/j/k/l>)
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- buffer navigation (matches your <leader>l / <leader>h)
map('n', '<leader>l', ':bnext<cr>', opts)
map('n', '<leader>h', ':bprevious<cr>', opts)
map('n', '<leader>bd', ':bdelete<cr>', opts)
map('n', '<leader>ba', ':%bd|e#<cr>', opts)

-- line number behaviour: 0 jumps to first non-blank
map('n', '0', '^', opts)

-- system clipboard (your <leader>y / <leader>p)
map('v', '<leader>y', '"+y', opts)
map('n', '<leader>p', '"+p', opts)

-- move lines up/down with Alt-j/k (your nmap <M-j>/<M-k>)
map('n', '<M-j>', ':m .+1<cr>==', opts)
map('n', '<M-k>', ':m .-2<cr>==', opts)
map('v', '<M-j>', ":m '>+1<cr>gv=gv", opts)
map('v', '<M-k>', ":m '<-2<cr>gv=gv", opts)

-- toggle paste / spell
map('n', '<leader>pp', ':setlocal paste!<cr>', opts)
map('n', '<leader>ss', ':setlocal spell!<cr>', opts)

-- strip trailing whitespace on save (your CleanExtraSpaces)
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.cpp', '*.hpp', '*.c', '*.h', '*.lua', '*.py', '*.sh', '*.md', '*.txt' },
    callback = function()
        local save = vim.fn.winsaveview()
        vim.cmd([[silent! %s/\s\+$//e]])
        vim.fn.winrestview(save)
    end,
})

-- return to last edit position (your au BufReadPost)
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ===== LSP =====
-- Reference tool only: go-to-definition, hover docs, references.
-- No autocomplete engine installed -> no popups while you type.
-- Use <C-x><C-o> manually if you ever want omnicompletion.

vim.lsp.config('clangd', {
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=never' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
})

vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    settings = {
        ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            check = { command = 'clippy' },
        },
    },
})

-- npm globals are shimmed as `<name>.cmd` on Windows; the bare name works elsewhere.
local exe_suffix = (vim.fn.has('win32') == 1) and '.cmd' or ''
vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server' .. exe_suffix, '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

vim.lsp.enable({ 'clangd', 'rust_analyzer', 'ts_ls' })

-- LSP keymaps: only set when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition,      opts)  -- jump to definition
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,     opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references,      opts)  -- find references
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,  opts)
        vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'K',  vim.lsp.buf.hover,           opts)  -- hover docs
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,  opts)
        vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
        vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count =  1 }) end, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

-- subtle diagnostic visuals
vim.diagnostic.config({
    virtual_text = { prefix = '▎', spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- ===== lazy.nvim bootstrap =====
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ===== plugins =====
require('lazy').setup({
    -- visuals: Catppuccin Mocha to match your terminal
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            require('catppuccin').setup({
                flavour = 'mocha',
                transparent_background = false,
                integrations = {
                    treesitter = true,
                    fzf = true,
                    gitsigns = true,
                    indent_blankline = { enabled = true },
                },
            })
            vim.cmd.colorscheme('catppuccin')
        end,
    },

    -- icons (used by lualine + others; needs your Nerd Font, which you have)
    { 'nvim-tree/nvim-web-devicons', lazy = true },

    -- statusline
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'catppuccin-mocha',
                    icons_enabled = true,
                    section_separators = '',
                    component_separators = '|',
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' },
                },
            })
        end,
    },

    -- subtle indent guides
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = { indent = { char = '│' }, scope = { enabled = false } },
    },

    -- THE headline upgrade: real syntax highlighting via tree-sitter parsers
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',  -- legacy stable; 'main' is the WIP rewrite
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'c', 'cpp', 'cmake', 'make',
                    'lua', 'vim', 'vimdoc',
                    'powershell', 'bash',
                    'json', 'jsonc', 'yaml', 'toml',
                    'markdown', 'markdown_inline',
                    'python', 'rust',
                    'javascript', 'typescript', 'tsx', 'html', 'css',
                    'gitcommit', 'diff',
                },
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
            })
        end,
    },

    -- fzf: matches your <leader>f / <leader>g / <leader>bf bindings
    { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
    {
        'junegunn/fzf.vim',
        dependencies = { 'junegunn/fzf' },
        keys = {
            { '<leader>f',  ':Files<cr>',   silent = true, desc = 'Files' },
            { '<leader>g',  ':Rg<cr>',      silent = true, desc = 'Grep' },
            { '<leader>bf', ':Buffers<cr>', silent = true, desc = 'Buffers' },
            { '<leader>bl', ':BLines<cr>',  silent = true, desc = 'Buffer lines' },
            { '<leader>c',  ':Commits<cr>', silent = true, desc = 'Commits' },
            { '<leader>bc', ':BCommits<cr>',silent = true, desc = 'Buffer commits' },
        },
    },

    -- the keepers from your old vimrc
    { 'tpope/vim-fugitive', cmd = { 'G', 'Git', 'Gdiff', 'Gblame', 'Glog', 'Gstatus' } },
    { 'tpope/vim-commentary' },
    { 'lewis6991/gitsigns.nvim', opts = {} },
}, {
    ui = { border = 'rounded' },
    change_detection = { notify = false },
})
