""""""""""""""""""""""""""""""""" .vimrc """"""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""" Basic """""""""""""""""""""""""""""""""""""""
set nocompatible
syntax enable
filetype plugin on
filetype plugin indent on

set path+=**
set wildignore+=**/build/**,**/*Debug*/**
set wildmenu
set guioptions=
set guicursor=
set guifont=Noto_Mono_for_Powerline:h12:cANSI:qDRAFT
set backspace=indent,eol,start  " more powerful backspacing
set noshowmatch
set relativenumber
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set autoread
set scrolloff=5
" Give more space for displaying messages.
set cmdheight=2

" Open new splits to right and bottom
set splitbelow
set splitright

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

set colorcolumn=81
"""""""""""""""""""""""""""""""""""" Basic """"""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""" Plugins """""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugin')

Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'phanviet/vim-monokai-pro'
Plug 'flazz/vim-colorschemes'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'
Plug 'rakr/vim-one'
Plug 'Lokaltog/powerline'
" Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'neoclide/coc.nvim'
Plug 'sheerun/vim-polyglot'
Plug 'mbbill/undotree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'wincent/ferret'

call plug#end()
""""""""""""""""""""""""""""""""""" Plugins """""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""" OS Check """"""""""""""""""""""""""""""""""
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif
""""""""""""""""""""""""""""""""""" OS Check """"""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""" Basic Map """"""""""""""""""""""""""""""""""
" Maping leader key
let mapleader = ","

" Easy split navigation
map <C-j> <C-w>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Disable arrow keys in Escape mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

nnoremap <leader>u :UndotreeShow<CR>

let g:python_highlight_all = 1
"""""""""""""""""""""""""""""""""" Basic Map """"""""""""""""""""""""""""""""""

"""""""""""""""""""""""""" Start of AirLine Settings """"""""""""""""""""""""""
let g:airline_theme='deus'
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#formatter = 'unique_tail'
""""""""""""""""""""""""""" End of AirLine Settings """""""""""""""""""""""""""

"""""""""""""""""""""""""" Start Powerline Settings """""""""""""""""""""""""""
set guifont=Source\ Code\ Pro\ for\ Powerline:h12:cANSI
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
" set t_Co=256
" set fillchars+=stl:\ ,stlnc:\
" if has("gui_running")
"     if g:os == "Windows"
"         set term=Cmder
"     endif
" endif
set termencoding=utf-8
""""""""""""""""""""""""" End of PowerLine Settings """""""""""""""""""""""""""

""""""""""""""""""""""""" Start of Air-Line Symnols """""""""""""""""""""""""""
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
"""""""""""""""""""""""""" End of Air-Line Symnols """"""""""""""""""""""""""""

"""""""""""""""""""""""""""" FZF Config Start """""""""""""""""""""""""""""""""
augroup fzf
  autocmd!
augroup END

" Key mapping

" History of file opened
nnoremap <leader>h :History<cr>

" Buffers opens
nnoremap <leader>b :Buffers<cr>

" Files recursively from pwd
" Everything except gitignore files
nnoremap <leader>f :GFiles --cached --others --exclude-standard<cr>
nnoremap <leader>F :Files<cr>

" Ex commands
nnoremap <leader>c :Commands<cr>
" Ex command history. <C-e> to modify the command
nnoremap <leader>: :History:<cr>

nnoremap <leader>a :Rgi<space>
nnoremap <leader>A :exec "Rgi ".expand("<cword>")<cr>

"" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)

" ripgrep command to search in multiple files
autocmd fzf VimEnter * command! -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...)
autocmd fzf VimEnter * command! -nargs=* Rgi
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case
autocmd fzf VimEnter * command! -nargs=* Rgic
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case
autocmd fzf VimEnter * command! -nargs=* Rgir
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case and activate regex search
autocmd fzf VimEnter * command! -nargs=* Rgr
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --hidden --no-ignore --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-h': 'split',
  \ 'ctrl-v': 'vsplit'
  \ }

nmap <leader><tab> <plug>(fzf-maps-n)
""""""""""""""""""""""""""""" FZF Config End """"""""""""""""""""""""""""""""""

""""""""""""""""""""""""""" Start of Color Scheme """""""""""""""""""""""""""""
"colorscheme one
colorscheme molokai              " set color scheme
"colorscheme skittles_berry       " set color scheme
"colorscheme sonokai             " set color scheme
"set background=dark
"""""""""""""""""""""""""""" End of Color Scheme """"""""""""""""""""""""""""""

""""""""""""""""""""""""""""" Coc Config Start """"""""""""""""""""""""""""""""
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

let g:coc_global_extensions = [
            \'coc-todolist',
            \'coc-tag',
            \'coc-syntax',
            \'coc-marketplace',
            \'coc-lists',
            \'coc-highlight',
            \'coc-git',
            \'coc-explorer',
            \'coc-dictionary',
            \'coc-calc',
            \'coc-python',
            \'coc-json',
            \'coc-gocode',
            \'coc-cmake',
            \'coc-tasks'
            \]
""""""""""""""""""""""""""""" Coc Config End """"""""""""""""""""""""""""""""""

highlight ColorColumn ctermbg=74 guibg=#5fafd7

" Function for triming white spaces
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd GUIEnter * simalt ~x

autocmd BufWritePre * :call TrimWhitespace()

""""""""""""""""""""""""""""""""".vimrc """""""""""""""""""""""""""""""""""""""
