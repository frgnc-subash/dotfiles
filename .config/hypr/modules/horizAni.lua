-- ┌─┐┌┐┌┬┌┬┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
-- ├─┤│││││││├─┤ │ ││ ││││└─┐
-- ┴ ┴┘└┘┴┴ ┴┴ ┴ ┴ ┴└─┘┘└┘└─┘
-- name "Horizontal | Fast"

hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 5, bezier = "smoothIn" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "default", style = "slidefadevert 20%" })

