local shared = { };

local elementalWeaknesses = {
    ["Fire"] = "Water",
    ["Ice"] = "Fire",
    ["Wind"] = "Ice",
    ["Earth"] = "Wind",
    ["Thunder"] = "Earth",
    ["Water"] = "Thunder",

    ["Light"] = "Dark",
    ["Dark"] = "Light",
};

---Returns the MAB bonus for `element` as if Hachirin-no-Obi were equipped.
---@param element string
---@return number
shared.GetObiBonus = function (element)
    local environment = gData.GetEnvironment();
    local weakness = elementalWeaknesses[element];

    local dayBonus = ({
        [element] = 0.1,
        [weakness] = -0.1,
    })[environment.DayElement] or 0.0;

    local weatherBonus = ({
        [element] = 0.1,
        [weakness] = -0.1,
        [element .. " x2"] = 0.25,
        [weakness .. " x2"] = -0.25,
    })[environment.Weather] or 0.0;

    return dayBonus + weatherBonus;
end

return shared;
