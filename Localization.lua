-- English localization (Default)
DSGLOOT_PREFIX = "DSGLootRemoteMSG";
DSGLOOT_ITEMROLL = "ITEM: (%S+) Roll: (%S+)"
DSGLOOT_ITEMROLL_REPLY = "ITEM: (%S+) Roll: (%S+) Result: (%d+)"
RAIDLOOT_ROLL_PATTERN = "(.+) rolls (%d+) %((%d+)%-(%d+)%)"
DSG_LOOT = "DSG Loot"
DSGLOOT_ITEMROLL_OUTPUT = " rolled (%S+). Result: (%d+)"
DSGLOOT_LEVEL_NEED = "NEED"
DSGLOOT_LEVEL_GREED = "GREED"
DSGLOOT_LEVEL_STYLE = "STYLE"

-- German localization
if GetLocale() == "deDE" then
	RAIDLOOT_ROLL_PATTERN = "(.+) w\195\188rfelt. Ergebnis: (%d+) %((%d+)%-(%d+)%)"
	DSGLOOT_ITEMROLL_OUTPUT = " w\195\188rfelt (%S+). Ergebnis: (%d+)"
-- French localization
elseif GetLocale() == "frFR" then
	RAIDLOOT_ROLL_PATTERN = "(%S+) obtient un (%d+) %((%d+)%-(%d+)%)"
-- Spanish localization
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
	RAIDLOOT_ROLL_PATTERN = "(%S+) tira los dados y obtiene (%d+) %((%d+)%-(%d+)%)"
end