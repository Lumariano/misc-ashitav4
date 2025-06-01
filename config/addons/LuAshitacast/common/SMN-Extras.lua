local extras = {
    IsWeatherSpirit = false,

    AtkBPs = T{
        "Poison Nails",
        "Moonlit Charge", "Crescent Fang", "Eclipse Bite",
        "Punch", "Double Punch",
        "Rock Throw", "Rock Buster", "Megalith Throw", "Mountain Buster", "Crag Throw",
        "Barracuda Dive", "Tail Whip", "Spinning Dive",
        "Claw", "Predator Claws",
        "Axe Kick", "Double Slap", "Rush",
        "Shock Strike", "Chaotic Strike", "Volt Strike",
        "Camisado", "Blindside",
        "Regal Scratch", "Regal Gash",
        "Welt", "Roundhouse", "Hysteric Assault",
    },
    MABBPs = T{
        "Searing Light", "Meteorite", "Holy Mist",
        "Howling Moon", "Lunar Bay", "Impact",
        "Inferno", "Fire II", "Fire IV", "Meteor Strike", "Conflag Strike",
        "Earthen Fury", "Stone II", "Stone IV", "Geocrush",
        "Tidal Wave", "Water II", "Water IV", "Grand Fall",
        "Aerial Blast", "Aero II", "Whispering Wind", "Aero IV", "Wind Blade",
        "Diamond Dust", "Blizzard II", "Blizzard IV", "Heavenly Strike",
        "Judgement Bolt", "Thunder II", "Thunderspark", "Thunder IV", "Thunderstorm",
        "Ruinous Omen", "Nether Blast", "Night Terror",
        "Level ? Holy",
        "Clarsach Call", "Tornado II",
    },
    MAccBPs = T{
        "Lunar Cry", "Lunar Roar",
        "Slowga", "Tidal Roar",
        "Sleepga", "Diamond Storm",
        "Shock Squall",
        "Somnolence", "Nightmare", "Ultimate Terror", "Pavor Nocturnus",
        "Eerie Eye", "Mewing Lullaby",
        "Sonic Buffet", "Bitter Elegy",
    },
    HybridBPs = T{ "Burning Strike", "Flaming Crush", },
    SkillBPs = T{
        "Shining Ruby", "Glittering Ruby",
        "Ecliptic Growl", "Ecliptic Howl",
        "Crimson Howl", "Inferno Howl",
        "Earthen Armor",
        "Soothing Current",
        "Hastega", "Fleet Wind", "Hastega II",
        "Frost Armor", "Crystal Blessing",
        "Rolling Thunder", "Lightning Armor",
        "Noctoshield", "Dream Shroud",
        "Katabatic Blades",
    },
};

extras.SummonSiphonSpirit = function ()
    local environment = gData.GetEnvironment();
    local element = "";

    if (not environment.WeatherElement:any("None", "Unknown")) then
        element = environment.WeatherElement;
        extras.IsWeatherSpirit = true;
    else
        element = environment.DayElement;
        extras.IsWeatherSpirit = false;
    end

    element = element == "Wind" and "Air" or element;
    AshitaCore:GetChatManager():QueueCommand(CommandMode.AshitaParse, ("/ma \"%s Spirit\" <me>"):fmt(element));
end

return extras;
