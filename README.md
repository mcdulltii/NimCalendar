# ShiftCalendar
3-Day Shift Calendar with SDL2 in Nim

# ![Running Binary File](Calendar.png)

## Building

`nimble build` or `nim -d:release c calendar` both build a `calendar`
binary file based on the host OS.

## Dependencies

- Requires .ttf (font) file and .jpg (background) file within the same directory as built binary file.
- Imports SDL2, SDL2_image, SDL2_ttf and stopwatch
	- Install SDL2 on host machine before running executable binary
		- Eg. apt install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev
	- If SDL2 dependencies faults at execution, interchange between x86 and x64 SDL2 dlls to find the correct dlls used in execution
