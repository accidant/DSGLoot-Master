local playerList;
local lootList;

LootDB = {}
DSGLootMasterConfig = {
}

local DefaultDSGLootMasterConfig = {
	enabled = true,
	autoAnswer = true,
	dockToLootFrame = true	
}

local exampleDB = {
	"ID" = {
		0 = {
			Item = "ITEMLINK",
			rolls = {
				"PLAYER1" = {
					roll = {
						level = "NEED",
						result = 89,
					}
				},
				"PLAYER2" = {
					roll = {
						level = "GREED",
						result = 25,
					}
				},
			}
		}
	}
}

-- Sets Defaultoptions for the MasterLooterConfiguration if there aren't any saved ones
function assignDefaultOptions()
	if DSGLootMasterConfig.enabled == nil then
		DSGLootMasterConfig.enabled = DefaultDSGLootMasterConfig.enabled
	end
	if DSGLootMasterConfig.autoReply == nil then
		DSGLootMasterConfig.autoReply = DefaultDSGLootMasterConfig.Reply
	end
	if DSGLootMasterConfig.dockToLootFrame == nil then
		DSGLootMasterConfig.dockToLootFrame = DefaultDSGLootMasterConfig.dockToLootFrame
	end
end


function DSGLootMaster_OnLoad(self)
	assignDefaultOptions();
	self:RegisterEvent("CHAT_MSG_ADDON");
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	RegisterAddonMessagePrefix(DSGLOOT_PREFIX);
	DSGLootMaster_FullUpdate(self)
	self:Show();
end


function DSGLootMaster_OnEvent(self, event)
	if event == "CHAT_MSG_ADDON" then
		prefix, message, distribution, sender = ...;
		if(prefix == DSGLOOT_PREFIX) then
			revievedAddonMsg(message, sender);
		end
	elseif event == "LOOT_OPENED" then
		DSGLootMaster_FullUpdate(self);
		self:Show();
	elseif event == "LOOT_CLOSED" then
		self:Hide();
	elseif event == "LOOT_SLOT_CLEARED" then
	
	end	
end

function DSGLootMaster_FullUpdate(self)
	local numItems = 2;
	local previous = nil;
	for i=1, numItems do
		local frame = CreateFrame("BUTTON", nil, self.ScrollFrame.ScrollChild, "DSGLootItemTemplate");
	
		DSGLootMaster_UpdateItemFrame(self, frame, GetContainerItemLink(3,12+i));
		if (previous) then
			frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -5);
		else
			frame:SetPoint("TOPLEFT", 0, -2);
		end
		frame:Show();
		previous = frame;
	end
end

function DSGLootMaster_UpdateItemFrame(self, itemFrame, item)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(item);
	itemFrame.Icon:SetTexture(itemTexture);
	local colorInfo = ITEM_QUALITY_COLORS[itemRarity];
	itemFrame.IconBorder:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
	itemFrame.ItemName:SetText(itemName);
	itemFrame.ItemName:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
end

function recievedAddonMsg(message, sender)
	if string.find(message, DSGLOOT_ITEMROLL) then
		local item, level = string.find(message, DSGLOOT_ITEMROLL);
		local result = rollForLevel(level);
		registerRollAndReply(item, result, level);
	end
end

function rollForLevel(level)
	if level == DSGLOOT_LEVEL_NEED then
		return randdom(1, 100);
	elseif level == DSGLOOT_LEVEL_GREED then
		return randdom(1, 101);
	elseif level == DSGLOOT_LEVEL_STYLE then
		return randdom(1, 102);
	else
		print("There is a roll request with an not matching rolllevel");
	end
end

function registerRollAndReply(item, result, level)
	SendAddonMessage(DSGLOOT_PREFIX, string.format(DSGLOOT_ITEMROLL_REPLY, item, level, result);
	--REGISTER ROLL;
end