# Package


version       = "1.0"
author        = "Aaron Ti"
description   = "A 3-Day shift system calendar with SDL2"
license       = "GPL-3.0"


srcDir        = "./Build"
binDir        = "./Build"
bin           = @["calendar"]


# Dependencies


requires "nim >= 1.0.6"
requires "sdl2 >= 2.0.2"
requires "stopwatch >= 3.5"
requires "nimdeps >= 0.1.0"