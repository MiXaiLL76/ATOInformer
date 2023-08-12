local sectorId = nil

function point_dist(a, b, a1, b1) return math.sqrt((a1 - a) ^ 2 + (b1 - b) ^ 2) end

function getNameByTexture(textureId)
    local texture_path = getNormalString(common.GetTexturePath(textureId))
    if texture_path:find('Green') then return 'G' end

    if texture_path:find('Red') then return 'R' end

    if texture_path:find('Blue') then return 'B' end
end

function getMyHubInfo()
    local radius = math.floor(astral.GetHubRadius())
    local pos = astral.GetHubCenter()
    local x = math.floor(tonumber(getNormalString(pos['posX'])))
    local y = math.floor(tonumber(getNormalString(pos['posY'])))

    return "Hub_" .. tostring(radius) .. "_" .. tostring(x) .. "_" ..
               tostring(y)
end

function OnTimer(params)
    local shipId = unit.GetTransport(avatar.GetId())
    local mx = 0
    local my = 0

    -- LogToChat("shipId: " .. getNormalString(shipId))
    if shipId then
        local activeShipInfo = transport.GetPosition(shipId)
        mx = tonumber(getNormalString(activeShipInfo['posX']))
        my = tonumber(getNormalString(activeShipInfo['posY']))

        local objects = astral.GetObjects()
        for i, objectId in pairs(objects) do
            local object = astral.GetObjectInfo(objectId)

            if object then
                local cur_name = getNormalString(object['name'])
                local pos = object.position

                if cur_name:find(Utf8ToAnsi(
                                     'Астральная воронка')) then

                    local x = tonumber(getNormalString(pos['posX']))
                    local y = tonumber(getNormalString(pos['posY']))

                    local dist = point_dist(mx, my, x, y)
                    local object_type = getNameByTexture(object.image)

                    LogToChat("dist: " .. tostring(object_type) .. " > " ..
                                  getNormalString(dist))
                end
            end
        end

    end
end

function OnHubChanged(params)
    LogToChat(dump(params))

    local zoneInfo = cartographer.GetCurrentZoneInfo()
    LogToChat(dump(zoneInfo))
    local zonesMapId = unit.GetZonesMapId(avatar.GetId())
    LogToChat(dump(zonesMapId))
    local radius = astral.GetHubRadius()
    LogToChat(dump(radius))
    local pos = astral.GetHubCenter()
    LogToChat(dump(pos))
    -- common.RegisterEventHandler( OnHubChanged, "EVENT_ASTRAL_HUB_CHANGED" )
    -- OnHubChanged()

    -- common.RegisterEventHandler( OnTimer, "EVENT_SECOND_TIMER" )
    -- -- LogToChat('started.')
    -- local sectorId = astral.GetCurrentSector()
    -- if sectorId then
    --     LogToChat( getNormalString(sectorId) )
    --     LogToChat(getMyHubInfo())
    -- end

end
