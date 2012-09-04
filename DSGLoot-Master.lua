local playerList = {};
local lootList = {};
local raidId = nil;

LootDB = {}
DSGLootMasterConfig = {
}

local DefaultDSGLootMasterConfig = {
	enabled = true,
	autoAnswer = true,
	dockToLootFrame = true	
}

local exampleDB = {
	["ID"] = {
		[0] = {
			Item = "ITEMLINK",
			rolls = {
				["PLAYER1"] = {
					roll = {
						level = "NEED",
						result = 89,
					}
				},
				["PLAYER2"] = {
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
	self.itemFrames = {};
	self.expandedRolls = {};
	self.usedPlayerFrames = {};
	self.unusedPlayerFrames = {};
	self.highlightedRolls = {};

	assignDefaultOptions();
	getRaidId();
	self:RegisterEvent("CHAT_MSG_ADDON");
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("LOOT_CLOSED");
	self:RegisterEvent("LOOT_SLOT_CLEARED");
	RegisterAddonMessagePrefix(DSGLOOT_PREFIX);
	DSGLootMaster_FullUpdate(self)
	self:Show();
end


function DSGLootMaster_OnEvent(self, event, ...)
	args = ...;

	if event == "CHAT_MSG_ADDON" then
		prefix, message, distribution, sender = args;
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

--Full Update of the DSGLootMasterFrame
function DSGLootMaster_FullUpdate(self)
	DSGLootMaster_RecyclePlayerFrames(self);
	local numItems = GetNumLootItems();
	local previous = nil;
	for i=1, numItems do
		if (LootSlotHasItem(i)) then	
			local frame = self.itemFrames[i];
			if (not frame) then
				frame = CreateFrame("BUTTON", nil, self.ScrollFrame.ScrollChild, "DSGLootItemTemplate");
				self.itemFrames[i] = frame;
			end			
			
			frame.rollId = i;
			frame.itemIdx = i;
			frame.itemLink = GetLootSlotLink(i);	

			--Dirty fix cause LootSlotHasItems doesn't detect coins
			--If Fixed: can be removed
			if frame.itemLink ~= nil then
				DSGLootMaster_UpdateItemFrame(self, frame);
				frame:Show();
				
				if (previous) then
					frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -5);
				else
					frame:SetPoint("TOPLEFT", 0, -2);
				end
				
				if (self.expandedRolls[frame.rollId]) then
					local firstFrame, lastFrame = DSGLootMaster_UpdatePlayerFrames(self, frame.itemIdx);
					if ( firstFrame ) then
						firstFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2);
						previous = lastFrame;
					else
						previous = frame;
					end
				else
					previous = frame;
				end
			end
		end
	end
	for i=numItems + 1, #self.itemFrames do
		self.itemFrames[i]:Hide();
	end
end

-- Recycles all PlayerFrames
function DSGLootMaster_RecyclePlayerFrames(self)
	for i=1, #self.usedPlayerFrames do
		local frame = self.usedPlayerFrames[i];
		frame.itemIdx = nil;
		frame.playerIdx = nil;
		frame:Hide();
		table.insert(self.unusedPlayerFrames, frame);
	end
	table.wipe(self.usedPlayerFrames);
end


function DSGLootMaster_UpdateItemFrame(self, itemFrame)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemFrame.itemLink);
	local expanded = self.expandedRolls[itemFrame.rollId];
	
	if (expanded) then
		itemFrame.ToggleButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
		itemFrame.ToggleButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
		itemFrame.ToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled");
	else
		itemFrame.ToggleButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
		itemFrame.ToggleButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down");
		itemFrame.ToggleButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled");
	end
	
	itemFrame.Icon:SetTexture(itemTexture);
	local colorInfo = ITEM_QUALITY_COLORS[itemRarity];
	itemFrame.IconBorder:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
	itemFrame.ItemName:SetText(itemName);
	itemFrame.ItemName:SetVertexColor(colorInfo.r, colorInfo.g, colorInfo.b);
	
	if ( self.highlightedRolls[rollID] ) then
		itemFrame.ActiveHighlight:Show();
	else
		itemFrame.ActiveHighlight:Hide();
	end
end

function DSGLootMaster_GetPlayerFrame(self)
	local frame = table.remove(self.unusedPlayerFrames);
	if (not frame) then
		frame = CreateFrame("BUTTON", nil, self.ScrollFrame.ScrollChild, "DSGLootPlayerTemplate");
	end
	table.insert(self.usedPlayerFrames, frame);
	return frame;
end

function DSGLootMaster_UpdatePlayerFrames(self, itemIdx)
	local firstFame, lastFrame;
	
	for i=1, GetNumGroupMembers() do
		local candidate, _ = GetMasterLootCandidate(i, itemIdx);
		playerList[i] = candidate;
	
		local frame = DSGLootMaster_GetPlayerFrame(self);
		if (lastFrame) then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -1);
		else
			frame:ClearAllPoints();
		end
		
		firstFrame = firstFrame or frame;
		lastFrame = frame;
		
		frame.itemIdx = itemIdx;
		frame.playerIdx = i;
		DSGLootMaster_UpdatePlayerFrame(self, frame);
		frame:Show();
	end
	return firstFrame, lastFrame;
end

function DSGLootMaster_UpdatePlayerFrame(self, playerFrame)
	local name, rank, subgroup, level, class, filename, zone = GetRaidRosterInfo(playerFrame.playerIdx);
	if ( playerFrame.playerIdx ) then
		if (playerFrame.playerIdx % 2 == 1) then
			playerFrame.AlternatingBG:Show();
		else
			playerFrame.AlternatingBG:Hide();
		end
		
		if ( name ) then
			playerFrame.PlayerName:SetText(name);
			local classColor = RAID_CLASS_COLORS[filename];
			playerFrame.PlayerName:SetVertexColor(classColor.r, classColor.g, classColor.b);
		else
			playerFrame.PlayerName:SetText(UNKNOWNOBJECT);
			playerFrame.PlayerName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		end
	else
		playerFrame.AlternatingBG:Show();
		playerFrame.PlayerName:SetText(LOOT_HISTORY_ALL_PASSED);
		playerFrame.PlayerName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		playerFrame.RollIcon.Texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up");
		playerFrame.RollIcon.tooltip = PASS;
		playerFrame.RollText:SetText("");
		playerFrame.RollIcon:SetPoint("RIGHT", playerFrame, "RIGHT", -2, -1);
		playerFrame.WinMark:Hide();
	end
end

function DSGLootMaster_ToggleRollExpanded(self, rollID)
	DSGLootMaster_SetRollExpanded(self, rollID, not self.expandedRolls[rollID]);
end

function DSGLootMaster_SetRollExpanded(self, rollID, isExpanded)
	self.expandedRolls[rollID] = isExpanded;
	DSGLootMaster_FullUpdate(self);
end

-- Gets the current Raid id
function getRaidId()
	local name = GetInstanceInfo();
	for i = 1, GetNumSavedInstances() do
		local savedName, id = GetSavedInstanceInfo(i);
		if savedName == name then
			raidId = id
		end
	end
end

-- Gets all Raidmember
function getRaidMembers()
	numGrpMembers = 0;
	for i =1, GetNumGroupMembers() do
		local candidate, _ = GetMasterLootCandidate(i)
		if not (candidate == nil) then
			numGrpMembers = numGrpMembers + 1;
			raidMembers[numGrpMembers] = candidate;
		end
	end
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
	SendAddonMessage(DSGLOOT_PREFIX, string.format(DSGLOOT_ITEMROLL_REPLY, item, level, result));
	--REGISTER ROLL;
end