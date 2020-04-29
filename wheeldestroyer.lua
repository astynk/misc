local ev = require('lib.samp.events')

local state = false
local target = 0

local global = false
local g_radius = 5

function main()
    repeat wait(0) until isSampAvailable()
    sampRegisterChatCommand('wd', function(param)
        if not isCharOnFoot(PLAYER_PED) then return sampAddChatMessage('need to be onfoot', -1) end
        if not param:match('%d+') then return sampAddChatMessage('use: /wd [targetid]', -1) end
        local _, veh = sampGetCarHandleBySampVehicleId(param)
        if not _ then return sampAddChatMessage('invalid car', -1) end
        local x, y, z = getCharCoordinates(PLAYER_PED)
        target = tonumber(param)
        state = true
        local px, py, pz = getActiveCameraPointAt()
        pcall(sampForceOnfootSync)
        pcall(sampForceUnoccupiedSyncSeatId, target, 0)
        sampSendDamageVehicle(target, 0, 0, 0, 99999999)
        state = false
        pcall(sampForceOnfootSync)
        sampAddChatMessage('done', -1)
    end)
    sampRegisterChatCommand('wda', function() 
        global = not global
        if global then
            lua_thread.create(function() 
                sampAddChatMessage('start', -1)
                while global do
                    wait(0)
                    local cars = getAllVehicles()
                    for k, car in pairs(cars) do
                        local x, y, z = getCharCoordinates(PLAYER_PED)
                        local is, res, err = pcall(isCarInArea3d, car, x + g_radius, y + g_radius, z + g_radius, x - g_radius, y - g_radius, z - g_radius, false)
                        if is and res then
                            local _, vid = sampGetVehicleIdByCarHandle(car)
                            if _ and getDriverOfCar(car) == -1 then
                                target = vid
                                state = true
                                local px, py, pz = getActiveCameraPointAt()
                                pcall(sampForceOnfootSync)
                                pcall(sampForceUnoccupiedSyncSeatId, target, 0)
                                sampSendDamageVehicle(target, 0, 0, 0, 99999999)
                                state = false
                                for i = 0, 5 do
                                    pcall(sampForceOnfootSync)
                                end
                                wait(500)
                            end
                        end
                    end
                end
                sampAddChatMessage('done', -1)
            end)
        end
    end)
    wait(-1)
end

function ev.onSetPlayerPos()
    if state then return false end
end

function ev.onSendPlayerSync(data)
    if state then
        local _, veh = sampGetCarHandleBySampVehicleId(target)
        if _ then
            local x, y, z = getCarCoordinates(veh)
            data.position = {x = x, y = y, z = z + 1}
            data.surfingVehicleId = target
            data.surfingOffsets.z = 1
            printStringNow('obrabotka ~r~' .. target, 500)
        end
    end
end