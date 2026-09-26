local mysql = exports.mysql

addCommandHandler("setlowrp", function(admin, _, targetName)
	if not exports.integration:isPlayerAdmin(admin) then return end

	local target = exports.global:findPlayerByPartialNick(admin, targetName)
	if not target then return end

	local charID = getElementData(target, "dbid")
	if not tonumber(charID) then return end

	setElementData(target, "lowrp", true, true)

	mysql:query_free(
		"UPDATE characters SET low_rp=1 WHERE id=" .. mysql:escape_string(charID)
	)

	outputChatBox("You set LOW RP on "..getPlayerName(target)..".", admin, 0, 255, 0)
	outputChatBox("An admin has marked you as LOW RP.", target, 255, 100, 100)
end)

addCommandHandler("unsetlowrp", function(admin, _, targetName)
	if not exports.integration:isPlayerAdmin(admin) then return end

	local target = exports.global:findPlayerByPartialNick(admin, targetName)
	if not target then return end

	local charID = getElementData(target, "dbid")
	if not tonumber(charID) then return end

	-- remove runtime flag
    removeElementData(target, "lowrp")

	-- persist to DB
mysql:query_free(
    "UPDATE characters SET low_rp=0 WHERE id=" .. mysql:escape_string(getElementData(target, "dbid"))
)

	outputChatBox("You removed LOW RP from "..getPlayerName(target)..".", admin, 0, 255, 0)
	outputChatBox("Your LOW RP status has been removed.", target, 100, 255, 100)
end)
