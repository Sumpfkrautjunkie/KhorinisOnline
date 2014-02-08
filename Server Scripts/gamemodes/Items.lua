--iteminstances and item names and alias
items ={
	["itmi_gold"]={name="Gold"},
	["ItFo_Addon_SchnellerHering"]={name="Schneller Hering"},
	["ItRi_Str_01"]={name="Ring der Kraft"},
}
-- short names for items
itemAlias={} --created in game init

--create itemAlias based on items table
--if item has alias, alias is used
--if item has only name, name is used without spaces/nonalphabetical characters
function CreateItemAlias()
	itemAlias={}
	for key,value in pairs(items) do
		
		if(value.alias~=nil) then--has alias attribute?
			itemAlias[value.alias]=key -- use it!				
		elseif (value.name~=nil) then--has name?
			local name=value.name
			name=string.lower(string.gsub(name,"%A+",""));			
			itemAlias[name]=key
		end
		
	end
end
--returns the internal iteminstance
--accepts both alias and iteminstance
function GetItemInstance(instance)
	
	if(itemAlias[instance]~=nil) then--alias used?
		return itemAlias[instance]--get true item
	end
	return instance
end
--stores callbacks, as long there is no multithreading it should work
--each player gets based on the playerid a callback function
hasItemsFunc={}

--retrieves the amount of iteminstance playerid has and calls callback(amount,equipped)
--where amount=0 when playerid has no such item
--and equipped is 0/1 if item is currently equipped
function GetPlayerItems(playerid,itemInstance,callback) --callback(amount,isEquipped)
	hasItemsFunc[playerid]=callback;
	HasItem(playerid,GetItemInstance(itemInstance),playerid)
end

--returns the name of the itemInstance
function GetItemName(itemInstance)
	local itemName=itemInstance
	if(items[itemInstance]~=nil) then
		if(items[itemInstance].name~=nil) then
			itemName=items[itemInstance].name
		end 
	end
	return itemName
end

--called by OnPlayerHasItem, needed to check amount of items
function PlayerHasItem(playerid, item_instance, amount, equipped, checkid)	
	if item_instance == "NULL" then
		amount=0
		equipped=0
	end
	if hasItemsFunc[checkid]~=nil then
		hasItemsFunc[checkid](amount,equipped);
	end
end