--[[

Enigma Auto Equip
http://luodan.com

Quickly swap/define your suites with one click.

Code inspired by Bigfoot autoequip, but totally re-wrote.
Thanks to Bigfoot staff.

History
2005.09.13 Version 1.0.1
* Localization string adjusted.

2005.09.07 Version 1.0
* Initial release.

2007-9-12
update 1.1.1 by Bryan
]]

-- Consts
EAE_Version = "1.1.1";

EAE_Slots = { 
	"HeadSlot", 
	"NeckSlot", 
	"ShoulderSlot", 
	"BackSlot", 
	"ChestSlot", 
	"ShirtSlot", 
	"TabardSlot", 
	"WristSlot", 
	"HandsSlot", 
	"WaistSlot", 
	"LegsSlot", 
	"FeetSlot", 
	"Finger0Slot", 
	"Finger1Slot", 
	"Trinket0Slot", 
	"Trinket1Slot", 
	"MainHandSlot", 
	"SecondaryHandSlot", 
	"RangedSlot", 
	"AmmoSlot", 
} 

EAE_Lock = true;

StaticPopupDialogs["EAE_SAVE"] = { 
	text = EAE_SAVE_CONFIRM, 
	button1 = TEXT(YES), 
	button2 = TEXT(NO), 
	OnAccept = function() EAE_SavePlayerEquipSet(EAE_GetCurrentSetId()) end, 
	OnCancel = function(arg1) end, 
	showAlert = 1, 
	timeout = 0, 
}
StaticPopupDialogs["EAE_NULL"] = { 
	text = EAE_NULL_CONFIRM, 
	button1 = TEXT(YES), 
	button2 = TEXT(NO), 
	OnAccept = function() EAE_Reset() end, 
	OnCancel = function(arg1) end, 
	showAlert = 1, 
	timeout = 0, 
}

-- Events handlers
function EAE_OnLoad()
	-- Register events
	this:RegisterEvent("ADDON_LOADED");

	-- Init data
	if (not EAE_Config) then
		EAE_Config = {};
	end;
	EAE_RealmName = GetCVar("realmName");
	if (not EAE_RealmName) then
		EAE_RealmName = "Enigma";
	end;
	EAE_PlayerName = UnitName("player");
	if (not EAE_PlayerName) then
		EAE_PlayerName = "Unknown";
	end;
	EAE_PlayerId = EAE_PlayerName .. "@" .. EAE_RealmName;

	SLASH_EAE1 = "/eae";
	SlashCmdList["EAE"] = EAE_Command;
end 

function EAE_OnEvent(event) 
	if ( event == "ADDON_LOADED" and arg1 == "EN_AutoEquip" ) then
		
		setId = EAE_GetCurrentSetId();

		if ( not setId or setId == 0 ) then
		--[[
			EAE_SetCurrentSetId(1);
			EAE_SavePlayerEquipSet(1); 
			EAE_FrameSetButton1:SetChecked(1);
		]]
		else 
			--not auto changes
		--	EAE_LoadPlayerEquipSet(setId, 0);
			local objSetButton = getglobal("EAE_FrameSetButton" .. setId);
			if (objSetButton) then 
				objSetButton:SetChecked(1);
			end;
		end;
		
		--Change Texture
		if (EUF_Options) then
			EAE_FrameTexture:SetTexture("Interface\\AddOns\\EN_AutoEquip\\EN_AutoEquip");
		end
	end;
end

function EAE_SetButton_OnClick(setId)
	if (CursorHasItem() or UnitIsDeadOrGhost("player")) then
		return;
	end;
	if ( setId == 1 ) then 
		EAE_FrameSetButton1:SetChecked(1); 
		EAE_FrameSetButton2:SetChecked(nil); 
		EAE_FrameSetButton3:SetChecked(nil); 
		EAE_FrameSetButton4:SetChecked(nil);
		EAE_FrameNakedButton:SetChecked(nil);
		NakedObj.Nakie = false;
	elseif ( setId == 2 ) then 
		EAE_FrameSetButton1:SetChecked(nil); 
		EAE_FrameSetButton2:SetChecked(1); 
		EAE_FrameSetButton3:SetChecked(nil); 
		EAE_FrameSetButton4:SetChecked(nil); 
		EAE_FrameNakedButton:SetChecked(nil);
		NakedObj.Nakie = false;
	elseif ( setId == 3 ) then 
		EAE_FrameSetButton1:SetChecked(nil); 
		EAE_FrameSetButton2:SetChecked(nil); 
		EAE_FrameSetButton3:SetChecked(1); 
		EAE_FrameSetButton4:SetChecked(nil);
		EAE_FrameNakedButton:SetChecked(nil);
		NakedObj.Nakie = false;
	elseif ( setId == 4 ) then 
		EAE_FrameSetButton1:SetChecked(nil); 
		EAE_FrameSetButton2:SetChecked(nil); 
		EAE_FrameSetButton3:SetChecked(nil); 
		EAE_FrameSetButton4:SetChecked(1);
		EAE_FrameNakedButton:SetChecked(nil);
		NakedObj.Nakie = false;
	elseif ( setId == 5 ) then
		local id = EAE_GetCurrentSetId()
		EAE_FrameSetButton1:SetChecked(nil); 
		EAE_FrameSetButton2:SetChecked(nil); 
		EAE_FrameSetButton3:SetChecked(nil); 
		EAE_FrameSetButton4:SetChecked(nil);
		getglobal("EAE_FrameSetButton"..id):SetChecked(1); 
		EAE_FrameNakedButton:SetChecked(nil);
		NakedObj.Nakie = false;
	else 
		EAE_FrameSetButton1:SetChecked(nil); 
		EAE_FrameSetButton2:SetChecked(nil); 
		EAE_FrameSetButton3:SetChecked(nil); 
		EAE_FrameSetButton4:SetChecked(nil);
	end 
--	if ( setId or CursorHasItem() ) then 
--		return 
--	end 
--	if (setId ~= EAE_GetCurrentSetId()) then 
	if ( setId ~= nil and setId > 0 and setId < 5) then
		EAE_LoadPlayerEquipSet(setId, 1); 
		PlaySound("igChatEmoteButton"); 
	end
end

function EAE_SaveButton_OnClick( arg1 )
	if ( arg1 == "LeftButton" ) then
		local id = EAE_GetCurrentSetId();
		if ( id < 1 or id > 4) then
			DEFAULT_CHAT_FRAME:AddMessage(BINDING_HEADER_EAE_TITLE..": "..string.format(EAE_MSG_NULL_SAVED, setId), 1, 0.75 , 0);
			return
		end
		StaticPopup_Show("EAE_SAVE");
	elseif ( arg1 == "RightButton"  ) then
		StaticPopup_Show("EAE_NULL");
	end
end

function EAE_NakedButton_OnClick() 
	SlashCmdList.NAKEDTOGGLE();
	if ( this:GetChecked() ) then
		EAE_SetButton_OnClick()
	else
		EAE_SetButton_OnClick(5)
	end
end 

function EAE_SaveButton_OnEnter()
	GameTooltip_AddNewbieTip(EAE_HELP_SAVE_BTN_TITLE, 1, 1, 1, EAE_HELP_SAVE_BTN_DESC);
end 

function EAE_NakedButton_OnEnter()
	GameTooltip_AddNewbieTip(EAE_HELP_NAKED_BTN_TITLE, 1, 1, 1, EAE_HELP_NAKED_BTN_DESC);
end 

function EAE_SetButton_OnEnter(arg1)
	GameTooltip_AddNewbieTip(string.format(EAE_HELP_SET_BTN_TITLE, arg1), 1, 1, 1, string.format(EAE_HELP_SET_BTN_DESC, arg1));
end 

function EAE_Reset() 
	EAE_Config[EAE_PlayerId] = {};
	EAE_SetCurrentSetId(0);
	EAE_FrameSetButton1:SetChecked(nil); 
	EAE_FrameSetButton2:SetChecked(nil); 
	EAE_FrameSetButton3:SetChecked(nil); 
	EAE_FrameSetButton4:SetChecked(nil);
end

function EAE_SavePlayerEquipSet(setId)
	local index, value; 
	local equipSet = EAE_GetPlayerEquipSet(setId);
	for index, value in pairs(EAE_Slots) do 
		local itemName, itemLinkId = EAE_GetItemInfo("inventory", value);
		if (itemName and itemLinkId) then
			equipSet[value] = {name = itemName, link = itemLinkId};
		else
			equipSet[value] = {name = nil, link = nil};
		end 
	end
	DEFAULT_CHAT_FRAME:AddMessage(BINDING_HEADER_EAE_TITLE..": "..string.format(EAE_MSG_SET_SAVED, setId), 1, 0.75 , 0);
end 

function EAE_LoadPlayerEquipSet(setId, showMsg)
	EAE_GetPlayerItems()
	local equipSet = EAE_GetPlayerEquipSet(setId) 
	if ( not equipSet ) then 
		EAE_SetCurrentSetId(setId);
		return 
	end 
	EAE_LoadSet = {} 
	EAE_LoadSetFirst = {} 
	
	if (showMsg == 1) then
		DEFAULT_CHAT_FRAME:AddMessage(BINDING_HEADER_EAE_TITLE..": "..string.format(EAE_MSG_LOAD_SET, setId), 1, 0.75 , 0);
	end

	local slotName, itemData
	local UnequipItems = {};
	for slotName, itemData in pairs(equipSet) do
		if (itemData.link) then
			local srcSlot = EAE_PlayerItems[itemData.link]
			if (srcSlot) then 
				local dstSlot = {}
				dstSlot.type = "inventory";
				dstSlot.slotId = GetInventorySlotInfo(slotName);
				if ( EAE_MustPickUp(srcSlot, dstSlot, setId) ) then
					if (srcSlot.type == "inventory") then
							local index, s, b
							for index,s in pairs(EAE_LoadSetFirst) do
								if (EAE_IsSlotEqual(dstSlot, s.srcSlot)) then
									table.remove(EAE_LoadSetFirst, index)
									EAE_SaveItemPareToLoadSet(srcSlot, dstSlot, 1)
									b = true;
									break;
								end
							end
						if (not b) then
							EAE_SaveItemPareToLoadSet(srcSlot, dstSlot, 0)
						end
					elseif( EAE_IfExist(srcSlot)) then
						local srcSlot2 = EAE_PlayerItems[itemData.link..":2"];
						if (srcSlot2) then
							if (srcSlot2.type == "inventory") then
								if (not EAE_IsSlotEqual(srcSlot2, dstSlot)) then
									EAE_SaveItemPareToLoadSet(srcSlot2, dstSlot, 0)
								end
							else
								EAE_SaveItemPareToLoadSet(srcSlot2, dstSlot, 1)
							end
						else
							EAE_SaveItemPareToLoadSet(srcSlot, dstSlot, 1)
						end
					else
						EAE_SaveItemPareToLoadSet(srcSlot, dstSlot, 1)
					end
				end
			else
				if (showMsg == 1) then
					DEFAULT_CHAT_FRAME:AddMessage(string.format(EAE_MSG_ITEM_NOTEXISTS, itemData.name), 1, 0.75, 0);
				end;
			end
		elseif (slotName ~= "AmmoSlot" and GetInventorySlotInfo(slotName)) then
			local dstSlot = {}
			dstSlot.type = "inventory";
			dstSlot.slotId = GetInventorySlotInfo(slotName);
			table.insert(UnequipItems, dstSlot);
		end
	end 
	
	if (EAE_IsLoadSetLocked() and showMsg == 1 ) then 
		DEFAULT_CHAT_FRAME:AddMessage(EAE_MSG_ITEM_LOCKED, 1, 0.75, 0);
		return;
	end;

	local index, value, slotPare, slot2
	EAE_GetBagEmptyNums();
		
	for index, slotPare in pairs(EAE_LoadSetFirst) do 
		if (TotalBagEmptyNums == 0 and showMsg == 1 ) then
			DEFAULT_CHAT_FRAME:AddMessage(EAE_MSG_BAG_FULL, 1, 0.75, 0);
			break;
		end
		EAE_PickUpItem(slotPare.dstSlot) 
		if ( CursorHasItem() ) then 
			for bag = 0, 4 do
				if (BagEmptyNums[bag] > 0) then
					if (bag == 0) then
						PutItemInBackpack(); 
					else
						PutItemInBag(19+bag);
					end
					BagEmptyNums[bag] = BagEmptyNums[bag] - 1;
					TotalBagEmptyNums = TotalBagEmptyNums - 1;
					break;
				end
			end
		end
		EAE_PickUpItem(slotPare.srcSlot) 
		if ( CursorHasItem() ) then 
			EquipCursorItem(slotPare.dstSlot.slotId-1) 
		end 
	end
		
	for index, slotPare in pairs(EAE_LoadSet) do 
		EAE_PickUpItem(slotPare.srcSlot) 
		if ( CursorHasItem() ) then 
			EAE_PickUpItem(slotPare.dstSlot) 
		end 
	end
	
	for index, slot2 in pairs(UnequipItems) do
		if (TotalBagEmptyNums == 0 and showMsg == 1 ) then
			DEFAULT_CHAT_FRAME:AddMessage(EAE_MSG_BAG_FULL, 1, 0.75, 0);
			break;
		end
		EAE_PickUpItem(slot2) 
		if (CursorHasItem()) then
			for bag = 0, 4 do
				if (BagEmptyNums[bag] > 0) then
					if (bag == 0) then
						PutItemInBackpack(); 
					else
						PutItemInBag(19+bag);
					end
					BagEmptyNums[bag] = BagEmptyNums[bag] - 1;
					TotalBagEmptyNums = TotalBagEmptyNums - 1;
					break;
				end
			end
		end
	end
	EAE_PlayerItems = {};
	EAE_LoadSet = {};
	EAE_LoadSetFirst = {};
	EAE_SetCurrentSetId(setId)
end

function EAE_IfExist(slot)
	for _,s in pairs(EAE_LoadSet) do
		if (EAE_IsSlotEqual(slot, s.srcSlot)) then return true; end
	end
	return false;
end
	
function EAE_GetBagEmptyNums()
	local bag, totalSlots, slot;
	BagEmptyNums = {};
	TotalBagEmptyNums = 0;
	for bag = 0, 4 do
		BagEmptyNums[bag] = 0;
		totalSlots = GetContainerNumSlots(bag);
		for slot=1, totalSlots do
			if not GetContainerItemInfo(bag, slot) then
				BagEmptyNums[bag] = BagEmptyNums[bag] + 1;
				TotalBagEmptyNums = TotalBagEmptyNums + 1;
			end
		end
	end
end

function EAE_MustPickUp(srcSlot, dstSlot, setId)
	if (srcSlot.type == "container") then 
		-- if source slot is in container, return true (from container to inventory);
		return 1;
	else
		if (EAE_IsSlotEqual(srcSlot, dstSlot)) then 
			-- if source slot equals to destination slot, return false (no pickup needed);
			return;
		end
		return 1;
	end
end

function EAE_GetSetItemInventorySlot(itemLinkId, setId)
	-- Return a set item's inventory location (where to equip this set item).
	local equipSet = EAE_GetPlayerEquipSet(setId);
	if ( not equipSet ) then 
		return;
	end 
	local slotName, itemData;
	for slotName, itemData in equipSet do 
		if ( itemData.link == itemLinkId ) then
			local slot = {};
			slot.type = "inventory";
			slot.slotId = GetInventorySlotInfo(slotName);
			return slot; 
		end 
	end 
end

-- Base Functions
function EAE_SaveItemPareToLoadSet(srceLoc, destLoc, flag) 
	local index, value, TempLoadSet
	if ( flag == 0) then
		TempLoadSet = EAE_LoadSetFirst;
	else
		TempLoadSet = EAE_LoadSet;
	end
	-- Check if they are already in load set
	for index, itemPare in pairs(TempLoadSet) do 
		if ( EAE_IsSlotEqual(itemPare.srcSlot, srceLoc) and EAE_IsSlotEqual(itemPare.dstSlot, destLoc) ) then 
			return;
		end 
		if ( EAE_IsSlotEqual(itemPare.srcSlot, destLoc) and EAE_IsSlotEqual(itemPare.dstSlot, srceLoc)) then
			return;
		end 
	end 

	local itemPare = {} 
	itemPare.srcSlot = srceLoc; 
	itemPare.dstSlot = destLoc; 
	table.insert(TempLoadSet, itemPare); 
end 

function EAE_IsSlotEqual(slot1, slot2) 
	return (slot1.type == slot2.type and slot1.bagId == slot2.bagId and slot1.slotId == slot2.slotId) 
end 

function EAE_IsSlotItemLocked(slot) 
	if ( slot.type == "container" ) then 
		local _, _, isLocked, _, _ = GetContainerItemInfo(slot.bagId, slot.slotId);
		return isLocked;
	elseif ( slot.type == "inventory" ) then 
		return IsInventoryItemLocked(slot.slotId);
	end 
end

function EAE_IsLoadSetLocked() 
	local index, itemPare
	for index, itemPare in pairs(EAE_LoadSet) do 
		if (EAE_IsSlotItemLocked(itemPare.srcSlot) or EAE_IsSlotItemLocked(itemPare.dstSlot)) then 
			return 1; 
		end
	end
end

function EAE_PickUpItem(slot) 
	if (slot.type == "container") then 
		PickupContainerItem(slot.bagId, slot.slotId) 
	elseif (slot.type == "inventory") then 
		PickupInventoryItem(slot.slotId) 
	end 
end 

function EAE_GetPlayerItems()
	-- Generate a dataset, index is item linkid, value is item's slotinfo
	EAE_PlayerItems = {};
	local bagIndex; 
	for bagIndex = 0, NUM_CONTAINER_FRAMES, 1 do 
		local slotIndex; 
		for slotIndex = 1, GetContainerNumSlots(bagIndex), 1 do 
			local itemName, itemLinkId = EAE_GetItemInfo("container", bagIndex, slotIndex); 
			if (itemName and itemLinkId) then 
				local slot = {}; 
				slot.type = "container"; 
				slot.bagId = bagIndex; 
				slot.slotId = slotIndex; 
				if (EAE_PlayerItems[itemLinkId]) then
					EAE_PlayerItems[itemLinkId..":2"] = slot; 
				else
					EAE_PlayerItems[itemLinkId] = slot; 
				end
			end; 
		end; 
	end; 
	local index, value; 
	for index, slotName in pairs(EAE_Slots) do 
		local itemName, itemLinkId = EAE_GetItemInfo("inventory", slotName); 
		if (itemName and itemLinkId) then 
			local slot = {}; 
			slot.type = "inventory"; 
			slot.slotId = GetInventorySlotInfo(slotName); 
			if (EAE_PlayerItems[itemLinkId]) then
				EAE_PlayerItems[itemLinkId..":2"] = slot; 
			else
				EAE_PlayerItems[itemLinkId] = slot; 
			end
		end; 
	end; 
end; 

function EAE_GetPlayerEquipSet(setId) 
	local numSetId = tonumber(setId) 
	if ( not numSetId ) then 
		return
	end 
	if ( not EAE_Config[EAE_PlayerId][numSetId] ) then 
		EAE_Config[EAE_PlayerId][numSetId] = {} 
	end 
	return EAE_Config[EAE_PlayerId][numSetId] 
end 

function EAE_GetCurrentSetId()
	if (not EAE_Config[EAE_PlayerId]) then
		EAE_Config[EAE_PlayerId] = {};
	end;
	if (not EAE_Config[EAE_PlayerId].CurrentSetId) then
		EAE_Config[EAE_PlayerId].CurrentSetId = 0;
	end;
	return EAE_Config[EAE_PlayerId].CurrentSetId;
end;

function EAE_SetCurrentSetId(setId)
	if (not EAE_Config[EAE_PlayerId]) then
		EAE_Config[EAE_PlayerId] = {};
	end;
	EAE_Config[EAE_PlayerId].CurrentSetId = setId;
end; 

-- Framework Functions
function EAE_GetInventoryItemLinkId(slotId) 
	local itemLink = GetInventoryItemLink("player", slotId);
	local itemName, itemLinkId = EAE_GetItemInfoByLink(itemLink);
	return itemLinkId;
end 

function EAE_GetItemInfoByLink(itemLink) 
	if ( not itemLink or type(itemLink) ~= "string" ) then 
		return;
	end 
	local _, _, itemLinkId, itemName = string.find(itemLink, "^|c%x+|H(.+)|h%[(.+)%]"); 
	if (itemLinkId and itemName) then 
		return itemName, itemLinkId;
	end 
end 

function EAE_GetItemInfo(itemType, arg1, arg2) 
	if (itemType == "container") then 
		--arg1, 2 for bagId, slotId
		local itemLink = GetContainerItemLink(arg1, arg2) 
		return EAE_GetItemInfoByLink(itemLink)
	elseif (itemType == "inventory") then
		--arg1 for slotName
		local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(arg1)) 
		return EAE_GetItemInfoByLink(itemLink)
	end 
end

function EAE_DEBUG(arg1,arg2)
	local msg = "";
	if (arg1) then msg = msg .. arg1; end;
	if (arg2) then msg = msg .. "=" .. arg2; end;
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end;

function EAE_Command(cmd)
	if( cmd == "lock" ) then
		EAE_Frame:EnableMouse(false);
		EAE_Lock = true;
	elseif( cmd == "unlock" ) then
		EAE_Frame:EnableMouse(true);
		EAE_Lock = false;
	else
		DEFAULT_CHAT_FRAME:AddMessage("Usage /eae [lock][unlock]");
	end
end

function EAE_MouseUp()
	if ( this.isMoving ) then
		this:StopMovingOrSizing();
		this.isMoving = false;
	end
end

function EAE_MouseDown(button)
	if ( EAE_Lock == false  and ( button == "LeftButton" ) ) then
		this:StartMoving();
		this.isMoving = true;
	end
end

function EAE_OnHide()
	if ( this.isMoving ) then
		this:StopMovingOrSizing();
		this.isMoving = false;
	end
end

