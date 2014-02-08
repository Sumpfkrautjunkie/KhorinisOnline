
--enum of talk modes (influences range, chat appearance etc.)
talkModes = {
	TALK=0,
	WHISPER=1,
	SHOUT=2,
	OFFTOPIC=3,
	ME=4,
}
--breaks chat message in multiple lines if necessary and prints it in the chat
function SendMessageLines(playerid,red,green,blue,message)
	local lines=string.breakLines(message,settings.chat.limits.MAX_CHARS_PER_LINE)
	for k,line in ipairs(lines) do
		SendPlayerMessage(playerid,red,green,blue, line)		
	end	
end

--if a player enters a chat text
-- for mode see talkModes
function SayText(playerid, text, mode)	
	--normal talking distance as default
	local distance=settings.chat.distances.TALK
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
		distance=settings.chat.distances.WHISPER	
		sayString=strings.chat.WHISPERS
	elseif mode==talkModes.SHOUT then
		distance=settings.chat.distances.SHOUT
		sayString=strings.chat.SHOUTS	
	elseif mode==talkModes.OFFTOPIC then
		distance=settings.chat.distances.OFFTOPIC
		sayString=strings.chat.OFFTOPIC
		colon="";
	elseif mode==talkModes.ME then
		distance=settings.chat.distances.ME
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

--simple information print, not part of the RP
-- broadcast: true/false: display message to all players
function DebugInfo(playerid,text,broadcast)
	
	local message=string.format("%s %s","##",text)
	local lines=string.breakLines(message,settings.chat.limits.MAX_CHARS_PER_LINE)
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
--contact a player directly
--params: id messagetext
function SendPersonalMessage(playerid,params)
	local result,recipient,message = sscanf(params,"ds")
	if result==1 then
		if IsPlayerConnected(recipient) == 1 then
			local senderName=GetPlayerName(playerid)
			local recipientName=GetPlayerName(recipient)
			message=string.format("(%s %s: %s)",senderName,strings.chat.MESSAGED_YOU,message)		
			SendMessageLines(recipient,255,255,0,message)
			message=string.format("(%s %s: %s)",recipientName,strings.chat.GOT_MESSAGE,message)		
			SendMessageLines(playerid,255,255,0,message)
		else
			DebugInfo(playerid,string.format("%s %s",strings.error.NO_SUCH_ID,playerid))
		end
	end
end
--sends a non RP message to everyone
--params: message
function Broadcast(playerid,params)
	DebugInfo(playerid, params,true)
end