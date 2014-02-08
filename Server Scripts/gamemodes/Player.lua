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
	end
end
--called when player disconnects
function DisconnectPlayer(playerid)
	Broadcast(playerid,string.format("%s %s", strings.debug.LEFT_SERVER,GetPlayerName(playerid)))
	player[playerid]=nil;
	
end