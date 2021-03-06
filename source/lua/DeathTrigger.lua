-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DeathTrigger.lua
--
--    Created by:   Brian Cronin (brian@unknownworlds.com)
--
-- Kill entity that touches this.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")

class 'DeathTrigger' (Trigger)

DeathTrigger.kMapName = "death_trigger"

local networkVars =
{
}

AddMixinNetworkVars(TechMixin, networkVars)

local teamType = enum({ "Both", "Marine", "Alien" })

-- This is also in DamageTypes.lua
local damageType = enum({ "Normal", "Gas", "Fire", "Electric" })

local function KillEntity(self, entity)

    if Server and HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetCanDie(true) then
    
        local direction = GetNormalizedVector(entity:GetModelOrigin() - self:GetOrigin())
        entity:Kill(self, self, self:GetOrigin(), direction)
        
    end
    
end

local function KillAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        KillEntity(self, entity)
    end
    
end

function DeathTrigger:OnCreate()

    Trigger.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, SignalListenerMixin)
    
    self.enabled = true
    self.lastExtraFunctionTime = Shared.GetTime()

    self:RegisterSignalListener(function() KillAllInTrigger(self) end, "kill")
    
end

local function GetDamageOverTimeIsEnabled(self)
    return self.damageOverTime ~= nil and self.damageOverTime > 0
end

local function GetTeamType(self)
    return self.teamType ~= nil and self.teamType
end

local function GetDamageType(self)
    return self.damageType ~= nil and self.damageType
end

function DeathTrigger:OnInitialized()

    Trigger.OnInitialized(self)
    
    self:SetTriggerCollisionEnabled(true)
    
    self:SetUpdates(GetDamageOverTimeIsEnabled(self))
    
end

local function DoDamageOverTime(self, entity, damage)

    if HasMixin(entity, "Live") then
        if GetTeamType(self) == teamType.Both or self.teamType == nil then
            if entity:isa("Exo") then
                entity:TakeDamage(damage, self, self, nil, nil, damage, 0, kDamageType.Normal, true)
            else
                entity:TakeDamage(damage, self, self, nil, nil, 0, damage, kDamageType.Normal, true)
            end
        elseif GetTeamType(self) == teamType.Marine and entity:isa("Marine") then
            entity:TakeDamage(damage, self, self, nil, nil, 0, damage, kDamageType.Normal, true)
        elseif GetTeamType(self) == teamType.Marine and entity:isa("Exo") then
            entity:TakeDamage(damage, self, self, nil, nil, damage, 0, kDamageType.Normal, true)
        elseif GetTeamType(self) == teamType.Alien and entity:isa("Alien") then
            entity:TakeDamage(damage, self, self, nil, nil, 0, damage, kDamageType.Normal, true)
        end

        if self.lastExtraFunctionTime + 2 < Shared.GetTime() then
            local params =
            {
                effecthostcoords = entity:GetCoords(),
                damagetype = GetDamageType(self)
            }

            entity:TriggerEffects("damage_trigger", params)

            if GetDamageType(self) == damageType.Fire then
                if entity.SetOnFire then
                    entity:SetOnFire(self, self)
                end
            elseif GetDamageType(self) == damageType.Electric then
                if entity.SetElectrified then
                    entity:SetElectrified(kElectrifiedDuration/2)
                end
            end

            self.lastExtraFunctionTime = Shared.GetTime()
        end

    end

end


if Server then

    function DeathTrigger:OnUpdate(deltaTime)

        if GetDamageOverTimeIsEnabled(self) then
            self:ForEachEntityInTrigger(function(entity) DoDamageOverTime(self, entity, self.damageOverTime * deltaTime) end)
        end

    end

    function DeathTrigger:OnTriggerEntered(enterEnt, triggerEnt)

        if self.enabled and not GetDamageOverTimeIsEnabled(self) then
            KillEntity(self, enterEnt)
        end

    end

end

Shared.LinkClassToMap("DeathTrigger", DeathTrigger.kMapName, networkVars)