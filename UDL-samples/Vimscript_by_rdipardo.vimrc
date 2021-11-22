" Edited, with additions to demonstrate more highlighting features
" from https://github.com/fatih/vim-go-tutorial/blob/master/vimrc
"
" Copyright (c) 2016, Fatih Arslan All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
" * Redistributions of source code must retain the above copyright notice, this
"   list of conditions and the following disclaimer.
"
" * Redistributions in binary form must reproduce the above copyright notice,
"   this list of conditions and the following disclaimer in the documentation
"   and/or other materials provided with the distribution.
"
" * Neither the name of the copyright holder nor the names of its
"   contributors may be used to endorse or promote products derived from
"   this software without specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

plug#begin()
Plug 'fatih/vim-go'
Plug 'fatih/molokai'
call plug#end()

""""""""""""""""""""""
"      Settings      "
""""""""""""""""""""""
set nocompatible                " Enables us Vim specific features
filetype off                    " Reset filetype detection first ...
filetype plugin indent on       " ... and enable filetype detection
set laststatus=2                " Show status line always
set backspace=indent,eol,start  " Makes backspace key more powerful.
set number                      " Show line numbers
set hidden                      " Buffer should still exist if window is closed
set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats
set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not it begins with upper case
set completeopt=menu,menuone    " Show popup menu, even if there is one entry

" This enables us to undo files even if you exit Vim.
if has('persistent_undo') && empty(&undodir)
  set undofile
  set undodir='~/.config/vim/tmp/undo/'
endif

" Colorscheme
syntax enable
set t_Co=256
highlight Visual cterm=NONE ctermbg=76 ctermfg=16 gui=NONE guibg=#5fd700 guifg=#000000
highlight StatusLine cterm=NONE ctermbg=0xE7 ctermfg=0xa0 gui=NONE guibg=#ffffff guifg=#d70000
highlight Normal cterm=NONE ctermbg=0o21 gui=NONE guibg=#00005f
highlight NonText cterm=NONE ctermbg=0b00010001 gui=NONE guibg=#00005f
colorscheme molokai

""""""""""""""""""""""
"      Mappings      "
""""""""""""""""""""""
" Set leader shortcut to a comma ','. By default it's the backslash
let mapleader = ','
nmap <C-n> :cnext<CR>
nmap <C-m> :cprevious<Cr>
nnoremap <Leader>a :cclose<cr>

" Enter automatically into the files directory
autocmd BufEnter * silent! lcd %:p:h

"""""""""""""""""""""
"      Plugins      "
"""""""""""""""""""""
func! s:build_go_files() abort
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunc

" vim: syntax=vim
