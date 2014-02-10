function PlayerCommandText(playerid, cmdtext)
	local cmd,params = GetCommand(cmdtext)
	if(params==nil) then params="" end
	cmd=string.sub (cmd, 2)	
	--DebugInfo(playerid,cmdtext)
	if(commandList[cmd]~=nil) then
		commandList[cmd](playerid,params)
	end
	
	if(cmd~="last" and cmd~="l") then
		player[playerid].lastCommand=cmdtext
	end
end

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
--lists all items
function PrintItems(playerid,params)
	
	local tt = {}
	for key,value in pairs(itemAlias) do
		tt[#tt+1]=key
	end
	DebugInfo(playerid,table.concat(tt,", "))
	
end
--get coordinates for point distance cm ahead of playerid
function GetPointAhead(playerid,distance)
	local x,y,z = GetPlayerPos(playerid);
	local rads =  math.rad(GetPlayerAngle(playerid));
	
	local s=math.sin(rads)
	local c=math.cos(rads)
	local xnew = x+distance * s;
	local znew = z+distance * c;
	
	return xnew,y,znew
end
--inserts item (amount) in front of playerid
function InsertItem(playerid,params)
	local result,itemInstance,amount = sscanf(params,"sd")
	if result==0 then
		result,itemInstance = sscanf(params,"s")
		amount=1
	end
	
	if result==1 then		
		local x,y,z =GetPointAhead(playerid,100)	
		itemInstance=GetItemInstance(itemInstance)
		CreateItem(itemInstance, amount, x, y, z, settings.global.WORLD)
	end
end
--teleports playerid 4m ahead
function JumpForward(playerid,params)
	
	local x,y,z =GetPointAhead(playerid,400)
	SetPlayerPos(playerid,x,y+80,z)
	
end
--spawns an npc
function SpawnNPC (playerid,params)
	local result,NPCInstance = sscanf(params,"s")
	if result==1 then
		local x,y,z = GetPointAhead(playerid,100)
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
--kills player in focus
function Kill(playerid,params)
	
	local focusid=GetFocus(playerid);
	if focusid >= 0 then
		SetPlayerHealth(focusid,0)
	end
	
end
--revives player in focus
function Revive(playerid,params)
	
	local focusid=GetFocus(playerid);
	if focusid >= 0 then
		SetPlayerHealth(focusid,GetPlayerMaxHealth(focusid))
		if IsDead(focusid) == 1  then
			PlayAnimation(focusid,"T_PRACTICEMAGIC3");
			PlayAnimation(focusid,"S_FALLDN");
		end
	end
	
end
--sets the game time 
function SetGameTime(playerid,params)
	
	local result,hour,minute = sscanf(params,"dd")
	if result==0 then
		result,hour = sscanf(params,"d")
		minute=0
	end
	
	if result==1 then		
		SetTime(hour,minute)
	end
	
end
--kicks player with id
function KickPlayer(playerid,params)

	local result,kickid = sscanf(params,"d")
	if kickid >= 0 and IsPlayerConnected(kickid) == 1 then
		Kick(kickid);
		local name=GetPlayerName(kickid)
		Broadcast(playerid,string.format("%s (%d) %s",name, kickid,strings.debug.KICKED))
	end
end
--transforms player into instance	
function TransformTo(playerid,params)

	local result,instance = sscanf(params,"s")
	SetPlayerInstance(playerid,instance)
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
	["helpitems"] = function (playerid,params)
		PrintItems(playerid,params);
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
	["jumper"] = function (playerid,params)
		JumpForward(playerid,params)
	end,
	["kill"] = function (playerid,params)
		Kill(playerid,params)
	end,
	["revive"] = function (playerid,params)
		Revive(playerid,params)
	end,
	["drop"] = function (playerid,params)
		DropItems(playerid,params)
	end,
	["give"] = function (playerid,params)
		GiveItems(playerid,params)
	end,
	["color"] = function (playerid,params)
		RandomPlayerColor(playerid)
	end,
	["rob"] = function (playerid,params)
		Rob(playerid,params)
	end,
	["steal"] = function (playerid,params)
		Rob(playerid,params)
	end,
	["gettime"] = function (playerid,params)
	    local hour,minute = GetTime();
		DebugInfo(playerid,string.format("%02d:%02d",hour,minute))
	end,
	["settime"] = function (playerid,params)
		SetGameTime(playerid,params)
	end,
	["kick"] = function (playerid,params)
		KickPlayer(playerid,params)
	end,
	["transform"] = function (playerid,params)
		TransformTo(playerid,params)
	end,
}
--alternative commands
commandList.setpos=commandList.goto
commandList.l=commandList.last

commandList.help= function (playerid,params)
					PrintHelp(playerid,params);
				end