local cfg = _G.CONFIG_LIFECAYGAME or {
    Default_Pos = {0.5, -150, 0, 10}, 
    Default_FontSize = 18, 
    Background_Transparency = 0.3
}

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local folderName = "Trangthaidonhang"
local fileName = folderName .. "/" .. LocalPlayer.Name .. ".json"

local function ensureFolder()
    pcall(function()
        if not isfolder(folderName) then makefolder(folderName) end
    end)
end

local function loadCurrentAcc()
    local default = {don = "Đang chờ đơn...", pos = cfg.Default_Pos, fontSize = cfg.Default_FontSize, transparency = cfg.Background_Transparency, hasData = false}
    local success, content = pcall(function() if isfile(fileName) then return readfile(fileName) end end)
    if success and content then
        local ok, result = pcall(function() return HttpService:JSONDecode(content) end)
        if ok then 
            return {
                don = result.DonHang, 
                pos = result.Position or cfg.Default_Pos, 
                fontSize = result.FontSize or cfg.Default_FontSize,
                transparency = result.Transparency or cfg.Background_Transparency,
                hasData = true
            } 
        end
    end
    return default
end

local settings = loadCurrentAcc()

if settings.don == "notload" then 
    return 
end

local function saveCurrentAcc(data)
    ensureFolder()
    pcall(function()
        local payload = {
            UserName = LocalPlayer.Name,
            DonHang = data.don,
            Position = data.pos,
            FontSize = data.fontSize,
            Transparency = data.transparency
        }
        writefile(fileName, HttpService:JSONEncode(payload))
    end)
end

if game:GetService("CoreGui"):FindFirstChild("LifeCayGame_Final") then
    game:GetService("CoreGui").LifeCayGame_Final:Destroy()
end

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "LifeCayGame_Final"
sg.IgnoreGuiInset = true

local frame = Instance.new("Frame", sg)
frame.Position = UDim2.new(unpack(settings.pos))
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = settings.transparency
frame.Active = true
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 2
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 20
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
minBtn.ZIndex = 50

-- PHẦN FIX: Tách riêng chữ Đơn
local labelDonTitle = Instance.new("TextLabel", frame)
labelDonTitle.Size = UDim2.new(0, 50, 0, 30)
labelDonTitle.Position = UDim2.new(0, 12, 0, 10) -- Căn lề trái 12px
labelDonTitle.BackgroundTransparency = 1
labelDonTitle.Text = "Đơn:"
labelDonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
labelDonTitle.Font = Enum.Font.SourceSansBold
labelDonTitle.TextSize = 18
labelDonTitle.TextXAlignment = Enum.TextXAlignment.Left
labelDonTitle.ZIndex = 5

local editDon = Instance.new("TextBox", frame)
editDon.Size = UDim2.new(1, -95, 0, 30)
editDon.Position = UDim2.new(0, 65, 0, 10) -- Đẩy sang phải để không đè chữ Đơn
editDon.BackgroundTransparency = 1
editDon.Text = settings.don
editDon.TextColor3 = Color3.fromRGB(255, 255, 255) -- Sáng trắng rực rỡ
editDon.Font = Enum.Font.SourceSansBold
editDon.TextSize = settings.fontSize
editDon.TextXAlignment = Enum.TextXAlignment.Left
editDon.TextWrapped = true
editDon.TextEditable = false
editDon.ZIndex = 5

local mainContent = Instance.new("Frame", frame)
mainContent.Size = UDim2.new(1, 0, 0, 80)
mainContent.BackgroundTransparency = 1

local labelTen = Instance.new("TextLabel", mainContent)
labelTen.Size = UDim2.new(1, -40, 0, 30)
labelTen.BackgroundTransparency = 1
labelTen.Text = "Tên: " .. (string.sub(LocalPlayer.Name, 1, 3) .. "####")
labelTen.Font = Enum.Font.SourceSansBold
labelTen.TextSize = 18
labelTen.TextXAlignment = Enum.TextXAlignment.Left

local btnContainer = Instance.new("Frame", mainContent)
btnContainer.Size = UDim2.new(1, -30, 0, 32)
btnContainer.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", btnContainer)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 8)

local function createBtn(text, color)
    local b = Instance.new("TextButton", btnContainer)
    b.Size = UDim2.new(0.5, -4, 1, 0)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local editBtn = createBtn("Edit", Color3.fromRGB(45, 45, 45))
local doneBtn = createBtn("Done ✓", Color3.fromRGB(34, 139, 34))

local protector = Instance.new("TextButton", frame)
protector.BackgroundTransparency = 1
protector.Text = ""
protector.ZIndex = 10

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    frameStroke.Color = color
    labelTen.TextColor3 = color
end)

local isMin = settings.hasData
local function refreshLayout(noTween)
    local textHeight = game:GetService("TextService"):GetTextSize(editDon.Text, editDon.TextSize, editDon.Font, Vector2.new(205, 2000)).Y
    local finalEditHeight = math.max(30, textHeight)
    editDon.Size = UDim2.new(1, -95, 0, finalEditHeight)
    if isMin then
        mainContent.Visible = false; minBtn.Text = "+"
        local newSize = UDim2.new(0, 300, 0, finalEditHeight + 25)
        if noTween then frame.Size = newSize else frame:TweenSize(newSize, "Out", "Quint", 0.3, true) end
        protector.Size = UDim2.new(1, 0, 1, 0)
    else
        mainContent.Visible = true; minBtn.Text = "-"
        labelTen.Position = UDim2.new(0, 15, 0, finalEditHeight + 15)
        btnContainer.Position = UDim2.new(0, 15, 0, finalEditHeight + 50)
        local newSize = UDim2.new(0, 300, 0, finalEditHeight + 100)
        if noTween then frame.Size = newSize else frame:TweenSize(newSize, "Out", "Quint", 0.3, true) end
        protector.Size = UDim2.new(1, 0, 0, finalEditHeight + 45)
    end
end

local function finish()
    protector.Visible = true
    editDon.TextEditable = false
    editBtn.Text = "Edit"
    settings.don = editDon.Text
    refreshLayout()
    saveCurrentAcc(settings)
    if settings.don == "notload" then sg:Destroy() end
end

doneBtn.MouseButton1Click:Connect(function() 
    pcall(function() if isfile(fileName) then delfile(fileName) end end)
    sg:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function() isMin = not isMin refreshLayout() end)

editBtn.MouseButton1Click:Connect(function() 
    if editBtn.Text == "Edit" then 
        protector.Visible = false
        editDon.TextEditable = true
        editBtn.Text = "Xong"
        if editDon.Text == "Đang chờ đơn..." then editDon.Text = "" end
        editDon:CaptureFocus() 
    else 
        finish() 
    end 
end)

editDon:GetPropertyChangedSignal("Text"):Connect(refreshLayout)
editDon.FocusLost:Connect(function() finish() end)

local dragging, dragStart, startPos
protector.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if dragging then dragging = false settings.pos = {frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset} saveCurrentAcc(settings) end end)

task.spawn(function() refreshLayout(true); task.wait(0.1); refreshLayout(true) end)
