--[[
-- Event active, menu name and interface hidden checks from Thorny's tCrossbar addon.
-- Chat expanded check from onimitch's minimapcontrol addon.
--]]

addon.name = "autohide";
addon.author = "Lumaro";
addon.version = "1.0";
addon.desc = "Automatically hides all elements drawn by Ashita during certains states.";
addon.link = "";

local autohide = {
    visible = true,
    logged_in = false,
    event_system_p = 0,
    menu_p = 0,
    chat_p = 0,
    interface_p = 0,
};

local function get_event_active()
    local pointer = ashita.memory.read_uint32(autohide.event_system_p + 0x01);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer) == 1);
end

local function get_menu_name()
    local pointer = ashita.memory.read_uint32(autohide.menu_p);
    local value = ashita.memory.read_uint32(pointer);

    if (value == 0) then
        return "";
    end

    local menu_header = ashita.memory.read_uint32(value + 0x04);
    local menu_name = ashita.memory.read_string(menu_header + 0x46, 16);
    return string.gsub(menu_name, "\x00", "");
end

local function get_chat_expanded()
    local pointer = ashita.memory.read_uint32(autohide.chat_p);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer + 0xF1) ~= 0);
end

local function get_interface_hidden()
    local pointer = ashita.memory.read_uint32(autohide.interface_p + 0x0A);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer + 0xB4) == 1);
end

local function should_hide()
    if (autohide.logged_in == false) then
        return true;
    end

    if (get_event_active()) then
        return true;
    end

    if (string.match(get_menu_name(), "map")) then
        return true;
    end

    if (get_chat_expanded()) then
        return true;
    end

    if (get_interface_hidden()) then
        return true;
    end

    return false;
end

ashita.events.register("load", "load_cb", function ()
	autohide.logged_in = GetPlayerEntity() and true or false;

    local pointer = ashita.memory.find("FFXiMain.dll", 0, "A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3", 0, 0);
    assert(pointer ~= 0, "Failed to find event system pointer.");
    autohide.event_system_p = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "8B480C85C974??8B510885D274??3B05", 0x10, 0);
    assert(pointer ~= 0, "Failed to find menu pointer.");
    autohide.menu_p = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "83EC??B9????????E8????????0FBF4C24??84C0", 0x04, 0)
    assert(pointer ~= 0, "Failed to find chat pointer.");
    autohide.chat_p = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "8B4424046A016A0050B9????????E8????????F6D81BC040C3", 0, 0);
    assert(pointer ~= 0, "Failed to find interface pointer.");
    autohide.interface_p = pointer;
end);

ashita.events.register("unload", "unload_cb", function ()
    AshitaCore:GetFontManager():SetVisible(true);
    AshitaCore:GetPrimitiveManager():SetVisible(true);
    AshitaCore:GetGuiManager():SetVisible(true);
end);

ashita.events.register("packet_in", "packet_in_cb", function (e)
    if (e.id == 0x000A) then
        autohide.logged_in = true;
        return;
    end

    if (e.id == 0x000B) then
        autohide.logged_in = false;
        return;
    end
end);

ashita.events.register("d3d_present", "d3d_present_cb", function ()
    local visible = not should_hide()

    if (visible ~= autohide.visible) then
        AshitaCore:GetFontManager():SetVisible(visible);
        AshitaCore:GetPrimitiveManager():SetVisible(visible);
        AshitaCore:GetGuiManager():SetVisible(visible);
        autohide.visible = visible;
    end
end);
