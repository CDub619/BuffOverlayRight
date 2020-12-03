--On Git HUB
local overlays = {}
local buffs = {}

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

147833, --Intervene
53480,  --Roar of Sacrifice
212640, --Mending Bandage
223685, --Safeguard
213871, --Bodyguard
207810, --Nether Bond
291944, --Regeneration’
59543, --Gift of the Naaru

--**DMG/Heal CDs Given**--
--**Threat MIsdirect Given**--

57934, --Tricks of the Trade
"Misdirection",
--10060, --Power Infusion

--** Secondary’ Class Ds**--

19236, --Desperate Prayer
277187, --Gladiator’s Emblem
193065, --Masochism
"Spirit Mend",

--**Class Perm Passive Buffs & DMG CDs**--

2645, --Ghost Wolf
--190456, -- Ignore Pain
197690, --Defensive Stance
102558, --Incarnation: Guardian of Ursoc
5487, --Bear Form
201940, --Protector of the Pack **MAJOR DEFENSIVE**

51271, --Pillars of Frost

783, --Travel Form
197625, --Moonkin Form
102543, --Incarnation: King of the Jungle
106951, --Berserk
768, --Cat Form
102560, --Incarnation: Chosen of Elune
194223, --Celestial Alignment
117679, --Incarnation Tree of Life

190319, --Combustion
235313, --Blazing Barrier
11426, --Ice Barrier
235450, --Prismatic Barrier

194249, --Voidform

199261, --Death Wish

204205, --Wild Protector
232698, --Shadowform
24858, --Moonkin Form


}

for k, v in ipairs(prioritySpellList) do
	buffs[v] = k
end

hooksecurefunc("CompactUnitFrame_UpdateAuras", function(self)
	if self:IsForbidden() or not self:IsVisible() or not self.buffFrames then
		return
	end

	local unit, index, buff = self.displayedUnit, index, buff
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

	local overlay = overlays[self]
	if not overlay then
		if not index then
			return
		end
		overlay = CreateFrame("Button", "$parentBuffOverlayRight", self, "CompactAuraTemplate")
		overlay:ClearAllPoints()
		overlay:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, -1.5)
		overlay:SetAlpha(1)
		overlay:EnableMouse(false)
		overlay:RegisterForClicks()
		overlays[self] = overlay
	end

	if index then
		overlay:SetSize(self.buffFrames[1]:GetSize())
		overlay:SetScale(1.15)
		CompactUnitFrame_UtilSetBuff(overlay, index, UnitBuff(unit, index))
	end
	overlay:SetShown(index and true or false)
end)
