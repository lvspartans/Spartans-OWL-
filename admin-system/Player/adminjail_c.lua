local JailUI = {visible = false, data = nil, secondsLeft = 0, x = 0, y = 45, w = 412, h = 135, alpha = 0}
local sw, sh = guiGetScreenSize()
JailUI.x = (sw - JailUI.w) / 2

addEvent("updateAdminJailCounter", true)
addEventHandler("updateAdminJailCounter", root,
    function(data)
        local wasVisible = JailUI.visible

        JailUI.data = data
        JailUI.visible = data ~= nil

        if data then
            if not wasVisible then
                local sound = playSound(":resources/sounds/jail.ogg")
                if sound then
                    setSoundVolume(sound, 0.4)
                end
            end

            if data.minutesleft >= 999999 then
                JailUI.secondsLeft = 999999999
            else
                JailUI.secondsLeft = data.minutesleft * 60
            end
        end
    end
)

setTimer(function()
    if JailUI.visible and JailUI.secondsLeft > 0 and JailUI.secondsLeft < 999999999 then
        JailUI.secondsLeft = JailUI.secondsLeft - 1
    end
end, 1000, 0)

local function updateFade()
    if JailUI.visible and JailUI.alpha < 255 then
        JailUI.alpha = math.min(255, JailUI.alpha + 12)
    elseif not JailUI.visible and JailUI.alpha > 0 then
        JailUI.alpha = math.max(0, JailUI.alpha - 12)
    end
end

local function drawJailUI()
    updateFade()

    if JailUI.alpha <= 0 or not JailUI.data then return end

    local x, y, w, h = JailUI.x, JailUI.y, JailUI.w, JailUI.h
    local a = JailUI.alpha

    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 170 * a/255), true)
    dxDrawRectangle(x, y, w, 4, tocolor(85,161,216,a), true)
    dxDrawText("ADMIN JAIL SENTENCE", x, y+5, x+w, y+35, tocolor(255,255,255,a), 1.1, "default-bold", "center", "center")
    dxDrawText("Reason: "..(JailUI.data.reason or "Unknown"), x+15, y+35, x+w-15, y+70, tocolor(255,255,255,255), 1, "default-bold", "center", "center", true)

    local timeText
    if JailUI.secondsLeft >= 999999999 then
        timeText = "PERMANENT"
    else
        timeText = exports.datetime:formatSeconds(JailUI.secondsLeft)
    end
    dxDrawText(timeText, x, y+65, x+w, y+105, tocolor(85,161,216,255), 1.5, "bankgothic", "center", "center")
    dxDrawText("Jailed by: "..(JailUI.data.admin or "Unknown"), x, y+105, x+w, y+h, tocolor(200,200,200,a), 0.9, "default", "center", "center")
end
addEventHandler("onClientRender", root, drawJailUI)

addEventHandler("onClientPlayerSpawn", localPlayer,
    function()
        JailUI.visible = false
        JailUI.data = nil
        JailUI.secondsLeft = 0
    end
)
