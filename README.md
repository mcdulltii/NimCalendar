# ShiftCalendar
3-Day Shift Calendar with SDL2 in Nim

# ![Running Binary File](Calendar.png)

## Building

`nimble build` or `nim c "Build\calendar.nim"` both build a `calendar`
binary executable based on the host OS.

`nimble install` builds a `calendar` binary executable into ~/.nimble/bin, where \*.ttf files and \*.jpg files in the relative directory will be read by the running executable.

## Dependencies

- Requires .ttf (font) file and .jpg (background) file within the same directory as built binary file.
- Imports SDL2, SDL2_image, SDL2_ttf and stopwatch
	- Install SDL2 on host machine before running executable binary
		1. Linux:
			- apt install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
		2. MacOS:
			- brew install libsdl2 libsdl2-image libsdl2-ttf
		3. Windows:
			- Install from [libsdl2](https://www.libsdl.org/download-2.0.php)
			- If SDL2 dependencies faults at execution, interchange between x86 and x64 SDL2 dlls to find the correct dlls used in execution
