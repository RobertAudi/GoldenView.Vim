Always have a nice view for vim split windows
=============================================

```text
------------- - -----------------------------------------------
Plugin        : GoldenView.vim
Author        : Zhao Cai
EMail         : caizhaoff@gmail.com
Homepage      : https://github.com/RobertAudi/GoldenView.Vim
Version       : 1.3.6
Date Created  : Tue 18 Sep 2012 05:23:13 PM EDT
Last Modified : Mon 22 Apr 2013 05:55:22 PM EDT
------------- - -----------------------------------------------
```

The initial motive for [GoldenView][] comes from the frustration of using other vim plugins to auto-resize split windows. The idea is deadly simple and very useful: **resize the focused window to a proper size.** However, in practice, many hiccups makes **auto-resizing** not a smooth experience.  Below are a list of issues [GoldenView][] attempts to solve:

First and the most important one, auto-resizing should play nicely with existing plugins like `tagbar`, `vimfiler`, `unite`, `VOoM`, `quickfix`, `undotree`, `gundo`, etc. These windows should manage there own window size.

Second, auto-resizing should take care of **the other windows** too. Resizing the focused window may cause the other windows become too small. When you have 4+ split windows, auto-resizing may just make a mess out of it.

Features
--------

[GoldenView][] has preliminarily solved the issues described above. It also provides other features. Basically, it does two things:

### 1. AutoResizing

First of all, it automatically resize the focused split window to a "golden" view based on [golden ratio][golden-ratio-wikipedia] and `textwidth`.

### 2. Tiled Windows Management

Second, it maps a single key (`<C-L>` by default) to nicely split windows to tiled windows.

```text
----+----------------+------------+---+
|   |                |            |   |
| F |                |    S1      | T |
| I |                +------------| A |
| L |                |    S2      | G |
| E |   MAIN PANE    +------------+ B |
| R |                |    S3      | A |
|   |                |            | R |
|   |                |            |   |
+---+----------------+------------+---+
```

To get this view, just hit `<C-L>` 4 times. or, if you have a large monitor, you may get tiled windows below.

```text
----+---------------+--------------+------------+---+
|   |               |              |            |   |
| F |               |              |    S1      | T |
| I |               |              +------------| A |
| L |               |      M2      |    S2      | G |
| E |   MAIN PANE   |              +------------+ B |
| R |               |              |    S3      | A |
|   |               |              |            | B |
|   |               |              |            |   |
+---+---------------+--------------+------------+---+
```

To quickly switch between those windows, a few keys are mapped to:

- Focus to the main window
- Switch with the `MAIN PANE`, the largest, smallest, etc.
- Jump to the next and previous window

Installation
------------

Install [GoldenView][] is the *same as installing other vim plugins*. If experienced with vim, you can skim the example below and move to [next section](#quick-start).

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'RobertAudi/GoldenView.Vim'
```

### [Vundle](https://github.com/gmarik/vundle)

```vim
Plugin 'RobertAudi/GoldenView.Vim'
```

### [Pathogen](https://github.com/tpope/vim-pathogen)

```console
$ cd ~/.vim/bundle
$ git clone https://github.com/RobertAudi/GoldenView.Vim.git
```

Quick Start
-----------

[GoldenView][] should work out of the box without configuration. It should automatically start to resize focused window to [golden ratio][golden-ratio-wikipedia] based on `textwidth` and vim available size. You may start to play with it now.

To get you started, a few default keys are mapped as below:

```vim
" 1. split to tiled windows
nmap <silent> <C-L>  <Plug>GoldenViewSplit

" 2. quickly switch current window with the main pane
" and toggle back
nmap <silent> <F8>   <Plug>GoldenViewSwitchMain
nmap <silent> <S-F8> <Plug>GoldenViewSwitchToggle

" 3. jump to next and previous window
nmap <silent> <C-N>  <Plug>GoldenViewNext
nmap <silent> <C-P>  <Plug>GoldenViewPrevious
```

The meaning of those keys are self-explaining. A general workflow would be `<Plug>GoldenViewSplit` key to quickly and nicely split windows to the layout as below. Then you may open your files.

```text
----+----------------+------------+---+
|   |                |            |   |
| F |                |    S1      | T |
| I |                +------------| A |
| L |                |    S2      | G |
| E |   MAIN PANE    +------------+ B |
| R |                |    S3      | A |
|   |                |            | R |
|   |                |            |   |
+---+----------------+------------+---+
```

To switch `S1` with `MAIN PANE`, in `S1` and hit `<Plug>GoldenViewSwitchMain`. To switch back, hit `<Plug>GoldenViewSwitchToggle` in either `MAIN PAIN` or `S1`

#### `g:goldenview__enable_default_mapping`

Every experienced vim user has a different set of key mappings. If you you are (most likely) unhappy about some of the mappings, map you own keys as below:

```vim
let g:goldenview__enable_default_mapping = 0

nmap <silent> <MY_KEY> <Plug>GoldenViewSplit
" ... and so on
```

#### `g:goldenview__enable_at_startup`

if you do not want to start auto-resizing automatically, you can put the following script in your vimrc.

```vim
let g:goldenview__enable_at_startup = 0
```

More Commands and Mappings
--------------------------

### `:ToggleGoldenViewAutoResize`
### `:DisableGoldenViewAutoResize`
### `:EnableGoldenViewAutoResize`

These commands toggle, enable, and disable GoldenView auto-resizing.

### `:GoldenViewResize`

This command do manual resizing of focused window.

You can also map a key for this as below:

```vim
nmap <silent> <YOUR_KEY> <Plug>GoldenViewResize
```

### `:SwitchGoldenViewMain`
### `:SwitchGoldenViewLargest`
### `:SwitchGoldenViewSmallest`

These commands do as it named.

You can also add mappings as below. (no default keys for these mappings)

```vim
nmap <silent> <YOUR_KEY> <Plug>GoldenViewSwitchWithLargest
nmap <silent> <YOUR_KEY> <Plug>GoldenViewSwitchWithSmallest
```

Other switch rules can be easily defined.

Rules
-----

[GoldenView][] defines two rules:

### `g:goldenview__ignore_urule`

Is to "ignore" - allow those special buffers to manage their own window size.

### `g:goldenview__restore_urule`

Is to "restore" - restore window size of some of special buffers.

The `urule` (user rules) are like this, which will be normalize at runtime for faster processing.

```vim
    \ {
    \    'filetype' : [
    \      ''        ,
    \      'qf'      , 'vimpager', 'undotree', 'tagbar',
    \      'nerdtree', 'vimshell', 'vimfiler', 'voom'  ,
    \      'tabman'  , 'unite'   , 'quickrun', 'Decho' ,
    \    ],
    \    'buftype' : [
    \      'nofile'  ,
    \    ],
    \    'bufname' : [
    \      'GoToFile'                  , 'diffpanel_\d\+'      ,
    \      '__Gundo_Preview__'         , '__Gundo__'           ,
    \      '\[LustyExplorer-Buffers\]' , '\-MiniBufExplorer\-' ,
    \      '_VOOM\d\+$'                , '__Urannotate_\d\+__' ,
    \      '__MRU_Files__' ,
    \    ],
    \ },

```

Profiles
--------

[GoldenView][] defines two profile:

### `g:goldenview__active_profile`

Defines the functions and preferences to auto resize windows.

### `g:goldenview__reset_profile`

Defines reset preferences to restore everything to default.

`function GoldenView#ExtendProfile()` is provided to customize preferences.

For more details, please read the source code! :)

Troubleshooting:
----------------

### Please do not resize me!

[GoldenView][] maintains rules for "common" cases. But vim offers a great variety of plugins which defines buffers for special purposes. If you find some special buffers which is supposed to not be auto-resized. Please check `g:goldenview__ignore_urule`. You may also extend the `g:goldenview__active_profile` yourself.

### I cannot resize window height to < 7

This is features. As mentioned in the [Introduction](#always-have-a-nice-view-for-vim-split-windows) section, there is no normal cases to have a normal window too small. For special cases, it can be handled case by case.

However, if you really want to have small windows. It can be done by:

```vim
" Extend a new profile named 'small-height' from default profile.
"
" 1. Change "2" to your desire minimal height
" 2. Change "small-height" to the profile name you like
" ---------------------------------------------------------------
call GoldenView#ExtendProfile('small-height', {
    \   'other_window_winheight'  : 2  ,
    \ })

let g:goldenview__active_profile = 'small-height'
```

(refer to issue [#5](https://github.com/zhaocai/GoldenView.Vim/issues/5))

```vim
echo GoldenView#Info()
```

RELEASE HISTORY
---------------

Refer to [History.md](History.md).

LICENSE:
--------

```text
Copyright (c) 2013 Zhao Cai \<caizhaoff@gmail.com\>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
```

[golden-ratio-wikipedia]: http://en.wikipedia.org/wiki/Golden_ratio
[GoldenView]:  https://github.com/RobertAudi/GoldenView.Vim "GoldenView Homepage"
