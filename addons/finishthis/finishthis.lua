addon.name    = "finishthis";
addon.author  = "Lumaro";
addon.version = "1.0";
addon.desc    = "Adds text to chat without sending it (needs thirdparty)";
addon.link    = "https://github.com/Lumariano/misc-ashitav4";

require("common");

local chat = AshitaCore:GetChatManager();

ashita.events.register("command", "command_cb", function (e)
    local args = e.command:args();

    if (#args ~= 2 or args[1] ~= "/finishthis") then
        return;
    end

    e.blocked = true;
        
    local input_status = chat:IsInputOpen();

    if (input_status == ChatInputOpenStatus.OpenedChat) then
        chat:SetInputText(args[2]);
    elseif (input_status == ChatInputOpenStatus.Closed) then
        if (not AshitaCore:GetPluginManager():IsLoaded("thirdparty")) then
            return;
        end

        chat:QueueCommand(CommandMode.AshitaParse, "/sendkey space down");
        coroutine.sleep(0.1);
        chat:QueueCommand(CommandMode.AshitaParse, "/sendkey space up");

        if (chat:IsInputOpen() == ChatInputOpenStatus.OpenedChat) then
            chat:SetInputText(args[2]);
        end
    end
end);
