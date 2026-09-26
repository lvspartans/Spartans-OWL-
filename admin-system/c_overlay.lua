local sx, sy = guiGetScreenSize()
local localPlayer = localPlayer or getLocalPlayer()
local openReports = 0
local handledReports = 0
local ckAmount = 0
local unansweredReports = {}
local ownReports = {}
local admstr = ""
local show = false
local fps = 0
local fpsFrames = 0
local fpsTick = getTickCount()
local fontSmall = dxCreateFont(":resources/fonts/Roboto-Regular.ttf", 9) or "default-bold"
local fontTitle = dxCreateFont(":resources/fonts/Roboto-Bold.ttf", 10) or "default-bold"
local overlay = {alpha = 0, targetAlpha = 0, offsetY = 30, targetOffsetY = 0, glow = 0}
local reportBlink = {active = false, startTick = 0}
local panel = {w = 850, h = 32}

local function getAdminTitle(thePlayer)
    return exports.global:getPlayerAdminTitle(thePlayer) or "Admin"
end

local function isOnDuty()
    return getElementData(localPlayer, "duty_admin") == 1 or getElementData(localPlayer, "duty_supporter") == 1
end

local function isStaff()
    return exports.integration:isPlayerStaff(localPlayer)
end

local function getCurrentFPS()
    return fps
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function updateFPS()
    fpsFrames = fpsFrames + 1
    local now = getTickCount()
    if now - fpsTick >= 1000 then
        fps = fpsFrames
        fpsFrames = 0
        fpsTick = now
    end
end
addEventHandler("onClientRender", root, updateFPS)

local function updateBlinkState()
    if #unansweredReports > 0 then
        if not reportBlink.active then
            reportBlink.active = true
            reportBlink.startTick = getTickCount()
        end
    else
        reportBlink.active = false
    end
end

local function getPulseColor()
    if not reportBlink.active then
        return 255, 255, 255
    end

    local elapsed = (getTickCount() - reportBlink.startTick) / 500
    local pulse = (math.sin(elapsed * math.pi * 2) + 1) / 2
    local g

    if #unansweredReports >= 5 then
        g = 40 + (pulse * 50)
    else
        g = 120 + (pulse * 90)
    end

    return 255, g, 0
end

local function createGUI()
    show = isStaff() and isOnDuty()
    overlay.targetAlpha = show and 255 or 0
    overlay.targetOffsetY = show and 0 or 30
end

addEventHandler("onClientResourceStart", resourceRoot, createGUI)

addEventHandler("onClientElementDataChange", localPlayer,
    function(dataName)
        if dataName == "admin_level"
        or dataName == "hiddenadmin"
        or dataName == "account:gmlevel"
        or dataName == "duty_supporter"
        or dataName == "duty_admin" then
            createGUI()
        end
    end
)

addEvent("updateReportsCount", true)
addEventHandler("updateReportsCount", localPlayer,
    function(open, handled, unanswered, own, admst)
        openReports = tonumber(open) or 0
        handledReports = tonumber(handled) or 0
        unansweredReports = type(unanswered) == "table" and unanswered or {}
        ownReports = type(own) == "table" and own or {}
        admstr = tostring(admst or "")
        overlay.glow = 75
        updateBlinkState()
    end
)

addEvent("addOneToCKCount", true)
addEventHandler("addOneToCKCount", localPlayer,
    function()
        ckAmount = ckAmount + 1
    end
)

addEvent("addOneToCKCountFromSpawn", true)
addEventHandler("addOneToCKCountFromSpawn", localPlayer,
    function()
        if ckAmount < 1 then
            ckAmount = ckAmount + 1
        end
    end
)

addEvent("subtractOneFromCKCount", true)
addEventHandler("subtractOneFromCKCount", localPlayer,
    function()
        ckAmount = math.max(0, ckAmount - 1)
    end
)

addEventHandler("onClientPlayerQuit", root,
    function()
        updateBlinkState()
    end
)

local function buildInfoParts()
    local ucp = getElementData(localPlayer, "account:username") or "Unknown"
    local adminTitle = getAdminTitle(localPlayer)
    local ping = getPlayerPing(localPlayer) or 0
    local fpsNow = math.floor(getCurrentFPS() or 0)

    local parts = {
        adminTitle .. " (" .. ucp .. ")"
    }

    if admstr and admstr ~= "" then
        table.insert(parts, admstr)
    end

    table.insert(parts, "Ping: " .. ping)
    table.insert(parts, "FPS: " .. fpsNow)

    return parts
end

local function drawBadge(x, y, text, bgColor, textColor, paddingX)
    paddingX = paddingX or 8

    local textW = dxGetTextWidth(text, 1, fontSmall)
    local w = textW + (paddingX * 2)
    local h = 18

    dxDrawRectangle(x, y, w, h, bgColor, false)
    dxDrawText(text, x, y, x + w, y + h, textColor, 1, fontSmall, "center", "center", false, false, true, true)
    return w
end

local function drawLeftBadge(x, y, text, textColor, alpha, paddingX)
    paddingX = paddingX or 8

    local textW = dxGetTextWidth(text, 1, fontSmall)
    local w = textW + (paddingX * 2)
    local h = 18

    dxDrawRectangle(x, y, w, h, tocolor(55, 55, 55, alpha), false)
    dxDrawText(text, x, y, x + w, y + h, textColor, 1, fontSmall, "center", "center", false, false, true, true)

    return w
end

local function drawOverlay()
    if not show or not exports.hud:isActive() then
        return
    end

    if getPedWeapon(localPlayer) == 43 and getPedControlState(localPlayer, "aim_weapon") then
        return
    end

    overlay.alpha = lerp(overlay.alpha, overlay.targetAlpha, 0.12)
    overlay.offsetY = lerp(overlay.offsetY, overlay.targetOffsetY, 0.10)
    overlay.glow = overlay.glow * 0.90

    if overlay.alpha < 1 then
        return
    end

    local alpha = overlay.alpha
    local py = sy - 32 + overlay.offsetY
    local glow = math.min(70, overlay.glow)

    local statusText = isOnDuty() and "ACTIVE" or "INACTIVE"
    local unansweredCount = #unansweredReports
    local ownCount = #ownReports
    local rr, rg, rb = getPulseColor()

    local spacing = 4
    local padding = 8

    local elements = {}

    local infoParts = buildInfoParts()

    for _, part in ipairs(infoParts) do
        table.insert(elements,{
            text = tostring(part),
            bg = tocolor(55,55,55,alpha),
            tc = tocolor(255,255,255,alpha)
        })
    end

    table.insert(elements,{
        text = statusText,
        bg = tocolor(
            statusText == "ACTIVE" and 50 or 120,
            statusText == "ACTIVE" and 130 or 40,
            statusText == "ACTIVE" and 80 or 40,
            alpha
        ),
        tc = tocolor(255,255,255,alpha)
    })

    table.insert(elements,{
        text = "Unanswered: "..unansweredCount,
        bg = tocolor(120,50,20,alpha),
        tc = tocolor(rr,rg,rb,alpha)
    })

    table.insert(elements,{
        text = "Accepted: "..handledReports,
        bg = tocolor(60,120,70,alpha),
        tc = tocolor(255,255,255,alpha)
    })

    table.insert(elements,{
        text = "My: "..ownCount,
        bg = tocolor(70,70,120,alpha),
        tc = tocolor(255,255,255,alpha)
    })

    table.insert(elements,{
        text = "CK: "..ckAmount,
        bg = tocolor(55,55,55,alpha),
        tc = tocolor(255,255,255,alpha)
    })

    local totalWidth = 20

    for _, v in ipairs(elements) do
        totalWidth = totalWidth + dxGetTextWidth(v.text,1,fontSmall) + (padding * 2) + spacing
    end

    local px = (sx - totalWidth) / 2

    local pulseAlpha = math.floor(glow * (alpha / 255))

    if pulseAlpha > 0 then
        dxDrawRectangle(px - 3, py - 3, totalWidth + 6, panel.h + 6,
            tocolor(85,161,216,math.min(40,pulseAlpha * 0.55)), false)

        dxDrawRectangle(px - 1, py - 1, totalWidth + 2, panel.h + 2,
            tocolor(255,255,255,math.min(16,pulseAlpha * 0.22)), false)
    end

    dxDrawRectangle(px, py, totalWidth, panel.h,
        tocolor(8,8,8,185 * alpha / 255), false)

    dxDrawRectangle(px, py, totalWidth, 2,
        tocolor(85,161,216,alpha), false)

    dxDrawRectangle(px, py + panel.h - 1, totalWidth, 1,
        tocolor(255,255,255,18 * alpha / 255), false)

    if glow > 1 then
        dxDrawRectangle(px, py - 1, totalWidth, 1,
            tocolor(85,161,216,glow), false)
    end

    local currentX = px + 10

    for _, v in ipairs(elements) do
        local w = dxGetTextWidth(v.text,1,fontSmall) + (padding * 2)

        dxDrawRectangle(currentX, py + 7, w, 18, v.bg, false)

        dxDrawText(
            v.text,
            currentX,
            py + 7,
            currentX + w,
            py + 25,
            v.tc,
            1,
            fontSmall,
            "center",
            "center",
            false,
            false,
            true,
            true
        )

        currentX = currentX + w + spacing
    end
end
addEventHandler("onClientRender", root, drawOverlay)