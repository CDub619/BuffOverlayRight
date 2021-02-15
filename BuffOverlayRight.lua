--On Git HUB
local overlays = {}
local buffs = {}
local tblinsert = table.insert

local prioritySpellList = { --The higher on the list, the higher priority the buff has.

--**Stealth Given**

198158, --Mass Invisibility
"Shroud of Concealment",

--**Class Stealth**--

"Stealth",
199483, --Camouflage
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

260881, --Spirit Wolf
204262, --Spectral Recovery
2645, --Ghost Wolf
335903, --Doomwinds (shadowlands legendary)
114050, --Ascendance
114051, --Ascendance
191634, --Stormkeeper
320137, --Stormkeeper
--188616, --Shaman Earth Ele CLEU,
--118323, --Shaman Primal Earth Ele CLEU,

51271, --Pillars of Frost

108293, --Heart of the Wild (Guardian)
102558, --Incarnation: Guardian of Ursoc
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
--248280, --Trees CLEU

190319, --Combustion
12042, --Arcane Power
12472, --Icy Veins
321686, --Mirror Image CLEU,
235313, --Blazing Barrier
11426, --Ice Barrier
235450, --Prismatic Barrier

152173, --Serenity
137639, --Storm, Earth, and Fire

231895, --Crusade
152262, --Seraphim

194249, --Voidform

121471, --Shadow Blades

113860, --Dark Soul: Instability
113860, --Dark Soul: Misery

107574, -- Avatar
197690, --Defensive Stance
199261, --Death Wish

162264, -- Metamorphosis (Havoc)

193065, --Masochism
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

	if index or CLEUAura[sourceGUID] then
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura
		if (buffs[buff] == nil and CLEUAura[sourceGUID]) or (CLEUAura[sourceGUID] and buffs[buff] > buffs[CLEUAura[sourceGUID][1][5]]) then
			icon = CLEUAura[sourceGUID][1][1]
			duration = CLEUAura[sourceGUID][1][2]
			expirationTime = CLEUAura[sourceGUID][1][3]
			count = CLEUAura[sourceGUID][1][4]
		else
			name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index)
		end
		overlay:SetSize(self.buffFrames[1]:GetSize())
		overlay:SetScale(1.15)
		CompactUnitFrame_UtilSetBuff(overlay, icon, duration, expirationTime, count)
	end
	if (buffs[buff] == nil and CLEUAura[sourceGUID]) or (CLEUAura[sourceGUID] and buffs[buff] > buffs[CLEUAura[sourceGUID][1][5]]) then
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
	--[248280] = 10, --Trees
	--[188616] = 60, --Shaman Earth Ele
	--[118323] = 60, --Shaman Primal Earth Ele

}

local BORCLEU = CreateFrame("Frame")
BORCLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BORCLEU:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		BORCLEU:CLEU()
	end
end)


function BORCLEU:CLEU()
		local _, event, _, sourceGUID, _, sourceFlags, _, destGUID, destName, destFlags, _, spellId, _, _, _, _, spellSchool = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_SUMMON") or (event == "SPELL_CREATE") then --Summoned CDs
			if castedAuraIds[spellId] then
				local duration = castedAuraIds[spellId]
				local _, _, icon = GetSpellInfo(spellId)
				local expirationTime = GetTime() + duration
				local count = 0
				if spellId == 321686 then
					icon = 135994
				end
				if not CLEUAura[sourceGUID] then
					CLEUAura[sourceGUID] = {}
				end
				tblinsert (CLEUAura[sourceGUID], 1, {icon, duration, expirationTime, count, spellId})
				C_Timer.After(duration, function()
					if CLEUAura[sourceGUID] then
						CLEUAura[sourceGUID] = nil
					end
				end)
			end
		end
	end
