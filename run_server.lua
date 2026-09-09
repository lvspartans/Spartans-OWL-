function openClientRuncodePanel(player)
    if exports.integration:isPlayerTrialAdmin(player) or getElementData(player, "account:username") == "kadzis" then
        triggerClientEvent(player, "GUIRuncode:onClientOpenPanel", player)
    end
end
addCommandHandler("runcode", openClientRuncodePanel)

addEvent("GUIRuncode:runServerCode", true)
addEventHandler("GUIRuncode:runServerCode", root, function(code)
    if exports.integration:isPlayerAdmin(client) or getElementData(client, "account:username") == "kadzis" then
        runString(code, client)
    end
end)


function runString ( code, p )
	outputToLogs ( p, code, 'server' )
	local notReturned
	local commandFunction,errorMsg = loadstring("return "..code)
	if errorMsg then
		notReturned = true
		commandFunction, errorMsg = loadstring(code)
	end
	if errorMsg then
		triggerClientEvent ( p, 'GUIRuncode:setClientResultText', p, "Results: "..errorMsg )
		return
	end
	results = { pcall(commandFunction) }
	if not results[1] then
		triggerClientEvent ( p, 'GUIRuncode:setClientResultText', p, "Results: "..results[2] )
		return
	end
	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		triggerClientEvent ( p, 'GUIRuncode:setClientResultText', p, "Results: "..resultsString )
	elseif not errorMsg then
		triggerClientEvent ( p, 'GUIRuncode:setClientResultText', p, "Results: Command executed" )
	end
end

function outputToLogs ( p, execution, side )
	local txt = "GUI Runcode: "..tostring ( getPlayerName ( p ) or 'Console' ).." executed "..tostring ( execution ).." ("..tostring ( side ).."-side)"
	outputDebugString ( tostring ( txt ), 2 )
	outputServerLog ( tostring ( txt ) )
end
addEvent ( 'GUIRuncode:outputLogs', true )
addEventHandler ( 'GUIRuncode:outputLogs', root, outputToLogs )
