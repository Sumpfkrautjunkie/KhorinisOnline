--gives the player in the focus items
--params: item [amount]
function GiveItems(playerid,params)
	local result,itemInstance,amount = sscanf(params,"sd")
	if result==0 then
		result,itemInstance = sscanf(params,"s")
		amount=1
	end
	
	if result==1 then	
		local focusid=GetFocus(playerid);
		if focusid >= 0 then					
			itemInstance=GetItemInstance(itemInstance)
			
			ItemTransfer(playerid,focusid,itemInstance,amount,
				-1,
				playerid,strings.chat.GIVES,false)
		end
	end
end

--player drops items
--params: item [amount]
function DropItems(playerid,params)
	local result,itemInstance,amount = sscanf(params,"sd")
	if result==0 then
		result,itemInstance = sscanf(params,"s")
		amount=1
	end
	
	if result==1 then	
		
		itemInstance=GetItemInstance(itemInstance)
		GetPlayerItems(playerid,itemInstance,
			function(hasAmount,equipped) 
				if amount<=hasAmount then
					DropItem(playerid,itemInstance, amount)			
					--DebugInfo(playerid,string.format("%s %d #d",strings.error.NOT_ENOUGH_ITEMS, amount, hasAmount))					
				else
					DebugInfo(playerid,string.format("%s %d",strings.error.NOT_ENOUGH_ITEMS, hasAmount))
				end
			end)
		
	end
end

--transfer amount itemInstance from giverid to receiverid
--if amount -1 use percent instead
--percent: -1 to ignore parameter, else 0-100% of amount of itemInstance giverid has (vor stealing robbing etc)
--activeid: active part in transaction, needed for text display
--transactionString: textual description in the chat
--silent: show message publicly in chat or only to activeid? (for stealing)
function ItemTransfer(giverid,receiverid,itemInstance,amount,percent,activeid,transactionString,silent)
	if(giverid==receiverid) then return end
	
	GetPlayerItems(giverid,itemInstance,
		function(hasAmount,equipped) 
			if amount<=hasAmount then
			
				local passiveid=receiverid --the one who is not active must be passive
				if(activeid==receiverid) then
					passiveid=giverid
				end
				local passiveName=GetPlayerName(passiveid)
				--local activeName=GetPlayerName(activeid)
				local itemName=GetItemName(itemInstance)
				
				if(percent>=0) then --optinal take percentage of all of itemInstance giverid has
					amount=math.ceil(hasAmount*percent/100)
				end
				
				if amount<0 then amount=0 end
				
				RemoveItem(giverid, itemInstance, amount)
				GiveItem(receiverid, itemInstance, amount)
				
				if(not silent) then
					SayText(activeid, string.format("%s %s %d %s",transactionString,passiveName,amount,itemName), talkModes.ME)
				else
					DebugInfo(activeid,string.format("%s %s %d %s",transactionString,passiveName,amount,itemName))
				end
			end
		end)
end		

--rob player in focus
--works only when unconscious or dead
function Rob(playerid,params)
	
	local focusid=GetFocus(playerid);
	if focusid >= 0 then		
		if IsDead(focusid)==1 or IsUnconscious(focusid)== 1  then
			local itemInstance=GetItemInstance(settings.global.MONEY)
			
			ItemTransfer(focusid,playerid,itemInstance,-1,
				math.random(settings.interaction.rob.MIN_MONEY_PERCENT,settings.interaction.rob.MAX_MONEY_PERCENT),
				playerid,strings.chat.ROBS,false)
		end
	end	
end

--steal from player in focus
--works only if close anough and not in front of player
function Steal(playerid,params)
	
	local focusid=GetFocus(playerid)
	if focusid >= 0 then
		local x,y,z = GetPlayerPos(playerid)
		local angle = GetPlayerAngle(playerid)
		local fx,fy,fz = GetPlayerPos(focusid)
		local fangle = GetPlayerAngle(focusid)
		
		local diffangle=diffAngle(angle,fangle)
   
		
		if GetDistance3D(x,y,z,fx,fy,fz)<=settings.interaction.steal.MAX_RANGE 
			and diffangle<=settings.interaction.steal.MAX_ANGLE   then
			
			local itemInstance=GetItemInstance(settings.global.MONEY)
			
			ItemTransfer(focusid,playerid,itemInstance,-1,
				math.random(settings.interaction.steal.MIN_MONEY_PERCENT,settings.interaction.steal.MAX_MONEY_PERCENT),
				playerid,strings.chat.STEALS,true)
		end
	end	
end