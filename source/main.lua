-- Common CoreLibs imports.
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

-- Use common shorthands for playdate code
local gfx <const> = playdate.graphics
local geo <const> = playdate.geometry

-- variables
local grid = {}
local gridTotalWidth <const> = playdate.display.getWidth() / 2 - 20
local start <const> = { x = 15, y = 30 }

-- Configurable variables
local size = 10
local xOffset = 0.5
local yOffset = 0.5
local xPosition = 0.0
local yPosition = 0.0

-- Options list view
local optionList = playdate.ui.gridview.new(0, 25)
optionList:setNumberOfRows(5)
optionList:setCellPadding(0, 0, 13, 10)
optionList:setContentInset(24, 24, 13, 11)

local backgroundImage = gfx.image.new(
    playdate.display.getWidth() / 2,
    playdate.display.getHeight(),
    gfx.kColorBlack
)
gfx.lockFocus(backgroundImage)
gfx.setColor(gfx.kColorWhite)
gfx.drawLine(0, 0, 0, playdate.display.getHeight())
gfx.unlockFocus()
optionList.backgroundImage = backgroundImage

function optionList:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(x, y, width, height)
    gfx.setColor(gfx.kColorWhite)
    if selected then
        gfx.fillRoundRect(x, y, width, 20, 4)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    end
    gfx.drawTextInRect("option" .. row, x, y+2, width, height, nil, "...", kTextAlignment.center)
end

-- random = 0, perlin = 1, perlinArray = 2
local generationMethod <const> = 1

--- By convention, most games need to perform some initial setup when they're
--- initially launched. Perform that setup here.
---
--- Note: This will be called exactly once. If you're looking to do something
--- whenever the game is resumed from the background, see playdate.gameWillResume
--- in lifecycle.lua
local function gameDidLaunch()
    print(playdate.metadata.name .. " launched!")

    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)
end
gameDidLaunch()

--- This update method is called once per frame.
function playdate.update()
    if #grid < size then
        for i=1, size, 1 do
            grid[i] = {}
        end

        generatePerlinGrid()

        drawLabel()
        drawGrid()
    end

    optionList:drawInRect(220, 0, 160, 240)
--
--     if playdate.buttonJustPressed(playdate.kButtonA) then
--         generationMethod += 1
--         generationMethod = generationMethod % 3
--         regenerateGrid()
--         drawEverything()
--     end

    -- playdate.drawFPS(0,220)

    -- Update and draw all sprites. Calling this method in playdate.update
    -- is generally what you want, if you're using sprites.
    -- See https://sdk.play.date/1.9.3/#f-graphics.sprite.update for more info
    gfx.sprite.update()

    -- Update all timers once per frame. This is required if you're using
    -- timers in your game.
    -- See https://sdk.play.date/1.9.3/#f-timer.updateTimers for more info
    playdate.timer.updateTimers()
end

function playdate.upButtonDown()
    optionList:selectPreviousRow()
        -- yPosition -= 1
    -- regenerateGrid()
    -- drawEverything()
end

function playdate.downButtonDown()
    optionList:selectNextRow()
    -- yPosition += 1
    -- regenerateGrid()
    -- drawEverything()
end

function playdate.leftButtonDown()
    xPosition -= 1
    regenerateGrid()
    drawEverything()
end

function playdate.rightButtonDown()
    xPosition += 1
    regenerateGrid()
    drawEverything()
end

function regenerateGrid()
    if generationMethod == 0 then
        generateMathRandomGrid()
    elseif generationMethod == 1 then
        generatePerlinGrid()
    else
        generatePerlinArrayGrid()
    end
end

function drawEverything()
    gfx.clear()

    drawLabel()
    drawGrid()
end

function drawLabel()
    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    if generationMethod == 0 then
        gfx.drawText("Math.random", 0, 0)
    elseif generationMethod == 1 then
        gfx.drawText("Perlin single values", 0, 0)
        gfx.drawText(string.format("x = %.2f", xPosition), 240, 0)
        gfx.drawText(string.format("y = %.2f", yPosition), 240, 40)
    else
        gfx.drawText("Perlin array", 0, 0)
        gfx.drawText(string.format("x = %.2f", xPosition), 240, 0)
        gfx.drawText(string.format("y = %.2f", yPosition), 240, 40)
    end
    gfx.popContext()
end

function drawGrid()
    local dx = gridTotalWidth / size

    for row = 1, size, 1 do
        for col = 1, size, 1 do
            local value = grid[col][row]
            local rect = geo.rect.new(
                start.x + (col - 1) * dx,
                start.y + (row - 1) * dx,
                dx,
                dx
            )
            gfx.pushContext()
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(value)
            gfx.fillRect(rect)
            gfx.popContext()
        end
    end
    gfx.pushContext()
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(start.x, start.y, gridTotalWidth, gridTotalWidth)
    gfx.popContext()
end

-- Grid generation
-- function generateMathRandomGrid()
--     for row = 1, size, 1 do
--         for col = 1, size, 1 do
--             local value = math.random()
--             grid[col][row] = value
--         end
--     end
-- end

function generatePerlinGrid()
    for row = 1, size, 1 do
        for col = 1, size, 1 do
            local value = gfx.perlin(
                (col - 1) + xOffset + xPosition,
                (row - 1) + yOffset + yPosition,
                1,
                0
            )
            grid[col][row] = value
        end
    end
end

-- function generatePerlinArrayGrid()
--     for col = 1, size, 1 do
--         local colValues = gfx.perlinArray(size, col / xOffset, 0, 1, 1 / yOffset)
--         grid[col] = colValues
--     end
-- end
