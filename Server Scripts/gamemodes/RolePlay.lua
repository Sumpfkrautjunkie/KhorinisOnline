-- Constants
local strings = {}
strings.chat={
	SAYS="sagt",
	WHISPERS="fluestert",
	SHOUTS="ruft",
	OFFTOPIC="////",
	ME="",
	MESSAGED_YOU="schreibt dir"
}
strings.error={
	NO_SUCH_ID="Kein Spieler mit id",
	NO_SUCH_WAYPOINT="Kein Wegpunkt gefunden:",
}

strings.debug={
	CURRENT_POS="Aktuelle Position (x,y,z,Winkel):",
	JOINED_SERVER="Spieler tritt dem Spiel bei:",
	LEFT_SERVER="Spieler verlässt das Spiel:",
}
-- Talk Modes
local talkModes = {
	TALK=0,
	WHISPER=1,
	SHOUT=2,
	OFFTOPIC=3,
	ME=4,
}
-- Chat Settings
local chatSettings = {}
chatSettings.distances={
	WHISPER=220, --distances are in cm (hopefully)
	TALK=1000,
	SHOUT=17000,
	OFFTOPIC=1000,
	ME=1000,
}



chatSettings.limits={
	MAX_CHARS_PER_LINE=50,
}
local waypoints = {
	["center"]={x=0,y=0,z=0,angle=0},
	["baum"]={x=4175,y=35,z=-809,angle=216},
}
local player = {}
--players[0].talkMode=talkModes.TALK
--players[0].isDeaf=false
	
--util start

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.breakLines(String,Limit)
	local lines={}
	local offset=0;
	local textLenght=string.len(String);
	
	
	while true do
		local found=string.find(String," ",offset+Limit,true)		
		if found==nil then
			table.insert(lines, string.sub (String, offset))
			break
		else
			table.insert(lines, string.sub (String, offset, found))
			offset=found+1
		end
	end
	return lines;
end
--util end

function ConnectPlayer(playerid)
	player[playerid]={
		talkMode=talkModes.TALK,
		isDeaf=false
	};
	
	Broadcast(playerid,string.format("%s %s", strings.debug.JOINED_SERVER,GetPlayerName(playerid)))
end

function DisconnectPlayer(playerid)
	Broadcast(playerid,string.format("%s %s", strings.debug.LEFT_SERVER,GetPlayerName(playerid)))
	player[playerid]=nil;
	
end
function SayText(playerid, text, mode)	
	--normal talking distance as default
	local distance=chatSettings.distances.TALK
	local sayString=strings.chat.SAYS
	local colon=":"
	local name=GetPlayerName(playerid)
	-- dead can't talk
	if IsDead(playerid) == 1 then
		return
	end
		
	-- limit distance the text can be heard
	-- unconscious actually can't talk too, but let's say they're only badly hurt
	if IsUnconscious(playerid) == 1 or mode==talkModes.WHISPER then
		distance=chatSettings.distances.WHISPER	
		sayString=strings.chat.WHISPERS
	elseif mode==talkModes.SHOUT then
		distance=chatSettings.distances.SHOUT
		sayString=strings.chat.SHOUTS	
	elseif mode==talkModes.OFFTOPIC then
		distance=chatSettings.distances.OFFTOPIC
		sayString=strings.chat.OFFTOPIC
		colon="";
	elseif mode==talkModes.ME then
		distance=chatSettings.distances.ME
		sayString=strings.chat.ME	
		colon="";		
		text=string.format("(%s %s)",name, text)
		name="";
	end
	
	
	--display text in player color
	local red,green,blue = GetPlayerColor(playerid)
	
	local message=string.format("%s %s%s %s",name,sayString,colon,text);
	for i = 0, GetMaxPlayers()-1 do 
		if IsPlayerConnected(i) == 1 and not player[i].isDeaf then
			if GetDistancePlayers(playerid,i) < distance then					
				SendMessageLines(i,red,green,blue,message)		
			end
		end
	end
end


function Init()
	EnableChat(0)
	EnableNicknameID(0)
end

--breaks chat message in multiple lines if necessary and prints it
function SendMessageLines(playerid,red,green,blue,message)
	local lines=string.breakLines(message,chatSettings.limits.MAX_CHARS_PER_LINE)
	for k,line in ipairs(lines) do
		SendPlayerMessage(playerid,red,green,blue, line)		
	end	
end

function DebugInfo(playerid,text,broadcast)
	
	local message=string.format("%s %s","##",text)
	local lines=string.breakLines(message,chatSettings.limits.MAX_CHARS_PER_LINE)
	if broadcast then
		for i = 0, GetMaxPlayers()-1 do 
			if IsPlayerConnected(i) == 1 then				
				SendMessageLines(i,0,255,0,message)						
			end
		end
	else
		SendMessageLines(playerid,0,255,0,message)						
	end
	
end

--prints the current coordinates
function GetPos(playerid)
	local x,y,z = GetPlayerPos(playerid);
	local angle = GetPlayerAngle(playerid);
	local message = string.format("%s %.0f %.0f %.0f   %.1f",strings.debug.CURRENT_POS,x,y,z,angle)
	DebugInfo(playerid,message)
end

--teleports to coordinates x y z
--if only one parameter is given:
--parameter is a number = teleports to player with given id
--parameter is string = teleports to waypoint, if set in waypoints table
function SetPos(playerid,params)

	local result,par1,par2,par3 = sscanf(params,"sss")
	
	if result==0 then --to get single parameter, if not all three are used
		result,par1 = sscanf(params,"s")
	end
	
	if result==1 and par1~=nil then
		--number, no waypoint
		if tonumber(par1) ~= nil then	
		
			if(par3~=nil) then--3 params: xyz coordinates
				SetPlayerPos(playerid,tonumber(par1),tonumber(par2),tonumber(par3));
			else --one param: player id
				if IsPlayerConnected(tonumber(par1)) == 1 then
					local x,y,z = GetPlayerPos(tonumber(par1));
					SetPlayerPos(playerid,x,y,z);					
				end
			end
		else --no number, no maybe waypoint
			--is in waypoint table?
			
			if(waypoints[par1] ~= nil) then
				SetPlayerPos(playerid,waypoints[par1].x,waypoints[par1].y,waypoints[par1].z);
				if waypoints[par1].angle ~= nil then -- optional angle
					SetPlayerAngle(playerid,waypoints[par1].angle);
				end
			else -- no waypoint error
				DebugInfo(playerid,string.format("%s %s",string.error.NO_SUCH_WAYPOINT,par1))
			end
		end
		
	end
	
end
--lists all commands
function PrintHelp(playerid,params)
	
	local tt = {}
	for key,value in pairs(commandList) do
		tt[#tt+1]=key
	end
	DebugInfo(playerid,table.concat(tt,", "))
end
--lists all waypoints
function PrintWaypoints(playerid,params)
	
	local tt = {}
	for key,value in pairs(waypoints) do
		tt[#tt+1]=string.format("%s %.0f,%.0f,%.0f",key,value.x,value.y,value.z)
	end
	DebugInfo(playerid,table.concat(tt,"/ "))
end

function SendPersonalMessage(playerid,params)
	local result,recipient,message = sscanf(params,"ds")
	if result==1 then
		if IsPlayerConnected(recipient) == 1 then
			local senderName=GetPlayerName(playerid)
			message=string.format("(%s (%s) %s: %s)",senderName,recipient,strings.chat.MESSAGED_YOU,message)		
			SendMessageLines(recipient,255,155,95,message)					
		else
			DebugInfo(playerid,string.format("%s %s",strings.error.NO_SUCH_ID,playerid))
		end
	end
end

function Broadcast(playerid,params)
	DebugInfo(playerid, params,true)
end
function InsertItem(playerid,params)
	local result,itemInstance,amount = sscanf(params,"sd")
	if result==0 then
		result,itemInstance = sscanf(params,"s")
		amount=1
	end
	
	if result==1 then
		local x,y,z = GetPlayerPos(playerid);
		local rads =  math.rad(GetPlayerAngle(playerid));
		local distance=60
		local s=math.sin(rads)
		local c=math.cos(rads)
		local xnew = 0 * c + 100 * s;
		local znew = 0 * s + 100 * c;
		
		CreateItem(itemInstance, amount, x+xnew, y, z+znew, "NEWWORLD\\NEWWORLD.ZEN")
	end
end

function SpawnNPC (playerid,params)
	local result,NPCInstance = sscanf(params,"s")
	if result==1 then
		local x,y,z = GetPlayerPos(playerid);
		local rads =  math.rad(GetPlayerAngle(playerid));
		local npc = CreateNPC("test");
		SpawnPlayer(npc);
		SetPlayerInstance(npc,NPCInstance);
		SetPlayerMaxHealth(npc,20);
		SetPlayerHealth(npc,20);
		SetPlayerStrength(npc,10);
		SetPlayerPos(npc,x,y,z);
		
	end
end
--list of all commands in chat console /command
commandList = {
	["getpos"] = function (playerid,params)
		GetPos(playerid)	
	end,
	["goto"] = function (playerid,params)
		SetPos(playerid,params)	
	end,
	["waypoints"] = function (playerid,params)
		PrintWaypoints(playerid,params)	
	end,
	["w"] = function (playerid,params)
		SayText(playerid, params, talkModes.WHISPER)
	end,
	["s"] = function (playerid,params)
		SayText(playerid, params, talkModes.SHOUT)
	end,
	["ot"] = function (playerid,params)
		SayText(playerid, params, talkModes.OFFTOPIC)
	end,
	["won"] = function (playerid,params)
		player[playerid].talkMode=talkModes.WHISPER
	end,
	["oton"] = function (playerid,params)
		player[playerid].talkMode=talkModes.OFFTOPIC
	end,
	["son"] = function (playerid,params)
		player[playerid].talkMode=talkModes.SHOUT
	end,
	["ton"] = function (playerid,params)
		player[playerid].talkMode=talkModes.TALK
	end,
	["me"] = function (playerid,params)
		SayText(playerid, params, talkModes.ME)
	end,
	["meon"] = function (playerid,params)
		player[playerid].talkMode=talkModes.ME
	end,
	["pm"] = function (playerid,params)
		SendPersonalMessage(playerid,params)
	end,
	["all"] = function (playerid,params)
		Broadcast(playerid,params)
	end,
	["insert"] = function (playerid,params)
		InsertItem(playerid,params)
	end,
	["spawn"] = function (playerid,params)
		SpawnNPC(playerid,params)
	end,
	["last"] = function (playerid,params)
		if(player[playerid].lastCommand~=nil) then
			OnPlayerCommandText(playerid,player[playerid].lastCommand)
		end
	end,
}
--alternative commands
commandList.setpos=commandList.goto

commandList.help= function (playerid,params)
					PrintHelp(playerid,params);
				end
function OnGamemodeInit()
	
	print("--------------------")
	print("Role Play Mode");
	print("--------------------")
	
	Init()
end

function OnGamemodeExit()

	print("-------------------")
	print("Role Play Mode was exited")
	print("-------------------")
end

function OnPlayerChangeClass(playerid, classid)
 
end

function OnPlayerSelectClass(playerid, classid)
 
end

function OnPlayerConnect(playerid)
	ConnectPlayer(playerid)
end

function OnPlayerDisconnect(playerid, reason)
	DisconnectPlayer(playerid)
end

function OnPlayerSpawn(playerid, classid)
 
end

function OnPlayerDeath(playerid, p_classid, killerid, k_classid)
 
end

function OnPlayerHit(playerid, killerid)
 
end

function OnPlayerUnconscious(playerid, p_classid, killerid, k_classid)

end

function OnPlayerDeath(playerid, killerid)
 
end

function OnPlayerText(playerid, text)	
	SayText(playerid, text, player[playerid].talkMode)
end

function OnPlayerCommandText(playerid, cmdtext)
	local cmd,params = GetCommand(cmdtext)
	if(params==nil) then params="" end
	cmd=string.sub (cmd, 2)	
	--DebugInfo(playerid,cmdtext)
	if(commandList[cmd]~=nil) then
		commandList[cmd](playerid,params)
	end
	
	if(cmd~="last") then
		player[playerid].lastCommand=cmdtext
	end
end

function OnPlayerChangeWorld(playerid, world)

end

function OnPlayerEnterWorld(playerid, world)

end

function OnPlayerDropItem(playerid, itemid, item_instance, amount, x, y, z)

end

function OnPlayerTakeItem(playerid, itemid, item_instance, amount, x, y, z)

end