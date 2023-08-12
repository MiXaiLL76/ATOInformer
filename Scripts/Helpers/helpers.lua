local ToWs = userMods.ToWString
local IsWs = common.IsWString
local FromWs = userMods.FromWString
local AddonName = tostring(common.GetAddonName())

function getNormalString(input_string)
    if not input_string then return nil end
    if (IsWs(input_string)) then input_string = FromWs(input_string); end
    return tostring(input_string);
end

function getZoneName()
    local zoneInfo = cartographer.GetCurrentZoneInfo();
    if zoneInfo ~= nil then return getNormalString(zoneInfo.zoneName); end
    return ''
end

function GetUnitName(unitId)
    local unit_name = object.GetName(unitId)
    return getNormalString(unit_name)
end

function LogToChat(text, chatColor, addonName)
    text = Utf8ToAnsi(text)

    local wtChat = nil
    local valuedText = common.CreateValuedText()

    if not wtChat then
        wtChat = stateMainForm:GetChildUnchecked("ChatLog", false)

        wtChat = wtChat:GetChildUnchecked("Container", true)

        local formatVT =
            "<html fontname='AllodsFantasy' fontsize='14' shadow='1'>" ..
                "<rs class='color'><r name='addon'/><r name='text'/></rs>" ..
                "</html>"
        valuedText:SetFormat(ToWs(formatVT))
    end

    if wtChat and wtChat.PushFrontValuedText then
        if not IsWs(text) then text = ToWs(text) end
        valuedText:ClearValues()
        valuedText:SetClassVal("color", chatColor or "LogColorYellow")
        valuedText:SetVal("text", text)
        valuedText:SetVal("addon", ToWs(addonName or AddonName .. ": "))
        wtChat:PushFrontValuedText(valuedText)
    end
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        if type(o) == 'userdata' then return getNormalString(o) end

        return tostring(o)
    end
end

function toLog(data)
    common.LogInfo('common', AddonName .. ' - ', tostring(getNormalString(data)))
end
