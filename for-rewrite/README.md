# Rewrite

upon consideration to implementing a gap/rope buffer its become obvious that a project rewrite will most likely be necessary. Fix all the slop with restructuring.

## Goals for rewrite

- tests tests tests. throughout this implementation, I want to maintain testing for each feature
- interfaces -- I want to have well defined interface for flexibility in structs without breaking anything
- clear decoupled modules

_this folder will not be considered a final iteration of this project. It served a starting point for a project structured for more frictionless upgrading_

## Project Structure

### Modules

these should be clearly divided within the project

- core
  - controller
- buffer
  - gap buffer
  - []string buffer
  - nodes?
- viewport
- ui (tui)
- cursor
