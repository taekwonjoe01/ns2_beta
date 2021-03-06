-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\InsightNetworkMessages_Client.lua
--
-- Created by: Jon Hughes (jon@jhuze.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function OnCommandHealth(healthTable)

    Insight_SetPlayerHealth(healthTable.clientIndex, healthTable.health, healthTable.maxHealth, healthTable.armor, healthTable.maxArmor)

end

Client.HookNetworkMessage("Health", OnCommandHealth)

function OnCommandTechPoints(techPointsTable)

    Insight_SetTechPoint(techPointsTable.entityIndex, techPointsTable.teamNumber, techPointsTable.techId,
        techPointsTable.location, techPointsTable.healthFraction, techPointsTable.powerNodeFraction,
        techPointsTable.builtFraction, techPointsTable.eggCount)

end

Client.HookNetworkMessage("TechPoints", OnCommandTechPoints)


function OnCommandRecycle(recycleTable)

    if recycleTable.techId == kTechId.Extractor then
        DeathMsgUI_AddRtsLost(kTeam1Index, 1)
    end

    DeathMsgUI_AddResLost(kTeam1Index, recycleTable.resLost)
    DeathMsgUI_AddResRecovered(recycleTable.resGained)

end

function OnCommandConsume(consumeTable)

    if consumeTable.techId == kTechId.Harvester then
        DeathMsgUI_AddRtsLost(kTeam2Index, 1)
    end

end

Client.HookNetworkMessage("Consume", OnCommandConsume)

Client.HookNetworkMessage("Recycle", OnCommandRecycle)


function OnCommandReset()

    DeathMsgUI_ResetStats()

end

Client.HookNetworkMessage("Reset", OnCommandReset)