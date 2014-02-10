--iteminstances and item names and alias
items ={
	["itmi_gold"]={name="Gold"},
	["ItFo_Addon_SchnellerHering"]={name="Schneller Hering"},
	["ItRi_Str_01"]={name="Ring der Kraft"},
	["ItAm_Strg_01"]={name="Amulett der Kraft"},
	["ItWr_ZweihandBuch"]={name="Der Doppelblock", alias="doppelblock"},
	["StandardBrief"]={name="StandardBrief"},
	["ItBe_Addon_Prot_Total"]={name="Beschuetzer-Guertel", alias="schutzguertel"},
	["ItAt_DragonEgg_Mis"]={name="Drachen-Ei"},
	["ItAt_Wing"]={name="Fluegel"},
	["ItAt_WargFur"]={name="Wargfell"},
	["ItWr_Map_NewWorld"]={name="Landkarte Khorinis", alias="karte"},
	["ItFo_Apple"]={name="Apfel"},
	["ItFo_Beer"]={name="Bier"},
	["ItFo_Bread"]={name="Brot"},
	["ItPl_Blueplant"]={name="Blauflieder"},
	["ItPl_Mushroom_01"]={name="Dunkelpilz"},
	["ItPl_Mana_Herb_03"]={name="Feuerwurzel"},
	["ItRi_Prot_Edge_01"]={name="Ring der Eisenhaut"},
	["ItAr_Bau_L"]={name="Arbeiterkleidung"},
	["ItAr_Bau_M"]={name="Bauernkleidung"},
	["ItAr_Mil_M"]={name="Schwere Milizruestung"},
	["ItSc_Lightningflash"]={name="Blitzschlag"},
	["ItSc_Sleep"]={name="Schlaf"},
	["ItSc_SumWolf"]={name="Wolf rufen"},
	["ItPo_Perm_Str"]={name="Elixier der Staerke"},
	["ItPo_Health_Addon_04"]={name="Reine Lebensenergie"},
	["ItPo_Mana_Addon_04"]={name="Reines Mana"},
	["ItPo_Perm_Mana"]={name="Elixier des Geistes"},
	["ItMw_1H_Vlk_Dagger"]={name="Dolch"},
	["ItMw_1H_Bau_Mace"]={name="Schwerer Ast"},
	
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
		end
		
		if (value.name~=nil) then--has name?
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