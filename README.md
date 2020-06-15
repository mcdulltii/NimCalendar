# ShiftCalendar
[![](https://img.shields.io/badge/Category-Applications%20in%20Nim-E5A505?style=flat-square)]() [![](https://img.shields.io/badge/Language-Nim-E5A505?style=flat-square)]() [![](https://img.shields.io/badge/Version-1.0-E5A505?style=flat-square&color=green)]()

3-Day Shift Calendar with SDL2 in Nim

# ![Running Binary File](Calendar.png)

## Building

`nimble build` or `nim c "Build\calendar.nim"` both build a `calendar`
binary executable based on the host OS.

`nimble install` builds a `calendar` binary executable into ~/.nimble/bin.

Upon building the binary executable, font.ttf and background.jpg is automatically loaded into the executable, enabling the executable to be run in any directory.

## Dependencies

- Imports SDL2, SDL2_image, SDL2_ttf, stopwatch and nimdeps
	- Install SDL2 on host machine before running executable binary
		1. Linux:
			- apt install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
		2. MacOS:
			- brew install libsdl2 libsdl2-image libsdl2-ttf
		3. Windows:
			- Install from [libsdl2](https://www.libsdl.org/download-2.0.php)
			- If SDL2 dependencies faults at execution, interchange between x86 and x64 SDL2 dlls to find the correct dlls used in execution
