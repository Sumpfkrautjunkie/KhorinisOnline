--stores all players
player = {}

--gives playerid a random playercolor
function RandomPlayerColor(playerid)
	
	--color should be bright and saturated, to be better visible
	--algorithm hard to explain here, just look at a color piker and the colors possible in the
	--selected ranges
	local colorTable={255,math.random(120,255),math.random(120,190)} 
	local shuffledTable=shuffled(colorTable)
	
	
	local r,g,b=shuffledTable[1],shuffledTable[2],shuffledTable[3]
	SetPlayerColor(playerid,r,g,b)
end
--gives test start equipment
function GiveStartEquipment(playerid)
	GiveItem(playerid, "itmi_gold", 200)
	GiveItem(playerid, "ItFo_Addon_SchnellerHering", 200)
	GiveItem(playerid, "ItRi_Str_01", 3)
	GiveItem(playerid, "ItAm_Strg_01", 3)
	GiveItem(playerid, "ItWr_ZweihandBuch", 3)
	GiveItem(playerid, "StandardBrief",3)	
	GiveItem(playerid, "ItBe_Addon_Prot_Total", 3)
	GiveItem(playerid, "ItAt_DragonEgg_Mis", 10)
	GiveItem(playerid, "ItAt_Wing", 200)
	GiveItem(playerid, "ItAt_WargFur", 200)
	GiveItem(playerid, "ItWr_Map_NewWorld", 2)
	GiveItem(playerid, "ItFo_Apple", 200)
	GiveItem(playerid, "ItFo_Beer", 200)	
	GiveItem(playerid, "ItFo_Bread", 200)
	GiveItem(playerid, "ItPl_Blueplant", 200)
	GiveItem(playerid, "ItPl_Mushroom_01", 200)
	GiveItem(playerid, "ItPl_Mana_Herb_03", 200)
	GiveItem(playerid, "ItRi_Prot_Edge_01", 200)
	GiveItem(playerid, "ItAr_Bau_L", 1)
	GiveItem(playerid, "ItAr_Bau_M", 1)	
	GiveItem(playerid, "ItAr_Mil_M", 1)
	GiveItem(playerid, "ItSc_Lightningflash", 200)
	GiveItem(playerid, "ItSc_Sleep", 200)
	GiveItem(playerid, "ItSc_SumWolf", 200)
	GiveItem(playerid, "ItPo_Perm_Str", 200)
	GiveItem(playerid, "ItPo_Health_Addon_04", 200)
	GiveItem(playerid, "ItPo_Mana_Addon_04", 200)	
	GiveItem(playerid, "ItPo_Perm_Mana", 200)
	GiveItem(playerid, "ItMw_1H_Vlk_Dagger", 1)
	GiveItem(playerid, "ItMw_1H_Bau_Mace", 1)
end
--called, when player connects
function ConnectPlayer(playerid)
	if(IsNPC(playerid)==0)then	
		--init
		player[playerid]={
			talkMode=talkModes.TALK,
			isDeaf=false
		}
		
		--get random color
		RandomPlayerColor(playerid)
		--notify about arrival
		Broadcast(playerid,string.format("%s %s", strings.debug.JOINED_SERVER,GetPlayerName(playerid)))
		GiveStartEquipment(playerid)
	end
end
--called when player disconnects
function DisconnectPlayer(playerid)
	Broadcast(playerid,string.format("%s %s", strings.debug.LEFT_SERVER,GetPlayerName(playerid)))
	player[playerid]=nil;
	
end