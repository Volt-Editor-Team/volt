- [x] switch to gap buffer -- a data structure much better for real-time editing of text. _this required significant refactoring across codebase_
  - [ ] the running plan to try and setup a rope buffer with gap buffers as the leafs.
    - we now have tha gap buffer as the default, but theres been a bit of difficulty attaching it to rope leaves correctly. it probably needs to be optimized a lot to really be performant

- [ ] fix cursor movement within wrapped text

- [ ] make changes to buffer path and render logic to account for working directory changes.

- [ ] Buffer flicker -- instead of redrawing entire screen, only redraw changes
- [ ] directory buffer tree -- refactor directory buffer to enable tree view
- [ ] syntax highlighting
- [ ] keybindings
- [ ] config file
- [ ] documentation buffer
