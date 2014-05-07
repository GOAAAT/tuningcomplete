module.exports = class CursorResponder
  select-at: (pt) -> true
  scale-by: (sf, pt) -> true

  pointer-down: (pt) -> true
  pointer-up: (pt) -> true
  pointer-moved: (pt) -> true

  pan-by: (delta) -> true

  pointers-changed: (pts) -> true
