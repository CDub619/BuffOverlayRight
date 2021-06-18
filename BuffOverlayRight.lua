--On Git HUB
local overlays = {}
local buffs = {}
local tblinsert = table.insert
local tremove = table.remove
local substring = string.sub
local prioritySpellList = { --The higher on the list, the higher priority the buff has.

--**Stealth Given**

198158, --Mass Invisibility
"Shroud of Concealment",

--**Class Stealth**--

"Stealth",
199483, --Camouflage
"Camouflage",
5215, --Prowl
110960, --Greater Invisibility
"Invisibility",


--**CC Help**--

213610, --Holy Ward
210256, --Blessing of Sanctuary
"Nimble Brew",
236321, --War Banner (Arms Only)

--**Secondary’s CD’s Given**--

53480,  --Roar of Sacrifice
212640, --Mending Bandage
223685, --Safeguard
213871, --Bodyguard
207810, --Nether Bond
291944, --Regeneration’
59543, --Gift of the Naaru
332505, --Soulsteel Clamps
332506, --Soulsteel Clamps
324867, --Fleshcraft (Necrolord)

--**DMG/Heal CDs Given**--
--**Threat MIsdirect Given**--

57934, --Tricks of the Trade
"Misdirection",
--10060, --Power Infusion

--** Secondary’ Class Ds**--

19236, --Desperate Prayer
277187, --Gladiator’s Emblem
"Gladiator's Emblem",
"Spirit Mend",

--**Class Perm Passive Buffs & DMG CDs**--

260402, -- Double Tap
288613, -- True Shot
212704, --The Beast within
193530, --Aspect of the Wild
19574, --Bestial Wraith
205691, --Dire Beast Basilisk

260881, --Spirit Wolf
204262, --Spectral Recovery
2645, --Ghost Wolf
335903, --Doomwinds (shadowlands legendary)
114050, --Ascendance
114051, --Ascendance
191634, --Stormkeeper
320137, --Stormkeeper
188616, --Shaman Earth Ele "Greater Earth Elemental", has sourceGUID [summonid]
118323, --Shaman Primal Earth Ele "Primal Earth Elemental", has sourceGUID [summonid]
188592, --Shaman Fire Ele "Fire Elemental", has sourceGUID [summonid]
118291, --Shaman Primal Fire Ele "Primal Fire Earth Elemental", has sourceGUID [summonid]
157299, --Storm Ele , has sourceGUID [summonid]

207289, --Unholy Assault
51271, --Pillars of Frost
288853, --Abomb

108293, --Heart of the Wild (Guardian)
--102558, --Incarnation: Guardian of Ursoc
5487, --Bear Form
783, --Travel Form
108291, --Heart of the Wild (Boomy)
108292, --Heart of the Wild (Feral)
108294, --Heart of the Wild (Resto)
197625, --Moonkin Form
102543, --Incarnation: King of the Jungle
106951, --Berserk
768, --Cat Form
102560, --Incarnation: Chosen of Elune
194223, --Celestial Alignment
117679, --Incarnation Tree of Life
248280, --Trees CLEU

190319, --Combustion
12042, --Arcane Power
12472, --Icy Veins
321686, --Mirror Image CLEU,
235313, --Blazing Barrier
11426, --Ice Barrier
235450, --Prismatic Barrier

310454, --Weapons of Order
152173, --Serenity
123904,--WW Xuen Pet Summmon "Xuen" same Id has sourceGUID
137639, --Storm, Earth, and Fire

231895, --Crusade
152262, --Seraphim

194249, --Voidform

121471, --Shadow Blades

113860, --Dark Soul: Instability
113860, --Dark Soul: Misery
111685, --Warlock Infernals,  has sourceGUID (spellId and Summons are different) [spellbookid]
205180, --Warlock Darkglare

107574, -- Avatar
197690, --Defensive Stance
199261, --Death Wish

162264, -- Metamorphosis (Havoc)

193065, --Masochism
123040, --Disc Pet Summmon Mindbender
34433, --Disc Pet Summmon Sfiend
201940, --Protector of the Pack **MAJOR DEFENSIVE**
204205, --Wild Protector
232698, --Shadowform
24858, --Moonkin Form
285933, --Demon Armor


}

local function CompactUnitFrame_UtilSetBuff(buffFrame, icon, duration, expirationTime, count)
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(buffFrame.cooldown);
	end
	buffFrame:Show();
end


for k, v in ipairs(prioritySpellList) do
	buffs[v] = k
end

local CLEUAura = {}


hooksecurefunc("CompactUnitFrame_UpdateAuras", function(self)
	if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
		return
	end

	local unit, index, buff = self.displayedUnit, index, buff
	local sourceGUID, realm = UnitName(unit)
	for i = 1, 32 do --BUFF_MAX_DISPLAY
		local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i,"HELPFUL")

		if spellId then
			if buffs[buffName] then
				buffs[spellId] = buffs[buffName]
			end

			if buffs[spellId] then
				if not buff or buffs[spellId] < buffs[buff] then
					buff = spellId
					index = i
				end
			end
		else
			break
		end
	end
	local sourceGUID = UnitGUID(unit)
	local overlay = overlays[self]
	if not overlay then
		if not index and not CLEUAura[sourceGUID] then
			return
		end
		overlay = CreateFrame("Button", "$parentBuffOverlayRight", self, "CompactAuraTemplate")
		overlay:ClearAllPoints()
		overlay:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -1.5)
		overlay:SetAlpha(1)
		overlay:SetFrameLevel(100)
		overlay:EnableMouse(false)
		overlay:RegisterForClicks()
		overlays[self] = overlay
	end

	local cleu = false

	if index or CLEUAura[sourceGUID] then
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura
			if CLEUAura[sourceGUID] then
					if (buffs[buff] == nil and CLEUAura[sourceGUID]) or (CLEUAura[sourceGUID] and buffs[buff] > buffs[CLEUAura[sourceGUID][1][4]]) then
						icon = CLEUAura[sourceGUID][1][1]
						duration = CLEUAura[sourceGUID][1][2]
						expirationTime = CLEUAura[sourceGUID][1][3]
						spellId = CLEUAura[sourceGUID][1][4]
						cleu = true
						if spellId == 321686 or 248280 then
							count = #CLEUAura[sourceGUID]
						else
							count = 0
						end
					else
					name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index)
				end
			else
				name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index)
			end
		overlay:SetSize(self.buffFrames[1]:GetSize())
		overlay:SetScale(1.15)
		CompactUnitFrame_UtilSetBuff(overlay, icon, duration, expirationTime, count)
	end

	if cleu then
		local durationTime = CLEUAura[sourceGUID][1][3] - GetTime();
		overlay:SetShown(true)
		if durationTime > 0 then
			C_Timer.After(durationTime, function()
				overlay:SetShown(false)
			end)
		end
	else
		overlay:SetShown(index and true or false)
	end
end)


local castedAuraIds = {
	[321686] = 40, --Mirror Image
	[248280] = 10, --Trees
	[188616] = 60, --Shaman Earth Ele "Greater Earth Elemental", has sourceGUID [summonid]
	[118323] = 60, --Shaman Primal Earth Ele "Primal Earth Elemental", has sourceGUID [summonid]
	[188592] = 60, --Shaman Fire Ele "Fire Elemental", has sourceGUID [summonid]
	[118291] = 60, --Shaman Primal Fire Ele "Primal Fire Earth Elemental", has sourceGUID [summonid]
	[157299] = 30, --Storm Ele , has sourceGUID [summonid]
	[288853] = 25, --Dk Raise Abomination "Abomination" same Id has sourceGUID
	[123904] = 24,--WW Xuen Pet Summmon "Xuen" same Id has sourceGUID
	[111685] = 30, --Warlock Infernals,  has sourceGUID (spellId and Summons are different) [spellbookid]
	[205180] = 20, --Warlock Darkglare
	[123040] = 12, --Mindbender
	[34433] = 15, --Disc Pet Summmon Sfiend "Shadowfiend" same Id has sourceGUID
	[205691] = 30, --Dire Beast Basilisk

}

local tip = CreateFrame('GameTooltip', 'GuardianOwnerTooltip', nil, 'GameTooltipTemplate')
local function GetGuardianOwner(guid)
  tip:SetOwner(WorldFrame, 'ANCHOR_NONE')
  tip:SetHyperlink('unit:' .. guid or '')
  local text = GuardianOwnerTooltipTextLeft2
	local text1 = GuardianOwnerTooltipTextLeft3
	if text1 and type(text1:GetText()) == "string" then
		if strmatch(text1:GetText(), "Corpse") then
			return "Corpse" --Only need for Earth Ele and Infernals
		else
			return strmatch(text and text:GetText() or '', "^([^%s-]+)")
		end
	else
		return strmatch(text and text:GetText() or '', "^([^%s-]+)")
	end
end

local BORCLEU = CreateFrame("Frame")
BORCLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BORCLEU:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		BORCLEU:CLEU()
	end
end)


function BORCLEU:CLEU()
		local _, event, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") then --Summoned CDs
			if castedAuraIds[spellId] then
				local duration = castedAuraIds[spellId]
				local namePrint, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + duration

				if spellId == 321686 then
					icon = 135994
				end

				if spellId == 157299 then
					icon = 2065626
				end

				print(sourceName.." Summoned "..namePrint.." "..substring(destGUID, -7).." for "..duration.." BOR")

				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert (CLEUAura[sourceGUID], {icon, duration, expirationTime, spellId, destGUID})
				C_Timer.After(duration, function()
					if CLEUAura[sourceGUID] then
						CLEUAura[sourceGUID] = nil
					end
				end)
				self.ticker = C_Timer.NewTicker(0.5, function()
					local name = GetSpellInfo(spellId)
					if CLEUAura[sourceGUID] then
						for k, v in pairs(CLEUAura[sourceGUID]) do
							if CLEUAura[sourceGUID][k] then
								if v[5] then
	                if substring(v[5], -5) == substring(destGUID, -5) then --string.sub is to help witj Mirror Images bug
	                  if strmatch(GetGuardianOwner(v[5]), 'Corpse') or strmatch(GetGuardianOwner(v[5]), 'Level') then
	                		CLEUAura[sourceGUID][k] = nil
											tremove(CLEUAura[sourceGUID], k)
	                    print(sourceName.." "..GetGuardianOwner(v[5]).." "..namePrint.." "..substring(v[5], -7).." left w/ "..string.format("%.2f", expirationTime-GetTime()).." BOR")
	                    self.ticker:Cancel()
											if #CLEUAura[sourceGUID] == 0 then
											CLEUAura[sourceGUID] = nil
											end
											break
	                  end
	                end
								end
							end
						end
					end
				end, duration * 2)
			end
		end
	end
