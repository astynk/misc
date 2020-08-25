script_name('Shotinfo')
script_author('astynk / Leon4ik')
script_version('1.1')

local events = require 'lib.samp.events'

local settings = {
	max_lines = 30,
	fake_afk = false,
	remove_on_quit = false
}

local pool = {}
local active = false
local active2 = false
local noshot = false

function create_empty_item()
	return {
		shots = 0,
		hits = 0,
		accuracy = 0,
		last = 0,
		nick = '',
		lines = {}
	}
end


function get_speed_safely(id)
	if id == select(2, sampGetPlayerIdByCharHandle(1)) then return math.floor(getCharSpeed(1) * 3) end
	local res, ped = sampGetCharHandleBySampPlayerId(id)
	if not res then return 'UNK' else
	return math.floor(getCharSpeed(ped) * 3) end
end

function get_vspeed_safely(id)
	local res, car = sampGetCarHandleBySampVehicleId(id)
	if not res then return 'UNK' else
	return math.floor(getCarSpeed(car) * 3) end
end

function get_vehicle_model(id)
	local res, car = sampGetCarHandleBySampVehicleId(id)
	if res then return getNameOfVehicleModel(getCarModel(car)) else return 'UNK ' .. tostring(id) end
end

function get_weapon_name(id)
	local weapons = {
		[22] = 'glock',
		[23] = 's glock',
		[24] = 'deagle',
		[25] = 'shotgun',
		[26] = 'sawn',
		[27] = 'spac12',
		[28] = 'uzi',
		[29] = 'mp5',
		[30] = 'ak47',
		[31] = 'm4',
		[32] = 'tec9',
		[33] = 'rifle',
		[34] = 'sniper',
		[38] = 'minigun'
	}
	return weapons[id] or 'Нет в списке: ' .. tostring(id)
end

local vsi = 0
local vsi2 = 0
local popal = 0

local lkm = true


function events.onSendGiveDamage(id, data, data1, data2, data3)
		return {id, 50, data1, data2, data3}
end

function process_bullet_sync(id, data)
	if not pool[id] or pool[id].nick ~= sampGetPlayerNickname(id) then pool[id] = create_empty_item() end
	local warning = '' --IDK
	local warning2 = '' -- Fast Fire
	local warning3 = '' -- Dist fire
	local warning4 = '' --  recoil

	local w1 = 0
	local w2 = 0
	local w3 = 0
	local time_since2 = -1

	local O, T = data.origin, data.target
	local distance = math.sqrt((O.x - T.x) ^ 2 + (O.y - T.y) ^ 2 + (O.z - T.z) ^ 2)
	local dist_text = ''
	local dist = math.floor(distance)
	if data.targetType == 1 or data.targetType == 2 then dist_text = ', ' .. math.floor(distance) .. 'm' end

	local hit_name = '{6495ED}ПРОМАХ'
	if data.targetType == 1 then  popal = popal+1 hit_name = sampGetPlayerNickname(data.targetId) end
	if data.targetType == 2 then hit_name = get_vehicle_model(data.targetId) end

	local speed_vs = ''
	if data.targetType == 1 then speed_vs = ', ' .. get_speed_safely(id) .. ' vs ' .. get_speed_safely(data.targetId) end
	if data.targetType == 2 then speed_vs = ', ' .. get_speed_safely(id) .. ' vs ' .. get_vspeed_safely(data.targetId) end
	
	local time_since = os.clock() - pool[id].last
	if time_since > 5 and pool[id].shots > 0 then pool[id].lines[#pool[id].lines + 1] = '' end
	if time_since > 1 then time_since = 'ok' else time_since2 = math.floor(1000 * time_since) time_since = math.floor(1000 * time_since) .. 'ms' end

	pool[id].nick = sampGetPlayerNickname(id)
	pool[id].last = os.clock()
	pool[id].shots = pool[id].shots + 1
	if data.targetType == 1 or data.targetType == 2 then pool[id].hits = pool[id].hits + 1 end
	pool[id].accuracy = math.floor(100 * pool[id].hits / pool[id].shots)

	if data.targetType == 1 and not isLineOfSightClear(O.x, O.y, O.z, T.x, T.y, T.z, true, true, false, true, true) then
		w1 = 1
		warning = ' {CCAA00}(стрельба сквозь текстуры)'
	end
	
	if dist > 90 and  isCurrentCharWeapon(PLAYER_PED,31) and data.targetType == 1 then warning3 = '{ec9491}(Дальность стрельбы)' end
	if dist > 30 and  isCurrentCharWeapon(PLAYER_PED,24) and data.targetType == 1 then warning3 = '{ec9491}(Дальность стрельбы)' end
	
	--if popal > 3 and dist > 50 and  hit_name ~= '{6495ED}ПРОМАХ' then warning4 = "{ec9491}(Recoil)" if data.targetType == 0 then popal = 0 local warning4 = ''   end end
	

	if tonumber(time_since2) < 100 and time_since2 ~= -1 then  vsi = vsi+1 end
	if  time_since == "ok" then warning2 = '' end
	
	if  isCurrentCharWeapon(PLAYER_PED,31) and vsi > 1 then vsi = 0 warning2 = ' {ec9491}(Быстрая стрельба)' w2 = 1 end
	if tonumber(time_since2) < 700 and time_since2 ~= -1  and isCurrentCharWeapon(PLAYER_PED,24)  then warning2 = ' {ec9491}(Быстрая стрельба)'  end
	
	
	if w1 == 1 then warning3 = '' w1 = 0 end
	if w2 == 1 then warning3 = '' w2 = 0 end
	
	
	
	local line = string.format('%s > %s%s, %s%s > %s%s %s %s %s', pool[id].nick, get_weapon_name(data.weaponId), dist_text, time_since, speed_vs, hit_name, warning, warning2,warning3, warning4)
	pool[id].lines[#pool[id].lines + 1] = '[' .. os.date('%H:%M:%S') .. '] ' .. line
	mynick = select(2, sampGetPlayerIdByCharHandle(1))
	if id == mynick and active then sampAddChatMessage('{6495ED}[S] {FFFFFF}' .. line, -1) end
	
	
	if  id == mynick  and not isKeyDown(0x1) and active2 and  noshot then
	end

	if data.targetType == 0 or  data.targetType == 1 or  data.targetType == 2 then
		if id == mynick and active2 then
			if isKeyJustPressed(0x1) or wasKeyPressed(0x1) then
				sampAddChatMessage("{6495ED}[KEY]{FFFFFF} Нажата:{ff2400} KEY_FIRE",-1)
			end
			if not isKeyDown(0x1) and not isKeyJustPressed(0x1) then
			   sampAddChatMessage("{6495ED}[KEY]{FFFFFF} Нажата:{009900} KEY_ACTION",-1) 
			end
		end
	end
	
 --[[	if  id == mynick and active2 then
	if  data.targetType == 1 or  data.targetType == 2 or  data.targetType == 0 then
		if  noshot and isCurrentCharWeapon(PLAYER_PED,31) or noshot and isCurrentCharWeapon(PLAYER_PED,24) then
			sampAddChatMessage("{6495ED}[KEY]{FFFFFF}  Нажата:{009900} KEY_ACTION",-1)
			noshot = not noshot
		end
	end
	end]]
	
end


function events.onSendBulletSync(data)
	process_bullet_sync(select(2, sampGetPlayerIdByCharHandle(1)), data)
end


function events.onBulletSync(id, data)
	process_bullet_sync(id, data)
end

function events.onPlayerJoin(id, color, npc, nick) -- removing duplicates
	for i = 0, 999 do
		if pool[i] and pool[i].nick == nick then
			pool[i] = nil
			return
		end
	end
end

function events.onPlayerQuit(id)
	if settings.remove_on_quit and pool[id] then
		pool[id] = nil
	end
	
end

function events.onApplyPlayerAnimation(id, lib, name, loop, x, y, freeze, time)
    print('id: ' .. id .. ' name: ' .. name .. ' time: ' .. time)
end


function main()
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("/shotinfo",function()
	active = not active
	if active  then sampAddChatMessage("{6495ED}[SHOTINFO]{FFFFFF} активирован.",-1) else  sampAddChatMessage("{6495ED}[SHOTINFO]{FFFFFF} деактивирован.",-1) end
	end)
	sampRegisterChatCommand("/keyinfo",function()
	active2 = not active2
	if active2  then sampAddChatMessage("{6495ED}[KeyInfo]{FFFFFF} активирован.",-1) else  sampAddChatMessage("{6495ED}[KeyInfo]{FFFFFF} деактивирован.",-1) end
	end)
	sampAddChatMessage("{6495ED}[SHOTINFO]{FFFFFF} Fix from Leon4ik. {6495ED}//shotinfo | //keyinfo",-1)
	
	while true do wait(0)
	
	local line = string.format(' %s%s',key,key2)
	
	--[[if active2 and isKeyJustPressed(0x1)  then
		local key = ''
		key = '{ff2400} KEY_FIRE'
		if  isCurrentCharWeapon(PLAYER_PED,31) or  isCurrentCharWeapon(PLAYER_PED,24) then
			sampAddChatMessage("{6495ED}[KEY]{FFFFFF}  Нажата:{ff2400} KEY_FIRE",-1)
			noshot = false
		else noshot = true
		end
	end]]
	
	
	if active2 and isKeyJustPressed(0x2) then
		local key2 = ''
		key2 = '{009900} KEY_AIM'
		if  isCurrentCharWeapon(PLAYER_PED,31) or  isCurrentCharWeapon(PLAYER_PED,24) then
			sampAddChatMessage("{6495ED}[KEY]{FFFFFF} Нажата:"..key2,-1)
			 noshot = false
		else noshot = true
		end
	
	end
	
	end
	
end