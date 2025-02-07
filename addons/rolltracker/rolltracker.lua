addon.name    = "rolltracker";
addon.author  = "Lumaro";
addon.version = "1.0";
addon.desc    = "Tracks rolls.";
addon.link    = "https://github.com/Lumariano/misc-ashitav4/"

require("common");
local rolls = require("rolls");
local chat  = require("chat");

local function roll_print(roll_id, result, targets)
    local roll = rolls[roll_id];
    local message = "";

    if (targets ~= nil) then
        message = "[" .. #targets .. "] ";

        for key, name in ipairs(targets) do
            message = message .. chat.color1(({ 88, 105, 6, 89, 67 })[key], name);
            message = message .. (key < #targets and ", " or " ");
        end

        message = message .. string.char(0x81, 0xC3) .. " ";
    end

    local info = " " .. roll.Effect;

    info = ({
        [roll.Lucky]   = chat.success(" (Lucky!)" .. info),
        [roll.Unlucky] = chat.error(" (Unlucky!)" .. info),
        [11]           = chat.success(" (XI!)" .. info),
        [12]           = chat.critical(" (Bust!)" .. info),
    })[result] or chat.message(info);

    message = message .. roll.Name .. " [" .. roll.Lucky .. "/" .. roll.Unlucky .. "] " .. string.char(0x87, result - 1 + 64) .. info;
    print(chat.header(addon.name):append(message));
end

ashita.events.register("packet_in", "packet_in_cb", function (e)
    if (e.id == 0x0028) then
        local party = AshitaCore:GetMemoryManager():GetParty();
        local actor_id = ashita.bits.unpack_be(e.data_raw, 40, 32);

        if (actor_id ~= party:GetMemberServerId(0)) then
            return;
        end

        local action_category = ashita.bits.unpack_be(e.data_raw, 82, 4);

        if (action_category ~= 6) then
            return;
        end

        local ability_id = ashita.bits.unpack_be(e.data_raw, 86, 32);

        if (rolls[ability_id] == nil) then
            return;
        end

        local rolled_number = ashita.bits.unpack_be(e.data_raw, 213, 17);
        local target_count = ashita.bits.unpack_be(e.data_raw, 72, 6);

        if (not (target_count > 1)) then
            roll_print(ability_id, rolled_number);
            return;
        end

        local party_members = { };
        local offset = 273;

        for _ = 1, target_count do
            local target_id = ashita.bits.unpack_be(e.data_raw, offset, 32);
            offset = offset + 123;

            for party_index = 1, 5 do
                if (party:GetMemberServerId(party_index) == target_id) then
                    table.insert(party_members, party:GetMemberName(party_index));
                    break;
                end
            end
        end
        roll_print(ability_id, rolled_number, party_members);
        return;
    end
end);
