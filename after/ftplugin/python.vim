" Taken from 
" https://github.com/idbrii/vim-david/blob/main/compiler/python.vim

let s:cpo_save = &cpo
set cpo-=C

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=python\ -u\ %

" Use each file and line of Tracebacks (to see and step through the code executing).
CompilerSet errorformat=%A%\\s%#File\ \"%f\"\\,\ line\ %l\\,\ in%.%#
" Include failed toplevel doctest example.
CompilerSet errorformat+=%+CFailed\ example:%.%#
" Ignore big star lines from doctests.
CompilerSet errorformat+=%-G*%\\{70%\\}
" Ignore most of doctest summary. x2
CompilerSet errorformat+=%-G%*\\d\ items\ had\ failures:
CompilerSet errorformat+=%-G%*\\s%*\\d\ of%*\\s%*\\d\ in%.%#

" SyntaxErrors (%p is for the pointer to the error column).
" Source: http://www.vim.org/scripts/script.php?script_id=477
CompilerSet errorformat+=%E\ \ File\ \"%f\"\\\,\ line\ %l
" %p must come before other lines that might match leading whitespace
CompilerSet errorformat+=%-C%p^
CompilerSet errorformat+=%+C\ \ %m
CompilerSet errorformat+=%Z\ \ %m

let &cpo = s:cpo_save
unlet s:cpo_save
