---@meta _

---@class gData
gData = { };

---@return string
function gData.GetCurrentCall() end

---@return alliance
function gData.GetAlliance() end

---@return action
function gData.GetAction() end

---@return entity
function gData.GetActionTarget() end

---@param matchBuff integer | string
---@return integer
function gData.GetBuffCount(matchBuff) end

---@param index integer
---@return entity
function gData.GetEntity(index) end

---@return environment
function gData.GetEnvironment() end

---@return equipment
function gData.GetEquipment() end

---@return equipscreen
function gData.GetEquipScreen() end

---@return pet?
function gData.GetPet() end

---@return player
function gData.GetPlayer() end

---@return party
function gData.GetParty() end

---@return entity?
function gData.GetTarget() end