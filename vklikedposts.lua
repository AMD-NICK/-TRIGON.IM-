
-- human - ID человека, лайки которого надо найти на стене
-- wall  - ID группы или человека, на стене стене которой(го) будут искаться лайки
local human,wall = 1,1










----------------------------------------------------------------------------------------

-- Оверрайт принт функции, чтобы она подставляла время в начало
local print_ = print
local function print(...)
	local args = {...}
	args[1] = os.date("%H:%M:%S",os.time()) .. " > " .. tostring(args[1])

	print_(unpack(args))
end


local function getPosts(wallid,count,callback)
	local tmp = {} -- временная таблица хранения данных постов
	local done = 0 -- сколько проходов выполнено

	-- ВК позволяет получать максимум 100 постов/запрос, поэтому разбиваем и делаем очередь
	local mults = math.floor(count / 100) -- если нужно меньше 100 постов, то будет 0
	local rest  = count -- сколько осталось получить постов

	-- Даже если mults 0, то один раз по циклу пройдемся
	-- З.Ы, Отсчет начинаем с нуля, чтобы был верный offset
	for deep = 0,mults do
		local cnt = rest

		if rest >= 100 then
			cnt  = 100
		end

		-- Сработает, только если запрашивать 100, 200, 300, 400 и т.д. постов
		-- Костыльчик. Если вк аргументом count передать 0, то оно вернет 20 постов и в итоге при
		-- получении постов, количество которых кратно 100, мы получим на 20 постов больше без этой хрени
		if cnt == 0 then
			done = done + 1

			if done == mults + 1 then
				callback(tmp)
			end

			continue
		end

		http.Fetch("https://api.vk.com/method/wall.get?owner_id=" .. wallid .. "&count=" .. cnt .. "&offset=" .. 100 * deep,
			function(res)
				local t = util.JSONToTable(res)

				for i = 2,#t.response do -- первый блок - инфа
					local v = t.response[i]
					tmp[v.id] = v
				end

				done = done + 1

				-- Если парсить завершили, то выплескиваем результат в каллбэк
				if done == mults + 1 then
					callback(tmp)
				end
			end
		)

		rest = rest - cnt
	end
end

local function getLikes(wall,post,count,callback)
	http.Fetch("https://api.vk.com/method/likes.getList?type=post&owner_id=" .. wall .. "&item_id=" .. post .. "&count=" .. count,
		function(res)
			local t = util.JSONToTable(res)

			callback(t.response.users)
		end
	)
end



local function getPostsCount(wall,callback)
	http.Fetch("https://api.vk.com/method/wall.get?owner_id=" .. wall .. "&count=1",
		function(res)
			local t = util.JSONToTable(res)

			callback(t.response[1])
		end
	)
end


-- human_id  - ID человека ВК, лайки которого нужно найти
-- target_id - ID человека или группы ВК, на стене которого нужно найти лайканные посты
-- ID группы необходимо указывать со знаком МИНУС в начале
local function getLikedPosts(human_id,target_id,cb)
	MsgN()
	print("Получаем кол-во постов на стене vk.com/wall" .. target_id)

	getPostsCount(target_id,function(count)
		print("Получено кол-во постов на стене: " .. count)

		local done = 0
		local liked_posts = {}
		MsgN()
		print("Получаем данные всех постов со стены")
		getPosts(target_id,count,function(res)
			local totalposts = table.Count(res)
			print("Все посты получены")

			local matchpoint = -- говнокод, но в 3 утра мозг уже не варит
				(totalposts >= 1000000 and 100000) or
				(totalposts >= 100000 and 10000) or
				(totalposts >= 10000 and 1000) or
				(totalposts >= 1000 and 100) or
				(totalposts >= 100 and 10) or
				(totalposts >= 10 and 1) or 1

			local nextpoint = 0

			print("Ищем пролайканные посты")
			for post_id,dat in pairs(res) do

				getLikes(target_id,post_id,1000,function(ids)
					if done == nextpoint then
						print("Обработано " .. done .. " постов")
						nextpoint = nextpoint + matchpoint
					end

					if table.HasValue(ids,human_id) then
						liked_posts[post_id] = dat
					end

					done = done + 1
					if done == totalposts then
						cb(liked_posts)
					end
				end)

			end
		end)
	end)
end


print("Скрипт запущен. Получаем посты vk.com/id" .. human .. " со стены vk.com/wall" .. wall)
getLikedPosts(human,wall,function(posts)
	MsgN()
	MsgN()
	print("Пролайканные посты получены. Всего " .. table.Count(posts) .. " постов:")

	local result = {}
	for id,dat in pairs(posts) do
		result[#result + 1] = "vk.com/wall" .. wall .. "_" .. id
	end

	for _,link in pairs(result) do
		print(link)
	end
end)
