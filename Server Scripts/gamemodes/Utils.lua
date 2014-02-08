--helper functions

--checks if string starts with a substring
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

--checks if string ends with a substring
function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

--breaks string into multiple lines
--after LIMIT characters in a line the function breaks the line at the next space
--returns a table of lines
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
--shuffles contents of table by mkottman
function shuffled(tab)
	local n, order, res = #tab, {}, {}
	 
	for i=1,n do order[i] = { rnd = math.random(), idx = i } end
	table.sort(order, function(a,b) return a.rnd < b.rnd end)
	for i=1,n do res[i] = tab[order[i].idx] end
	return res
end
--absolute angle difference in deg
function diffAngle(angle1, angle2)
	local diffangle = angle1 - angle2
   
	if (diffangle > 180) then
		diffangle = diffangle - 360
	elseif (diffangle < -180) then
		diffangle = diffangle + 360
	end
	return math.abs(diffangle)
end