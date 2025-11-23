## Core - tasks that are vital to Volts processes

- [x] switch to gap buffer -- a data structure much better for real-time editing of text. _this required significant refactoring across codebase_
  - [ ] switch to rope buffer -- the running plan is to try and setup a rope buffer with gap buffers as the leafs.
    - we now have that gap buffer as the default, but theres been a bit of difficulty attaching it to rope leaves correctly and it probably still needs to be optimized to really be performant.
- [ ] fix cursor movement within wrapped text
- [x] make changes to buffer path and render logic to account for working directory changes.
- [ ] directory buffer tree -- refactor directory buffer to enable tree view
  - [ ] implement actual directory buffer. changes should be tracked and visually indicated, then executed on save via making new files (which should open as well), making new directories, changing file/directory names, deleting paths, etc.

- [ ] decide on a keystroke philosophy. i haven't adhered to one so far, but the idea is that it is consistent throughout the editor

## Rendering / Performance

- [x] Buffer flicker -- instead of redrawing entire screen, only redraw changes
  - [ ] implement redraws at line level. current draws the entire buffer once per key stroke; however this is not ideal as it reduces but doesn't eliminate screen flickering.
- [ ] improve fuzzy search scoring
- [ ] implement a way to load larger files faster.
- [ ] make scrolling smoother

## Other

- [ ] implement more testing for buffer operations
  - [ ] not sure where but make tests for other modules as well
- [ ] syntax highlighting
- [ ] keybindings (add more)
- [ ] config file
- [ ] documentation (help) buffer -- right now its just nvims help text
