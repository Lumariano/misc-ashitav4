addon.name = "nodaze";
addon.author = "Lumaro";
addon.version = "1.0";
addon.desc = "Prevents the Haste Daze vfx and sfx from playing.";
addon.link = "https://github.com/Lumariano/misc-ashitav4/tree/main/addons/nodaze";

ashita.events.register("packet_in", "packet_in_cb", function (e)
    if (e.id == 0x0028) then
        local cmd_no = ashita.bits.unpack_be(e.data_raw, 82, 4);

        if (cmd_no == 1 or cmd_no == 2) then
            local result_sum = ashita.bits.unpack_be(e.data_raw, 182, 4);
            local offset = 186

            for _ = 1, result_sum do
                offset = offset + 85;
                local has_proc = ashita.bits.unpack_be(e.data_raw, offset, 1) > 0;
                offset = offset + 1;

                if (has_proc) then
                    local proc_kind = ashita.bits.unpack_be(e.data_raw, offset, 6);

                    if (proc_kind == 23) then
                        ashita.bits.pack_be(e.data_modified_raw, 0, offset, 6);
                    end

                    offset = offset + 37;
                end

                local has_react = ashita.bits.unpack_be(e.data_raw, offset, 1) > 0;

                if (has_react) then
                    offset = offset + 35;
                end
            end
        end
    end
end);
