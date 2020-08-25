script_name('shotinfo by wildboar')
script_author('wildboar')
script_version('1.2')

require 'lib.moonloader'
local sampev = require 'lib.samp.events'
local weapons = require 'game.weapons'
local keys = require 'vkeys'

local script_state = false

function main()
    while not isSampAvailable() or not isSampfuncsLoaded() do wait(0) end
    wait(0)
    sampAddChatMessage('shotinfo {00ff00}loaded', 0xffffff)
    sampRegisterChatCommand('shotinfo', shot)
    while true do
            wait(0)
            if script_state == true then
                if isKeyJustPressed(VK_RBUTTON) then
                    sampAddChatMessage('[KEY] {FFFFFF}Нажата {33aa33}KEY_AIM{FFFFFF}.', 0x6495ED)
                end
                if isKeyJustPressed(VK_LBUTTON) then
                    sampAddChatMessage('[KEY] {FFFFFF}Нажата {FF8282}KEY_FIRE{FFFFFF}.', 0x6495ED)
                end
            end
    end   
end

function sampev.onSendBulletSync(data)
    if sampIsPlayerConnected(data.targetId) then
        weapon = getCurrentCharWeapon(PLAYER_PED)
        _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nick = sampGetPlayerNickname(myid)
        enemy = sampGetPlayerNickname(data.targetId)

        local res, ped = sampGetCharHandleBySampPlayerId(data.targetId)
        if res then 
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local var_x, var_y, var_z = getCharCoordinates(ped)
            local dis = getDistanceBetweenCoords3d(x, y, z, var_x, var_y, var_z)
            dis = math.floor(dis)
            if data.targetType == 1 and script_state == true then
                sampAddChatMessage('[S] {FFFFFF}' .. nick .. ' > ' .. weapons.get_name(weapon) .. ', ' .. dis .. ' m' .. ' > ' .. enemy, 0x6495ED)
            end
        end
    end
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(myid)
    weapon = getCurrentCharWeapon(PLAYER_PED)
    if data.targetType == 0 and script_state == true then
        sampAddChatMessage('[S] {FFFFFF}' .. nick .. ' > ' .. weapons.get_name(weapon) .. ' > ' .. '{6495ED}ПРОМАХ', 0x6495ED)
    end
end

function shot()
    if script_state == false then
        sampAddChatMessage('shotinfo {00ff00}on', 0xffffff)
        script_state = true
    else
        sampAddChatMessage('shotinfo {ff0000}off', 0xffffff)
        script_state = false
    end
end