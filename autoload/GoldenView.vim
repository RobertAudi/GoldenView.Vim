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
" Initialization And Profile:
" ============================================================================
let s:golden_ratio_dot = str2float("1.618")
let s:golden_ratio_comma = str2float("1,618")
if s:golden_ratio_dot > s:golden_ratio_comma
  let s:golden_ratio = s:golden_ratio_dot
else
  let s:golden_ratio = s:golden_ratio_comma
endif
lockvar s:golden_ratio

let s:goldenview__profile = {
      \   'reset': {
      \     'focus_window_winheight': &winheight,
      \     'focus_window_winwidth':  &winwidth,
      \     'other_window_winheight': &winminheight,
      \     'other_window_winwidth':  &winminwidth,
      \   },
      \   'default': {
      \     'focus_window_winheight': function('GoldenView#GoldenHeight'),
      \     'focus_window_winwidth':  function('GoldenView#TextWidth'),
      \     'other_window_winheight': function('GoldenView#GoldenMinHeight'),
      \     'other_window_winwidth':  function('GoldenView#GoldenMinWidth'),
      \   },
      \ }

function! GoldenView#ExtendProfile(name, def) abort
  let l:default = get(s:goldenview__profile, a:name,
        \ copy(s:goldenview__profile['default']))

  let s:goldenview__profile[a:name] = extend(l:default, a:def)
endfunction

function! GoldenView#Init() abort
  if get(g:, 'goldenview__initialized', v:false) == v:true
    return
  endif

  set equalalways
  set eadirection=ver

  call GoldenView#ExtendProfile('golden-ratio', {
        \   'focus_window_winwidth': function('GoldenView#GoldenWidth'),
        \ })

  let s:goldenview__ignore_nrule = GoldenView#zl#rule#norm(
        \   g:goldenview__ignore_urule, {
        \     'logic': 'or',
        \   }
        \ )

  let s:goldenview__restore_nrule = GoldenView#zl#rule#norm(
        \   g:goldenview__restore_urule, {
        \     'logic': 'or',
        \   }
        \ )

  let g:goldenview__initialized = v:true
endfunction

" ============================================================================
" Auto Resize:
" ============================================================================
function! GoldenView#ToggleAutoResize() abort
  if get(s:, 'goldenview__auto_resize', v:false)
    call GoldenView#DisableAutoResize()
    call s:print_moremsg('GoldenView Auto Resize: Off')
  else
    call GoldenView#EnableAutoResize()
    call s:print_moremsg('GoldenView Auto Resize: On')
  endif
endfunction

function! GoldenView#EnableAutoResize() abort
  call GoldenView#Init()

  let l:active_profile = s:goldenview__profile[g:goldenview__active_profile]
  call s:set_focus_window(l:active_profile)
  call s:set_other_window(l:active_profile)

  augroup GoldenView
    autocmd!
    " Enter
    autocmd VimResized  * call GoldenView#Enter({ 'event': 'VimResized' })
    autocmd BufWinEnter * call GoldenView#Enter({ 'event': 'BufWinEnter' })
    autocmd WinEnter    * call GoldenView#Enter({ 'event': 'WinEnter' })

    " Leave
    autocmd WinLeave    * call GoldenView#Leave()
  augroup END

  let s:goldenview__auto_resize = v:true
endfunction

function! GoldenView#DisableAutoResize() abort
  autocmd! GoldenView

  call GoldenView#ResetResize()

  let s:goldenview__auto_resize = v:false
endfunction

function! GoldenView#Leave(...) abort
  " Do nothing if there is no split window
  " --------------------------------------
  if winnr('$') < 2
    return
  endif

  call GoldenView#Diff()

  if GoldenView#IsIgnore()
    " Record the last size of ignored windows. Restore there sizes if affected
    " by GoldenView.

    " For new split, the size does not count, which is highly possible
    " to be resized later. Should use the size with WinLeave event.
    "
    call s:initialize_tab_variable()

    let t:goldenview['bufs'][bufnr('%')] = {
          \   'winnr':     winnr(),
          \   'winwidth':  winwidth(0),
          \   'winheight': winheight(0),
          \ }

    let t:goldenview['cmdheight'] = &cmdheight
  end
endfunction

function! GoldenView#Diff() abort
  " Diff Mode: auto-resize to equal size
  if !exists('b:goldenview_diff')
    let b:goldenview_diff = v:false
  endif

  if &diff
    if !b:goldenview_diff
      let l:buflist = s:tabpagebuflist()

      for l:nr in l:buflist
        if getbufvar(l:nr, '&diff')
          call setbufvar(l:nr, 'goldenview_diff', v:true)
        endif
      endfor

      execute 'wincmd ='
    endif

    return v:true
  else
    if b:goldenview_diff
      let b:goldenview_diff = v:false
    endif
  endif

  return v:false
endfunction

function! GoldenView#Enter(...) abort
  if exists("g:SessionLoad") && g:SessionLoad
    return
  endif

  if GoldenView#Diff()
    return
  endif

  return call('GoldenView#Resize', a:000)
endfunction

function! GoldenView#Resize(...) abort
  "--------- ------------------------------------------------
  " Desc    : resize focused window
  "
  " Args    : {'event' : event}
  " Return  : none
  "
  " Raise   : none from this function
  "
  " Pitfall :
  "   - Can not set winminwith > winwidth
  "   - AutoCmd Sequence:
  "     - `:copen` :
  "       1. WinEnter (&ft inherited from last buffer)
  "       2. BufWinEnter (&ft == '')
  "       3. BufWinEnter (&ft == 'qf', set winfixheight)
  "     - `:split`
  "       1. WinLeave current window
  "       2. WinEnter new split window with current buffer
  "       3. `split` return, user script may change the buffer
  "          type, width, etc.
  "
  "
  "--------- ------------------------------------------------

  let l:opts = { 'is_force' : v:false }

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  let l:winnr_diff = s:winnr_diff()

  if l:winnr_diff > 0
    " Plus Split Window:
    " ++++++++++++++++++
    return
  elseif l:winnr_diff < 0
    " Minus Split Window:
    " -------------------

    call s:initialize_tab_variable()

    let l:saved_lazyredraw = &lazyredraw

    set lazyredraw

    let l:current_winnr = winnr()

    " Restore: original size based on "g:goldenview__restore_urule"
    " ------------------------------------------------------------
    for l:winnr in range(1, winnr('$'))
      let l:bufnr = winbufnr(l:winnr)
      let l:bufsaved = get(t:goldenview['bufs'], l:bufnr, {})

      " Ignored Case: same buffer displayed in multiply windows
      " -------------------------------------------------------
      if !empty(l:bufsaved) && l:bufsaved['winnr'] == l:winnr
        silent noautocmd execute l:winnr . 'wincmd w'

        if GoldenView#IsRestore()
          silent execute 'vertical resize ' . l:bufsaved['winwidth']
          silent execute 'resize ' . l:bufsaved['winheight']
        endif
      endif
    endfor

    if &cmdheight != t:goldenview['cmdheight']
      execute 'set cmdheight=' . t:goldenview['cmdheight']
    endif

    silent execute l:current_winnr . 'wincmd w'

    redraw

    let &lazyredraw = l:saved_lazyredraw

    return
  endif

  if !l:opts['is_force']
    " Do nothing if there is no split window
    if winnr('$') < 2
      return
    endif

    if GoldenView#IsIgnore()
      return
    endif
  endif

  let l:active_profile = s:goldenview__profile[g:goldenview__active_profile]

  call s:set_focus_window(l:active_profile)

  " reset focus windows minimal size
  let &winheight = &winminheight
  let &winwidth  = &winminwidth
endfunction

function! GoldenView#IsIgnore() abort
  return GoldenView#zl#rule#is_true(s:goldenview__ignore_nrule)
endfunction

function! GoldenView#IsRestore() abort
  return GoldenView#zl#rule#is_true(s:goldenview__restore_nrule)
endfunction

function! GoldenView#ResetResize() abort
  let l:reset_profile = s:goldenview__profile[g:goldenview__reset_profile]

  call s:set_other_window(l:reset_profile, { 'force': v:true })
  call s:set_focus_window(l:reset_profile, { 'force': v:true })
endfunction

function! GoldenView#GoldenHeight(...) abort
  return float2nr(&lines / s:golden_ratio)
endfunction

function! GoldenView#GoldenWidth(...) abort
  return float2nr(&columns / s:golden_ratio)
endfunction

function! GoldenView#GoldenMinHeight(...) abort
  return float2nr(GoldenView#GoldenHeight() / (5 * s:golden_ratio))
endfunction

function! GoldenView#GoldenMinWidth(...) abort
  return float2nr(GoldenView#GoldenWidth() / (3 * s:golden_ratio))
endfunction

function! GoldenView#TextWidth(...) abort
  let l:textwidth = getbufvar('%', '&textwidth')

  if l:textwidth != 0
    return float2nr(l:textwidth * 4 / 3)
  else
    let l:textwidth = float2nr(80 * 4 / 3)
    let l:goldenwidth = GoldenView#GoldenWidth()

    return l:textwidth > l:goldenwidth ? l:goldenwidth : l:textwidth
  endif
endfunction

" ============================================================================
" Split:
" ============================================================================
function! GoldenView#Split() abort
  let l:oldSplitBelow = &splitbelow
  let l:oldSplitRight = &splitright

  set nosplitbelow
  set nosplitright

  let l:split_cmd = s:nicely_split_cmd()

  try
    execute l:split_cmd
  catch /^Vim\%((\a\+)\)\=:E36/ " Not enough room
    if l:split_cmd == 'split'
      let &winminheight = &winminheight / 2
    else
      let &winminwidth = &winminwidth / 2
    endif

    execute l:split_cmd
  endtry

  wincmd p

  let &splitbelow = l:oldSplitBelow
  let &splitright = l:oldSplitRight
endfunction

" ============================================================================
" Helper Functions:
" ============================================================================

function! s:eval(profile, val) abort
  let l:val_type = type(a:val)

  if l:val_type ==# v:t_number
    return a:val
  elseif l:val_type ==# v:t_func
    return a:val(a:profile)
  else
    try
      return eval(a:val)
    catch /^Vim\%((\a\+)\)\=:E/
      throw 'GoldenView: invalid profile value type!'
    endtry
  endif
endfunction

function! s:set_focus_window(profile,...) abort
  let l:opts = {
        \   'force': v:false
        \ }

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  try
    if !&winfixwidth || l:opts['force']
      let &winwidth = s:eval(a:profile, a:profile['focus_window_winwidth'])
    endif

    if !&winfixheight || l:opts['force']
      let &winheight = s:eval(a:profile, a:profile['focus_window_winheight'])
    endif
  catch /^Vim\%((\a\+)\)\=:E36/ " Not enough room
    call s:print_warning('GoldenView: E36 Not enough room')
  endtry
endfunction

function! s:set_other_window(profile,...) abort
  let l:opts = {
        \   'force': v:false
        \ }

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  try
    if !&winfixwidth || l:opts['force']
      let &winminwidth = s:eval(a:profile, a:profile['other_window_winwidth'])
    endif

    if !&winfixheight || l:opts['force']
      let &winminheight = s:eval(a:profile, a:profile['other_window_winheight'])
    endif
  catch /^Vim\%((\a\+)\)\=:E36/ " Not enough room
    call s:print_warning('GoldenView: ' . v:exception)
  endtry
endfunction

function! s:nicely_split_cmd() abort
  let l:winwidth = winwidth(0)
  let l:textwidth = &textwidth

  if l:textwidth != 0 && l:winwidth > s:golden_ratio * l:textwidth
    return 'vsplit'
  endif

  if l:winwidth > &columns / s:golden_ratio
    return 'vsplit'
  endif

  return 'split'
endfunction

function! s:initialize_tab_variable() abort
  if !exists('t:goldenview')
    let t:goldenview = {
          \   'nrwin': winnr('$') ,
          \   'cmdheight': &cmdheight ,
          \   'bufs': {},
          \ }
  endif
endfunction

function! s:winnr_diff() abort
  call s:initialize_tab_variable()

  let l:nrwin = winnr('$')

  if l:nrwin != t:goldenview['nrwin']
    let l:diff = l:nrwin - t:goldenview['nrwin']
    let t:goldenview['nrwin'] = l:nrwin

    return l:diff
  else
    return v:false
  endif
endfunction

function! s:tabpagebuflist() abort
  let l:list = tabpagebuflist()
  let l:count = len(l:list)
  let l:i = 0
  let l:seen = {}

  while l:i < l:count
    let l:key = string(l:list[l:i])

    if has_key(l:seen, l:key)
      call remove(l:list, l:i)
    else
      let l:seen[l:key] = 1
      let l:i += 1
    endif
  endwhile

  return l:list
endfunction

function! s:print_warning(message) abort
  echohl WarningMsg
  echomsg a:message
  echohl NONE
endfunction

function! s:print_moremsg(message) abort
  echohl MoreMsg
  echomsg a:message
  echohl NONE
endfunction
