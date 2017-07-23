/*
Очень баянистый файл, который я делал более года назад.
С того момента так и не использовал. И не буду
*/

if CLIENT then
	-- minecraft styled by _AMD_ special for TRIGON.IM
	-- http://i.imgur.com/9c7uB.png
	local c = {
		["0"] = "Color(0,0,0)",       -- black
		["1"] = "Color(30,0,155)",    -- navy
		["2"] = "Color(0,100,0)",     -- green
		["3"] = "Color(0,170,170)",   -- teal
		["4"] = "Color(192,0,0)",     -- maroon
		["5"] = "Color(170,0,170)",   -- purple
		["6"] = "Color(255,170,0)",   -- gold
		["7"] = "Color(166,166,166)", -- silver
		["8"] = "Color(89,89,89)",    -- grey
		["9"] = "Color(89,89,255)",   -- blue
		["a"] = "Color(85,255,85)",   -- lime
		["b"] = "Color(85,255,255)",  -- aqua
		["c"] = "Color(255,85,85)",   -- red
		["d"] = "Color(255,85,255)",  -- pink
		["e"] = "Color(255,255,85)",  -- yellow
		["f"] = "Color(255,255,255)", -- white
	}

	function TL.mcText(txt)
		txt = txt or ""

		local txttbl = string.Explode("&",txt)

		local f = "chat.AddText("
		for i = 1, #txttbl do
			local cword = c[string.sub(txttbl[i],1,1)] and txttbl[i] or ("f" .. txttbl[i])

			f = f .. c[string.sub(cword,1,1)] .. ",\"" .. string.sub(cword,2,#cword) .. "\","
		end
		if string.sub(f,#f,#f) == "," then
			f = string.sub(f,1,#f - 1)
		end
		f = f .. ")"

		RunString(f)
	end


	net.Receive("TL.mcText",function()
		TL.mcText(net.ReadString())
	end)

end


if CLIENT then return end

util.AddNetworkString("TL.mcText")
function TL.mcText(txt,ply)
	net.Start("TL.mcText")
		net.WriteString(txt)
	net.Send(ply)
end
