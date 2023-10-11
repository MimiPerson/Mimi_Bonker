local AceGUI = LibStub("AceGUI-3.0")

-- Define item qualities and their corresponding colors
ItemQualities = {
  [0] = "Poor",
  [1] = "Common",
  [2] = "Uncommon",
  [3] = "Rare",
  [4] = "Epic",
  [5] = "Legendary",
  [6] = "Artifact",
  [7] = "Vanity / Heirloom",
}
ItemQualityColors = {
  "FF9D9D9D", -- Poor (Gray)
  "FFFFFFFF", -- Common (White)
  "FF1EFF00", -- Uncommon (Green)
  "FF0070DD", -- Rare (Blue)
  "FFA335EE", -- Epic (Purple)
  "FFFF8000", -- Legendary (Orange)
  "FFE6CC80", -- Artifact (Gold)
  "FFFFD864", -- Artifact (Gold)
}

-- Define the UI setup function
function DrawUI()
  -- Create the frame container
  ConfigFrame = AceGUI:Create("Frame")

  ConfigFrame:SetWidth(400)
  ConfigFrame:SetHeight(500)
  ConfigFrame:SetTitle("|cFFE6CC80Mimi's Bonk Config|r")
  ConfigFrame:SetStatusText("Close and Save")
  ConfigFrame:SetCallback("OnClose", function(widget)
    AceGUI:Release(widget)
    BagLoop()
  end)

  ConfigFrame:SetLayout("Fill")

  -- Create the TabGroup
  local tab = AceGUI:Create("ScrollFrame")

  tab:SetLayout("Flow")

  -- Add the TabGroup to the frame container
  ConfigFrame:AddChild(tab)

  DrawGroup(tab)
end

-- Function to draw widgets for the first tab
function DrawGroup(container)
  container:SetFullWidth(true)
  container:SetLayout("Flow")

  -- Create checkboxes for item qualities
  for i = 0, 7 do
    local BoxGroup = AceGUI:Create("SimpleGroup")

    BoxGroup:SetLayout("Flow")
    BoxGroup:SetHeight(25)
    BoxGroup:SetFullWidth(true)

    local OptionsGroup = AceGUI:Create("SimpleGroup")

    OptionsGroup:SetLayout("Flow")
    OptionsGroup:SetFullWidth(true)
    OptionsGroup:SetHeight(30)

    local DestroyBox = AceGUI:Create("CheckBox")

    DestroyBox:SetWidth(100)
    DestroyBox:SetLabel("|cFFFF0000Destroy|r")

    local SellBox = AceGUI:Create("CheckBox")

    SellBox:SetWidth(50)
    SellBox:SetLabel("|cFFE6CC80Sell|r")

    local header = AceGUI:Create("Label")

    header:SetFont("Fonts\\MORPHEUS.TTF", 14)
    header:SetText("|c" .. ItemQualityColors[i + 1] .. ItemQualities[i] .. "|r")
    if LocalVar.DestroyQualities[i] then
      DestroyBox:SetValue(LocalVar.DestroyQualities[i])
    end

    DestroyBox:SetCallback("OnValueChanged", function(self, event, value)
      LocalVar.DestroyQualities[i] = value
      SellBox:SetValue(false)
    end)

    if LocalVar.SellQualities[i] then
      SellBox:SetValue(LocalVar.SellQualities[i])
    end
    SellBox:SetCallback("OnValueChanged", function(self, event, value)
      LocalVar.SellQualities[i] = value

      if value == true then
        DestroyBox:SetValue(false)
      end
    end)

    OptionsGroup:AddChild(SellBox)
    OptionsGroup:AddChild(DestroyBox)
    BoxGroup:AddChild(header)
    BoxGroup:AddChild(OptionsGroup)
    container:AddChild(BoxGroup)
  end
end

-- Callback function for tab selection
function SelectGroup(container, event, group)
  container:ReleaseChildren()
  local functionName = "DrawGroup" .. group
  local func = _G[functionName]

  if type(func) == "function" then
    func(container)
  end
end

-- Create an event listener frame
local EventListener = CreateFrame("Frame", "eventListener")
EventListener:RegisterEvent("BAG_UPDATE")
EventListener:RegisterEvent("ADDON_LOADED")

-- Function to purge inventory
function purgeInventory(itemName, rarity, bag, item)
  PickupContainerItem(bag, item)
  DeleteCursorItem()
end
function BagLoop()
  for bag = 0, 4 do
    if GetBagName(bag) then
      local numBagSlots = GetContainerNumSlots(bag)
      for item = 1, numBagSlots do
        local _, itemCount, _, _, _, _, itemLink =
          GetContainerItemInfo(bag, item)
        if itemLink then
          local itemId = itemLink:match("|Hitem:(%d+):")
          local itemName, _, itemRarity = GetItemInfo(itemId)
          if LocalVar.DestroyQualities[itemRarity] == true then
            purgeInventory(itemName, itemRarity, bag, item)
          end
          if LocalVar.SellQualities[itemRarity] == true then  end
        end
      end
    end
  end
end
-- Event handler function
function EventHandler(self, event, arg)
  if event == "ADDON_LOADED" and arg == "MimiBonker" then
    if not LocalVar then
      LocalVar = {}
    end
    if not LocalVar.DestroyQualities then
      LocalVar.DestroyQualities = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        [7] = false,
        [8] = false,
      }
    end
    if not LocalVar.SellQualities then
      LocalVar.SellQualities = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        [7] = false,
        [8] = false,
      }
    end
  end

  if event == "BAG_UPDATE" then
    BagLoop()
  end
end

-- Slash commands to open the UI
SLASH_MimiBonk1 = "/mimibonk"
SLASH_MimiBonk2 = "/mb"

SlashCmdList["MimiBonk"] = function()
  DrawUI()
end

EventListener:SetScript("OnEvent", EventHandler)
