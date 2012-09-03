
function DSGLootMaster_OnLoad(self)
	print(GetContainerItemLink(3,14));
	print(GetContainerItemLink(3,13));
	DSGLootMaster_FullUpdate(self)
	self:Show();
end

function DSGLootMaster_OnEvent(self)

end

function DSGLootMaster_FullUpdate(self)
	local numItems = 2;
	local previous = nil;
	for i=1, numItems do
		local frame = CreateFrame("BUTTON", nil,self.ScrollFrame.ScrollChild, "DSGLootItemTemplate");
	
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