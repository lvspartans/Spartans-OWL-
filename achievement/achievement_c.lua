local achievement = {
    visible = false,
    alpha = 0,
    x = 0,
    y = 0,
    targetX = 0,
    width = 420,
    height = 90,
    title = "",
    desc = "",
    gc = 0,
    startTick = 0,
    state = "in"
}

local SHOW_TIME = 8000
local SLIDE_SPEED = 18
local FADE_SPEED = 8
local newfonts = dxCreateFont (":resources/fonts/bold.ttf" , 12)

addEvent("displayAchievement", true)
function displayAchievement(title, desc, gc)
    local sw, sh = guiGetScreenSize()

    achievement.title = title and string.upper(title) or "ACHIEVEMENT UNLOCKED"
    achievement.desc = desc or ""
    achievement.gc = tonumber(gc) or 0

    achievement.alpha = 0
    achievement.width = 420
    achievement.height = 90

    achievement.x = sw
    achievement.targetX = sw - achievement.width - 25
    achievement.y = sh - achievement.height - 25

    achievement.startTick = getTickCount()
    achievement.state = "in"
    achievement.visible = true

    playSound("sounds/achievement.mp3", false)
end
addEventHandler("displayAchievement", root, displayAchievement)

addEventHandler("onClientRender", root,
function()
    if not achievement.visible then return end
    local now = getTickCount()
    if achievement.state == "in" then
        achievement.x = achievement.x - SLIDE_SPEED
        achievement.alpha = math.min(achievement.alpha + FADE_SPEED, 200)
        if achievement.x <= achievement.targetX then
            achievement.x = achievement.targetX
            achievement.state = "show"
            achievement.startTick = now
        end
    end
    if achievement.state == "show" then
        if now - achievement.startTick >= SHOW_TIME then
            achievement.state = "out"
        end
    end
    if achievement.state == "out" then
        achievement.x = achievement.x + SLIDE_SPEED
        achievement.alpha = achievement.alpha - FADE_SPEED

        if achievement.alpha <= 0 then
            achievement.visible = false
            return
        end
    end
    drawAchievement()
end)

function drawAchievement()
    local x, y = achievement.x, achievement.y
    local w, h = achievement.width, achievement.height
    local a = achievement.alpha
    -- Background
    dxDrawRectangle(x, y, w, h, tocolor(20, 20, 20, a))
    dxDrawRectangle(x, y, 5, h, tocolor(85, 161, 216, a))
    -- Title
    dxDrawText(achievement.title,x + 15, y + 10,x + w - 10, y + 30,tocolor(85, 161, 216, a),1,"default-bold","left","top")
    -- Description
    dxDrawText(achievement.desc,x + 15, y + 33,x + w - 10, y + h - 30,tocolor(220, 220, 220, a),1,newfonts,"left","top",true, true)
    -- GC reward (icon + text)
    if achievement.gc > 0 then
        local iconSize = 14
        local iconX = x + 15
        local iconY = y + h - 22
        -- Coin icon
        dxDrawImage(iconX,iconY - 4,iconSize,iconSize,":donators/gamecoin.png",0, 0, 0,tocolor(255, 255, 255, a))
        dxDrawText("+ " .. achievement.gc .. " GC",iconX + iconSize + 6,iconY - 8,x + w - 10,iconY + iconSize,tocolor(255, 215, 0, a),1,newfonts,"left","center")
    end
end