local OFFLINEMODE, ACCOUNT_ID, ACCOUNT_USERNAME = false, nil, nil

function enterCommand(commandName, ...)
	triggerServerEvent("checkCommandEntered", getLocalPlayer(), getLocalPlayer(), commandName, ...)
end
addCommandHandler("check", enterCommand, false, false)

function CreateCheckWindow()
	local width, height = guiGetScreenSize()
	Button = {}
	Window = guiCreateWindow(width-400,height/4,400,385,"Account Check - Player Online",false)
	guiWindowSetSizable(Window, false)
	Button[3] = guiCreateButton(0.85,0.86,0.12, 0.125,"Close",true,Window)
	addEventHandler( "onClientGUIClick", Button[3], CloseCheck )
	Label = {
		guiCreateLabel(0.03,0.06,0.95,0.0887,"Name: N/A",true,Window),
		guiCreateLabel(0.03,0.10,0.66,0.0887,"IP: N/A",true,Window),
		guiCreateLabel(0.03,0.26,0.66,0.0887,"Money: N/A",true,Window),
		guiCreateLabel(0.03,0.30,0.17,0.0806,"Health: N/A",true,Window),
		guiCreateLabel(0.03,0.34,0.17,0.0806,"Skin: N/A",true,Window),
		guiCreateLabel(0.55,0.30,0.30,0.0806,"Weapon: N/A",true,Window),
		guiCreateLabel(0.55,0.34,0.30,0.0806,"Armor: N/A",true,Window),
		guiCreateLabel(0.03,0.38,0.66,0.0806,"Faction: N/A",true,Window),
		guiCreateLabel(0.03,0.18,0.66,0.0806,"Ping: N/A",true,Window),
		guiCreateLabel(0.03,0.42,0.56,0.0806,"Vehicle: N/A",true,Window),
		guiCreateLabel(0.55,0.38,0.66,0.0806,"Warns: N/A",true,Window),
		guiCreateLabel(0.55,0.42,0.97,0.0766,"Location: N/A",true,Window),
		guiCreateLabel(0.7,0.06,0.4031,0.0766,"X:",true,Window),
		guiCreateLabel(0.7,0.10,0.4031,0.0766,"Y: N/A",true,Window),
		guiCreateLabel(0.7,0.14,0.4031,0.0766,"Z: N/A",true,Window),
		guiCreateLabel(0.7,0.18,0.2907,0.0806,"Interior: N/A",true,Window),
		guiCreateLabel(0.7,0.22,0.2907,0.0806,"Dimension: N/A",true,Window),
		guiCreateLabel(0.03,0.14,0.66,0.0887,"Staff Rank: N/A", true,Window),
		guiCreateLabel(0.7,0.26,0.4093,0.0806,"Hours on Character: N/A\n~ Total: N/A",true,Window),
		guiCreateLabel(0.03,0.22,0.66,0.0887,"GameCoins: N/A", true,Window),
		guiCreateLabel(0.03,0.50,0.66,0.0806,"",true,Window),
	}

	-- player notes
	memo = guiCreateMemo(0.03, 0.55, 0.8, 0.42, "", true, Window)
	addEventHandler( "onClientGUIClick", Window,
		function( button, state )
			if button == "left" and state == "up" then
				if source == memo then
					guiSetInputEnabled( true )
				else
					guiSetInputEnabled( false )
				end
			end
		end
	)
	Button[4] = guiCreateButton(0.85,0.60, 0.12,0.125,"Save\nNote",true,Window)
	addEventHandler( "onClientGUIClick", Button[4], SaveNote, false )

	Button[5] = guiCreateButton(0.03, 0.47, 0.80, 0.07,"History: N/A",true,Window)
	addEventHandler( "onClientGUIClick", Button[5], ShowHistory, false ) 

	Button[6] = guiCreateButton(0.85,0.73,0.12,0.125,"Inv.",true,Window)
	addEventHandler( "onClientGUIClick", Button[6], showInventory, false )

	Button[7] = guiCreateButton(0.85,0.47,0.12,0.125,"Copy Admin Details",true,Window)
	addEventHandler( "onClientGUIClick", Button[7], function(button, state)
		if ( button == "left" ) then
			local time = getRealTime()
			local content = table.concat({"","(" .. tostring(time.monthday) .. "/" ..tostring(time.month + 1) .. "/" ..tostring(time.year + 1900) .. ")", getElementData(localPlayer, "account:username")}, " - ")
			if setClipboard(content) then
				outputChatBox("Admin details successfully copied to clipboard.", 0, 255, 0)
			end
		end
	end, false )

	guiSetVisible(Window, false)

	triggerEvent("hud:convertUI", localPlayer, Window)
end

function OpenCheck( ip, adminreports, donPoints, note, history, warns, points, transfers, bankmoney, money, adminlevel, hoursPlayed, accountname, hoursAcc, accountID, offline )
	if Window and isElement(Window) then
		destroyElement(Window)
		showCursor(false)
	end

	ACCOUNT_ID = accountID
	ACCOUNT_USERNAME = accountname

	if offline then
		OFFLINEMODE = true
	else
		OFFLINEMODE = false
	end

	CreateCheckWindow()
	player = source

	if not OFFLINEMODE then
		guiSetText(Label[1], "Username: "..accountname.." (" .. getPlayerName(player):gsub("_", " ")..")")
	else
		guiSetText(Label[1], "Username: " .. accountname)
		guiSetText(Button[6], "N/A")
		guiSetText(Window, "Account Check - Player Offline")
		guiSetProperty(Button[6], "Disabled", "True")
	end

	if adminreports == nil then
		adminreports = "-1"
	end

	if donPoints == nil then
		donPoints = "Unknown"
	end

	if transfers == nil then
		transfers = "N/A"
	end

	if points == nil then
		points = "N/A"
	end

	if warns == nil then
		warns = "N/A"
	end

	if history == nil then
		history = "N/A"
	else
		local total = 0
		local str = {}
		local gramma = "Active Point"

		if tonumber(points) > 1 then 
			gramma = "Active Points"
		end

		if tonumber(points) > 0 then
			table.insert(str, points .. " " .. gramma)
		end
		
		history = table.concat(str, " - ")
	end

	if bankmoney == nil then
		bankmoney = "-1"
	end

	guiSetText ( Label[2], "IP: " .. ip )
	guiSetText ( Label[18], "Staff Rank: " ..adminlevel.. " (" .. adminreports .. " Reports)" )
	guiSetText ( Label[11], "Warns: " .. warns )
	if not exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
		guiSetText ( Label[3], "Money: N/A (Bank: N/A)")
	else
		guiSetText ( Label[3], "Money: $" .. exports.global:formatMoney(money) .. " (Bank: $" .. exports.global:formatMoney(bankmoney) .. ")")
	end
	guiSetText ( Button[5], history )
	guiSetText ( Label[20], "GameCoins: " .. exports.global:formatMoney(donPoints) )
	guiSetText ( Label[19], "Hours Char: " .. ( hoursPlayed or "N/A" ) .. "\n~ Total: " .. ( hoursAcc or "N/A" ) )

	if (player == getLocalPlayer()) and not exports.integration:isPlayerAdmin(getLocalPlayer()) and not OFFLINEMODE then
		guiSetText ( memo, "-You can not view your own note-")
		guiMemoSetReadOnly(memo, true)
		guiSetEnabled(Button[4], false)
	elseif not exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
		guiSetText ( memo, "-You do not have access to admin note-")
		guiMemoSetReadOnly(memo, true)
		guiSetEnabled(Button[4], false)
	else
		guiSetText ( memo, note or "ERROR: COULD NOT FETCH NOTE")
		guiSetEnabled(Button[4], true)
		guiMemoSetReadOnly(memo, false)
	end
	
	if not guiGetVisible( Window ) then
		guiSetVisible(Window, true)
	end
end

addEvent( "onCheck", true )
addEventHandler( "onCheck", getRootElement(), OpenCheck )

function getPlayerTeams(thePlayer)
	playerFactions = {}
	for k,v in pairs(getElementData(thePlayer, "faction")) do
		table.insert(playerFactions, k)
	end
	return "Factions: " .. table.concat(playerFactions, ", ") or "Factions: N/A"
end

local function canSeeAdminHoverInfo()
    if getElementData(localPlayer, "loggedin") ~= 1 then
        return false
    end

    if getElementData(localPlayer, "hiddenadmin") == 1 then
        return false
    end

    local adminLevel = tonumber(getElementData(localPlayer, "admin_level")) or 0
    local adminDuty = tonumber(getElementData(localPlayer, "duty_admin")) == 1
    local supporterDuty = tonumber(getElementData(localPlayer, "duty_supporter")) == 1

    if adminLevel > 0 and adminDuty then
        return true
    end

    if exports.integration:isPlayerSupporter(localPlayer) and supporterDuty then
        return true
    end

    return false
end

local function formatMoney(amount)
    amount = tonumber(amount) or 0
    local formatted = tostring(amount)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return "$" .. formatted
end

local function getPlayerAdminRank(player)
    if getElementData(player, "hiddenadmin") == 1 then
        return "Hidden Admin"
    end

    local adminLevel = tonumber(getElementData(player, "admin_level")) or 0
    local supporterDuty = tonumber(getElementData(player, "duty_supporter")) == 1

    if exports.integration:isPlayerSupporter(player) and supporterDuty then
        return "Supporter"
    end

    if adminLevel == 5 then
        return "Owner"
    elseif adminLevel == 4 then
        return "Head Admin"
    elseif adminLevel == 3 then
        return "Senior Admin"
    elseif adminLevel == 2 then
        return "Admin"
    elseif adminLevel == 1 then
        return "Trial Admin"
    end

    return "Player"
end

local function getPlayerVehicleName(player)
    local veh = getPedOccupiedVehicle(player)
    if not veh then
        return "N/A"
    end

    local name = getVehicleName(veh)
    return name or "Vehicle"
end

local function getPlayerInteriorText(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    return tostring(interior or 0), tostring(dimension or 0)
end

local function getPlayerCountry(player)
    local country = getElementData(player, "country")
    if type(country) == "string" and country ~= "" then
        return country
    end
    return "N/A"
end

local function getPlayerHours(player)
    return tonumber(getElementData(player, "hoursplayed")) or 0
end

local function getPlayerTotalHours(player)
    return tonumber(getElementData(player, "hoursplayed")) or 0
end

local function getPlayerArmor(player)
    return math.floor(getPedArmor(player) or 0)
end

local function getPlayerHealth(player)
    local hp = getElementHealth(player) or 100
    return math.floor(hp)
end

local function getPlayerGunName(player)
    local weapon = getPedWeapon(player)
    if not weapon or weapon == 0 then
        return "Fist"
    end

    local name = getWeaponNameFromID(weapon)
    return name or "Unknown"
end

local function getPlayerSkin(player)
    return tonumber(getElementModel(player)) or 0
end

local function getPlayerWarns(player)
    return tonumber(getElementData(player, "warns")) or 0
end

local function getPlayerGMCoins(player)
    return tonumber(getElementData(player, "credits")) or tonumber(getElementData(player, "gc")) or 0
end

local function getPlayerBankMoney(player)
    return tonumber(getElementData(player, "bankmoney")) or 0
end

local function getPlayerCash(player)
    return tonumber(getElementData(player, "money")) or getPlayerMoney(player) or 0
end

local function getPlayerReports(player)
    return tonumber(getElementData(player, "adminreports")) or tonumber(getElementData(player, "reports")) or 0
end

local function getPlayerAdminHoverLines(player)
    local username = getElementData(player, "account:username") or getElementData(player, "account:name") or "Unknown"
    local charName = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):gsub("_", " ")
    local ip = getPlayerIP(player) or "N/A"

    local x, y, z = getElementPosition(player)
    local interior, dimension = getPlayerInteriorText(player)

    local gender = tonumber(getElementData(player, "gender")) or 0
    local genderText = (gender == 1 and "Male") or (gender == 2 and "Female") or "N/A"

    local lines = {
        "Username: " .. tostring(username) .. " (" .. charName .. ")",
        "IP: " .. tostring(ip),
        "Staff Rank: " .. getPlayerAdminRank(player) .. " (" .. tostring(getPlayerReports(player)) .. " Reports)",
        "Ping: " .. tostring(getPlayerPing(player)),
        "GameCoins: " .. tostring(getPlayerGMCoins(player)),
        "Money: " .. formatMoney(getPlayerCash(player)) .. " (Bank: " .. formatMoney(getPlayerBankMoney(player)) .. ")",
        "Health: " .. tostring(getPlayerHealth(player)),
        "Armour: " .. tostring(getPedArmor(player)),
        "Factions: " .. getFactionName(player),
        "Vehicle: " .. getPlayerVehicleName(player),
        "X: " .. string.format("%.5f", x),
        "Y: " .. string.format("%.5f", y),
        "Z: " .. string.format("%.5f", z),
        "Interior: " .. interior,
        "Dimension: " .. dimension,
        "Hours Char: " .. tostring(getPlayerHours(player)) .. "  Total: " .. tostring(getPlayerTotalHours(player)),
        "Skin: " .. tostring(getElementModel(player)) .. "  " .. genderText,
        "Weapon: " .. getPlayerGunName(player),
        "Warns: " .. tostring(getPlayerWarns(player)),
        "Location: " .. getPlayerCountry(player)
    }

    return lines
end

addEventHandler( "onClientRender", getRootElement(),
	function()
		if Window and isElement(Window) and guiGetVisible(Window) and isElement( player ) then
			local x, y, z = 0, 0, 0
			
			if OFFLINEMODE then 
				guiSetText (Label[13], "X: N/A")
				guiSetText (Label[14], "Y: N/A")
				guiSetText (Label[15], "Z: N/A")
			elseif not exports.integration:isPlayerSupporter(getLocalPlayer()) and getElementAlpha(player) ~= 0 or exports.integration:isPlayerLeadAdmin(getLocalPlayer()) then
				x, y, z = getElementPosition(player)
				guiSetText ( Label[13], "X: " .. string.format("%.5f", x) )
				guiSetText ( Label[14], "Y: " .. string.format("%.5f", y) )
				guiSetText ( Label[15], "Z: " .. string.format("%.5f", z) )
			end

			if not OFFLINEMODE then 
				guiSetText ( Label[4], "Health: " .. math.floor( getElementHealth( player ) ) )
				guiSetText ( Label[5], "Armour: " .. math.floor( getPedArmor( player ) ) )
				guiSetText ( Label[6], "Skin: " .. getElementModel( player ) )
			else
				guiSetText ( Label[4], "Health: N/A " )
				guiSetText ( Label[5], "Armour: N/A " )
				guiSetText ( Label[6], "Skin: N/A " )
			end 

			local weapon = getPedWeapon( player )
			if weapon then
				weapon = getWeaponNameFromID( weapon )
			elseif OFFLINEMODE then 
				weapon = "N/A"
			else
				weapon = "N/A"
			end
			guiSetText ( Label[7], "Weapon: " .. weapon )

			if not OFFLINEMODE then
				guiSetText ( Label[8], getPlayerTeams(player))
				guiSetText ( Label[9], "Ping: " .. getPlayerPing( player ) )
			end

			local vehicle = getPedOccupiedVehicle( player )
			if vehicle and not exports.integration:isPlayerSupporter(getLocalPlayer()) and not OFFLINEMODE then
				guiSetText ( Label[10], "Vehicle: "..getElementData( vehicle, "dbid" ) .. "")
			else
				guiSetText ( Label[10], "Vehicle: N/A")
			end

			guiSetText ( Label[12], "Location: N/A" )
			guiSetText ( Label[16], "Interior: N/A" )
			guiSetText ( Label[17], "Dimension: N/A" )
		end
	end
)

function CloseCheck( button, state )
	if source == Button[3] and button == "left" and state == "up" then
		--triggerEvent("cursorHide", getLocalPlayer())
		--guiSetVisible( Window, false )
		--guiSetInputEnabled( false )
		--player = nil
		destroyElement(Window)
		showCursor(false)
	end
end

function SaveNote( button, state )
	if source == Button[4] and button == "left" and state == "up" then
		local text = guiGetText(memo)
		if text then
			triggerServerEvent("savePlayerNote", getLocalPlayer(), ACCOUNT_ID, ACCOUNT_USERNAME, text)
		end
	end
end

function ShowHistory( button, state )
	if source == Button[5] and button == "left" and state == "up" then
		triggerServerEvent("showOfflineAdminHistory", getLocalPlayer(), ACCOUNT_ID, ACCOUNT_USERNAME)
	end
end

function showInventory( button, state )
	if source == Button[6] and button == "left" and state == "up" then
		if not exports.integration:isPlayerSupporter(getLocalPlayer()) then
			triggerServerEvent( "admin:showInventory", player )
		end
	end
end

local wHist, gHist, bClose, lastElement

-- window


addEvent( "cshowAdminHistory", true )
addEventHandler( "cshowAdminHistory", getRootElement(),
	function( info, targetID )
		if wHist then
			destroyElement( wHist )
			wHist = nil

			showCursor( false )
		else
			local sx, sy = guiGetScreenSize()

			local name
			if targetID == nil then
				name = getPlayerName( source )
			else
				name = "Account " .. tostring(targetID)
			end

			wHist = guiCreateWindow( sx / 2 - 350, sy / 2 - 250, 800, 600, "Admin History: ".. name, false )

			-- date, action, reason, duration, a.username, c.charactername, id

			gHist = guiCreateGridList( 0, 0.04, 1, 0.88, true, wHist )
			local colID = guiGridListAddColumn( gHist, "ID", 0.05 )
			local colAction = guiGridListAddColumn( gHist, "Action", 0.07 )
			local colChar = guiGridListAddColumn( gHist, "Character", 0.2 )
			local colReason = guiGridListAddColumn( gHist, "Reason", 0.25 )
			local colDuration = guiGridListAddColumn( gHist, "Time", 0.07 )
			local colAdmin = guiGridListAddColumn( gHist, "Admin", 0.15 )
			local colDate = guiGridListAddColumn( gHist, "Date", 0.15 )


			for _, res in pairs( info ) do
				local row = guiGridListAddRow( gHist )
				guiGridListSetItemText( gHist, row, colID,   res[7]  or "?", false, true )
				guiGridListSetItemText( gHist, row, colAction, getHistoryAction(res[2]), false, false )
				guiGridListSetItemText( gHist, row, colChar, res[6], false, false )
				guiGridListSetItemText( gHist, row, colReason, res[3], false, false )
				guiGridListSetItemText( gHist, row, colDuration, historyDuration( res[4], tonumber( res[2] ) ), false, false )
				guiGridListSetItemText( gHist, row, colAdmin, res[5], false, false )
				guiGridListSetItemText( gHist, row, colDate, res[1], false, false )
			end


			local bremove = guiCreateButton( 0, 0.93, 0.5, 0.07, "Remove", true, wHist )
			addEventHandler( "onClientGUIClick", bremove,
				function( button, state )
					if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer) then
						local row, col = guiGridListGetSelectedItem( gHist )
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( gHist , row, col )
							local record = getHistoryRecordFromId(info, gridID)
							if tonumber(record[2]) == 6 then
								return outputChatBox( "This record is not removable.", 255, 0, 0 )
							end
							if not exports.integration:isPlayerLeadAdmin(localPlayer) and tonumber(record[8]) ~= getElementData(localPlayer, "account:id") then
								return outputChatBox( "You can only remove admin history that you're the creator. Otherwise, it requires a Lead Admin or higher up.", 255, 0, 0 )
							end
							triggerServerEvent("admin:removehistory", getLocalPlayer(), gridID)
							destroyElement( wHist )
							wHist = nil
							showCursor( false )
						else
							outputChatBox( "You need to pick a record.", 255, 0, 0 )
						end
					else
						outputChatBox( "Please submit a ticket on Support Center to appeal and get this admin history record removed.", 255, 0, 0 )
					end
				end, false
			)


			bClose = guiCreateButton( 0.52, 0.93, 0.47, 0.07, "Close", true, wHist )
			addEventHandler( "onClientGUIClick", bClose,
				function( button, state )
					if button == "left" and state == "up" then
						destroyElement( wHist )
						wHist = nil

						showCursor( false )
					end
				end, false
			)

			showCursor( true )
			triggerEvent("hud:convertUI", localPlayer, wHist)
		end
	end
)
