Changelog
=========

v1.4.0 / 2019-04-27
-------------------

Only keep the functionality to auto-resize. @RobertAudi

### Changes

- Remove commands to switch window:
  - `:SwitchGoldenViewMain`
  - `:SwitchGoldenViewToggle`
  - `:SwitchGoldenViewLargest`
  - `:SwitchGoldenViewSmallest`
- Remove default mappings.
- Remove the `g:goldenview__enable_default_mapping` option.
- Remove unused [zl.vim][] functions.

v1.3.0 / 2013-04-22
-------------------

Diff Mode auto resizing (Zhao Cai <caizhaoff@gmail.com>)

### Changes:

#### Major Enhancements

- Diff mode auto-resizing.

#### Minor Enhancements

- Refactor `autocmd` function: tweak restore behavior.

v1.2.2 / 2013-04-21
-------------------

Improve documents and small bug fixes, Load guard for [#4][issue-4] (Zhao Cai <caizhaoff@gmail.com>)

### Changes:

#### Minor Enhancements

- Better tracing.

#### Bug Fixes

- Load guard for issue [#4][issue-4].

```text
E806: using Float as a String
```

[issue-4]: https://github.com/zhaocai/GoldenView.Vim/issues/4

v1.2.0 / 2013-04-18
-------------------

 (Zhao Cai <caizhaoff@gmail.com>)

### Changes:

#### Major Enhancements

- Add restore rule for some special buffers.

#### Bug Fixes

- `E36 Not enough room` to split.
- Issue [#2](https://github.com/zhaocai/GoldenView.Vim/issues/2) MRU plugin window.
- Init sequence.
- [zl.vim][] load guard.

v1.1.2 / 2013-04-18
-------------------

Fix init sequence between [zl.vim][] and GoldenVim. (Zhao Cai <caizhaoff@gmail.com>)

v1.1.1 / 2013-04-18
-------------------

Improve documents, fix [zl.vim][] library load. (Zhao Cai <caizhaoff@gmail.com>)

v1.1.0 / 2013-04-18
-------------------

 (Zhao Cai <caizhaoff@gmail.com>)

### Changes:

#### Major Enhancements

- Add `WinLeave` event into account. This version works perfectly.
- Fix various hiccups caused by `WinLeave`.
- Use ignore rules from [zl.vim][].

#### Minor Enhancements

- Add mapping to switch to main pane. [minor] speed up buffer switch with `noautocmd`.
- Include [zl.vim][] into source code.
- Tune for `autocmd` sequence.
- Treat `winfixwidth` and `winfixheight` separately.

#### Bug Fixes

- `WinLeave` cause ignored windows resized.
- Cannot let `&winminwidth > &winwidth`.

#### Nominal Changes

- Change profile variable scope to `s:`
- Tweak golden ratio for win size

v1.0 / 2012-09-18
----------------

 (Zhao Cai <caizhaoff@gmail.com>)

[zl.vim]: https://github.com/zhaocai/zl.vim
