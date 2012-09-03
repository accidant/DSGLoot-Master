-- English localization (Default)
DSG_LOOT = "DSG Loot"
RAIDLOOT_ROLL_PATTERN = "(.+) rolls (%d+) %((%d+)%-(%d+)%)"


-- German localization
if GetLocale() == "deDE" then
	RAIDLOOT_ROLL_PATTERN = "(.+) w\195\188rfelt. Ergebnis: (%d+) %((%d+)%-(%d+)%)"
-- French localization
elseif GetLocale() == "frFR" then
	RAIDLOOT_ROLL_PATTERN = "(%S+) obtient un (%d+) %((%d+)%-(%d+)%)"
-- Spanish localization
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
	RAIDLOOT_ROLL_PATTERN = "(%S+) tira los dados y obtiene (%d+) %((%d+)%-(%d+)%)"
end