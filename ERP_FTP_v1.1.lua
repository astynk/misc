local q,vector,tp,sync = require('lib.samp.events'), require 'vector3d',false,false
function main()
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand('ftp', function()
		if isCharInAnyCar(PLAYER_PED) or tp then return end
		blip, blipX, blipY, blipZ = getTargetBlipCoordinatesFixed()
		if blip then
			sync = true
			charPosX, charPosY, charPosZ = getCharCoordinates(PLAYER_PED)
			local distan = getDistanceBetweenCoords3d(blipX, blipY, charPosZ, charPosX, charPosY, charPosZ)
			if distan < 35 then return setCharCoordinates(PLAYER_PED, blipX, blipY, blipZ) end
			tp = true
			tpTime = os.clock()
		end
	end)
	sampRegisterChatCommand('ftpc', function()
		if isCharInAnyCar(PLAYER_PED) or tp then return end
		blip, blipX, blipY, blipZ = SearchMarker()
		if blip then
			sync = true
			charPosX, charPosY, charPosZ = getCharCoordinates(PLAYER_PED)
			local distan = getDistanceBetweenCoords3d(blipX, blipY, charPosZ, charPosX, charPosY, charPosZ)
			if distan < 35 then return setCharCoordinates(PLAYER_PED, blipX, blipY, blipZ) end
			tp = true
			tpTime = os.clock()
		end
	end)
	while true do 
		wait(0)
		for i=0,1 do
			if tp then
				ncharPosX, ncharPosY, ncharPosZ = getCharCoordinates(PLAYER_PED)
				local distanc = getDistanceBetweenCoords3d(blipX, blipY, charPosZ, charPosX, charPosY, charPosZ)
				if getDistanceBetweenCoords3d(blipX, blipY, charPosZ, charPosX, charPosY, charPosZ) > 7 then
					vectorX = blipX - charPosX
					vectorY = blipY - charPosY
					vectorZ = blipZ - charPosZ
					local vec = vector(vectorX, vectorY, vectorZ)
					vec:normalize()
					charPosX = charPosX + vec.x * 7
					charPosY = charPosY + vec.y * 7
					charPosZ = charPosZ + vec.z * 7
					sendOnfootSync(charPosX, charPosY, charPosZ)
					sendOnfootSync(charPosX, charPosY, charPosZ + 55)
				else
					sendOnfootSync(charPosX, charPosY, charPosZ)
					sendOnfootSync(charPosX, charPosY, charPosZ + 55)
					setCharCoordinates(PLAYER_PED, blipX, blipY, blipZ)
					wait(1000)
					tp = false
					printStringNow('~y~please wait~W~...',5000)
					printStringNow('~y~onfoot ~W~teleported', 4000)
					sync = false
				end
			end
		end
	end
end
function q.onSetPlayerPos(p) if sync then timer = os.clock() return false end end
function q.onSendPlayerSync(data) if tp then return false end end
function sendOnfootSync(x, y, z) local data = samp_create_sync_data('player'); data.position = {x, y, z}; data.moveSpeed = {0.899999, 0.899999, -0.899999}; data.send() end
function getTargetBlipCoordinatesFixed() local bool, x, y, z = getTargetBlipCoordinates(); if not bool then return false end; requestCollision(x, y); loadScene(x, y, z); local bool, x, y, z = getTargetBlipCoordinates(); return bool, x, y, z end
function SearchMarker(posX, posY, posZ) local ret_posX,ret_posY,ret_posZ,isFind  = 0,0,0,false; for id = 0, 31 do local MarkerStruct = 0xC7F168 + id * 56; local MarkerPosX,MarkerPosY,MarkerPosZ = representIntAsFloat(readMemory(MarkerStruct + 0, 4, false)),representIntAsFloat(readMemory(MarkerStruct + 4, 4, false)),representIntAsFloat(readMemory(MarkerStruct + 8, 4, false)); if MarkerPosX ~= 0.0 or MarkerPosY ~= 0.0 or MarkerPosZ ~= 0.0 then ret_posX,ret_posY,ret_posZ,isFind = MarkerPosX,MarkerPosY,MarkerPosZ,true end end return isFind, ret_posX, ret_posY, ret_posZ end
function samp_create_sync_data(sync_type, copy_from_player) local ffi,sampfuncs,raknet = require 'ffi', require 'sampfuncs', require 'samp.raknet'; copy_from_player = copy_from_player or true; local sync_traits = {player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}}; local sync_info = sync_traits[sync_type]; local data_type = 'struct ' .. sync_info[1]; local data = ffi.new(data_type, {}); local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data))) if copy_from_player then local copy_func = sync_info[3] if copy_func then local _, player_id if copy_from_player == true then _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED) else player_id = tonumber(copy_from_player) end copy_func(player_id, raw_data_ptr) end end local func_send = function() local bs = raknetNewBitStream() raknetBitStreamWriteInt8(bs, sync_info[2]) raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data)) raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1) raknetDeleteBitStream(bs) end local mt = {__index = function(t, index) return data[index] end, __newindex = function(t, index, value) data[index] = value end } return setmetatable({send = func_send}, mt) end