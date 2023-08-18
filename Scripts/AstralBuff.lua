Global("AstralBuff", {})

AstralBuff.pvp_astral_chest_name =
    "Захваченная аномальная материя"
AstralBuff.astral_chest_name =
    "Стабилизация аномальной материи"
AstralBuff.ship_breaked_name =
    "Энергетическое возмущение"
AstralBuff.last_time = nil
AstralBuff.registred = false

AstralBuff.buff_panel = mainForm:GetChildChecked("BuffPanel", true)
AstralBuff.buff_panel_state = {
    ["PVP"] = false,
    ["PVE"] = false,
    ["SHIP"] = false
}

function AstralBuff.getBuffTimeout(buff)
    return math.floor(buff['remainingMs'] / 1000)
end

function AstralBuff.createSound()
    AstralBuff.sound = nil
    if common.IsSoundEnabled() == true then
        local group = common.GetAddonRelatedSoundGroup("Sound")
        local soundId = group:GetSound('Sound1')
        AstralBuff.sound = common.CreateSound(soundId)
    end
end

function AstralBuff.playSound()
    if AstralBuff.sound then AstralBuff.sound:Play(true) end
end

function AstralBuff.Init()
    common.RegisterEventHandler(AstralBuff.ChangeTransport,
                                "EVENT_AVATAR_TRANSPORT_CHANGED")

    AstralBuff.ChangeTransport()
    AstralBuff.createSound()
end

function AstralBuff.reg_un_reg()
    if AstralBuff.registred then
        common.UnRegisterEventHandler(AstralBuff.FindShipBuffs,
                                      "EVENT_OBJECT_BUFFS_CHANGED")
        common.UnRegisterEventHandler(AstralBuff.WatchShipBuffs,
                                      "EVENT_SECOND_TIMER")
        AstralBuff.registred = false
        return
    end

    common.RegisterEventHandler(AstralBuff.FindShipBuffs,
                                "EVENT_OBJECT_BUFFS_CHANGED",
                                {objectId = AstralBuff.shipId})
    common.RegisterEventHandler(AstralBuff.WatchShipBuffs, "EVENT_SECOND_TIMER")
    AstralBuff.registred = true
end

function AstralBuff.ChangeTransport()
    AstralBuff.shipId = AstralBuff.get_my_id()
    AstralBuff.last_time = common.GetLocalDateTimeMs() / 1000

    if AstralBuff.shipId == nil then return end
    
    if AstralBuff.registred then
        AstralBuff.reg_un_reg()
    end

    AstralBuff.reg_un_reg()

    LogToChat("Вы сели на транспорт: " ..
                  dump({["shipID"] = AstralBuff.shipId}))
    -- LogToChat(dump(AstralBuff.registred))
end

function AstralBuff.get_my_id()
    local shipId = unit.GetTransport(avatar.GetId())
    -- if shipId == nil then
    --     shipId = avatar.GetId()
    --     LogToChat("Игрок....")
    -- end

    return shipId
end

function AstralBuff.FindShipBuffs()
    if AstralBuff.shipId == nil then return end
    local activeBuffs = object.GetBuffs(AstralBuff.shipId)

    AstralBuff.pvp_astral_chest_buff = nil
    AstralBuff.astral_chest_buff = nil
    AstralBuff.ship_breaked_buff = nil

    for i, buffID in pairs(activeBuffs) do
        local buff_info = object.GetBuffInfo(buffID)
        local buff_name = getNormalString(buff_info['name'])
        -- LogToChat(dump(buff_info))

        if buff_name:find(Utf8ToAnsi(AstralBuff.pvp_astral_chest_name)) then
            -- LogToChat(dump(buff_info))
            AstralBuff.pvp_astral_chest_buff = buff_info
        end

        if buff_name:find(Utf8ToAnsi(AstralBuff.astral_chest_name)) then
            -- LogToChat(dump(buff_info))
            AstralBuff.astral_chest_buff = buff_info
        end

        if buff_name:find(Utf8ToAnsi(AstralBuff.ship_breaked_name)) then
            -- LogToChat(dump(buff_info))
            AstralBuff.ship_breaked_buff = buff_info
        end

        -- if buff_name:find(Utf8ToAnsi("Тактика")) then
        --     -- LogToChat(dump(buff_info))
        --     AstralBuff.ship_breaked_buff = buff_info
        -- end
    end

    AstralBuff.last_time = AstralBuff.last_time - 10
end

function AstralBuff.WatchShipBuffs()
    if AstralBuff.shipId == nil then return end

    -- LogToChat(dump(AstralBuff.shipId ))

    local delta = math.floor((common.GetLocalDateTimeMs() / 1000) -
                                 AstralBuff.last_time)
    if (delta <= 5) then
        AstralBuff.FindShipBuffs()
        return
    end

    AstralBuff.last_time = common.GetLocalDateTimeMs() / 1000

    if AstralBuff.pvp_astral_chest_buff then
        local sec = AstralBuff.getBuffTimeout(AstralBuff.pvp_astral_chest_buff)
        if sec < 120 then
            AstralBuff.showMsg("PVP",
                               AstralBuff.pvp_astral_chest_buff['texture'], sec)
        end
    else
        AstralBuff.showMsg("PVP")
    end

    if AstralBuff.astral_chest_buff then
        local sec = AstralBuff.getBuffTimeout(AstralBuff.astral_chest_buff)
        if sec < 120 then
            AstralBuff.showMsg("PVE", AstralBuff.astral_chest_buff['texture'],
                               sec)
        end
    else
        AstralBuff.showMsg("PVE")
    end

    if AstralBuff.ship_breaked_buff then
        local sec = AstralBuff.getBuffTimeout(AstralBuff.ship_breaked_buff)
        if sec < 120 then
            AstralBuff.showMsg("SHIP", AstralBuff.ship_breaked_buff['texture'],
                               sec)
        end
    else
        AstralBuff.showMsg("SHIP")
    end

    if AstralBuff.ship_breaked_buff or AstralBuff.astral_chest_buff or
        AstralBuff.pvp_astral_chest_buff then
        AstralBuff.buff_panel:Show(true)
        mainForm:Show(true)
    else
        AstralBuff.buff_panel:Show(false)
        mainForm:Show(false)
    end
end

function AstralBuff.showMsg(value, textureId, sec)
    if (sec == nil) then
        if (AstralBuff.buff_panel_state[value] == false) then
            return
        else
            AstralBuff.buff_panel_state[value] = false
            sec = 0
        end
    end

    -- LogToChat(dump({['value'] = value, ['sec'] = sec}))

    local color = "LogColorGreen"

    if (sec < 90) then color = "LogColorOrange" end

    if (sec > 85 and sec < 90) then AstralBuff.playSound() end

    if (sec < 60) then color = "LogColorRed" end

    if (sec > 55 and sec < 60) then AstralBuff.playSound() end

    local label = AstralBuff.buff_panel:GetChildChecked(value, true)
                      :GetChildChecked("AnnounceLabel", true)
    local texture = AstralBuff.buff_panel:GetChildChecked(value, true)
                        :GetChildChecked("AnnounceTexture", true)
    local counter = AstralBuff.buff_panel:GetChildChecked(value, true)
                        :GetChildChecked("AnnounceCounter", true)
    if (textureId == nil) then
        texture:Show(false)
        label:Show(false)
        counter:Show(false)
        return
    end

    texture:SetBackgroundTexture(textureId)
    texture:Show(true)

    label:SetClassVal("color", color)
    label:SetVal("value", userMods.ToWString(value))
    label:Show(true)

    counter:SetVal("value", userMods.ToWString(tostring(sec)))
    counter:SetClassVal("color", color)
    counter:Show(true)

    AstralBuff.buff_panel:Show(true)
    AstralBuff.buff_panel_state[value] = true
end
