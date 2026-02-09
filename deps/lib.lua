-- Progressbar wrapper for 404_reloadTexture

local ProgressBar = {
    isActive = false,
    currentProgress = 0,
    maxProgress = 100
}

-- Start progress bar with duration and text
function ProgressBar:Start(duration, text)
    if self.isActive then return false end
    
    self.isActive = true
    self.currentProgress = 0
    self.maxProgress = 100
    
    startUI(duration, text or "Processing...")
    return true
end

-- Update progress (0-100)
function ProgressBar:Update(progress)
    if not self.isActive then return false end
    
    self.currentProgress = math.max(0, math.min(100, progress))
    return true
end

-- Calculate progress percentage from current/total
function ProgressBar:SetProgress(current, total)
    if total == 0 then return false end
    local percent = math.floor((current / total) * 100)
    return self:Update(percent)
end

-- Stop and hide progress bar
function ProgressBar:Stop()
    self.isActive = false
    self.currentProgress = 0
    SendNUIMessage({
        type = "ui",
        display = false
    })
    return true
end

return ProgressBar
