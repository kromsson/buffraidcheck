local BRCheck = LibStub("AceAddon-3.0"):NewAddon("BuffRaidCheck", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local BUFFS = {
    PALADIN_BLESSINGS = {
        ["Kings"] = {"Blessing of Kings", "Greater Blessing of Kings"},
        ["Might"] = {"Blessing of Might", "Greater Blessing of Might"},
        ["Wisdom"] = {"Blessing of Wisdom", "Greater Blessing of Wisdom"},
        ["Sanctuary"] = {"Blessing of Sanctuary", "Greater Blessing of Sanctuary"},
    },
    PALADIN_AURAS = {
        "Devotion Aura", "Retribution Aura", "Concentration Aura", 
        "Shadow Resistance Aura", "Frost Resistance Aura", "Fire Resistance Aura", "Crusader Aura"
    },
    DRUID = {"Mark of the Wild", "Gift of the Wild"},
    PRIEST = {"Power Word: Fortitude", "Prayer of Fortitude"},
    MAGE = {"Arcane Intellect", "Arcane Brilliance"}
}

local FLASKS = {
    "Flask of the Frost Wyrm", "Flask of Endless Rage", "Flask of Pure Mojo", "Flask of Stoneblood",
    "Flask of the North", "Distilled Wisdom", "Flask of Chromatic Wonder", "Flask of Blinding Light",
    "Flask of Mighty Restoration", "Flask of Pure Death", "Flask of Relentless Assault", "Flask of Fortification",
    "Flask of Titans", "Flask of Supreme Power", "Flask of Chromatic Resistance"
}

function BRCheck:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BuffRaidCheckDB", { profile = { minimized = false } }, true)
    self:RegisterChatCommand("brc", "ToggleScan")
    self:RegisterChatCommand("buffraidcheck", "ToggleScan")
end

local function HasBuff(unit, buffList)
    for i = 1, 40 do
        local name = UnitAura(unit, i, "HELPFUL")
        if not name then break end
        for _, buffName in ipairs(buffList) do
            if name == buffName then return true end
        end
    end
    return false
end

local function GetPaladinStatus(unit)
    local blessingsCount = 0
    local hasAura = false
    
    for i = 1, 40 do
        local name = UnitAura(unit, i, "HELPFUL")
        if not name then break end
        
        -- Check Blessings
        for typeName, variants in pairs(BUFFS.PALADIN_BLESSINGS) do
            for _, variant in ipairs(variants) do
                if name == variant then
                    blessingsCount = blessingsCount + 1
                    break
                end
            end
        end
        
        -- Check Auras
        for _, auraName in ipairs(BUFFS.PALADIN_AURAS) do
            if name == auraName then
                hasAura = true
                break
            end
        end
    end
    return blessingsCount, hasAura
end

function BRCheck:CreateUI(results)
    if self.frame then self.frame:Release() end
    
    local f = AceGUI:Create("Frame")
    f:SetTitle("BuffRaidCheck Results")
    f:SetStatusText("Scan complete")
    f:SetLayout("Fill")
    f:SetWidth(400)
    f:SetHeight(500)
    self.frame = f

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    f:AddChild(scroll)

    for _, res in ipairs(results) do
        local label = AceGUI:Create("Label")
        local color = #res.missing == 0 and "|cFF00FF00" or "|cFFFF0000"
        local missingText = #res.missing == 0 and "OK" or table.concat(res.missing, ", ")
        label:SetText(string.format("%s%s|r: %s", color, res.name, missingText))
        label:SetFullWidth(true)
        scroll:AddChild(label)
    end
end

function BRCheck:ToggleScan()
    local numPaladins, numDruids, numPriests, numMages = 0, 0, 0, 0
    local members = {}
    local numRaid = GetNumRaidMembers()
    local numParty = GetNumPartyMembers()
    
    if numRaid > 0 then
        for i = 1, numRaid do table.insert(members, "raid" .. i) end
    elseif numParty > 0 then
        for i = 1, numParty do table.insert(members, "party" .. i) end
        table.insert(members, "player")
    else
        table.insert(members, "player")
    end

    for _, unit in ipairs(members) do
        local _, class = UnitClass(unit)
        if class == "PALADIN" then numPaladins = numPaladins + 1 end
        if class == "DRUID" then numDruids = numDruids + 1 end
        if class == "PRIEST" then numPriests = numPriests + 1 end
        if class == "MAGE" then numMages = numMages + 1 end
    end

    local results = {}
    for _, unit in ipairs(members) do
        local name = UnitName(unit)
        if name then
            local missing = {}
            local bCount, hasAura = GetPaladinStatus(unit)
            
            if numPaladins > 0 then
                local req = math.min(numPaladins, 2)
                if bCount < req then table.insert(missing, "Blessing("..bCount.."/"..req..")") end
                if not hasAura then table.insert(missing, "No Aura") end
            end
            if numDruids > 0 and not HasBuff(unit, BUFFS.DRUID) then table.insert(missing, "MotW") end
            if numPriests > 0 and not HasBuff(unit, BUFFS.PRIEST) then table.insert(missing, "Fortitude") end
            if numMages > 0 and not HasBuff(unit, BUFFS.MAGE) then table.insert(missing, "Int") end
            if not HasBuff(unit, FLASKS) then table.insert(missing, "Flask") end
            if not HasBuff(unit, {"Well Fed"}) then table.insert(missing, "Food") end
            
            table.insert(results, {name = name, missing = missing})
        end
    end
    
    self:CreateUI(results)
end
