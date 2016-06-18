-- --------------------------------------------------
-- Непроверенная альтернатива функции player.GetBySteamID()
-- Тесты показали, что она в несколько раз быстрее, но до
-- тестов руки так и не дошли.
-- --------------------------------------------------

local plyrsSids = {}

function player.GetBySteamID(sid)
	return plyrsSids[sid] and IsValid(plyrsSids[sid]) and plyrsSids[sid]
end

hook.Add("PlayerInitialSpawn","player.GetBySteamID Replacement",function(ply)
	plyrsSids[ply:SteamID()] = ply
end)

-- Так то можно вообще без этого хука
-- единственное, для чего он полезен -- уменьшить размер индексов таблицы
hook.Add("PlayerDisconnected","player.GetBySteamID Replacement",function(ply)
	plyrsSids[ply:SteamID()] = nil
end)
