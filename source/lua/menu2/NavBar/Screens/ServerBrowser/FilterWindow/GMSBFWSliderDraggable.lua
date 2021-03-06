-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWSliderDraggable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIDraggable themed for the server browser's filter window.
--
--  Properties:
--      BeingDragged    Whether or not this object is currently being dragged by the user.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDraggable.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GMSBFWSliderDraggable : GUIDraggable
class "GMSBFWSliderDraggable" (GUIDraggable)

local kSliderStrokeColor = MenuStyle.kServerBrowserFilterWindowSliderStrokeColor
local kSliderFillColor = MenuStyle.kServerBrowserFilterWindowSliderFillColor
local kSliderStrokeWidth = 2

local function UpdateSize(self)
    self.graphic:SetSize(self:GetSize())
end

local function OnSliderDrag(self)
    PlayMenuSound("SliderSound")
end

function GMSBFWSliderDraggable:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIDraggable.Initialize(self, params, errorDepth)
    
    self.graphic = CreateGUIObject("graphic", GUIMenuBasicBox, self)
    
    self.graphic:SetFillColor(kSliderFillColor)
    self.graphic:SetStrokeColor(kSliderStrokeColor)
    self.graphic:SetStrokeWidth(kSliderStrokeWidth)
    
    self:HookEvent(self, "OnDrag", OnSliderDrag)
    
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    
end

-- Override for animations.
function GMSBFWSliderDraggable:SetPosition(p1, p2, p3)
    
    -- Only animate if the slider isn't being dragged, and if this call wasn't triggered by the
    -- animation system.
    if not self:GetBeingDragged() and not GetGUIAnimationManager():GetIsSettingPropertyForAnimation() then
        
        local value = ProcessVectorInput(p1, p2, p3)
        self:ConstrainPosition(value)
        local oldValue = self:GetPosition()
        
        if value == oldValue then
            return false -- no change.
        end
        
        self:AnimateProperty("Position", value, MenuAnimations.FlyIn)
        
        return true
        
    end
    
    -- Either the slider is being dragged, or this call originated from the animation system.  Just
    -- set it like normal.
    local result = GUIDraggable.SetPosition(self, p1, p2, p3)
    return result
    
end
