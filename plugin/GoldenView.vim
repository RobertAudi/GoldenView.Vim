" =============== ============================================================
" Name:           GoldenView
" Description:    Golden view for vim split windows
" Author:         Zhao Cai <caizhaoff@gmail.com>
" Homepage:       https://github.com/RobertAudi/GoldenView.vim
" Date Created:   Tue 18 Sep 2012 10:25:23 AM EDT
" Last Modified:  Sat 29 Sep 2012 01:23:02 AM EDT
" Copyright:      © 2012 by Zhao Cai,
"                 Released under current GPL license.
" =============== ============================================================

" ============================================================================
" Load Guard:
" ============================================================================
if exists('g:loaded_GoldenView') || &cp || v:version < 704
  finish
endif
let g:loaded_GoldenView = 1

let s:save_cpo = &cpo
set cpo&vim

" ============================================================================
" Configuration:
" ============================================================================

if !exists('g:goldenview__enable_at_startup')
  let g:goldenview__enable_at_startup = v:true
endif

if !exists('g:goldenview__active_profile')
  let g:goldenview__active_profile = 'default'
endif

if !exists('g:goldenview__reset_profile')
  let g:goldenview__reset_profile = 'reset'
endif

if !exists('g:goldenview__ignore_urule')
  let g:goldenview__ignore_urule =
        \ {
        \   'filetype': [
        \     '', 'qf', 'vimpager', 'undotree', 'tagbar',
        \     'nerdtree', 'vimshell', 'vimfiler', 'voom',
        \     'tabman', 'denite', 'denite-filter', 'unite',
        \     'quickrun', 'Decho', 'ControlP', 'diff', 'extradite'
        \   ],
        \   'buftype': [
        \     'nofile',
        \   ],
        \   'bufname': [
        \     'GoToFile', 'diffpanel_\d\+',
        \     '__Gundo_Preview__', '__Gundo__',
        \     '\[LustyExplorer-Buffers\]', '\-MiniBufExplorer\-',
        \     '_VOOM\d\+$', '__Urannotate_\d\+__',
        \     '__MRU_Files__', 'FencView_\d\+$'
        \   ],
        \ }
endif

if !exists('g:goldenview__restore_urule')
  let g:goldenview__restore_urule =
        \ {
        \   'g:goldenview__restore_urule': {
        \     'filetype': [
        \       'nerdtree', 'vimfiler',
        \     ],
        \     'bufname': [
        \       '__MRU_Files__',
        \     ],
        \   },
        \ }
endif

" ============================================================================
" Public Interface:
" ============================================================================

" Auto Resize:
" ------------
command! -nargs=0 ToggleGoldenViewAutoResize call GoldenView#ToggleAutoResize()

command! -nargs=0 DisableGoldenViewAutoResize call GoldenView#DisableAutoResize()

command! -nargs=0 EnableGoldenViewAutoResize call GoldenView#EnableAutoResize()

nnoremap <Plug>ToggleGoldenViewAutoResize :<C-U>ToggleGoldenViewAutoResize<CR>

" Manual Resize:
" --------------
command! -nargs=0 GoldenViewResize call GoldenView#EnableAutoResize() | call GoldenView#DisableAutoResize()

nnoremap <Plug>GoldenViewResize :<C-U>GoldenViewResize<CR>

" Layout Split:
" -------------
nnoremap <Plug>GoldenViewSplit :<C-u>call GoldenView#Split()<CR>
" [TODO]( define comfortable width &tw * 4/3) @zhaocai @start(2012-09-29 01:17)

" ============================================================================
" Initialization:
" ============================================================================
if g:goldenview__enable_at_startup == 1
  autocmd VimEnter * call GoldenView#EnableAutoResize()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
