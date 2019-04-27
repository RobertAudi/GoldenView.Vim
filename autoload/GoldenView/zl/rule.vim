" =============== ============================================================
" Name:           rule.vim
" Synopsis:       vim script library: rule
" Author:         Zhao Cai <caizhaoff@gmail.com>
" HomePage:       https://github.com/zhaocai/zl.vim
" Date Created:   Sat 03 Sep 2011 03:54:00 PM EDT
" Last Modified:  Sat 29 Sep 2012 01:03:24 AM EDT
" Copyright:      © 2012 by Zhao Cai,
"                 Released under current GPL license.
" =============== ============================================================

" ============================================================================
" Rule:
" ============================================================================

" [TODO]( list for at type ) @zhaocai @start(2012-09-27 08:05)

let s:rule_types =  [
      \   'filetype', 'buftype', 'mode', 'cword',
      \   'bufname', 'at', 'syntax', 'expr',
      \ ]

let s:nrule = {
      \   'eval_order': copy(s:rule_types),
      \   'eval_negate': [],
      \   'logic': 'or',
      \   'rule': {},
      \ }

function! GoldenView#zl#rule#norm(urule, ...) abort
  "--------- ------------------------------------------------
  " Desc    : normalize rules
  "
  " Rule    :
  "   - "urule" : "Unnormalized RULE", rules written by users.
  "   - "nrule" : "Nnormalized RULE", rules completed with
  "               optional items and internal items.
  "
  " Args    :
  "   - urule: un-normalized rule
  "   - opts :
  "     - eval_order   : order in s:rule_types,
  "     - eval_negate  : reverse eval result
  "     - logic :
  "       - {or}     : 'v:filetype || v:bufname || ...'
  "       - {and}    : 'v:filetype && v:bufname && ...'
  "       - {string} : similar to v:val for filter()
  "
  " Return  : normalized rules
  " Raise   :
  "
  " Example : >
  "
  " Refer   :
  "--------- ------------------------------------------------
  let l:nrule = deepcopy(s:nrule)

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:nrule, a:1)
  endif

  let l:type_expr = {
        \   'buftype': '&buftype',
        \   'filetype': '&ft',
        \   'bufname': "bufname('%')",
        \   'cword': "expand('<cword>')",
        \ }

  let l:type_pat = {}

  for l:type in ['filetype', 'buftype', 'syntax']
    if has_key(a:urule, l:type)
      let l:type_pat[l:type] = '^\%(' . join(a:urule[l:type], '\|') . '\)$'
    endif
  endfor

  for l:type in ['bufname', 'cword']
    if has_key(a:urule, l:type)
      let l:type_pat[l:type] = '^\%(' . join(map(a:urule[l:type], "escape(v:val, '^$.*\\[]~')"), '\|') . '\)$'
    endif
  endfor

  " normalize each type of rules
  for l:type in ['mode']
    if has_key(a:urule, l:type)
      let l:nrule['rule'][l:type] = a:urule[l:type]
    endif
  endfor

  for l:type in ['filetype', 'buftype', 'bufname', 'cword']
    if has_key(a:urule, l:type)
      let l:nrule['rule'][l:type] =
            \ {
            \ 'eval_expr': 1,
            \ 'expr': l:type_expr[l:type],
            \ 'pat': l:type_pat[l:type],
            \ }
    endif
  endfor

  for l:type in ['syntax']
    if has_key(a:urule, l:type)
      let l:nrule['rule'][l:type] = l:type_pat[l:type]
    endif
  endfor

  for l:type in ['mode', 'at']
    if has_key(a:urule, l:type)
      let l:nrule['rule'][l:type] = a:urule[l:type]
    endif
  endfor

  for l:type in ['expr']
    if has_key(a:urule, l:type)
      try
        let l:nrule['rule'][l:type] =
              \ join(
              \   map(
              \     map(
              \       copy(a:urule[l:type]),
              \       "join(v:val,' || ')"
              \     ),
              \     "'('.v:val.')'"
              \   ),
              \   ' && '
              \ )
      catch /^Vim\%((\a\+)\)\=:E714/ " E714: List required
        throw 'zl(rule): expr rule should be written as list of lists.'
      endtry
    endif
  endfor

  call filter(
        \   l:nrule['eval_order'],
        \   "has_key(l:nrule['rule'], v:val) && !empty(l:nrule['rule'][v:val])"
        \ )

  return l:nrule
endfunction

function! GoldenView#zl#rule#is_true(nrule, ...) abort
  try
    return call('GoldenView#zl#rule#logic_' . a:nrule['logic'], [a:nrule] + a:000)
  catch /^Vim\%((\a\+)\)\=:E129/
    throw 'zl(rule): undefined logic funcref'
  endtry
endfunction

function! GoldenView#zl#rule#is_false(nrule, ...) abort
  return !call('GoldenView#zl#rule#is_true', [a:nrule] + a:000)
endfunction

function! GoldenView#zl#rule#logic_or(nrule, ...) abort
  let l:opts = {}

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  for l:type in a:nrule['eval_order']
    if s:_return(a:nrule, l:type, s:eval_{l:type}(a:nrule['rule'], l:opts))
      return 1
    endif
  endfor

  return 0
endfunction

function! GoldenView#zl#rule#logic_and(nrule, ...) abort
  let l:opts = {}

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  for l:type in a:nrule['eval_order']
    if !s:_return(a:nrule, l:type, s:eval_{l:type}(a:nrule['rule'], l:opts))
      return 0
    endif
  endfor

  return 1
endfunction

function! GoldenView#zl#rule#logic_expr(nrule, ...) abort
  let l:opts = {}

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  let l:str = a:nrule['expr']

  for l:type in a:nrule['eval_order']
    let str = substitute(l:str,
          \   'v:' . l:type,
          \   string(
          \     s:_return(a:nrule, l:type,
          \       s:eval_{l:type}(a:nrule['rule'], l:opts)
          \     )
          \   ),
          \   'ge'
          \ )
  endfor

  try
    return eval(l:str)
  catch /^Vim\%((\a\+)\)\=:E/
    throw printf('zl(rule): eval(%s) raises %s', l:str, v:exception)
  endtry
endfunction

" ============================================================================
" Helper Functions:
" ============================================================================

" rule logic
function! s:_return(nrule, type, ret) abort
  return index(a:nrule['eval_negate'], a:type) >= 0 ? !a:ret : a:ret
endfunction

" nrule eval
function! s:eval_filetype(nrule, ...) abort
  return call('s:_eval_match', ['filetype', a:nrule] + a:000)
endfunction

function! s:eval_cword(nrule, ...) abort
  return call('s:_eval_match', ['cword', a:nrule] + a:000)
endfunction

function! s:eval_buftype(nrule, ...) abort
  return call('s:_eval_match', ['buftype', a:nrule] + a:000)
endfunction

function! s:eval_bufname(nrule, ...) abort
  return call('s:_eval_match', ['bufname', a:nrule] + a:000)
endfunction

function! s:eval_at(nrule, ...) abort
  return search(get(a:nrule, 'at', '\%#'), 'bcnW')
endfunction

function! s:eval_mode(nrule, ...) abort
  let l:mode_pat  = get(a:nrule, 'mode', [])
  let l:mode_expr = a:0 >= 1 && type(a:1) ==# v:t_dict ? get(a:1, 'mode', mode()) : mode()

  return !empty(filter(l:mode_pat, 'stridx(mode_expr, v:val) == -1'))
endfunction

function! s:eval_syntax(nrule, ...) abort
  let l:pat = get(a:nrule, 'syntax', '')

  let l:opts = {}

  if a:0 >= 1 && type(a:1) ==# v:t_dict
    call extend(l:opts, a:1)
  endif

  let l:syn_names = GoldenView#zl#syntax#synstack_names(l:opts)

  return !empty(filter(l:syn_names, 'match(v:val, l:pat) != -1'))
endfunction

function! s:eval_expr(nrule, ...) abort
  try
    return eval(get(a:nrule, 'expr', 1))
  catch /^Vim\%((\a\+)\)\=:E/
    return 0
  endtry
endfunction

function! s:_eval_match(type, nrule, ...) abort
  "--------- ------------------------------------------------
  " Desc    : internal match evluation
  " Rule    :
  "   { 'type':
  "     {
  "       'eval_expr': (1|0),
  "       'expr':      {expr},
  "       'pat':       {pat},
  "     }
  "   }
  "
  " Args    : [{type}, {nrule}[, {opts}]]
  " Return  :
  "   - 0 : false
  "   - 1 : true
  " Raise   : zl(rule)
  "
  " Refer   : vimhelp:match()
  "--------- ------------------------------------------------

  let l:rule = copy(get(a:nrule, a:type, {}))

  if empty(l:rule)
    throw 'zl(rule): ' . v:exception
  endif

  " opt for {expr} from runtime opts
  if a:0 >= 1 && type(a:1) ==# v:t_dict && has_key(a:1, a:type)
    let l:rt_rule = a:1[a:type]

    if type(l:rt_rule) ==# v:t_dict
      call extend(l:rule, l:rt_rule)
    elseif type(l:rt_rule) ==# v:t_string
      let l:rule['expr']      = l:rt_rule
      let l:rule['eval_expr'] = 0
    endif
  endif

  if l:rule['eval_expr']
    let l:rule['expr'] = eval(l:rule['expr'])
  endif

  try
    return call('match', [l:rule['expr'], l:rule['pat']]) != -1
  catch /^Vim\%((\a\+)\)\=:E/
    throw 'zl(rule): ' . v:exception
  endtry
endfunction
