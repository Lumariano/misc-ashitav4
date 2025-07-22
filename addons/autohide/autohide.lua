--[[
-- Event active, menu name and interface hidden checks from Thorny's tCrossbar addon.
-- Chat expanded check from onimitch's minimapcontrol addon.
--]]

addon.name = "autohide";
addon.author = "Lumaro";
addon.version = "1.1";
addon.desc = "Hides elements drawn by Ashita during certain client states.";
addon.link = "https://github.com/Lumariano/misc-ashitav4/tree/main/addons/autohide";

require("common");
local chat = require("chat");
local imgui = require("imgui");
local settings = require("settings");

local default_settings = T{
    chat = {
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
    event = {
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
    interface = {
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
    zoning = {
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
};

local default_menus = T{
    {
        name = "menu    map",
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
    {
        name = "menu    cnqframe",
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
    {
        name = "menu    scanlist",
        hide_font = { true },
        hide_gui = { true },
        hide_prim = { true },
    },
};

local autohide = {
    hidden_flags = 0,
    logged_in = false,
    pointers = {
        chat = 0,
        event = 0,
        interface = 0,
        menu = 0,
    },
    gui = {
        visible = { false },
        selected_menu = { -1 },
        new_menu = { "" },
    },
    settings = settings.load(default_settings);
};

local function get_chat_expanded()
    local pointer = ashita.memory.read_uint32(autohide.pointers.chat);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer + 0xF1) ~= 0);
end

local function get_event_active()
    local pointer = ashita.memory.read_uint32(autohide.pointers.event + 0x01);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer) == 1);
end

local function get_interface_hidden()
    local pointer = ashita.memory.read_uint32(autohide.pointers.interface + 0x0A);

    if (pointer == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(pointer + 0xB4) == 1);
end

local function get_menu_name()
    local pointer = ashita.memory.read_uint32(autohide.pointers.menu);
    local value = ashita.memory.read_uint32(pointer);

    if (value == 0) then
        return "";
    end

    local menu_header = ashita.memory.read_uint32(value + 0x04);
    local menu_name = ashita.memory.read_string(menu_header + 0x46, 16);
    return string.gsub(menu_name, "\x00", "");
end

local function get_visibility()
    if (not autohide.logged_in) then
        return autohide.settings.zoning;
    end

    if (get_event_active()) then
        return autohide.settings.event;
    end

    local menu_name = get_menu_name();

    for _, v in ipairs(autohide.settings.menus) do
        if (string.find(menu_name, v.name, 1, true)) then
            return v;
        end
    end

    if (get_chat_expanded()) then
        return autohide.settings.chat;
    end

    if (get_interface_hidden()) then
        return autohide.settings.interface;
    end

    return nil;
end

local function draw_manager_checkboxes(settings_table, stack_id)
    imgui.PushID(stack_id);

    if (imgui.Checkbox("Hide font objects", settings_table.hide_font)) then
        settings.save();
    end

    if (imgui.Checkbox("Hide ImGui", settings_table.hide_gui)) then
        settings.save();
    end

    if (imgui.Checkbox("Hide primitive objects", settings_table.hide_prim)) then
        settings.save();
    end

    imgui.PopID(stack_id);
end

settings.register("settings", "settings_update", function (s)
    if (s) then
        autohide.settings = s;
    end

    settings.save();
end);

ashita.events.register("load", "load_cb", function ()
    if (not autohide.settings.menus) then
        autohide.settings.menus = default_menus:copy();
        settings.save();
    end

    autohide.logged_in = GetPlayerEntity() and true or false;

    local pointer = ashita.memory.find("FFXiMain.dll", 0, "83EC??B9????????E8????????0FBF4C24??84C0", 0x04, 0)
    assert(pointer ~= 0, "Failed to find chat pointer.");
    autohide.pointers.chat = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3", 0, 0);
    assert(pointer ~= 0, "Failed to find event system pointer.");
    autohide.pointers.event = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "8B4424046A016A0050B9????????E8????????F6D81BC040C3", 0, 0);
    assert(pointer ~= 0, "Failed to find interface pointer.");
    autohide.pointers.interface = pointer;

    pointer = ashita.memory.find("FFXiMain.dll", 0, "8B480C85C974??8B510885D274??3B05", 0x10, 0);
    assert(pointer ~= 0, "Failed to find menu pointer.");
    autohide.pointers.menu = pointer;
end);

ashita.events.register("unload", "unload_cb", function ()
    AshitaCore:GetFontManager():SetVisible(true);
    AshitaCore:GetGuiManager():SetVisible(true);
    AshitaCore:GetPrimitiveManager():SetVisible(true);
    settings.save();
end);

ashita.events.register("command", "command_cb", function (e)
    local args = e.command:args();

    if (#args == 0 or args[1] ~= "/autohide") then
        return;
    end

    e.blocked = true;

    if (#args == 2 and args[2] == "config") then
        autohide.gui.visible[1] = not autohide.gui.visible[1];
        return;
    end

    if (#args == 2 and args[2] == "getmenu") then
        coroutine.sleep(0.1);
        print(chat.header(addon.name):append(chat.message("Currently active menu name is \"%s\"."):fmt(get_menu_name())));
        return;
    end
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

ashita.events.register("d3d_beginscene", "d3d_beginscene_cb", function ()
    local visibility = get_visibility();

    if (visibility) then
        local flags = bit.bor(
            bit.lshift(visibility.hide_font[1] and 1 or 0, 0),
            bit.lshift(visibility.hide_gui[1] and not autohide.gui.visible[1] and 1 or 0, 1),
            bit.lshift(visibility.hide_prim[1] and 1 or 0, 2)
        );

        if (flags ~= autohide.hidden_flags) then
            AshitaCore:GetFontManager():SetVisible(not visibility.hide_font[1]);

            if (autohide.gui.visible[1]) then
                AshitaCore:GetGuiManager():SetVisible(true);
            else
                AshitaCore:GetGuiManager():SetVisible(not visibility.hide_gui[1]);
            end

            AshitaCore:GetPrimitiveManager():SetVisible(not visibility.hide_prim[1]);
            autohide.hidden_flags = flags;
        end
    elseif (autohide.hidden_flags ~= 0) then
        AshitaCore:GetFontManager():SetVisible(true);
        AshitaCore:GetGuiManager():SetVisible(true);
        AshitaCore:GetPrimitiveManager():SetVisible(true);
        autohide.hidden_flags = 0;
    end
end);

ashita.events.register("d3d_present", "d3d_present_cb", function ()
    if (not autohide.gui.visible[1]) then
        return;
    end

    if (imgui.Begin(addon.name, autohide.gui.visible, ImGuiWindowFlags_AlwaysAutoResize)) then
        if (imgui.BeginTabBar("tabs")) then
            if (imgui.BeginTabItem("Base Config")) then
                imgui.TextColored({ 1.0, 0.65, 0.25, 1.0 }, "While the chat is expanded:");
                draw_manager_checkboxes(autohide.settings.chat, "chat");
                imgui.TextColored({ 1.0, 0.65, 0.25, 1.0 }, "While an event is active:");
                imgui.ShowHelp("E.g. a cutscene or NPC interaction.");
                draw_manager_checkboxes(autohide.settings.event, "event");
                imgui.TextColored({ 1.0, 0.65, 0.25, 1.0 }, "While the interface is hidden:");
                imgui.ShowHelp("I.e. hidden by yourself using the \"Hide Menus\" bind on controllers for example.");
                draw_manager_checkboxes(autohide.settings.interface, "interface");
                imgui.TextColored({ 1.0, 0.65, 0.25, 1.0 }, "While zoning:");
                draw_manager_checkboxes(autohide.settings.zoning, "zoning");
                imgui.EndTabItem();
            end

            if (imgui.BeginTabItem("Menus")) then
                imgui.Text("autohide will activate on any menu, whose internal name matches an entry in this list.");
                imgui.ShowHelp("Case-sensitive. Partial or full matches.")
                imgui.Text("Use \"/autohide getmenu\" to determine the name of the currently active menu.");
                imgui.Separator();

                if (imgui.InputText("New menu", autohide.gui.new_menu, 256, ImGuiInputTextFlags_EnterReturnsTrue)) then
                    table.insert(autohide.settings.menus, {
                        name = autohide.gui.new_menu[1],
                        hide_font = { true },
                        hide_gui = { true },
                        hide_prim = { true },
                    });

                    autohide.gui.new_menu[1] = "";
                    settings.save();
                end

                imgui.BeginGroup();

                if (imgui.BeginChild("menu_list", { imgui.GetWindowWidth() / 2, 200 }, true, ImGuiWindowFlags_HorizontalScrollbar)) then
                    for k, v in ipairs(autohide.settings.menus) do
                        imgui.PushID(k);

                        if (imgui.Selectable("\"" .. v.name .. "\"", autohide.gui.selected_menu[1] == k)) then
                            autohide.gui.selected_menu[1] = k;
                        end

                        imgui.PopID(k);
                    end

                    imgui.EndChild();
                end

                imgui.EndGroup();

                if (autohide.gui.selected_menu[1] > 0) then
                    imgui.SameLine();
                    imgui.BeginGroup();
                    local menu = autohide.settings.menus[autohide.gui.selected_menu[1]];
                    imgui.TextColored({ 1.0, 0.65, 0.25, 1.0 }, "While menu \"" .. menu.name .. "\" is active:");
                    draw_manager_checkboxes(menu, "menu");

                    if (imgui.Button("Remove selected")) then
                        table.remove(autohide.settings.menus, autohide.gui.selected_menu[1]);
                        autohide.gui.selected_menu[1] = -1;
                        settings.save();
                    end

                    imgui.EndGroup();
                end

                imgui.EndTabItem();
            end

            imgui.EndTabBar();
        end

        imgui.End();
    end
end);
