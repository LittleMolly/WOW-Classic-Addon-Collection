local restedXpFrame = CreateFrame("Frame", "RestedXpFrame")

local timeLastUpdate = 0
local executionInterval = 2 -- 1 second

local restedXP = 0
local lastRestedXP = 0
local lastLastRestedXP = 0
local restedPerSecond = 0

local tooltip = nil

restedXpFrame:SetScript("OnUpdate", function(self)
	local current = GetTime()	
	
	if (current - timeLastUpdate >= executionInterval) then
		restedXP = GetXPExhaustion()
		if not (restedXP) then return end
		diff = restedXP - lastLastRestedXP
		restedPerSecond = diff / (executionInterval*2)
		
		lastLastRestedXP = lastRestedXP
		lastRestedXP = restedXP
	
		timeLastUpdate = current 
		
		if (tooltip) then
			drawTooltip()
		end
	end
end)


function restedXpInfo_calculateXpValues(self, event)
    restedXp = GetXPExhaustion()
	restedPercentageFormatted = "0"
	
    if restedXp then        
        local XPMax = UnitXPMax("player")
        local restedCap = XPMax * 1.5
        local xpUntilCap = restedCap - restedXp
        local restedPercentage = 100 * restedXp / restedCap

        if restedPercentage < 10 then
            restedPercentageFormatted = string.format("%.1f", restedPercentage) 
        else 
            restedPercentageFormatted = string.format("%.0f", restedPercentage)
        end
    end
	return restedPercentageFormatted
end

function xpSpeedToTentCount(xpSpeed)
	if not (xpSpeed) then
		return ""
	end
	
	if (xpSpeed < 1) then
		return ""
	elseif (xpSpeed < 8) then
		return "1 tent"
	elseif (xpSpeed < 15) then
		return "2 tents"
	elseif (xpSpeed < 21) then
		return "3 tents"
	else 
		return "many tents"
	end
end

function drawTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
	
	GameTooltip:AddLine(restedXpInfo_calculateXpValues() .."% of max rested XP")
	
	if (restedPerSecond and restedPerSecond > 0 and lastLastRestedXP > 0) then
		perMinute = (restedPerSecond*60)/(UnitXPMax("player")*1.5) * 100
		GameTooltip:AddLine(xpSpeedToTentCount(perMinute) .." (".. string.format("%.1f", perMinute) .."%/min)")
	end
	GameTooltip:Show()
end

MainMenuExpBar:SetScript("OnEnter", function()
	drawTooltip()
	tooltip = GameTooltip
end)

MainMenuExpBar:SetScript("OnLeave", function()
	GameTooltip:Hide()
	tooltip = nil
end)

