import stopwatch
import sdl2, sdl2/image, sdl2/ttf


# Calculates execution time
var sw = stopwatch()
sw.start()


#[ ------------------------ Constants ------------------------ ]#
const
  WIDTH: cint = 600
  HEIGHT: cint = 600
  outlineColor = color(0, 0, 0, 64)
  wordColor = color(91, 132, 177, 255)


#[ ------------------------ Typedefs ------------------------ ]#
type
  SDLException = object of Exception

  Input {.pure.} = enum none, one, two, three, left, right, restart, quit

  Game = ref object
    inputs: array[Input, bool]
    renderer: RendererPtr
    font: FontPtr


#[ ------------------------ Set Variables ------------------------ ]#
var
  clip = rect(0,0,WIDTH,HEIGHT)
  dest = rect(0,0,WIDTH,HEIGHT)
  dates: seq[string] = @[]
  days: seq[string] = @["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  xcoord:cint = 4
  ycoord:cint = 0
  startx:cint = 4
  starty:cint = 0
  offset:cint = 0
  offday:cint = 0
  selectx:cint
  tick = "/"


#[ ------------------------ Fails in Build ------------------------ ]#
template sdlFailIf(cond: typed, reason: string) =
  if cond: raise SDLException.newException(
    reason & ", SDL error: " & $getError())


#[ ------------------------ Reset Screen ------------------------- ]#
proc newGame(renderer: RendererPtr): Game =
  new result
  result.renderer = renderer
  result.font = openFont("nasa.ttf", 25)
  sdlFailIf result.font.isNil: "Failed to load font"


#[ ------------------------ Limit Inputs ------------------------- ]#
proc toInput(key: Scancode): Input =
  case key
  of SDL_SCANCODE_1: Input.one
  of SDL_SCANCODE_2: Input.two
  of SDL_SCANCODE_3: Input.three
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_R: Input.restart
  of SDL_SCANCODE_Q: Input.quit
  else: Input.none


#[ ------------------------ Calculate Grid Dimensions ------------------------ ]#
proc calcGrid(num: int, offset: int): seq[cint] = 
  var grid: seq[cint]
  grid = @[]
  for i in countUp(1, num):
    grid.add(cint((WIDTH-offset) div num * i))
  if (dates.len == 0):
    for i in countUp(1, 31):
      dates.add($i)
  result = grid


#[ ------------------------ Handle Inputs ------------------------ ]#
proc handleInput(game: Game) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent:
      game.inputs[Input.quit] = true
    of KeyDown:
      game.inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp:
      game.inputs[event.key.keysym.scancode.toInput] = false
    else:
      discard


#[ ------------------------ Render Texts ------------------------- ]#
proc renderText(renderer: RendererPtr, font: FontPtr, text: string,
                x, y, outline: cint, color: Color) =
  let surface = font.renderUtf8Solid(text.cstring, color)
  sdlFailIf surface.isNil: "Could not render text surface"

  discard surface.setSurfaceAlphaMod(color.a)

  var source = rect(0, 0, surface.w, surface.h)
  var dest = rect(x, y, surface.w, surface.h)
  let texture = renderer.createTextureFromSurface(surface)

  sdlFailIf texture.isNil:
    "Could not create texture from rendered text"

  surface.freeSurface()

  renderer.copyEx(texture, source, dest, angle = 0.0, center = nil,
                  flip = SDL_FLIP_NONE)

  texture.destroy()

proc renderText(game: Game, text: string,
                x, y: cint, color: Color) =
  game.renderer.renderText(game.font, text, x, y, 2, outlineColor)
  game.renderer.renderText(game.font, text, x, y, 0, color)


#[ ------------------------ Draw Elements ------------------------ ]#
proc draw(game: Game, gridx: seq[cint], gridy: seq[cint], image: TexturePtr) =
  game.renderer.setDrawColor(r = 0, g = 0, b = 100)

  # Background
  game.renderer.copy(image, unsafeAddr clip, unsafeAddr dest)

  # Grids
  for i in countUp(0, gridx.len-1):
    game.renderer.drawLine(gridx[i], gridy[0], gridx[i], gridy[^1])
  for j in countUp(0, gridy.len-1):
    game.renderer.drawLine(gridx[0], gridy[j], gridx[^1], gridy[j])

  # Words
  block words:
    for i in dates:
      game.renderText(i, gridx[xcoord]+5, gridy[ycoord], wordColor)
      xcoord += 1.cint
      if (xcoord > 6.cint):
        xcoord = 0.cint
        ycoord += 1.cint
      if (ycoord > 4.cint):
        xcoord = 4.cint
        ycoord = 0.cint
        break words

  # Selected
  block select:
    selectx = startx + offset
    for i in countUp(0, dates.len div 3):
      try:
        game.renderText(tick, gridx[selectx]+20, gridy[starty]+30, wordColor)
        selectx += 3.cint
        if (selectx > 6.cint):
          selectx = (selectx - 4.cint) mod 3.cint
          starty += 1.cint
        if (starty > 4.cint):
          startx = 4.cint
          starty = 0.cint
          selectx = startx + offset
          break select
      except:
        break select

  # Days
  block day:
    var diff = (gridy[1] - gridy[0]) div 2
    for i in countUp(0, days.len-1-offday):
      game.renderText(days[i], gridx[i+offday], gridy[0] - diff, wordColor)
    if (offday > 0):
      for j in countDown(offday - 1, 0):
        game.renderText(days[^(j+1)], gridx[offday-1-j], gridy[0] - diff, wordColor)

  game.renderer.setDrawColor(r = 0, g = 0, b = 0)

proc render(game: Game, gridx: seq[cint], gridy: seq[cint], image: TexturePtr) =
  # Draw over all drawings of the last frame with the default color
  game.renderer.clear()
  game.draw(gridx, gridy, image)
  
  # Show the result on screen
  game.renderer.present()


#[ ------------------------ Creates Render Window --------------------------- ]#
proc main =
  sdlFailIf(not sdl2.init(INIT_VIDEO or INIT_TIMER or INIT_EVENTS)):
    "SDL2 initialization failed"

  # defer blocks get called at the end of the procedure, even if an
  # exception has been thrown
  defer: sdl2.quit()

  sdlFailIf(not setHint("SDL_RENDER_SCALE_QUALITY", "2")):
    "Linear texture filtering could not be enabled"

  sdlFailIf(ttfInit() == SdlError): "SDL2 TTF initialization failed"
  defer: ttfQuit()

  let window = createWindow(title = "Shift Calendar",
    x = SDL_WINDOWPOS_CENTERED, y = SDL_WINDOWPOS_CENTERED,
    w = WIDTH, h = HEIGHT, flags = SDL_WINDOW_SHOWN)
  sdlFailIf window.isNil: "Window could not be created"
  defer: window.destroy()

  let renderer = window.createRenderer(index = -1,
    flags = Renderer_Accelerated or Renderer_PresentVsync)
  sdlFailIf renderer.isNil: "Renderer could not be created"
  defer: renderer.destroy()

  # Set the default color to use for drawing
  renderer.setDrawColor(r = 0, g = 0, b = 0)
  renderer.clear()

  # Calculate gridarray
  var
    gridArrayx = calcGrid(8, 70)
    gridArrayy = calcGrid(6, 50)

  # Loads background image
  var image = renderer.loadTexture("background.jpg")

  # Loads render window
  var game = newGame(renderer)

  # Game loop, draws each frame
  while not game.inputs[Input.quit]:
    game.handleInput()
    game.render(gridArrayx, gridArrayy, image)
    if game.inputs[Input.restart]:
      window.destroy()
      dates = @[]
      xcoord = 4
      ycoord = 0
      startx = 4
      starty = 0
      offset = 0
      offday = 0
      selectx = 0
      main()
    elif game.inputs[Input.one]:
      offset = 0.cint
    elif game.inputs[Input.two]:
      offset = 1.cint
    elif game.inputs[Input.three]:
      offset = 2.cint
    elif game.inputs[Input.left]:
      offday -= 1.cint
    elif game.inputs[Input.right]:
      offday += 1.cint
    elif game.inputs[Input.quit]:
      quit(QuitSuccess)
    if (offday < 0.cint):
      offday += 7.cint
    else:
      offday = offday mod 7.cint


echo """

       _..._       .-'''-.                                  _..._     
    .-'_..._''.   '   _    \                             .-'_..._''.  
  .' .'      '.\/   /` '.   \     __  __   ___   .--.  .' .'      '.\ 
 / .'          .   |     \  '    |  |/  `.'   `. |__| / .'            
. '            |   '      |  '   |   .-.  .-.   '.--.. '              
| |            \    \     / /    |  |  |  |  |  ||  || |              
| |             `.   ` ..' / _   |  |  |  |  |  ||  || |              
. '                '-...-'`.' |  |  |  |  |  |  ||  |. '              
 \ '.          .          .   | /|  |  |  |  |  ||  | \ '.          . 
  '. `._____.-'/        .'.'| |//|__|  |__|  |__||__|  '. `._____.-'/ 
    `-.______ /       .'.'.-'  /                         `-.______ /  
             `        .'   \_.'                                   `   
                                                                      

3-Day Shift System for COSMIC


Usage (Not case-sensitive):

'A' -> Shifts days to the left
'D' -> Shifts days to the right
'1' -> First rotation starting from 1st day of the month
'2' -> Second rotation starting from 2nd day of the month
'3' -> Third rotation starting from 3rd day of the month

'R' -> Reset program
'Q' -> Exit program

"""


main()


# Calculates execution time
sw.stop()
let totalSeconds = sw.secs
echo "Time: ", totalSeconds
