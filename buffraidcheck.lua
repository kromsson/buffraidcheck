local BRCheck = LibStub("AceAddon-3.0"):NewAddon("BuffRaidCheck", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local BUFF_DEFINITIONS = {
    PALADIN = {
        Kings = {"Blessing of Kings", "Greater Blessing of Kings"},
        Might = {"Blessing of Might", "Greater Blessing of Might"},
        Wisdom = {"Blessing of Wisdom", "Greater Blessing of Wisdom"},
        Sanctuary = {"Blessing of Sanctuary", "Greater Blessing of Sanctuary"},
        Aura = {
            "Devotion Aura", "Retribution Aura", "Concentration Aura", 
            "Shadow Resistance Aura", "Frost Resistance Aura", "Fire Resistance Aura", "Crusader Aura"
        }
    },
    PRIEST = {
        Fortitude = {"Power Word: Fortitude", "Prayer of Fortitude"},
        Spirit = {"Divine Spirit", "Prayer of Spirit"},
        Shadow = {"Shadow Protection", "Prayer of Shadow Protection"}
    },
    DRUID = {
        MotW = {"Mark of the Wild", "Gift of the Wild"}
    },
    MAGE = {
        Intellect = {"Arcane Intellect", "Arcane Brilliance"}
    },
    WARRIOR = {
        BattleShout = {"Battle Shout"},
        CommandingShout = {"Commanding Shout"}
    },
    WARLOCK = {
        FelInt = {"Fel Intelligence"}
    }
}

local CONSUMABLES = {
    Flasks = {
        "Flask of the Frost Wyrm", "Flask of Endless Rage", "Flask of Pure Mojo", "Flask of Stoneblood",
        "Flask of the North", "Distilled Wisdom", "Flask of Chromatic Wonder", "Flask of Blinding Light",
        "Flask of Mighty Restoration", "Flask of Pure Death", "Flask of Relentless Assault", "Flask of Fortification",
        "Flask of Titans", "Flask of Supreme Power", "Flask of Chromatic Resistance"
    },
    Food = {"Well Fed"}
}

local function HasBuff(unit, buffList)
    if not buffList then return false end
    for i = 1, 40 do
        local name = UnitAura(unit, i, "HELPFUL")
        if not name then break end
        for _, buffName in ipairs(buffList) do
            if name == buffName then return true end
        end
    end
    return false
end

local function GetGroupMembers()
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
    return members
end

local resultsTable = {}

local options = {
    name = "BuffRaidCheck",
    handler = BRCheck,
    type = 'group',
    args = {
        scan = {
            type = 'group',
            name = "Raid Scan",
            order = 1,
            args = {
                refresh = {
                    type = 'execute',
                    name = "Refresh Scan",
                    func = function() BRCheck:UpdateResults() end,
                    order = 1,
                },
                results = {
                    type = 'group',
                    name = "Results",
                    inline = true,
                    order = 2,
                    args = resultsTable
                }
            }
        },
        settings = {
            type = 'group',
            name = "General Settings",
            order = 2,
            args = {
                whisperMessage = {
                    type = 'input',
                    name = "Whisper Missing Prefix",
                    desc = "Sent to player missing a buff.",
                    set = function(info, val) BRCheck.db.profile.whisperPrefix = val end,
                    get = function(info) return BRCheck.db.profile.whisperPrefix end,
                    order = 1,
                    width = "full",
                },
                whisperProviderPrefix = {
                    type = 'input',
                    name = "Whisper Provider Prefix",
                    desc = "Sent to class members who should buff.",
                    set = function(info, val) BRCheck.db.profile.whisperProviderPrefix = val end,
                    get = function(info) return BRCheck.db.profile.whisperProviderPrefix end,
                    order = 2,
                    width = "full",
                },
            }
        },
        buffs = {
            type = 'group',
            name = "Buff Selection",
            order = 3,
            args = {
                paladin = {
                    type = 'group', name = "Paladin", inline = true, args = {
                        checkKings = { type = 'toggle', name = "Kings", get = function() return BRCheck.db.profile.checkKings end, set = function(_,v) BRCheck.db.profile.checkKings = v end },
                        checkMight = { type = 'toggle', name = "Might", get = function() return BRCheck.db.profile.checkMight end, set = function(_,v) BRCheck.db.profile.checkMight = v end },
                        checkWisdom = { type = 'toggle', name = "Wisdom", get = function() return BRCheck.db.profile.checkWisdom end, set = function(_,v) BRCheck.db.profile.checkWisdom = v end },
                        checkSanctuary = { type = 'toggle', name = "Sanctuary", get = function() return BRCheck.db.profile.checkSanctuary end, set = function(_,v) BRCheck.db.profile.checkSanctuary = v end },
                        checkAura = { type = 'toggle', name = "Aura", get = function() return BRCheck.db.profile.checkAura end, set = function(_,v) BRCheck.db.profile.checkAura = v end },
                    }
                },
                priest = {
                    type = 'group', name = "Priest", inline = true, args = {
                        checkFort = { type = 'toggle', name = "Fortitude", get = function() return BRCheck.db.profile.checkFort end, set = function(_,v) BRCheck.db.profile.checkFort = v end },
                        checkSpirit = { type = 'toggle', name = "Spirit", get = function() return BRCheck.db.profile.checkSpirit end, set = function(_,v) BRCheck.db.profile.checkSpirit = v end },
                        checkShadow = { type = 'toggle', name = "Shadow Protection", get = function() return BRCheck.db.profile.checkShadow end, set = function(_,v) BRCheck.db.profile.checkShadow = v end },
                    }
                },
                druid = {
                    type = 'group', name = "Druid", inline = true, args = {
                        checkMotW = { type = 'toggle', name = "MotW", get = function() return BRCheck.db.profile.checkMotW end, set = function(_,v) BRCheck.db.profile.checkMotW = v end },
                    }
                },
                mage = {
                    type = 'group', name = "Mage", inline = true, args = {
                        checkInt = { type = 'toggle', name = "Intellect", get = function() return BRCheck.db.profile.checkInt end, set = function(_,v) BRCheck.db.profile.checkInt = v end },
                    }
                },
                warrior = {
                    type = 'group', name = "Warrior", inline = true, args = {
                        checkBattle = { type = 'toggle', name = "Battle Shout", get = function() return BRCheck.db.profile.checkBattle end, set = function(_,v) BRCheck.db.profile.checkBattle = v end },
                        checkComm = { type = 'toggle', name = "Commanding Shout", get = function() return BRCheck.db.profile.checkComm end, set = function(_,v) BRCheck.db.profile.checkComm = v end },
                    }
                },
                consumables = {
                    type = 'group', name = "Consumables", inline = true, args = {
                        checkFlask = { type = 'toggle', name = "Flask", get = function() return BRCheck.db.profile.checkFlask end, set = function(_,v) BRCheck.db.profile.checkFlask = v end },
                        checkFood = { type = 'toggle', name = "Food", get = function() return BRCheck.db.profile.checkFood end, set = function(_,v) BRCheck.db.profile.checkFood = v end },
                    }
                }
            }
        }
    }
}

function BRCheck:UpdateResults()
    for k in pairs(resultsTable) do resultsTable[k] = nil end
    local members = GetGroupMembers()
    
    local providers = { PALADIN = {}, PRIEST = {}, DRUID = {}, MAGE = {}, WARRIOR = {}, WARLOCK = {} }
    for _, unit in ipairs(members) do
        local _, class = UnitClass(unit)
        if class and providers[class] then
            table.insert(providers[class], (UnitName(unit)))
        end
    end

    for i, unit in ipairs(members) do
        local name = UnitName(unit)
        if name then
            local missing = {}
            local p = self.db.profile
            
            if #providers.PALADIN > 0 then
                if p.checkKings and not HasBuff(unit, BUFF_DEFINITIONS.PALADIN.Kings) then table.insert(missing, "Kings") end
                if p.checkMight and not HasBuff(unit, BUFF_DEFINITIONS.PALADIN.Might) then table.insert(missing, "Might") end
                if p.checkWisdom and not HasBuff(unit, BUFF_DEFINITIONS.PALADIN.Wisdom) then table.insert(missing, "Wisdom") end
                if p.checkSanctuary and not HasBuff(unit, BUFF_DEFINITIONS.PALADIN.Sanctuary) then table.insert(missing, "Sanctuary") end
                if p.checkAura and not HasBuff(unit, BUFF_DEFINITIONS.PALADIN.Aura) then table.insert(missing, "Aura") end
            end
            if #providers.PRIEST > 0 then
                if p.checkFort and not HasBuff(unit, BUFF_DEFINITIONS.PRIEST.Fortitude) then table.insert(missing, "Fort") end
                if p.checkSpirit and not HasBuff(unit, BUFF_DEFINITIONS.PRIEST.Spirit) then table.insert(missing, "Spirit") end
                if p.checkShadow and not HasBuff(unit, BUFF_DEFINITIONS.PRIEST.Shadow) then table.insert(missing, "Shadow") end
            end
            if #providers.DRUID > 0 and p.checkMotW and not HasBuff(unit, BUFF_DEFINITIONS.DRUID.MotW) then table.insert(missing, "MotW") end
            if #providers.MAGE > 0 and p.checkInt and not HasBuff(unit, BUFF_DEFINITIONS.MAGE.Intellect) then table.insert(missing, "Int") end
            if #providers.WARRIOR > 0 then
                if p.checkBattle and p.checkComm then
                    if not HasBuff(unit, BUFF_DEFINITIONS.WARRIOR.BattleShout) and not HasBuff(unit, BUFF_DEFINITIONS.WARRIOR.CommandingShout) then
                        table.insert(missing, "Shout")
                    end
                elseif p.checkBattle and not HasBuff(unit, BUFF_DEFINITIONS.WARRIOR.BattleShout) then table.insert(missing, "Battle")
                elseif p.checkComm and not HasBuff(unit, BUFF_DEFINITIONS.WARRIOR.CommandingShout) then table.insert(missing, "Comm") end
            end
            if p.checkFlask and not HasBuff(unit, CONSUMABLES.Flasks) then table.insert(missing, "Flask") end
            if p.checkFood and not HasBuff(unit, CONSUMABLES.Food) then table.insert(missing, "Food") end

            local color = #missing == 0 and "|cFF00FF00" or "|cFFFF0000"
            resultsTable["res"..i] = {
                type = 'description',
                name = string.format("%s%s|r: %s", color, name, #missing == 0 and "OK" or table.concat(missing, ", ")),
                order = i * 3,
                width = "double",
            }
            
            if #missing > 0 then
                resultsTable["w"..i] = {
                    type = 'execute', name = "W", desc = "Whisper player",
                    func = function() SendChatMessage(self.db.profile.whisperPrefix .. table.concat(missing, ", "), "WHISPER", nil, name) end,
                    order = i * 3 + 1, width = "half",
                }
                resultsTable["p"..i] = {
                    type = 'execute', name = "P", desc = "Whisper providers",
                    func = function()
                        local msgPrefix = self.db.profile.whisperProviderPrefix
                        local msg = string.format("%s %s needs: %s", msgPrefix, name, table.concat(missing, ", "))
                        for _, m in ipairs(missing) do
                            local providerClass = ""
                            if m == "Kings" or m == "Might" or m == "Wisdom" or m == "Sanctuary" or m == "Aura" then providerClass = "PALADIN"
                            elseif m == "Fort" or m == "Spirit" or m == "Shadow" then providerClass = "PRIEST"
                            elseif m == "MotW" then providerClass = "DRUID"
                            elseif m == "Int" then providerClass = "MAGE"
                            elseif m == "Battle" or m == "Comm" or m == "Shout" then providerClass = "WARRIOR" end
                            
                            if providerClass ~= "" and providers[providerClass] and #providers[providerClass] > 0 then
                                for _, pName in ipairs(providers[providerClass]) do
                                    SendChatMessage(msg, "WHISPER", nil, pName)
                                end
                            end
                        end
                    end,
                    order = i * 3 + 2, width = "half",
                }
            end
        end
    end
    AceConfigRegistry:NotifyChange("BuffRaidCheck")
end

function BRCheck:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BuffRaidCheckDB", { 
        profile = { 
            whisperPrefix = "You are missing: ",
            whisperProviderPrefix = "[BuffRaidCheck] ",
            checkKings = true, checkMight = false, checkWisdom = false, checkSanctuary = false, checkAura = true,
            checkFort = true, checkSpirit = true, checkShadow = false,
            checkMotW = true,
            checkInt = true,
            checkBattle = true, checkComm = true,
            checkFlask = true, checkFood = true,
        } 
    }, true)
    AceConfig:RegisterOptionsTable("BuffRaidCheck", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("BuffRaidCheck", "BuffRaidCheck")
    self:RegisterChatCommand("brc", "OpenResults")
    self:RegisterChatCommand("buffraidcheck", "OpenResults")
    self:UpdateResults()
end

function BRCheck:OpenResults()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    self:UpdateResults()
end
