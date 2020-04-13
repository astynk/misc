local q = require 'lib.samp.events'

function q.onSendUnoccupiedSync(data)
	if crash then 
		data.direction.x = 0/0
		data.position.x = data.position.x + math.random()*math.random(2, 5)
		data.position.y = data.position.y + math.random()*math.random(2, 5)
		data.position.z = data.position.z + math.random()*math.random(2, 5)
		data.moveSpeed = {x = math.random()/1000, y = math.random()/1000, z = math.random()/1000}
    end
end

function q.onPlayerEnterVehicle(id, veh_id)
	if crasher then 
		lua_thread.create(function()
			sampAddChatMessage('crashed player '..sampGetPlayerNickname(id)..'['..id..']', -1)
			sampSendVehicleDestroyed(veh_id)
			_, car = sampGetCarHandleBySampVehicleId(veh_id)
			x, y, z = getCarCoordinates(car)
			wait(1000)
			crash = true
			sendOnfootSync(x, y, z) 
			sampForceUnoccupiedSyncSeatId(veh_id,0)
			sampForceUnoccupiedSyncSeatId(veh_id,0)
			crash = false
			sampForceOnfootSync()
	    end)
	end
end

function sendOnfootSync(x, y, z)
	local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local data = allocateMemory(68)
	sampStorePlayerOnfootData(myId, data)
	setStructFloatElement(data, 6, x, false)
	setStructFloatElement(data, 10, y, false)
	setStructFloatElement(data, 14, z, false)
	sampSendOnfootData(data)
	freeMemory(data)
end

function main()
	repeat wait(0) until isSampAvailable()
	sampRegisterChatCommand('crsh', function()
		crasher = not crasher
		sampAddChatMessage("crasher - " .. (crasher and "on" or "off"), -1)
	end)
	wait(-1)
end