local showMessage = false
local messageText = ""
local messageStartTime = 0
local messageDuration = 5000
local screenW, screenH = guiGetScreenSize()
local annRole = "admin"
local titleFont = dxCreateFont(":resources/fonts/bold.ttf", 13)
local textFont  = dxCreateFont(":resources/fonts/clbold.ttf", 10)

local function wrapText(text, maxWidth, scale, font)
    local lines = {}
    local words = split(text, " ")
    local currentLine = ""
    for _, word in ipairs(words) do
        local testLine = currentLine .. word .. " "
        if dxGetTextWidth(testLine, scale, font) > maxWidth then
            table.insert(lines, currentLine)
            currentLine = word .. " "
        else
            currentLine = testLine
        end
    end
    table.insert(lines, currentLine)
    return lines
end

local function showAnnMessage(text, role)
    local lowerText = string.lower(text)
    if string.find(lowerText, "sup announcement:") then
        annRole = "supporter"
    else
        annRole = "admin"
    end
    text = string.gsub(text, "[Aa]dmin [Aa]nnouncement:%s*", "")
    text = string.gsub(text, "[Ss][Uu][Pp] [Aa]nnouncement:%s*", "")
    messageText = text
    messageStartTime = getTickCount()
    showMessage = true
end

addEventHandler("onClientRender", root, function()
    if not showMessage then return end
    local elapsed = getTickCount() - messageStartTime
    if elapsed > messageDuration then
        showMessage = false
        return
    end
    local alpha = 255
    if elapsed > messageDuration - 1000 then
        alpha = 255 - ((elapsed - (messageDuration - 1000)) / 1000 * 255)
    end
    local boxWidth = 600
    local x = (screenW - boxWidth) / 2
    local startY = -120
    local targetY = screenH * 0.01
    local animTime = 600
    local y
    if elapsed < animTime then
        local t = elapsed / animTime
        local ease = 1 - (1 - t) ^ 3
        y = startY + (targetY - startY) * ease
    else
        y = targetY
    end
    local titleText = "ADMIN ANNOUNCEMENT"
    local titleColor = tocolor(255, 194, 14, alpha)
    if annRole == "supporter" then
        titleText = "SUPPORTER ANNOUNCEMENT"
        titleColor = tocolor(80, 220, 120, alpha)
    end
    local accentColor = tocolor(85, 161, 216, 200 * (alpha / 255))
    local textColor = tocolor(200, 200, 200, alpha)
    local lines = wrapText(messageText, boxWidth - 40, 1, textFont)
    local lineHeight = 22
    local textHeight = #lines * lineHeight
    local boxHeight = 50 + textHeight
    local progress = 1 - (elapsed / messageDuration)
    if progress < 0 then progress = 0 end
    local progressBarHeight = 3
    local progressBarWidth = boxWidth * progress
    dxDrawRectangle(x, y, boxWidth, boxHeight, tocolor(0, 0, 0, 170 * (alpha / 255)), true)
    dxDrawRectangle(x, y, boxWidth, 3, accentColor, true)
    dxDrawRectangle(x, y + boxHeight - progressBarHeight, boxWidth, progressBarHeight, tocolor(20, 20, 20, 160 * (alpha / 255)), true)
    dxDrawRectangle(x, y + boxHeight - progressBarHeight, progressBarWidth, progressBarHeight, accentColor, true)
    dxDrawText(titleText, x, y + 10, x + boxWidth, y + 28, titleColor, 1, titleFont, "center", "top", false, false, true)
    dxDrawRectangle(x + 20, y + 35, boxWidth - 40, 1, tocolor(180, 180, 180, 160 * (alpha / 255)), true)
    for i, line in ipairs(lines) do
        local ty = y + 46 + (i - 1) * lineHeight
        dxDrawText(line, x + 20, ty, x + boxWidth - 20, ty + lineHeight, textColor, 1, textFont, "center", "top", false, false, true)
    end
end)

local function playAnnSound()
    playSound("announcement.mp3", false)
end

addEvent("announcement:post", true)
addEventHandler("announcement:post", root, function(text)
    showAnnMessage(text)
    playAnnSound()
end)