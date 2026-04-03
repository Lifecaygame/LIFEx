local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

Lighting.Ambient = Color3.fromRGB(180, 180, 180)
Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
Lighting.Brightness = 2
Lighting.GlobalShadows = false
Lighting.FogEnd = 1e6

local function FastSmooth(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("Texture") or child:IsA("Decal") then child:Destroy() end
        end
    end
end

local lp = Players.LocalPlayer
local RANGE = Vector3.new(100, 100, 100)

task.spawn(function()
    local all = Workspace:GetDescendants()
    for i, v in pairs(all) do
        if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or Workspace) then
            v.Transparency = 1
        end
        if i % 1000 == 0 then task.wait() end
    end

    while true do
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            
            local params = OverlapParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {char}
            
            local partsInZone = Workspace:GetPartBoundsInBox(CFrame.new(pos), RANGE, params)
            
            for _, obj in pairs(partsInZone) do
                if obj.Transparency ~= 0 then
                    obj.Transparency = 0
                    FastSmooth(obj)
                end
            end
        end
        task.wait(0.3)
    end
end)
