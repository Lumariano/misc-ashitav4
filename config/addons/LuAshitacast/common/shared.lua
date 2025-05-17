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

local function GetTrueActionTargetDistance()
    local actionTarget = gData.GetActionTarget();
    return actionTarget.Distance - AshitaCore:GetMemoryManager():GetEntity():GetModelHitboxSize(actionTarget.Index);
end
M.GetTrueActionTargetDistance = GetTrueActionTargetDistance;

local function GetIsIncapacitated()
    return gData.GetBuffCount(7) > 0 -- Petrification
        or gData.GetBuffCount(10) > 0 -- Stun
        or gData.GetBuffCount(28) > 0 -- Terror
        or gData.GetBuffCount(2) > 0 -- Sleep
        or gData.GetBuffCount(19) > 0; -- Sleep?
end
M.GetIsIncapacitated = GetIsIncapacitated;

local function GetCantUseAbilities()
    return gData.GetBuffCount(16) > 0 -- Amnesia
        or gData.GetBuffCount(261) > 0; -- Impairment
end

local function GetCantCastSpells()
    return gData.GetBuffCount(6) > 0 -- Silence
        or gData.GetBuffCount(29) > 0; -- Mute
end

M.Bailout = function ()
    local handler = gData.GetCurrentCall();
    local player = gData.GetPlayer();
    local action = gData.GetAction();
    local reason = "";

    repeat
        if (GetIsIncapacitated()) then
            reason = "Incapacitated!";
            break;
        end

        if (handler == "HandlePrecast" and GetCantCastSpells()) then
            reason = "Silenced";
            break;
        end

        if ((handler  == "HandleAbility" or handler == "HandleWeaponskill") and GetCantUseAbilities()) then
            reason = "Amnesia!";
            break;
        end

        if ((handler == "HandlePrecast" or handler == "HandlePreshot") and player.IsMoving) then
            reason = "You are moving!";
            break;
        end

        if (handler == "HandleWeaponskill" and player.TP < 1000) then
            reason = "Not enough TP!";
            break;
        end

        if (handler == "HandlePreshot") then
            if (M.GetTrueActionTargetDistance() > 24.9) then
                reason = "Out of range!";
                break;
            end
        elseif (action.Resource.Range ~= 15 and M.GetTrueActionTargetDistance() > actionRanges[action.Resource.Range]) then
            reason = "Out of range!";
            break;
        end
    until true;

    if (reason ~= "") then
        gFunc.CancelAction();

        if (not action.Resend) then
            print(chat.header(handler):append(chat.critical(reason)));
        end

        return true;
    end

    return false;
end

return M;
