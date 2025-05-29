---@meta _

---@class gData
gData = { };

---@return string
function gData.GetCurrentCall() end

---@return Alliance
function gData.GetAlliance() end

---@return Action
function gData.GetAction() end

---@return Entity
function gData.GetActionTarget() end

---@param matchBuff integer | string
---@return integer
function gData.GetBuffCount(matchBuff) end

---@param index integer
---@return Entity?
function gData.GetEntity(index) end

---@return Environment
function gData.GetEnvironment() end

---@return Equipment
function gData.GetEquipment() end

---@return Equipscreen
function gData.GetEquipScreen() end

---@return Pet?
function gData.GetPet() end

---@return PetAction?
function gData.GetPetAction() end

---@return Player
function gData.GetPlayer() end

---@return Party
function gData.GetParty() end

---@return Entity?
function gData.GetTarget() end
