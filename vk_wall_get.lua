-- --------------------------------------------------
-- Довольно старый мой скрипт, показывающий последние посты из группы ВК
-- Работу не гарантирую, он где-то с эпохи динозавров
-- Был заготовкой для скрипта отображения новостей с группы вк
-- --------------------------------------------------

VKN = {}
local win, lay, spnl

function VKN.processAPI(data)
	if data["response"] then

		-- начинаем с двух, потому что первое значение приходится на кол-во постов в группе
		for i = 2, #data["response"] do
			local txt = data["response"][i].text
			txt = string.Replace(txt,"<br>","\n")

			local pnl = vgui.Create( "DPanel", lay )
			pnl:SetSize( lay:GetWide(), 120 )
			pnl.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h + 20, Color( 224, 224, 224 ) ) -- Цвет обводящей линии ячейки
				draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 250, 250, 250 ) ) -- цвет фона ячейки
			end

			local rich = vgui.Create("RichText",pnl)
			rich:SetSize(lay:GetWide(),lay:GetTall())
			rich:SetPos(0,0)

			rich:InsertColorChange( 150, 150, 150, 255 )
			rich:AppendText(txt)

			lay:Add( pnl )

		end

	else
		--rich:InsertColorChange( 255, 64, 64, 255 )
		print("Ошибка получения данных блаблабла")
	end
end

-- 95087107 -- ид группы тригона в вк
function VKN.wallpost(groupid, posts, cb)
	local data

	local url = "https://api.vk.com/method/wall.get?owner_id=-" .. groupid .. "&count=" .. posts
	http.Fetch(url,
		function(body, len, headers, code)
			data = util.JSONToTable(body)
			cb(data);
		end,
		function( error )
			print("ERROR with fetching! " .. error)
		end
	);
end


win = vgui.Create("DFrame")
win:SetSize(500,500)
win:Center()
win:SetTitle("Новости из группы ВК")
win:ShowCloseButton(true)
win:MakePopup()

spnl = vgui.Create( "DScrollPanel", win)
spnl:SetSize( win:GetWide() - 10, win:GetTall() - 10 - 50 )
spnl:SetPos( 5, 30 )

lay = vgui.Create( "DListLayout", spnl )
lay:SetSize( win:GetWide() - 30, win:GetTall() - 10 - 50 )
lay:SetPos( 0, 0 )
lay:SetPaintBackground( true )
lay:SetBackgroundColor( Color( 0, 150, 150 ) )



VKN.wallpost(95087107, 50, VKN.processAPI)
