mysql = exports.mysql
integration = exports.integration
pool = exports.pool

addCommandHandler("ann",
function(player, commandName, ...)
    local isLoggedIn = getElementData(player, "loggedin") == 1
    if not isLoggedIn then return end
    if integration:isPlayerTrialAdmin(player) or integration:isPlayerSupporter(player) then
        if not (...) then
            outputChatBox("SYNTAX: /" .. commandName .. " [Message]", player, 255, 194, 14)
            return
        end
        local message = table.concat({...}, " ")
        local players = exports.pool:getPoolElementsByType("player")
        local username = getPlayerName(player)
        for _, arrayPlayer in ipairs(players) do
            if integration:isPlayerTrialAdmin(player) then
                triggerClientEvent(arrayPlayer, "announcement:post", arrayPlayer, message, "admin")
            elseif integration:isPlayerSupporter(player) then
                triggerClientEvent(arrayPlayer, "announcement:post", arrayPlayer, message, "supporter")
            end
        end
        outputConsole("Adm/SUPCmd: " .. message)
        exports.global:sendMessageToAdmins("Adm/SUPCmd: " .. username .. " made an announcement")
        exports.logs:dbLog(player, 4, player, "ANN " .. message)
    end
end, false, false)