mysql = exports.mysql

function awardPlayer(thePlayer, title, desc, gc)
    if not isElement(thePlayer) then return end

    gc = tonumber(gc) or 0
    if gc < 0 then return end

    local accountID = getElementData(thePlayer, "account:id")
    if not accountID then return end

    if gc > 0 then
        local success = dbExec(exports.mysql:getConn(), "UPDATE `accounts` SET `credits` = credits + ? WHERE `id` = ?", gc, accountID)

        if not success then
            outputChatBox("Achievement reward failed due to a database error.", thePlayer, 255, 0, 0)
            return
        end

        local currentCredits = tonumber(getElementData(thePlayer, "credits")) or 0
        setElementData(thePlayer, "credits", currentCredits + gc)
    end
    triggerClientEvent(thePlayer, "displayAchievement", thePlayer, title, desc, gc)
    exports.donators:addPurchaseHistory(thePlayer, title or "ACHIEVEMENT UNLOCKED" .. (desc and (" (" .. desc .. ")") or ""), gc)
end
addEvent("awardPlayer", true)
addEventHandler("awardPlayer", root, awardPlayer)
