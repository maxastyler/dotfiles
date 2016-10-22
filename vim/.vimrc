" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
if has('syntax') && has('eval')
  packadd matchit
endif

""""""""""""""""""""""""""""
"Backups and undos
"If using these, recommended to set up a job that clears these folders of
"files older than a certain time (eg, find ~/.vim/backup-dir -type f -mtime
"+90 -delete)
"
if !isdirectory($HOME."/.vim")
	call mkdir($HOME."/.vim", "", 0770)
endif
if !isdirectory($HOME."/.vim/backup-dir")
	call mkdir($HOME."/.vim/backup-dir", "", 0700)
endif
if !isdirectory($HOME."/.vim/undo-dir")
	call mkdir($HOME."/.vim/undo-dir", "", 0700)
endif
set backupdir=~/.vim/backup-dir,.
set undodir=~/.vim/undo-dir,.
set backup
set undofile


""""""""""
"Use pathogen
"""""""""
execute pathogen#infect()

filetype plugin indent on
syntax on

"""""""""""
"Set the statusbar to be visible, and use airline fonts if installed
""""""""""
set laststatus=2
let g:airline_powerline_fonts = 1

"Give ability to write to a protected file with w!! if you haven't started in
"sudo mode
cmap w!! w !sudo tee > /dev/null %
