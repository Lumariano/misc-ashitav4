addon.name    = "finishthis";
addon.author  = "Lumaro";
addon.version = "1.0";
addon.desc = "Adds text to the chat input without sending it.";
addon.link = "https://github.com/Lumariano/misc-ashitav4/tree/main/addons/finishthis";

require("common");

ashita.events.register("command", "command_cb", function (e)
    local args = e.command:args();

    if (#args ~= 2 or args[1] ~= "/finishthis") then
        return;
    end

    e.blocked = true;

    local chat = AshitaCore:GetChatManager();
    local input_status = chat:IsInputOpen();

    if (input_status == ChatInputOpenStatus.OpenedChat) then
        chat:SetInputText(args[2]);
    elseif (input_status == ChatInputOpenStatus.Closed and AshitaCore:GetPluginManager():IsLoaded("thirdparty")) then
        chat:QueueCommand(CommandMode.AshitaParse, "/sendkey space down");
        chat:QueueCommand(CommandMode.AshitaParse, "/sendkey space up");
        coroutine.sleep(0.1);

        if (chat:IsInputOpen() == ChatInputOpenStatus.OpenedChat) then
            chat:SetInputText(args[2]);
        end
    end
end);
