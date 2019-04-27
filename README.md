Always have a nice view for vim split windows
=============================================

The initial motive for GoldenView comes from the frustration of using other vim plugins to auto-resize split windows. The idea is deadly simple and very useful: **resize the focused window to a proper size.** However, in practice, many hiccups makes **auto-resizing** not a smooth experience. Below are a list of issues GoldenView attempts to solve:

First and the most important one, auto-resizing should play nicely with existing plugins like `Tagbar`, `NERDTree`, `unite`, `undotree`, etc. These windows should manage there own window size.

Second, auto-resizing should take care of **the other windows** too. Resizing the focused window may cause the other windows become too small. When you have 4+ split windows, auto-resizing may just make a mess out of it.

Features
--------

GoldenView has preliminarily solved the issues described above. It also provides other features. Basically, it does two things:

### Auto-Resizing

First of all, it automatically resize the focused split window to a "golden" view based on the [golden ratio](http://en.wikipedia.org/wiki/Golden_ratio) and `textwidth`.

### Tiled Windows Management

Second, it exposes `<Plug>GoldenViewSplit` to nicely split windows to tiled windows.

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

To get this view, just hit the mapped key 4 times. If you have a large monitor, you may get tiled windows below.

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

Installation
------------

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'RobertAudi/GoldenView.vim'
```

### [Vundle](https://github.com/gmarik/vundle)

```vim
Plugin 'RobertAudi/GoldenView.vim'
```

### [Pathogen](https://github.com/tpope/vim-pathogen)

```console
$ cd ~/.vim/bundle
$ git clone https://github.com/RobertAudi/GoldenView.vim.git
```

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

Commands
--------

| Command                        | Description                |
|:-------------------------------|:---------------------------|
| `:ToggleGoldenViewAutoResize`  | Toggle auto-resizing.      |
| `:DisableGoldenViewAutoResize` | Disable auto-resizing.     |
| `:EnableGoldenViewAutoResize`  | Enable auto-resizing.      |
| `:GoldenViewResize`            | Resize the current window. |

Configuration
-------------

Auto-resizing is enabled at startup. If you want to disable it by default, change the `g:goldenview__enable_at_startup` variable:

```vim
let g:goldenview__enable_at_startup = 0
```

### Rules

| Variable                      | Description                                            |
|:------------------------------|:-------------------------------------------------------|
| `g:goldenview__ignore_urule`  | Allow special buffers to manage their own window size. |
| `g:goldenview__restore_urule` | Restore the window size of some of special buffers.    |

### Profiles

| Variable                       | Description                                                                          |
|:-------------------------------|:-------------------------------------------------------------------------------------|
| `g:goldenview__active_profile` | Defines the functions and preferences to auto resize windows. _Default: `"default"`_ |
| `g:goldenview__reset_profile`  | Defines reset preferences to restore everything to default. _Default: `"reset"`_     |

Troubleshooting:
----------------

**Please do not resize me!**

GoldenView maintains rules for "common" cases. But vim offers a great variety of plugins which defines buffers for special purposes. If you find some special buffers which is supposed to not be auto-resized. Please check `g:goldenview__ignore_urule`. You may also extend the `g:goldenview__active_profile` yourself.

Changelog
---------

Refer to the [Changelog](CHANGELOG.md).

License
-------

```text
Copyright (c) 2013 Zhao Cai <caizhaoff@gmail.com>

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

