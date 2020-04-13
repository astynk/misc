require 'lib.moonloader'
function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end 
	sampRegisterChatCommand('hunt', function(id)
		hs = tonumber(id)
		state = not state
		if id == '' then
			sampAddChatMessage('{FF0000}[������] {FF8C00}������� ���������� ��!', 0xFFFF0000)
		else
			if state then
				if sampIsPlayerConnected(hs) then
					res, handle = sampGetCharHandleBySampPlayerId(hs) 
					if res then
						setCameraInFrontOfChar(handle)
					else
						sampAddChatMessage('{FF0000}[������] {FF8C00}������ ��� � ���� ������.', 0xFFFF0000)
						state = false
						setCameraInFrontOfChar(PLAYER_PED)
					end
				else
					sampAddChatMessage('{FF0000}[������] {FF8C00}����� �� � ����.', 0xFFFF0000)
					state = false
					setCameraInFrontOfChar(PLAYER_PED)
				end
			else
				setCameraInFrontOfChar(PLAYER_PED)
			end
		end
	end)
	while true do
		wait(0)
	end
end