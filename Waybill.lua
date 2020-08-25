-- /* Автор: BARRY_BARDLEY | Сообщество: vk.com/trinity_mod */ --

local se = require "lib.samp.events" -- Евенты
local waybillPanel = {} -- Массив с списком с /waybill
local waybillON = {false, false, false} -- Переменные для диалогов
local tempName = nil -- Имя заказа

-- Массив с координатами и иминами (сделано по дурному ибо вносил в json файл и лень было переделывать)
local waybillCoord = {
	{posX = -1429.0531005859, posZ = 101.66554260254, name = "Ферма «Утес Шитфилд»", posY = -1460.4440917969},
	{posX = -1028.3771972656, posZ = 31.715784072876, name = "Нефтезавод AF", posY = -683.62579345703},
	{posX = -1258.6958007813, posZ = 13.855659484863, name = "Центральный аэропорт AF", posY = 63.160491943359},
	{posX = -1949.0986328125, posZ = 35.175628662109, name = "Склад «SF General»", posY = 1000.4205322266},
	{posX = -1826.3991699219, posZ = 16.136058807373, name = "Электростанция San Fierro", posY = 93.566284179688},
	{posX = -1857.2760009766, posZ = 21.75, name = "Фабрика «AF Junkyard»", posY = -1720.1424560547},
	{posX = -71.887145996094, posZ = 0.78466147184372, name = "Склад «C & G»", posY = -1107.7906494141},
	{posX = 2824.5805664063, posZ = 11.765707015991, name = "Склад «East Rockshore»", posY = 966.54052734375},
	{posX = -147.57495117188, posZ = 20.767845153809, name = "Фабрика «Carson Wine»", posY = 1084.0933837891},
	{posX = 264.78353881836, posZ = 11.602527618408, name = "Нефтезавод RC", posY = 1359.248046875},
	{posX = 2743.5554199219, posZ = 14.46625995636, name = "Склад «Seville Storage»", posY = -2000.6407470703},
	{posX = 2677.5224609375, posZ = 31.511892318726, name = "Электростанция Los Santos", posY = -1491.8350830078},
	{posX = -2006.6813964844, posZ = 30.625, name = "Завод «Pine Paper»", posY = -2413.7993164063},
	{posX = -1056.9599609375, posZ = 128.84588623047, name = "Ферма «Плато Фергисон»", posY = -1192.6134033203},
	{posX = -1871.5373535156, posZ = 8.203145980835, name = "Склад «SF Pier»", posY = 1414.4914550781},
	{posX = -1733.7958984375, posZ = 4.5645842552185, name = "Склад «SF Docks»", posY = -122.03926086426},
	{posX = 822.3515625, posZ = 12.725006103516, name = "Карьер «Hunter»", posY = 854.73785400391},
	{posX = -331.87707519531, posZ = 76.369270324707, name = "Лаборатория «Big Ear»", posY = 1530.8173828125},
	{posX = 2736.8269042969, posZ = 14.553518295288, name = "Склад «LS Docks»", posY = -2507.0622558594},
	{posX = 1791.0274658203, posZ = -1.7586472034454, name = "Центральный аэропорт US", posY = -2324.2900390625},
	{posX = 823.51214599609, posZ = 17.35931968689, name = "Склад «Dillimore Depot»", posY = -609.28424072266},
	{posX = 220.91767883301, posZ = 3.594304561615, name = "Склад «Xoomer US»", posY = 13.159379005432},
	{posX = 1757.6219482422, posZ = 14.608687400818, name = "Склад «LS Unity»", posY = -2061.669921875},
	{posX = 2636.8815917969, posZ = 14.538791656494, name = "Нефтезавод US", posY = -2117.2036132813},
	{posX = 2347.7485351563, posZ = 11.751152038574, name = "Склад «Clown Pocket»", posY = 1885.8626708984},
	{posX = 1333.0765380859, posZ = 19.5546875, name = "Фабрика «Montgomery Sprunk»", posY = 288.15341186523},
	{posX = -108.87702941895, posZ = 1.4296875, name = "Завод «FleischBerg»", posY = -328.19812011719},
	{posX = -591.81530761719, posZ = 61.258460998535, name = "Электростанция Las Venturas", posY = 2021.8397216797},
	{posX = 2199.3088378906, posZ = 11.829942703247, name = "Фабрика «Prickle Food»", posY = 2788.3037109375},
	{posX = 864.60076904297, posZ = 17.995162963867, name = "Склад «LS Cinema»", posY = -1206.3461914063},
	{posX = 1414.3500976563, posZ = 10.8203125, name = "Склад «Kakagawa»", posY = 1067.9560546875},
	{posX = 1588.0592041016, posZ = 10.833473205566, name = "Центральный аэропорт RC", posY = 1450.1109619141},
	{posX = -2459.21484375, posZ = 4.6696014404297, name = "Завод «LV Fisher»", posY = 2294.0815429688}
}

-- Основная функция
function main()
	repeat wait(0) until isSampAvailable()
	
	-- Команда для взятия заказа
	sampRegisterChatCommand(
		'way', 
		function()
			waybillON[1] = true; sampSendChat("/waybill");
		end
	)
end

-- Хук на проверку диалога
function se.onShowDialog(id, style, title, btn1, btn2, text)
	-- Диалог /waybill
	if id == 6490 and waybillON[1] then
		local posX, posY, posZ = getCharCoordinates(PLAYER_PED) -- Получили координаты педа
		local tempDistance = 0 -- Временная переменная
		local key = 0 -- Переменная для подсчета listbox
		waybillPanel = {} -- Очистка массива
		
		-- Сортируем текст по строкам
		for line in text:gmatch("[^\r\n]+") do
			--Ищим нужные нам строки
			if line:find("Заказ был отправлен в работу") then
				table.insert(waybillPanel, {name = "Заказ был отправлен в работу", key = key})
			elseif line:find("Заказ от предприятия") then
				table.insert(waybillPanel, {name = all_trim(line), key = key}) -- Вносим имя и ключ listbox
			end
			key = key + 1 -- +1 каждый listbox
		end
		
		if waybillPanel ~= nil then
			for key, val in pairs(waybillCoord) do
				for key2, val2 in pairs(waybillPanel) do
					-- Ищим в масиве похожие имена
					if waybillPanel[key2]["name"]:find(waybillCoord[key]["name"]) then
						--Если нашли то вносим первый попавший заказ и дистанцию к нему
						if tempDistance == 0 or tempDistance == nil then
							tempDistance = getDistanceBetweenCoords3d(waybillCoord[key]["posX"], waybillCoord[key]["posY"], waybillCoord[key]["posZ"], posX, posY, posZ)
							tempName = waybillCoord[key]["name"]
						else -- После того как дистанция уже не 0, вносим самую меньшую дистанцию
							local distance = getDistanceBetweenCoords3d(waybillCoord[key]["posX"], waybillCoord[key]["posY"], waybillCoord[key]["posZ"], posX, posY, posZ)
							if tempDistance > distance then -- Если меньше что сохранили мы уже то перезаписуем дистанцию
								tempDistance = distance -- записали дистанцию
								tempName = waybillCoord[key]["name"] -- записали имя так же
							end
						end
					end
				end
			end
		end
		
		if tempName ~= nil or tempName ~= "" or tempName ~= " " then -- Если имя есть продолжаем
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Ближайший заказ {EF435D}"..tempName, -1) -- показываваем имя заказа
			for line in text:gmatch("[^\r\n]+") do
				if line:find(tempName) then
					for key, val in pairs(waybillPanel) do
						if waybillPanel[key]["name"]:find(tempName) then -- Ищим в /waybill нужный нам заказ
							sampSendDialogResponse(id, 1, waybillPanel[key]["key"], line) -- Нажимаем на него (line нужно для нажатия ибо без ввода input не рабатает!! Хз почему и с /route так же)
							waybillON[2] = true; waybillON[1] = false; 
							return false
						end
					end
				end
			end
		else
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Не найдено ближайшего заказа", -1) -- Если нет рядом ничего (Не возможно, но мб не все точки есть в массиве)
		end
		waybillON[1] = false
	end
	
	-- Диалог подтверждения заказа
	if id == 6491 and waybillON[2] then
		sampSendDialogResponse(id, 1, -1, -1)
		waybillON[3] = true; waybillON[2] = false;
		return false
	end
	
	-- Диалог оповещения о взятии заказа
	if id == 45 and waybillON[3] then
		sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Вы начали работу над заказом {EF435D}"..tempName, -1)
		sampSendDialogResponse(id, 1, -1, -1)
		waybillON[3] = false
		return false
	end
	
	-- Диалоги которые могут быть с /waybill
	if id == 45 then
		if text:find("Вами уже было получено направление на доставку грузов.") then
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Вами уже было получено направление на доставку грузов.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
	
		if text:find("Взяться за следующую миссию по доставке груза вы сможете только через .* мин. .* сек.") then
			local min, sek = text:match("Взяться за следующую миссию по доставке груза вы сможете только через (%d+) мин. (%d+) сек.")
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Взяться за следующую миссию по доставке груза вы сможете только через "..min.." мин. "..sek.." сек.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
		
		if text:find("Взяться за следующую миссию по доставке груза вы сможете только через .* сек.") then
			local sek = text:match("Взяться за следующую миссию по доставке груза вы сможете только через (%d+) сек.")
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Взяться за следующую миссию по доставке груза вы сможете только через "..sek.." сек.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
		
		if text:find("Это транспортное средство не принадлежит вам.") then
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Это транспортное средство не принадлежит вам.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
		
		if text:find("Вы должны находиться за рулем грузовика, который будет использоваться в работе.") then
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Вы должны находиться за рулем грузовика, который будет использоваться в работе.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
		
		if text:find("Для получения направления вам потребуется грузовик Linerunner, Tanker или Roadtrain.") then
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Для получения направления вам потребуется грузовик Linerunner, Tanker или Roadtrain.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
		
		if text:find("На сервере уже есть 5 заспавненных вами транспортов. Освободите один слот, который будет использоваться для спавна трейлера.") then
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: На сервере уже есть {EF435D}5 заспавненных {FFFFFF}вами транспортов.", -1)
			sampAddChatMessage("{EF435D}[{FFFFFF}WB{EF435D}] {FFFFFF}: Освободите один слот, который будет использоваться для спавна трейлера.", -1)
			sampSendDialogResponse(id, 1, -1, -1)
			return false
		end
	
	end
	
end

-- Функция убирает лишние пробелы
function all_trim(s)
	return s:match( "^%s*(.-)%s*$" )
end