local M = { };

local actionRanges = {
    [0] = 1,
    [2] = 3.4,
    [3] = 4.47273,
    [4] = 5.76,
    [5] = 6.88889,
    [6] = 7.8,
    [7] = 8.4,
    [8] = 10.4,
    [9] = 12.4,
    [10] = 14.5,
    [11] = 16.4,
    [12] = 20.4,
    [13] = 24.9,
};

local function GetIsIncapacitated()
    return gData.GetBuffCount(7) > 0 -- Petrification
        or gData.GetBuffCount(10) > 0 -- Stun
        or gData.GetBuffCount(28) > 0 -- Terror
        or gData.GetBuffCount(2) > 0 -- Sleep
        or gData.GetBuffCount(19) > 0; -- Sleep?
end
M.GetIsIncapacitated = GetIsIncapacitated;

local function GetTrueActionTargetDistance()
    local actionTarget = gData.GetActionTarget();
    return actionTarget.Distance - AshitaCore:GetMemoryManager():GetEntity():GetModelHitboxSize(actionTarget.Index);
end
M.GetTrueActionTargetDistance = GetTrueActionTargetDistance;

local function GetCantUseAbilities()
    return GetIsIncapacitated()
        or gData.GetBuffCount(16) > 0 -- Amnesia
        or gData.GetBuffCount(261) > 0; -- Impairment
end

local function GetCantCastSpells()
    return GetIsIncapacitated()
        or gData.GetBuffCount(6) > 0 -- Silence
        or gData.GetBuffCount(29) > 0; -- Mute
end

M.SpellBailout = function ()
    if (GetCantCastSpells()) then
        gFunc.CancelAction();
        print(chat.header("HandlePrecast"):append(chat.critical("Can't cast spells!")));
        return;
    end

    local rangeIndex = gData.GetAction().Resource.Range;

    if (rangeIndex ~= 15 and GetTrueActionTargetDistance() > actionRanges[rangeIndex]) then
        gFunc.CancelAction();
        print(chat.header("HandlePrecast"):append(chat.critical("Out of range!")));
        return;
    end
end

M.WeaponskillBailout = function ()
    if (GetCantUseAbilities()) then
        gFunc.CancelAction();
        print(chat.header("HandleWeaponskill"):append(chat.critical("Can't use weaponskills!")));
        return;
    end

    if (gData.GetPlayer().TP < 1000) then
        gFunc.CancelAction();
        print(chat.header("HandleWeaponskill"):append(chat.critical("Not enough TP!")));
        return;
    end

    local rangeIndex = gData.GetAction().Resource.Range;

    if (rangeIndex ~= 15 and GetTrueActionTargetDistance() > actionRanges[rangeIndex]) then
        gFunc.CancelAction();
        print(chat.header("HandleWeaponskill"):append(chat.critical("Out of range!")));
        return;
    end
end

return M;
