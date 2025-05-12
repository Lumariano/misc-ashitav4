---@meta _

---@class gFunc
gFunc = { };

---@param setName string
function gFunc.AddSet(setName) end

---@param baseTable string
function gFunc.ApplyBaseSets(baseTable) end

function gFunc.CancelAction() end

---@param id integer
function gFunc.ChangeActionId(id) end

---@param target integer
function gFunc.ChangeActionTarget(target) end

function gFunc.ClearEquipBuffer() end

---@param base table
---@param override table
---@return table
function gFunc.Combine(base, override) end

---@param item userdata
---@param itemEntry string
---@param container integer
---@return boolean
function gFunc.CompareItem(item, itemEntry, container) end

---@param slot string | integer
function gFunc.Disable(slot) end

---@param color integer
---@param text string
function gFunc.Echo(color, text) end

---@param slot string | integer
function gFunc.Enable(slot) end

---@param slot string | integer
---@param item string | table
function gFunc.Equip(slot, item) end

---@param set table | string
function gFunc.EquipSet(set) end

---@param text string
function gFunc.Error(text) end

---@param sets table
---@param level integer
function gFunc.EvaluateLevels(sets, level) end

---@param slot string | integer
---@param item string | table
function gFunc.ForceEquip(slot, item) end

---@param set table | string
function gFunc.ForceEquipSet(set) end

---@param slot string | integer
---@param item string | table
function gFunc.InterimEquip(slot, item) end

---@param set table | string
function gFunc.InterimEquipSet(set) end

---@param text string
function gFunc.Message(text) end

---@param path string
function gFunc.LoadFile(path) end

---@param set table | string
---@param seconds number
function gFunc.LockSet(set, seconds) end

---@param set table
function gFunc.LockStyle(set) end

---@param delay number
function gFunc.SetMidDelay(delay) end