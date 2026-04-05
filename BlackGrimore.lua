--[[
    ╔══════════════════════════════════════════╗
    ║         Hyper Hub - WindUI            ║
    ║     Auto-Farm / ESP / Kill Aura          ║
    ╚══════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════════════════════════════
-- SERVICES & CONFIG (Key System)
-- ══════════════════════════════════════════════════════════════════
local Config       = { ApiUrl = "https://hyperhub-bot.onrender.com/verify", ApiToken = "lolilol980", ValidKeys = {} }
local Players      = game:GetService("Players")
local HTTP         = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Player       = Players.LocalPlayer
local PlayerGui    = Player:WaitForChild("PlayerGui")
local SaveFolder   = "HyperHub"
local SaveFile     = SaveFolder .. "/" .. tostring(Player.UserId) .. ".key"

local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end
local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end
local function AddHover(btn, normal, hover)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hover}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = normal}) end)
end
local function KeyFile(action, data)
    if action == "save" then
        pcall(function()
            if not isfolder(SaveFolder) then makefolder(SaveFolder) end
            writefile(SaveFile, data)
        end)
    elseif action == "load" then
        local ok, r = pcall(function()
            return (isfolder(SaveFolder) and isfile(SaveFile)) and readfile(SaveFile) or nil
        end)
        return ok and r or nil
    end
end
local function ValidateKey(cleanKey)
    for _, v in ipairs(Config.ValidKeys) do
        if cleanKey == v:upper() then return true, {valid=true, type="perm", expiresAt=nil} end
    end
    local ok, response = pcall(function()
        return HTTP:RequestAsync({
            Url = Config.ApiUrl, Method = "POST",
            Headers = {["Content-Type"]="application/json", ["Authorization"]=Config.ApiToken},
            Body = HTTP:JSONEncode({key=cleanKey, userId=tostring(Player.UserId), username=Player.Name}),
        })
    end)
    if not ok then return false, {reason="Connection error"} end
    local dok, data = pcall(function() return HTTP:JSONDecode(response.Body) end)
    if dok and data and data.valid then return true, data end
    return false, (dok and data) or {reason="Invalid key"}
end

-- ══════════════════════════════════════════════════════════════════
-- KEY SYSTEM GUI
-- ══════════════════════════════════════════════════════════════════
local IsActivating = false
local OldGui = PlayerGui:FindFirstChild("HyperHubKey")
if OldGui then OldGui:Destroy() end
local ScreenGui = Make("ScreenGui", {
    Name="HyperHubKey", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true,
    DisplayOrder = 999,
}, PlayerGui)
local Blur    = Make("BlurEffect", {Size=24}, game:GetService("Lighting"))
local Overlay = Make("Frame", {
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0.4,
    BorderSizePixel=0, ZIndex=5
}, ScreenGui)
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local function m(a,b) return IsMobile and a or b end
local W, H = m(260,420), m(355,480)
local KeyFrame = Make("Frame", {
    Size=UDim2.fromOffset(W,H),
    Position=UDim2.new(0.5,-W/2,0.5,-H/2),
    BackgroundColor3=Color3.fromRGB(18,18,26),
    BorderSizePixel=0, ZIndex=10, Active=true,
    ClipsDescendants=false,
}, ScreenGui)
Make("UICorner", {CornerRadius=UDim.new(0,14)}, KeyFrame)
Make("UIStroke", {Color=Color3.fromRGB(60,60,90), Thickness=1.5}, KeyFrame)
-- Drag
local dragging, dragStart, startPos = false, nil, nil
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, KeyFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
-- Topbar
local Topbar = Make("Frame", {
    Size=UDim2.new(1,0,0,44),
    BackgroundColor3=Color3.fromRGB(22,22,34),
    BorderSizePixel=0, ZIndex=11
}, KeyFrame)
Make("UICorner", {CornerRadius=UDim.new(0,14)}, Topbar)
Make("Frame", {
    Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=Color3.fromRGB(22,22,34), BorderSizePixel=0, ZIndex=11
}, Topbar)
Make("Frame", {
    Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,44),
    BackgroundColor3=Color3.fromRGB(35,35,55), BorderSizePixel=0, ZIndex=11
}, KeyFrame)
-- Bouton fermer Mac
local MacBtn = Make("Frame", {
    Size=UDim2.fromOffset(13,13), Position=UDim2.new(0,12,0.5,-6),
    BackgroundColor3=Color3.fromHex("#F4695F"), BorderSizePixel=0, ZIndex=12
}, Topbar)
Make("UICorner", {CornerRadius=UDim.new(1,0)}, MacBtn)
local MacClose = Make("TextButton", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="", ZIndex=13, AutoButtonColor=false
}, MacBtn)
MacClose.MouseButton1Click:Connect(function()
    Tween(KeyFrame, {BackgroundTransparency=1}, 0.3)
    Tween(Overlay,  {BackgroundTransparency=1}, 0.3)
    task.wait(0.35)
    ScreenGui:Destroy()
    Blur:Destroy()
end)
-- Tag v3.0
local TagFrame = Make("Frame", {
    Size=UDim2.fromOffset(m(48,64), 22),
    Position=UDim2.new(1, m(-58,-76), 0.5, -11),
    BackgroundColor3=Color3.fromRGB(99,102,241),
    BorderSizePixel=0, ZIndex=12
}, Topbar)
Make("UICorner", {CornerRadius=UDim.new(0,6)}, TagFrame)
Make("TextLabel", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="⚡ v3.0", TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold, TextSize=m(8,11),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=13
}, TagFrame)
-- Contenu
local Content = Make("Frame", {
    Size=UDim2.new(1,-36,1,-58),
    Position=UDim2.new(0,18,0,52),
    BackgroundTransparency=1, ZIndex=11,
    ClipsDescendants=false,
}, KeyFrame)
Make("UIListLayout", {
    SortOrder=Enum.SortOrder.LayoutOrder,
    FillDirection=Enum.FillDirection.Vertical,
    HorizontalAlignment=Enum.HorizontalAlignment.Center,
    VerticalAlignment=Enum.VerticalAlignment.Top,
    Padding=UDim.new(0, m(6,10)),
}, Content)
Make("TextLabel", {
    Size=UDim2.new(1,0,0,m(22,30)), BackgroundTransparency=1,
    Text="⚡ Hyper Hub", TextColor3=Color3.fromRGB(99,102,241),
    Font=Enum.Font.GothamBold, TextSize=m(15,22),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=12, LayoutOrder=1,
}, Content)
Make("TextLabel", {
    Size=UDim2.new(1,0,0,m(34,50)), BackgroundTransparency=1,
    Text="🔑", TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold, TextSize=m(26,38),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=12, LayoutOrder=2,
}, Content)
Make("TextLabel", {
    Size=UDim2.new(1,0,0,m(20,28)), BackgroundTransparency=1,
    Text="License Activation", TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold, TextSize=m(13,20),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=12, LayoutOrder=3,
}, Content)
Make("TextLabel", {
    Size=UDim2.new(1,0,0,m(14,20)), BackgroundTransparency=1,
    Text="Enter your license key to continue",
    TextColor3=Color3.fromRGB(100,100,130),
    Font=Enum.Font.Gotham, TextSize=m(8,12),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=12, LayoutOrder=4,
}, Content)
-- Input
local InputContainer = Make("Frame", {
    Size=UDim2.new(1,0,0,m(34,46)),
    BackgroundColor3=Color3.fromRGB(26,26,40),
    BorderSizePixel=0, ZIndex=12, LayoutOrder=5,
}, Content)
Make("UICorner", {CornerRadius=UDim.new(0,10)}, InputContainer)
local InputStroke = Make("UIStroke", {Color=Color3.fromRGB(45,45,68), Thickness=1.2}, InputContainer)
local savedKey      = KeyFile("load")
local savedKeyClean = savedKey and savedKey:upper():gsub("%s+","") or nil
local InputBox = Make("TextBox", {
    Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1,
    Text=savedKeyClean or "",
    PlaceholderText="Ex: XXXX-XXXX-XXXX-XXXX",
    TextColor3=Color3.new(1,1,1),
    PlaceholderColor3=Color3.fromRGB(70,70,95),
    Font=Enum.Font.GothamBold, TextSize=m(10,13),
    ClearTextOnFocus=false, ZIndex=13,
}, InputContainer)
InputBox.Focused:Connect(function()
    Tween(InputStroke, {Color=Color3.fromRGB(99,102,241)})
    Tween(InputContainer, {BackgroundColor3=Color3.fromRGB(30,30,50)})
end)
InputBox.FocusLost:Connect(function()
    Tween(InputStroke, {Color=Color3.fromRGB(45,45,68)})
    Tween(InputContainer, {BackgroundColor3=Color3.fromRGB(26,26,40)})
end)
-- Bouton Verify
local VerifyBtn = Make("TextButton", {
    Size=UDim2.new(1,0,0,m(34,48)),
    BackgroundColor3=Color3.fromRGB(99,102,241),
    Text="Verify Key", TextColor3=Color3.new(1,1,1),
    Font=Enum.Font.GothamBold, TextSize=m(11,15),
    BorderSizePixel=0, AutoButtonColor=false,
    ZIndex=12, LayoutOrder=6,
}, Content)
Make("UICorner", {CornerRadius=UDim.new(0,10)}, VerifyBtn)
Make("UIGradient", {
    Color=ColorSequence.new(Color3.fromHex("#6366f1"), Color3.fromHex("#8b5cf6")),
    Rotation=90
}, VerifyBtn)
AddHover(VerifyBtn, Color3.fromRGB(99,102,241), Color3.fromRGB(120,124,255))
-- Status
local StatusLabel = Make("TextLabel", {
    Size=UDim2.new(1,0,0,m(20,24)), BackgroundTransparency=1,
    Text="", TextColor3=Color3.fromRGB(100,100,130),
    Font=Enum.Font.GothamBold, TextSize=m(9,12),
    TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=12, LayoutOrder=7,
}, Content)
-- Bouton Close
local CloseBtn = Make("TextButton", {
    Size=UDim2.new(1,0,0,m(30,42)),
    BackgroundColor3=Color3.fromRGB(28,28,42),
    Text="", BorderSizePixel=0, AutoButtonColor=false,
    ZIndex=12, LayoutOrder=8,
}, Content)
Make("UICorner", {CornerRadius=UDim.new(0,10)}, CloseBtn)
local closeStroke = Make("UIStroke", {Color=Color3.fromRGB(60,60,90), Thickness=1.2}, CloseBtn)
Make("TextLabel", {
    Size=UDim2.new(0,20,1,0), Position=UDim2.new(0.5,-36,0,0),
    BackgroundTransparency=1, Text="✕",
    TextColor3=Color3.fromRGB(200,80,80),
    Font=Enum.Font.GothamBold, TextSize=m(12,15),
    TextXAlignment=Enum.TextXAlignment.Center, ZIndex=13
}, CloseBtn)
Make("TextLabel", {
    Size=UDim2.new(0,60,1,0), Position=UDim2.new(0.5,-16,0,0),
    BackgroundTransparency=1, Text="Close",
    TextColor3=Color3.fromRGB(180,180,210),
    Font=Enum.Font.GothamBold, TextSize=m(10,13),
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13
}, CloseBtn)
CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(50,22,22)})
    Tween(closeStroke, {Color=Color3.fromRGB(180,50,50)})
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, {BackgroundColor3=Color3.fromRGB(28,28,42)})
    Tween(closeStroke, {Color=Color3.fromRGB(60,60,90)})
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(KeyFrame, {BackgroundTransparency=1}, 0.3)
    Tween(Overlay,  {BackgroundTransparency=1}, 0.3)
    task.wait(0.35)
    ScreenGui:Destroy()
    Blur:Destroy()
end)
-- Discord
Make("TextLabel", {
    Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
    Text="discord.gg/hyperhub",
    TextColor3=Color3.fromRGB(50,50,75),
    Font=Enum.Font.Gotham, TextSize=m(8,10),
    TextXAlignment=Enum.TextXAlignment.Center,
    ZIndex=12, LayoutOrder=9,
}, Content)

-- ══════════════════════════════════════════════════════════════════
-- CALLBACK POST-VALIDATION : lance le hub principal
-- ══════════════════════════════════════════════════════════════════
local function OnKeyValidated(licenseData)
    -- ════════════════════════════════════════════════════════════════
    -- CHARGEMENT DE WINDUI
    -- ════════════════════════════════════════════════════════════════
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    -- ════════════════════════════════════════════════════════════════
    -- SERVICES ROBLOX
    -- ════════════════════════════════════════════════════════════════
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    -- ════════════════════════════════════════════════════════════════
    -- VARIABLES GLOBALES
    -- ════════════════════════════════════════════════════════════════
    local AutoFarmEnabled = false
    local AutoFarmSpeed = 0.2
    local selectedMobName = ""
    local selectedToolName = ""
    local lastFarmHeight = 0
    local originalToolSize = nil
    local originalMobSizes = {}
    local floatingBodyPos = nil
    local jumpConnection = nil
    local connections = {}
    -- ════════════════════════════════════════════════════════════════
    -- CONFIGURATION WINDUI
    -- ════════════════════════════════════════════════════════════════
    WindUI:SetTheme("Dark")
    -- ════════════════════════════════════════════════════════════════
    -- FONCTIONS UTILITAIRES
    -- ════════════════════════════════════════════════════════════════
    local function findBadEntitiesFolder()
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Folder") and string.match(child.Name, "^BadEntities%d+$") then
                return child
            end
        end
        return nil
    end
    local function getMobNames()
        local names = {}
        local folder = findBadEntitiesFolder()
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                if mob:FindFirstChildOfClass("Humanoid") then
                    if not table.find(names, mob.Name) then
                        table.insert(names, mob.Name)
                    end
                end
            end
        end
        if #names == 0 then
            table.insert(names, "Aucun mob trouve")
        end
        return names
    end
    local function getToolNames()
        local tools = {}
        local searchLocations = {}
        if LocalPlayer.Character then
            table.insert(searchLocations, {LocalPlayer.Character, "Character"})
        end
        if LocalPlayer:FindFirstChild("Backpack") then
            table.insert(searchLocations, {LocalPlayer.Backpack, "Backpack"})
        end
        if LocalPlayer:FindFirstChild("StarterGear") then
            table.insert(searchLocations, {LocalPlayer.StarterGear, "StarterGear"})
        end
        for _, locInfo in ipairs(searchLocations) do
            local location = locInfo[1]
            local locName = locInfo[2]
            for _, obj in ipairs(location:GetChildren()) do
                if obj:IsA("Tool") or obj:IsA("HopperBin") then
                    table.insert(tools, obj.Name .. " [" .. locName .. "]")
                end
            end
            for _, obj in ipairs(location:GetDescendants()) do
                if obj:IsA("Tool") or obj:IsA("HopperBin") then
                    local alreadyFound = false
                    for _, t in ipairs(tools) do
                        if t == obj.Name .. " [" .. locName .. "]" then
                            alreadyFound = true
                            break
                        end
                    end
                    if not alreadyFound then
                        table.insert(tools, obj.Name .. " [" .. locName .. "]")
                    end
                end
            end
        end
        if #tools == 0 then
            table.insert(tools, "Aucun tool trouve")
        end
        return tools
    end
    local function getToolByName(name)
        local cleanName = name:match("^(.+) %[") or name
        local searchLocations = {}
        if LocalPlayer.Character then
            table.insert(searchLocations, LocalPlayer.Character)
        end
        if LocalPlayer:FindFirstChild("Backpack") then
            table.insert(searchLocations, LocalPlayer.Backpack)
        end
        for _, location in ipairs(searchLocations) do
            for _, obj in ipairs(location:GetDescendants()) do
                if (obj:IsA("Tool") or obj:IsA("HopperBin")) and obj.Name == cleanName then
                    return obj
                end
            end
        end
        return nil
    end
    local function equipTool(tool)
        if tool and tool:IsA("Tool") then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end
    local function applyToolHitbox(toolName)
        if originalToolSize then
            pcall(function()
                local oldTool = getToolByName(selectedToolName)
                if oldTool then
                    local handle = oldTool:FindFirstChild("Handle")
                    if handle then
                        handle.Size = originalToolSize
                    end
                end
            end)
            originalToolSize = nil
        end
        local tool = getToolByName(toolName)
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                originalToolSize = handle.Size
                handle.Size = Vector3.new(100, 100, 100)
                handle.Transparency = 0.8
                handle.CanCollide = false
            end
        end
    end
    local function restoreMobHitboxes()
        for mob, originalSize in pairs(originalMobSizes) do
            pcall(function()
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = originalSize
                end
            end)
        end
        originalMobSizes = {}
    end
    local function restoreToolHitbox()
        if originalToolSize and selectedToolName ~= "" then
            pcall(function()
                local tool = getToolByName(selectedToolName)
                if tool then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        handle.Size = originalToolSize
                        handle.Transparency = 0
                    end
                end
            end)
            originalToolSize = nil
        end
    end
    local function removeFloat()
        if floatingBodyPos then
            pcall(function()
                floatingBodyPos:Destroy()
            end)
            floatingBodyPos = nil
        end
    end
    local function floatAtHeight(height)
        removeFloat()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bp = Instance.new("BodyPosition")
        bp.Name = "HubFloat"
        bp.MaxForce = Vector3.new(0, math.huge, 0)
        bp.P = 15000
        bp.D = 1000
        bp.Position = Vector3.new(hrp.Position.X, height, hrp.Position.Z)
        bp.Parent = hrp
        floatingBodyPos = bp
    end
    -- ════════════════════════════════════════════════════════════════
    -- BOUCLE AUTO-FARM
    -- ════════════════════════════════════════════════════════════════
    task.spawn(function()
        while true do
            task.wait(0.1)
            if AutoFarmEnabled and selectedMobName ~= "" and selectedMobName ~= "Aucun mob trouve" then
                local folder = findBadEntitiesFolder()
                if not folder then continue end
                local myChar = LocalPlayer.Character
                if not myChar then
                    LocalPlayer.CharacterAdded:Wait()
                    task.wait(2)
                    myChar = LocalPlayer.Character
                end
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then
                    LocalPlayer.CharacterAdded:Wait()
                    task.wait(2)
                    myChar = LocalPlayer.Character
                    myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if not myHRP then continue end
                end
                local humanoid = myChar:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then
                    removeFloat()
                    LocalPlayer.CharacterAdded:Wait()
                    task.wait(2)
                    continue
                end
                if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                    local tool = getToolByName(selectedToolName)
                    if not tool then
                        removeFloat()
                        pcall(function()
                            local hum = myChar:FindFirstChildOfClass("Humanoid")
                            if hum then hum.Health = 0 end
                        end)
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(2)
                        continue
                    end
                end
                if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                    local tool = getToolByName(selectedToolName)
                    if tool then
                        pcall(function()
                            for _, part in ipairs(tool:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                end
                            end
                        end)
                    end
                end
                local targetMob = nil
                local closestDist = math.huge
                for _, mob in ipairs(folder:GetChildren()) do
                    if mob.Name == selectedMobName then
                        local hum = mob:FindFirstChildOfClass("Humanoid")
                        local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
                        if hum and hum.Health > 0 and hrp then
                            local dist = (myHRP.Position - hrp.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                targetMob = mob
                            end
                        end
                    end
                end
                if not targetMob then
                    for _, mob in ipairs(folder:GetChildren()) do
                        if mob.Name == selectedMobName then
                            local hum = mob:FindFirstChildOfClass("Humanoid")
                            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
                            if hum and hum.Health > 0 and hrp then
                                targetMob = mob
                                break
                            end
                        end
                    end
                end
                if targetMob then
                    local hum = targetMob:FindFirstChildOfClass("Humanoid")
                    local hrp = targetMob:FindFirstChild("HumanoidRootPart") or targetMob:FindFirstChild("Head")
                    if hum and hrp and hum.Health > 0 then
                        removeFloat()
                        if not originalMobSizes[targetMob] then
                            local mobHRP = targetMob:FindFirstChild("HumanoidRootPart")
                            if mobHRP then
                                originalMobSizes[targetMob] = mobHRP.Size
                                mobHRP.Size = Vector3.new(100, 100, 100)
                                mobHRP.Transparency = 1
                                mobHRP.CanCollide = false
                            end
                        end
                        local targetPos = hrp.Position + Vector3.new(0, 20, 0)
                        myHRP.CFrame = CFrame.new(targetPos)
                        myHRP.Velocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        lastFarmHeight = targetPos.Y
                        floatAtHeight(lastFarmHeight)
                        if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                            local tool = getToolByName(selectedToolName)
                            if tool then
                                if tool.Parent ~= myChar then
                                    equipTool(tool)
                                    task.wait(0.1)
                                end
                                pcall(function() tool:Activate() end)
                            end
                        end
                        task.wait(AutoFarmSpeed)
                    else
                        task.wait(0.1)
                    end
                else
                    if lastFarmHeight > 0 then
                        if not floatingBodyPos then
                            floatAtHeight(lastFarmHeight)
                        end
                        myHRP.Velocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    task.wait(0.5)
                end
            end
        end
    end)
    -- ════════════════════════════════════════════════════════════════
    -- CREATION DE LA FENETRE
    -- ════════════════════════════════════════════════════════════════
    local Window = WindUI:CreateWindow({
        Title = "Hyper Hub",
        Icon = "bot",
        Folder = "UltimateHub",
        Transparent = true,
        OpenButton = {
            Title = "Hub",
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            Scale = 0.5,
        },
        Topbar = {
            Height = 44,
            ButtonsType = "Mac",
        },
    })
    -- ════════════════════════════════════════════════════════════════
    -- TIMER / LICENSE TAG
    -- ════════════════════════════════════════════════════════════════
    local licenseType = licenseData and licenseData.type or "perm"
    local expiresAt   = licenseData and licenseData.expiresAt
    local isPerm      = (licenseType == "perm")
    local function GetRemaining()
        if not expiresAt then return "??:??:??" end
        local r = math.max(0, expiresAt - os.time())
        return string.format("%02d:%02d:%02d", math.floor(r/3600), math.floor((r%3600)/60), r%60)
    end
    Window:Tag({Title = "v3.0", Icon = "zap", Color = Color3.fromHex("#6366f1"), Border = true})
    local licenseTag = Window:Tag({
        Title = isPerm and "🔑 Permanent Key" or ("⏱ " .. GetRemaining()),
        Icon  = isPerm and "shield-check" or "clock",
        Color = isPerm and Color3.fromHex("#22c55e") or Color3.fromHex("#f59e0b"),
        Border = true,
    })
    if not isPerm then
        task.spawn(function()
            while task.wait(1) do
                pcall(function() licenseTag:SetTitle("⏱ " .. GetRemaining()) end)
            end
        end)
    end
    -- ════════════════════════════════════════════════════════════════
    -- SECTIONS & TABS
    -- ════════════════════════════════════════════════════════════════
    local MainSection = Window:Section({
        Title = "Principal",
        Opened = true,
    })
    local SettingsSection = Window:Section({
        Title = "Parametres",
        Opened = true,
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET ACCUEIL
    -- ════════════════════════════════════════════════════════════════
    local HomeTab = MainSection:Tab({
        Title = "Accueil",
        Icon = "home",
    })
    HomeTab:Section({
        Title = "Bienvenue, " .. LocalPlayer.DisplayName .. " !",
        TextSize = 22,
        FontWeight = Enum.FontWeight.Bold,
    })
    HomeTab:Section({
        Title = "Username: @" .. LocalPlayer.Name .. "  |  UserID: " .. LocalPlayer.UserId,
        TextSize = 14,
        TextTransparency = 0.35,
    })
    HomeTab:Divider()
    HomeTab:Paragraph({
        Title = "Hyper Hub",
        Desc = "Auto-Farm | Kill Aura | ESP | Tools\nProfite bien du hub !",
        Image = "zap",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET AUTO-FARM
    -- ════════════════════════════════════════════════════════════════
    local CombatTab = MainSection:Tab({
        Title = "Auto-Farm",
        Icon = "swords",
    })
    CombatTab:Section({
        Title = "Auto-Farm",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    local mobDropdown = CombatTab:Dropdown({
        Title = "Mob cible",
        Values = getMobNames(),
        Value = "",
        Callback = function(value)
            selectedMobName = value
        end,
    })
    CombatTab:Button({
        Title = "Rafraichir les mobs",
        Icon = "refresh-cw",
        Callback = function()
            local newMobs = getMobNames()
            mobDropdown:Refresh(newMobs)
            warn("[Hub] Mobs rafraichis: " .. #newMobs)
        end,
    })
    CombatTab:Toggle({
        Title = "Activer Auto-Farm",
        Value = false,
        Callback = function(state)
            AutoFarmEnabled = state
            if not state then
                removeFloat()
                restoreMobHitboxes()
                restoreToolHitbox()
            else
                if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                    applyToolHitbox(selectedToolName)
                end
            end
        end,
    })
    CombatTab:Slider({
        Title = "Vitesse d'attaque",
        Value = {
            Min = 0.05,
            Max = 2,
            Default = 0.2,
        },
        Step = 0.05,
        Callback = function(value)
            AutoFarmSpeed = value
        end,
    })
    CombatTab:Divider()
    CombatTab:Section({
        Title = "Tools",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    local toolDropdown = CombatTab:Dropdown({
        Title = "Tool a utiliser",
        Values = getToolNames(),
        Value = "",
        Callback = function(value)
            restoreToolHitbox()
            selectedToolName = value
            if value ~= "Aucun tool trouve" then
                applyToolHitbox(value)
            end
        end,
    })
    CombatTab:Button({
        Title = "Rafraichir les tools",
        Icon = "refresh-cw",
        Callback = function()
            local newTools = getToolNames()
            toolDropdown:Refresh(newTools)
            warn("[Hub] Tools trouves: " .. #newTools)
        end,
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET MONEY / ANTI-BAN
    -- ════════════════════════════════════════════════════════════════
    local MoneyTab = MainSection:Tab({
        Title = "Money",
        Icon = "coins",
    })
    local TweenServiceAB = game:GetService("TweenService")
    local AntiBan = {
        questsCompleted = 0,
        sessionStart = tick(),
        totalSessionQuests = 0,
        lastQuestTime = 0,
        cyclesSinceBreak = 0,
        CONFIG = {
            MIN_CYCLE_DELAY = 3,
            MAX_CYCLE_DELAY = 8,
            BREAK_EVERY = math.random(8, 15),
            BREAK_MIN = 30,
            BREAK_MAX = 90,
            AFK_EVERY = math.random(30, 50),
            AFK_DURATION_MIN = 10,
            AFK_DURATION_MAX = 30,
            MAX_PER_SESSION = math.random(80, 150),
            HOURLY_LIMIT = 25,
            TWEEN_SPEED = 20,
        }
    }
    function AntiBan:NaturalDelay(min, max)
        local base = min + (max - min) * math.random()
        local noise = (math.random() - 0.5) * 0.2 * base
        return base + noise
    end
    function AntiBan:CanDoQuest()
        if self.totalSessionQuests >= self.CONFIG.MAX_PER_SESSION then
            return false, "session_limit"
        end
        local now = tick()
        local oneHourAgo = now - 3600
        if self.lastQuestTime > oneHourAgo then
            local questsThisHour = self.questsCompleted
            if questsThisHour >= self.CONFIG.HOURLY_LIMIT then
                return false, "hourly_limit"
            end
        else
            self.questsCompleted = 0
        end
        return true, "ok"
    end
    function AntiBan:HandleBreaks()
        self.cyclesSinceBreak = self.cyclesSinceBreak + 1
        if self.cyclesSinceBreak >= self.CONFIG.BREAK_EVERY then
            self.cyclesSinceBreak = 0
            self.CONFIG.BREAK_EVERY = math.random(8, 15)
            local breakTime = self:NaturalDelay(self.CONFIG.BREAK_MIN, self.CONFIG.BREAK_MAX)
            return breakTime, "break"
        end
        local chance = math.random(1, 100)
        if chance <= 5 then
            return math.random(5, 15), "distraction"
        elseif chance <= 15 then
            return math.random(2, 5), "hesitation"
        end
        return 0, "none"
    end
    function AntiBan:TweenToPosition(hrp, targetPos, callback)
        local distance = (hrp.Position - targetPos).Magnitude
        local tweenTime = distance / self.CONFIG.TWEEN_SPEED
        tweenTime = tweenTime * self:NaturalDelay(0.8, 1.3)
        if tweenTime < 2 then tweenTime = 2 end
        if tweenTime > 30 then tweenTime = 30 end
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tween = TweenServiceAB:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        local bodyPos = Instance.new("BodyPosition")
        bodyPos.Name = "TweenFloat"
        bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
        bodyPos.P = 50000
        bodyPos.D = 5000
        bodyPos.Position = hrp.Position
        bodyPos.Parent = hrp
        local updateConnection
        updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if hrp and hrp.Parent then
                bodyPos.Position = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
            end
        end)
        tween:Play()
        if callback then
            task.spawn(function()
                task.wait(tweenTime * 0.7)
                callback(tweenTime * 0.3)
            end)
        end
        tween.Completed:Wait()
        updateConnection:Disconnect()
        bodyPos:Destroy()
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        return tweenTime
    end
    local AutoMoneyEnabled = false
    MoneyTab:Toggle({
        Title = "Deliver GreenJuice lvl 125",
        Value = false,
        Callback = function(state)
            AutoMoneyEnabled = state
            if state then
                AntiBan.questsCompleted = 0
                AntiBan.sessionStart = tick()
                AntiBan.totalSessionQuests = 0
                AntiBan.cyclesSinceBreak = 0
                AntiBan.CONFIG.BREAK_EVERY = math.random(8, 15)
                AntiBan.CONFIG.AFK_EVERY = math.random(30, 50)
                AntiBan.CONFIG.MAX_PER_SESSION = math.random(80, 150)
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer
                    local MainRemote = game:GetService("ReplicatedStorage").MainRemote
                    local cachedAstaParts = {}
                    local cachedAstaPosition = nil
                    local lastCacheTime = 0
                    local function refreshAsta()
                        if tick() - lastCacheTime < 10 then return end
                        cachedAstaParts = {}
                        cachedAstaPosition = nil
                        pcall(function()
                            local npcsFolder = workspace:FindFirstChild("NPCs")
                            if not npcsFolder then return end
                            local asta = npcsFolder:FindFirstChild("Asta")
                            if not asta then return end
                            for _, p in ipairs(asta:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    table.insert(cachedAstaParts, p)
                                end
                            end
                            local astaPart = asta:FindFirstChild("HumanoidRootPart")
                                or asta:FindFirstChild("Head")
                                or asta:FindFirstChild("Torso")
                            if not astaPart and asta:IsA("Model") then
                                astaPart = asta.PrimaryPart
                            end
                            if not astaPart and #cachedAstaParts > 0 then
                                astaPart = cachedAstaParts[1]
                            end
                            if astaPart then
                                cachedAstaPosition = astaPart.Position + Vector3.new(0, 0, 3)
                            end
                        end)
                        lastCacheTime = tick()
                    end
                    local function touchAstaProgressive(hrp)
                        if #cachedAstaParts == 0 then return false end
                        local touched = false
                        pcall(function()
                            local shuffled = {}
                            for i, v in ipairs(cachedAstaParts) do shuffled[i] = v end
                            for i = #shuffled, 2, -1 do
                                local j = math.random(1, i)
                                shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
                            end
                            local numToTouch = math.random(1, math.ceil(#shuffled / 2))
                            for i = 1, numToTouch do
                                local astaPart = shuffled[i]
                                if astaPart and astaPart.Parent then
                                    firetouchinterest(hrp, astaPart, 0)
                                    task.wait(AntiBan:NaturalDelay(0.05, 0.15))
                                    firetouchinterest(hrp, astaPart, 1)
                                    touched = true
                                end
                            end
                        end)
                        return touched
                    end
                    local function SendMoneyQuest()
                        pcall(function()
                            MainRemote:FireServer(
                                "pcgamer4",
                                {
                                    ["Extra"] = "DeliverGreenJuice",
                                    ["Type"] = "questpls",
                                    ["NpcName"] = "Yuno"
                                }
                            )
                        end)
                    end
                    local startPosition = nil
                    while AutoMoneyEnabled do
                        local canDo, reason = AntiBan:CanDoQuest()
                        if not canDo then
                            if reason == "session_limit" then
                                AutoMoneyEnabled = false
                                break
                            elseif reason == "hourly_limit" then
                                task.wait(AntiBan:NaturalDelay(30, 60))
                                continue
                            end
                        end
                        local character = player.Character
                        if not character then
                            player.CharacterAdded:Wait()
                            task.wait(2)
                            continue
                        end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then
                            player.CharacterAdded:Wait()
                            task.wait(2)
                            continue
                        end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            player.CharacterAdded:Wait()
                            task.wait(2)
                            continue
                        end
                        refreshAsta()
                        if not cachedAstaPosition then
                            task.wait(2)
                            continue
                        end
                        if not startPosition then
                            startPosition = hrp.Position
                        end
                        SendMoneyQuest()
                        task.wait(AntiBan:NaturalDelay(1, 3))
                        if not AutoMoneyEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        refreshAsta()
                        if not cachedAstaPosition then continue end
                        AntiBan:TweenToPosition(hrp, cachedAstaPosition, function(remainingTime)
                            local touchStart = tick()
                            while (tick() - touchStart) < remainingTime and AutoMoneyEnabled do
                                local char = player.Character
                                local h = char and char:FindFirstChild("HumanoidRootPart")
                                if h then touchAstaProgressive(h) end
                                task.wait(AntiBan:NaturalDelay(0.3, 0.8))
                            end
                        end)
                        if not AutoMoneyEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for i = 1, math.random(2, 5) do
                                touchAstaProgressive(hrp)
                                task.wait(AntiBan:NaturalDelay(0.2, 0.5))
                            end
                        end
                        task.wait(AntiBan:NaturalDelay(1, 3))
                        if not AutoMoneyEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if hrp and startPosition then
                            AntiBan:TweenToPosition(hrp, startPosition, nil)
                        end
                        AntiBan.questsCompleted = AntiBan.questsCompleted + 1
                        AntiBan.totalSessionQuests = AntiBan.totalSessionQuests + 1
                        AntiBan.lastQuestTime = tick()
                        if not AutoMoneyEnabled then break end
                        task.wait(AntiBan:NaturalDelay(
                            AntiBan.CONFIG.MIN_CYCLE_DELAY,
                            AntiBan.CONFIG.MAX_CYCLE_DELAY
                        ))
                        local pauseTime, pauseType = AntiBan:HandleBreaks()
                        if pauseTime > 0 then
                            task.wait(pauseTime)
                        end
                        if not AutoMoneyEnabled then break end
                    end
                end)
            end
        end,
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET TELEPORT
    -- ════════════════════════════════════════════════════════════════
    local TeleportTab = MainSection:Tab({
        Title = "Teleport",
        Icon = "map-pin",
    })
    TeleportTab:Section({
        Title = "Teleport",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    local TeleportLocations = {
        {Name = "Magic Tree", Position = Vector3.new(-1037.99, 67.40, -2099)},
        {Name = "Clever Village", Position = Vector3.new(-0.98, 45.30, -404.23)},
        {Name = "Tower", Position = Vector3.new(85.70, 55.07, -1093.18)},
    }
    local selectedTeleportName = nil
    local selectedTeleportPosition = nil
    local function getTeleportNames()
        local names = {}
        for _, location in ipairs(TeleportLocations) do
            table.insert(names, location.Name)
        end
        return names
    end
    local function getPositionByName(name)
        for _, location in ipairs(TeleportLocations) do
            if location.Name == name then
                return location.Position
            end
        end
        return nil
    end
    local teleportNames = getTeleportNames()
    if #teleportNames > 0 then
        selectedTeleportName = teleportNames[1]
        selectedTeleportPosition = getPositionByName(selectedTeleportName)
    end
    TeleportTab:Dropdown({
        Title = "Destination",
        Values = teleportNames,
        Value = selectedTeleportName or "",
        Callback = function(value)
            selectedTeleportName = value
            selectedTeleportPosition = getPositionByName(value)
        end,
    })
    TeleportTab:Button({
        Title = "Teleporter",
        Callback = function()
            if selectedTeleportPosition then
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(selectedTeleportPosition)
                end
            end
        end,
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET STATS
    -- ════════════════════════════════════════════════════════════════
    local StatsTab = MainSection:Tab({
        Title = "Stats",
        Icon = "chart-no-axes-combined",
    })
    StatsTab:Section({
        Title = "Auto Stats",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    local StatsRunning = {}
    local function SendStat(statName)
        pcall(function()
            local args = {
                [1] = "addPoints",
                [2] = statName,
                [3] = 1,
                [4] = false
            }
            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
        end)
    end
    local function StartStatLoop(statName)
        if StatsRunning[statName] then return end
        StatsRunning[statName] = true
        task.spawn(function()
            while StatsRunning[statName] do
                SendStat(statName)
                task.wait(0)
            end
        end)
    end
    local function StopStatLoop(statName)
        StatsRunning[statName] = false
    end
    StatsTab:Toggle({
        Title = "Auto Power",
        Value = false,
        Callback = function(state)
            if state then StartStatLoop("Power") else StopStatLoop("Power") end
        end,
    })
    StatsTab:Toggle({
        Title = "Auto Vitality",
        Value = false,
        Callback = function(state)
            if state then StartStatLoop("Vitality") else StopStatLoop("Vitality") end
        end,
    })
    StatsTab:Toggle({
        Title = "Auto Dexterity",
        Value = false,
        Callback = function(state)
            if state then StartStatLoop("Dexterity") else StopStatLoop("Dexterity") end
        end,
    })
    StatsTab:Toggle({
        Title = "Auto Mana",
        Value = false,
        Callback = function(state)
            if state then StartStatLoop("Mana") else StopStatLoop("Mana") end
        end,
    })
    StatsTab:Toggle({
        Title = "Auto Luck",
        Value = false,
        Callback = function(state)
            if state then StartStatLoop("Luck") else StopStatLoop("Luck") end
        end,
    })
    -- ════════════════════════════════════════════════════════════════
    -- ONGLET PARAMETRES
    -- ════════════════════════════════════════════════════════════════
    local SettingsTab = SettingsSection:Tab({
        Title = "Parametres",
        Icon = "settings",
    })
    SettingsTab:Section({
        Title = "Apparence",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    local themeNames = {}
    local ok, themes = pcall(function() return WindUI:GetThemes() end)
    if ok and themes then
        for themeName, _ in pairs(themes) do
            table.insert(themeNames, themeName)
        end
        table.sort(themeNames)
    end
    if #themeNames == 0 then
        themeNames = {"Dark", "Light", "Mocha", "Aqua"}
    end
    local ThemeDropdown = SettingsTab:Dropdown({
        Title = "Theme",
        Values = themeNames,
        Value = "Dark",
        Callback = function(selectedTheme)
            WindUI:SetTheme(selectedTheme)
            pcall(function() ThemeDropdown:Close() end)
        end,
    })
    SettingsTab:Slider({
        Title = "Transparence",
        Value = {
            Min = 0,
            Max = 1,
            Default = 0.2,
        },
        Step = 0.1,
        Callback = function(value)
            pcall(function() Window:SetBackgroundTransparency(value) end)
        end,
    })
    SettingsTab:Divider()
    SettingsTab:Section({
        Title = "Systeme",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    SettingsTab:Button({
        Title = "Detruire le Hub",
        Icon = "trash-2",
        Color = Color3.fromHex("#ff4830"),
        Callback = function()
            Window:Dialog({
                Title = "Confirmation",
                Content = "Veux-tu vraiment fermer le hub ?",
                Buttons = {
                    {
                        Title = "Oui",
                        Variant = "Primary",
                        Callback = function()
                            AutoFarmEnabled = false
                            removeFloat()
                            restoreMobHitboxes()
                            restoreToolHitbox()
                            if jumpConnection then
                                jumpConnection:Disconnect()
                            end
                            for _, conn in ipairs(connections) do
                                pcall(function() conn:Disconnect() end)
                            end
                            pcall(function()
                                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if hum then hum.WalkSpeed = 16 end
                            end)
                            Window:Destroy()
                        end,
                    },
                    {
                        Title = "Non",
                        Variant = "Tertiary",
                    },
                },
            })
        end,
    })
    -- ════════════════════════════════════════════════════════════════
    -- CALLBACKS WINDOW
    -- ════════════════════════════════════════════════════════════════
    Window:OnDestroy(function()
        AutoFarmEnabled = false
        removeFloat()
        restoreMobHitboxes()
        restoreToolHitbox()
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
        end
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        pcall(function()
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end)
        warn("[Hub] Hub detruit proprement.")
    end)
    warn("[Hub] Hyper Hub charge avec succes!")
end

-- ══════════════════════════════════════════════════════════════════
-- LOGIQUE DE VÉRIFICATION
-- ══════════════════════════════════════════════════════════════════
local function TryVerify(key)
    if key == "" then
        StatusLabel.Text = "⚠ Please enter a license key"
        StatusLabel.TextColor3 = Color3.fromRGB(234,179,8)
        return
    end
    if IsActivating then return end
    IsActivating = true
    VerifyBtn.Text = "Verifying..."
    Tween(VerifyBtn, {BackgroundColor3=Color3.fromRGB(50,50,80)})
    StatusLabel.Text = "Connecting to server..."
    StatusLabel.TextColor3 = Color3.fromRGB(100,100,140)
    task.spawn(function()
        local cleanKey = key:upper():gsub("%s+","")
        local valid, data = ValidateKey(cleanKey)
        if valid then
            KeyFile("save", cleanKey)
            StatusLabel.Text = "✔ Valid key! Loading..."
            StatusLabel.TextColor3 = Color3.fromRGB(34,197,94)
            VerifyBtn.Text = "✔ Activated!"
            Tween(VerifyBtn, {BackgroundColor3=Color3.fromRGB(34,197,94)})
            task.wait(0.8)
            Tween(KeyFrame, {BackgroundTransparency=1, Position=UDim2.new(0.5,-W/2,0.42,-H/2)}, 0.4)
            Tween(Overlay,  {BackgroundTransparency=1}, 0.4)
            task.wait(0.45)
            ScreenGui:Destroy()
            Blur:Destroy()
            OnKeyValidated(data)
        else
            local reason = (data and data.reason) or "Invalid license key."
            StatusLabel.Text = "✘ " .. reason
            StatusLabel.TextColor3 = Color3.fromRGB(239,68,68)
            VerifyBtn.Text = "Verify Key"
            Tween(VerifyBtn, {BackgroundColor3=Color3.fromRGB(99,102,241)})
            if savedKeyClean then pcall(function() writefile(SaveFile,"") end) end
            IsActivating = false
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- ✅ MODIFICATION : le GUI s'affiche TOUJOURS en premier.
-- Si une clé sauvegardée existe, elle est pré-remplie dans l'input
-- et un message indique qu'elle est prête à être vérifiée.
-- L'utilisateur clique lui-même sur "Verify Key".
-- ══════════════════════════════════════════════════════════════════
if savedKeyClean then
    StatusLabel.Text = "🔑 Saved key detected — click Verify"
    StatusLabel.TextColor3 = Color3.fromRGB(99,102,241)
end

VerifyBtn.MouseButton1Click:Connect(function() TryVerify(InputBox.Text) end)
