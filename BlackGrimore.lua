--[[
    ╔══════════════════════════════════════════╗
    ║         Hyper Hub - WindUI               ║
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
    -- ONGLET QUEST
    -- Contient les 3 nouveaux toggles du Script B
    -- ════════════════════════════════════════════════════════════════
    local QuestTab = MainSection:Tab({
        Title = "Quest",
        Icon = "scroll-text",
    })
        QuestTab:Section({
        Title = "Quests",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

-- ─── Toggle 1 : Defeat Thief (Johnny) ────────────────────────
local AutoThiefEnabled = false

    QuestTab:Toggle({
    Title = "Defeat Thief lvl 200",
    Value = false,
    Callback = function(state)
        AutoThiefEnabled = state
        if state then
            task.spawn(function()
                local function SendThiefQuest()
                    pcall(function()
                        local args = {
                            [1] = "pcgamer4",
                            [2] = {
                                ["Extra"]   = "DefeatThief",
                                ["Type"]    = "questpls",
                                ["NpcName"] = "Johnny"
                            }
                        }
                        game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                    end)
                end

                while AutoThiefEnabled do
                    SendThiefQuest()
                    task.wait(5)
                    if not AutoThiefEnabled then break end
                end
            end)
        end
    end,
})

-- ─── Toggle 2 : Defeat Fire Boar (Renna) ─────────────────────
local AutoFireBoarEnabled = false

    QuestTab:Toggle({
    Title = "Defeat Fire Boar lvl 300",
    Value = false,
    Callback = function(state)
        AutoFireBoarEnabled = state
        if state then
            task.spawn(function()
                local function SendFireBoarQuest()
                    pcall(function()
                        local args = {
                            [1] = "pcgamer4",
                            [2] = {
                                ["Extra"]   = "DefeatFire Boar",
                                ["Type"]    = "questpls",
                                ["NpcName"] = "Renna"
                            }
                        }
                        game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                    end)
                end

                while AutoFireBoarEnabled do
                    SendFireBoarQuest()
                    task.wait(5)
                    if not AutoFireBoarEnabled then break end
                end
            end)
        end
    end,
})

-- ─── Toggle 4 : Defeat Golem (Davrqwy) ───────────────────────
local AutoGolemEnabled = false

    QuestTab:Toggle({
    Title = "Defeat Golem lvl 1200",
    Value = false,
    Callback = function(state)
        AutoGolemEnabled = state
        if state then
            task.spawn(function()
                local function SendGolemQuest()
                    pcall(function()
                        local args = {
                            [1] = "pcgamer4",
                            [2] = {
                                ["Extra"]   = "DefeatGolem",
                                ["Type"]    = "questpls",
                                ["NpcName"] = "Davrqwy"
                            }
                        }
                        game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                    end)
                end

                while AutoGolemEnabled do
                    SendGolemQuest()
                    task.wait(5)
                    if not AutoGolemEnabled then break end
                end
            end)
        end
    end,
})

-- ─── Toggle : Defeat Security Golem ───────────
local AutoSecurityGolemEnabled = false

OtherQuestTab:Toggle({
    Title = "Defeat Security Golem lvl 2500",
    Value = false,
    Callback = function(state)
        AutoSecurityGolemEnabled = state
        if state then
            task.spawn(function()
                local function SendSecurityGolemQuest()
                    pcall(function()
                        local args = {
                            [1] = "pcgamer4",
                            [2] = {
                                ["Extra"]   = "DefeatSecurity Golem",
                                ["Type"]    = "questpls",
                                ["NpcName"] = "ahmedBOOM234"
                            }
                        }
                        game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                    end)
                end

                while AutoSecurityGolemEnabled do
                    SendSecurityGolemQuest()
                    task.wait(5)
                    if not AutoSecurityGolemEnabled then break end
                end
            end)
        end
    end,
})

    -- ════════════════════════════════════════════════════════════════
    -- ONGLET OTHER QUEST (ex-Money, sans Auto Delivery GreenJuice)
    -- Contient les 3 nouveaux toggles du Script B
    -- ════════════════════════════════════════════════════════════════
    local OtherQuestTab = MainSection:Tab({
        Title = "Other Quest",
        Icon = "scroll-text",
    })
    OtherQuestTab:Section({
        Title = "Other Quests",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    -- ─── Toggle 1 : Cut Woods lvl 1 ───────────────────────────────
    local AutoWoodEnabled = false

    OtherQuestTab:Toggle({
        Title = "Cut Woods lvl 1",
        Value = false,
        Callback = function(state)
            AutoWoodEnabled = state
            if state then
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer

                    local TreePositions = {
                        {Position = Vector3.new(-92.12, 45.75, -526.68),  LookAt = Vector3.new(-92.12,  45.75, -527.68)},
                        {Position = Vector3.new(-106.17, 45.75, -526.59), LookAt = Vector3.new(-106.17, 45.75, -527.59)},
                        {Position = Vector3.new(-92.00, 45.75, -537.22),  LookAt = Vector3.new(-92.00,  45.75, -538.22)},
                        {Position = Vector3.new(-106.09, 45.75, -535.37), LookAt = Vector3.new(-106.09, 45.75, -536.37)},
                        {Position = Vector3.new(-92.12, 45.75, -526.68),  LookAt = Vector3.new(-92.12,  45.75, -527.68)},
                    }
                    local NpcPosition = Vector3.new(-118.06, 45.25, -532.47)
                    local NpcLookAt   = Vector3.new(-119.06, 45.25, -532.47)

                    local function SendWoodQuest()
                        pcall(function()
                            local args = {
                                [1] = "pcgamer4",
                                [2] = {
                                    ["Extra"]   = "CutWoods",
                                    ["Type"]    = "questpls",
                                    ["NpcName"] = "Father Orfi"
                                }
                            }
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end

                    local function findMAxe()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            local tool = backpack:FindFirstChild("MAxe")
                            if tool then return tool end
                        end
                        local char = player.Character
                        if char then
                            local tool = char:FindFirstChild("MAxe")
                            if tool then return tool end
                        end
                        return nil
                    end

                    while AutoWoodEnabled do
                        local character = player.Character
                        if not character then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait(); task.wait(1); continue end

                        -- Etape 1 : NPC + quete
                        hrp.CFrame = CFrame.new(NpcPosition, NpcLookAt)
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        task.wait(0.5)
                        SendWoodQuest()
                        task.wait(2)
                        if not AutoWoodEnabled then break end

                        -- Etape 2 : Equiper MAxe
                        local axe = nil
                        local waitTime = 0
                        while not axe and waitTime < 5 and AutoWoodEnabled do
                            axe = findMAxe()
                            if not axe then task.wait(0.3); waitTime = waitTime + 0.3 end
                        end
                        if not axe or not AutoWoodEnabled then continue end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid and axe.Parent ~= character then
                            humanoid:EquipTool(axe)
                            task.wait(0.3)
                        end
                        if not AutoWoodEnabled then break end

                        -- Etape 3 : Couper les 5 arbres
                        for _, treeData in ipairs(TreePositions) do
                            if not AutoWoodEnabled then break end
                            character = player.Character
                            hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then break end
                            axe = findMAxe()
                            if axe then
                                if axe.Parent ~= character then
                                    humanoid:EquipTool(axe)
                                    task.wait(0.2)
                                end
                            end
                            hrp.CFrame = CFrame.new(treeData.Position, treeData.LookAt)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            task.wait()
                            axe = findMAxe()
                            if axe then
                                pcall(function() axe:Activate() end)
                            end
                            task.wait(2)
                        end
                        if not AutoWoodEnabled then break end

                        -- Etape 4 : Rendre au NPC
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        hrp.CFrame = CFrame.new(NpcPosition, NpcLookAt)
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        task.wait(3)
                        if not AutoWoodEnabled then break end
                    end
                end)
            end
        end,
    })
    
    -- ─── Toggle 2 : Auto Farm Potatoes lvl 30 ─────────────────────
    local AutoPotatoEnabled = false

    OtherQuestTab:Toggle({
        Title = "Auto Farm Potatoes lvl 30",
        Value = false,
        Callback = function(state)
            AutoPotatoEnabled = state
            if state then
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer

                    local function getChrisPosition()
                        local npcsFolder = workspace:FindFirstChild("NPCs")
                        if not npcsFolder then return nil end
                        local chris = npcsFolder:FindFirstChild("Chris")
                        if not chris then return nil end
                        if chris.PrimaryPart then return chris.PrimaryPart.CFrame end
                        local hrp = chris:FindFirstChild("HumanoidRootPart")
                        if hrp then return hrp.CFrame end
                        local head = chris:FindFirstChild("Head")
                        if head then return head.CFrame end
                        for _, part in ipairs(chris:GetDescendants()) do
                            if part:IsA("BasePart") then return part.CFrame end
                        end
                        return nil
                    end

                    local function SendPotatoQuest()
                        pcall(function()
                            local args = {
                                [1] = "pcgamer4",
                                [2] = {
                                    ["Extra"]   = "GetPotatoes",
                                    ["Type"]    = "questpls",
                                    ["NpcName"] = "Chris"
                                }
                            }
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end

                    local function findHoe()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            local tool = backpack:FindFirstChild("Hoe")
                            if tool then return tool end
                        end
                        local char = player.Character
                        if char then
                            local tool = char:FindFirstChild("Hoe")
                            if tool then return tool end
                        end
                        return nil
                    end

                    local function findPotatoes()
                        local potatoes = {}
                        pcall(function()
                            local theMap = workspace:FindFirstChild("THEMAP")
                            if not theMap then return end
                            local hagePotatoes = theMap:FindFirstChild("HAGEPOTATOES")
                            if not hagePotatoes then return end
                            for _, obj in ipairs(hagePotatoes:GetChildren()) do
                                if obj.Name == "BATATAautomatica" and (obj:IsA("MeshPart") or obj:IsA("BasePart")) then
                                    table.insert(potatoes, obj)
                                end
                            end
                        end)
                        return potatoes
                    end

                    local HARVEST_NEEDED = 10

                    while AutoPotatoEnabled do
                        local character = player.Character
                        if not character then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait(); task.wait(1); continue end

                        -- Etape 1 : Chris + quete
                        local chrisCFrame = getChrisPosition()
                        if chrisCFrame then
                            local chrisPos = chrisCFrame.Position
                            hrp.CFrame = CFrame.new(chrisPos + Vector3.new(0, 0, 3), chrisPos)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                        task.wait(0.5)
                        SendPotatoQuest()
                        task.wait(2)
                        if not AutoPotatoEnabled then break end

                        -- Etape 2 : Equiper Hoe
                        local hoe = nil
                        local waitTime = 0
                        while not hoe and waitTime < 5 and AutoPotatoEnabled do
                            hoe = findHoe()
                            if not hoe then task.wait(0.3); waitTime = waitTime + 0.3 end
                        end
                        if not hoe or not AutoPotatoEnabled then continue end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid and hoe.Parent ~= character then
                            humanoid:EquipTool(hoe)
                            task.wait(0.3)
                        end
                        if not AutoPotatoEnabled then break end

                        -- Etape 3 : Recolter 10 fois (10 x 3 = 30 patates)
                        local harvestCount = 0
                        while harvestCount < HARVEST_NEEDED and AutoPotatoEnabled do
                            character = player.Character
                            hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then break end

                            local potatoes = findPotatoes()
                            if #potatoes == 0 then task.wait(1); continue end

                            for _, potato in ipairs(potatoes) do
                                if not AutoPotatoEnabled then break end
                                if harvestCount >= HARVEST_NEEDED then break end
                                character = player.Character
                                hrp = character and character:FindFirstChild("HumanoidRootPart")
                                if not hrp then break end
                                humanoid = character:FindFirstChildOfClass("Humanoid")
                                if not humanoid or humanoid.Health <= 0 then break end

                                local potatoPos = potato.Position
                                local behindPos = potatoPos + Vector3.new(0, 0, 3)
                                hrp.CFrame = CFrame.new(behindPos, potatoPos)
                                hrp.Velocity = Vector3.new(0,0,0)
                                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                task.wait(0.3)

                                hoe = findHoe()
                                if hoe then
                                    if hoe.Parent ~= character then
                                        humanoid:EquipTool(hoe)
                                        task.wait(0.2)
                                    end
                                    pcall(function() hoe:Activate() end)
                                end
                                harvestCount = harvestCount + 1
                                task.wait(1)
                            end
                        end
                        if not AutoPotatoEnabled then break end

                        -- Etape 4 : Rendre a Chris
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        chrisCFrame = getChrisPosition()
                        if chrisCFrame then
                            local chrisPos = chrisCFrame.Position
                            hrp.CFrame = CFrame.new(chrisPos + Vector3.new(0, 0, 3), chrisPos)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                        task.wait(3)
                        if not AutoPotatoEnabled then break end
                    end
                end)
            end
        end,
    })

    -- ─── Toggle 3 : Auto Farm Steak lvl 60 ────────────────────────
    local AutoSteakEnabled = false
    -- Table globale des citizens deja livres (persiste meme si toggle off/on)
    local allDeliveredCitizens = {}

    OtherQuestTab:Toggle({
        Title = "Auto Farm Steak lvl 60",
        Value = false,
        Callback = function(state)
            AutoSteakEnabled = state
            if state then
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer

                    local function getChefJackPosition()
                        local npcsFolder = workspace:FindFirstChild("NPCs")
                        if not npcsFolder then return nil end
                        local jack = npcsFolder:FindFirstChild("Chef Jack")
                        if not jack then return nil end
                        if jack.PrimaryPart then return jack.PrimaryPart.CFrame end
                        local hrp = jack:FindFirstChild("HumanoidRootPart")
                        if hrp then return hrp.CFrame end
                        local head = jack:FindFirstChild("Head")
                        if head then return head.CFrame end
                        for _, part in ipairs(jack:GetDescendants()) do
                            if part:IsA("BasePart") then return part.CFrame end
                        end
                        return nil
                    end

                    local function SendSteakQuest()
                        pcall(function()
                            local args = {
                                [1] = "pcgamer4",
                                [2] = {
                                    ["Extra"]   = "DeliverSteak",
                                    ["Type"]    = "questpls",
                                    ["NpcName"] = "Chef Jack"
                                }
                            }
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end

                    local function findPlate()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in ipairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") and (tool.Name == "Plat" or tool.Name == "Plate" or tool.Name:lower():find("plat")) then
                                    return tool
                                end
                            end
                        end
                        local char = player.Character
                        if char then
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") and (tool.Name == "Plat" or tool.Name == "Plate" or tool.Name:lower():find("plat")) then
                                    return tool
                                end
                            end
                        end
                        return nil
                    end

                    local function findQuestTool()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in ipairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") then return tool end
                            end
                        end
                        local char = player.Character
                        if char then
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") and tool.Name ~= "Fist" then return tool end
                            end
                        end
                        return nil
                    end

                    local function getCitizenID(npc)
                        local part = npc:FindFirstChild("HumanoidRootPart")
                            or npc:FindFirstChild("Head")
                            or npc:FindFirstChild("Torso")
                        if part then
                            local pos = part.Position
                            return string.format("%.1f_%.1f_%.1f", pos.X, pos.Y, pos.Z)
                        end
                        return tostring(npc:GetFullName())
                    end

                    local function findAvailableCitizens()
                        local citizens = {}
                        pcall(function()
                            local wandering = workspace:FindFirstChild("WanderingNPCs")
                            if not wandering then return end
                            for _, npc in ipairs(wandering:GetChildren()) do
                                if npc.Name == "Citizen" then
                                    local citizenID = getCitizenID(npc)
                                    if allDeliveredCitizens[npc] or allDeliveredCitizens[citizenID] then
                                        continue
                                    end
                                    local npcPart = npc:FindFirstChild("HumanoidRootPart")
                                        or npc:FindFirstChild("Head")
                                        or npc:FindFirstChild("Torso")
                                        or npc:FindFirstChild("UpperTorso")
                                    if not npcPart and npc:IsA("Model") then npcPart = npc.PrimaryPart end
                                    if not npcPart then
                                        for _, part in ipairs(npc:GetDescendants()) do
                                            if part:IsA("BasePart") then npcPart = part; break end
                                        end
                                    end
                                    if npcPart then
                                        table.insert(citizens, {Model = npc, Part = npcPart, ID = citizenID})
                                    end
                                end
                            end
                        end)
                        return citizens
                    end

                    local function countTotalCitizens()
                        local count = 0
                        pcall(function()
                            local wandering = workspace:FindFirstChild("WanderingNPCs")
                            if not wandering then return end
                            for _, npc in ipairs(wandering:GetChildren()) do
                                if npc.Name == "Citizen" then count = count + 1 end
                            end
                        end)
                        return count
                    end

                    local function countDelivered()
                        local count = 0
                        for _ in pairs(allDeliveredCitizens) do count = count + 1 end
                        return math.floor(count / 2)
                    end

                    while AutoSteakEnabled do
                        local character = player.Character
                        if not character then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait(); task.wait(1); continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait(); task.wait(1); continue end

                        -- Reset si tous livres
                        local total = countTotalCitizens()
                        local delivered = countDelivered()
                        if delivered >= total and total > 0 then
                            allDeliveredCitizens = {}
                        end
                        local available = findAvailableCitizens()
                        if #available < 5 then
                            allDeliveredCitizens = {}
                            task.wait(0.5)
                        end

                        -- Etape 1 : Chef Jack + quete
                        local jackCFrame = getChefJackPosition()
                        if jackCFrame then
                            local jackPos = jackCFrame.Position
                            hrp.CFrame = CFrame.new(jackPos + Vector3.new(0, 0, 3), jackPos)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                        task.wait(0.5)
                        SendSteakQuest()
                        task.wait(3)
                        if not AutoSteakEnabled then break end

                        -- Etape 2 : Equiper le tool
                        local plate = nil
                        local waitTime = 0
                        while not plate and waitTime < 10 and AutoSteakEnabled do
                            plate = findPlate()
                            if not plate then plate = findQuestTool() end
                            if not plate then task.wait(0.5); waitTime = waitTime + 0.5 end
                        end
                        if not plate then task.wait(1); continue end
                        if not AutoSteakEnabled then break end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            if plate.Parent ~= character then humanoid:EquipTool(plate) end
                            task.wait(0.5)
                        end
                        if not AutoSteakEnabled then break end

                        -- Etape 3 : Livrer a 5 Citizens jamais livres
                        local deliverCount = 0
                        while deliverCount < 5 and AutoSteakEnabled do
                            character = player.Character
                            hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then break end

                            local citizens = findAvailableCitizens()
                            if #citizens == 0 then
                                allDeliveredCitizens = {}
                                task.wait(0.5)
                                citizens = findAvailableCitizens()
                                if #citizens == 0 then task.wait(1); continue end
                            end

                            for _, citizen in ipairs(citizens) do
                                if not AutoSteakEnabled then break end
                                if deliverCount >= 5 then break end
                                if allDeliveredCitizens[citizen.Model] or allDeliveredCitizens[citizen.ID] then continue end

                                character = player.Character
                                hrp = character and character:FindFirstChild("HumanoidRootPart")
                                if not hrp then break end
                                humanoid = character:FindFirstChildOfClass("Humanoid")
                                if not humanoid or humanoid.Health <= 0 then break end

                                plate = findPlate() or findQuestTool()
                                if plate then
                                    if plate.Parent ~= character then
                                        humanoid:EquipTool(plate)
                                        task.wait(0.3)
                                    end
                                end

                                local citizenPos = citizen.Part.Position
                                hrp.CFrame = CFrame.new(citizenPos + Vector3.new(0, 0, -3), citizenPos)
                                hrp.Velocity = Vector3.new(0,0,0)
                                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)

                                pcall(function()
                                    firetouchinterest(hrp, citizen.Part, 0)
                                    task.wait(0.1)
                                    firetouchinterest(hrp, citizen.Part, 1)
                                end)

                                allDeliveredCitizens[citizen.Model] = true
                                allDeliveredCitizens[citizen.ID]    = true
                                deliverCount = deliverCount + 1
                                task.wait(0.5)
                            end
                        end
                        if not AutoSteakEnabled then break end

                        -- Etape 4 : Rendre a Chef Jack
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        jackCFrame = getChefJackPosition()
                        if jackCFrame then
                            local jackPos = jackCFrame.Position
                            hrp.CFrame = CFrame.new(jackPos + Vector3.new(0, 0, 3), jackPos)
                            hrp.Velocity = Vector3.new(0,0,0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        end
                        task.wait(3)
                        if not AutoSteakEnabled then break end
                    end
                end)
            end
        end,
    })

-- ─── Toggle : Block NotificationFrame ─────────────────────
local BlockNotifEnabled = true
local _notifConns = {}
local _notifHeartbeat = nil
local _origSetCore = nil

OtherQuestTab:Toggle({
    Title = "Block Notifications",
    Value = true,
    Callback = function(state)
        BlockNotifEnabled = state

        if state then
            task.spawn(function()
                local Players    = game:GetService("Players")
                local CoreGui    = game:GetService("CoreGui")
                local RunService = game:GetService("RunService")
                local StarterGui = game:GetService("StarterGui")

                local LocalPlayer = Players.LocalPlayer
                local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

                local TARGETS = {
                    "NotificationFrame",
                    "PopupFrame",
                }

                local function isTarget(obj)
                    if not obj or not obj.Name then return false end
                    for _, name in ipairs(TARGETS) do
                        if obj.Name == name then return true end
                    end
                    return false
                end

                local function BlockObj(obj)
                    if not obj then return end
                    pcall(function()
                        if obj:IsA("GuiObject") then
                            obj.Visible = false
                            obj.BackgroundTransparency = 1
                            obj.Position = UDim2.new(99, 0, 99, 0)
                        end
                        for _, c in ipairs(obj:GetDescendants()) do
                            pcall(function()
                                if c:IsA("GuiObject") then
                                    c.Visible = false
                                    c.BackgroundTransparency = 1
                                end
                                if c:IsA("TextLabel") or c:IsA("TextButton") then
                                    c.TextTransparency = 1
                                end
                                if c:IsA("ImageLabel") or c:IsA("ImageButton") then
                                    c.ImageTransparency = 1
                                end
                            end)
                        end
                        task.delay(0.02, function()
                            pcall(function()
                                if obj and obj.Parent then obj:Destroy() end
                            end)
                        end)
                    end)
                end

                -- Scan initial
                pcall(function()
                    for _, obj in ipairs(PlayerGui:GetDescendants()) do
                        if isTarget(obj) then BlockObj(obj) end
                    end
                end)
                pcall(function()
                    for _, obj in ipairs(CoreGui:GetDescendants()) do
                        if isTarget(obj) then BlockObj(obj) end
                    end
                end)

                -- DescendantAdded PlayerGui
                local c1 = PlayerGui.DescendantAdded:Connect(function(obj)
                    if isTarget(obj) then BlockObj(obj) end
                end)
                table.insert(_notifConns, c1)

                -- DescendantAdded CoreGui
                pcall(function()
                    local c2 = CoreGui.DescendantAdded:Connect(function(obj)
                        if isTarget(obj) then BlockObj(obj) end
                    end)
                    table.insert(_notifConns, c2)
                end)

                -- ChildAdded PlayerGui (nouveaux ScreenGui)
                local c3 = PlayerGui.ChildAdded:Connect(function(child)
                    if child:IsA("ScreenGui") then
                        local c4 = child.DescendantAdded:Connect(function(obj)
                            if isTarget(obj) then BlockObj(obj) end
                        end)
                        table.insert(_notifConns, c4)
                        task.wait(0.05)
                        for _, obj in ipairs(child:GetDescendants()) do
                            if isTarget(obj) then BlockObj(obj) end
                        end
                    end
                end)
                table.insert(_notifConns, c3)

                -- ScreenGui existants
                pcall(function()
                    for _, sg in ipairs(PlayerGui:GetChildren()) do
                        if sg:IsA("ScreenGui") then
                            local c5 = sg.DescendantAdded:Connect(function(obj)
                                if isTarget(obj) then BlockObj(obj) end
                            end)
                            table.insert(_notifConns, c5)
                        end
                    end
                end)

                -- Hook SetCore
                _origSetCore = StarterGui.SetCore
                pcall(function()
                    StarterGui.SetCore = function(self, t, ...)
                        if t == "SendNotification" then return end
                        return _origSetCore(self, t, ...)
                    end
                end)

                -- Heartbeat 0.2s — filet de sécurité
                local timer = 0
                _notifHeartbeat = RunService.Heartbeat:Connect(function(dt)
                    if not BlockNotifEnabled then return end
                    timer = timer + dt
                    if timer < 0.2 then return end
                    timer = 0
                    pcall(function()
                        for _, obj in ipairs(PlayerGui:GetDescendants()) do
                            if isTarget(obj) then BlockObj(obj) end
                        end
                    end)
                end)

            end)

        else
            -- ARRÊT — Déconnecter tout
            for _, conn in ipairs(_notifConns) do
                pcall(function() conn:Disconnect() end)
            end
            _notifConns = {}

            if _notifHeartbeat then
                pcall(function() _notifHeartbeat:Disconnect() end)
                _notifHeartbeat = nil
            end

            -- Restaurer SetCore
            pcall(function()
                local StarterGui = game:GetService("StarterGui")
                if _origSetCore then
                    StarterGui.SetCore = _origSetCore
                    _origSetCore = nil
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
        {Name = "Magic Tree",     Position = Vector3.new(-1037.99, 67.40, -2099)},
        {Name = "Clever Village", Position = Vector3.new(-0.98,    45.30,  -404.23)},
        {Name = "Tower",          Position = Vector3.new(85.70,    55.07, -1093.18)},
    }
    local selectedTeleportName     = nil
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
            if location.Name == name then return location.Position end
        end
        return nil
    end
    local teleportNames = getTeleportNames()
    if #teleportNames > 0 then
        selectedTeleportName     = teleportNames[1]
        selectedTeleportPosition = getPositionByName(selectedTeleportName)
    end
    TeleportTab:Dropdown({
        Title = "Destination",
        Values = teleportNames,
        Value = selectedTeleportName or "",
        Callback = function(value)
            selectedTeleportName     = value
            selectedTeleportPosition = getPositionByName(value)
        end,
    })
    TeleportTab:Button({
        Title = "Teleporter",
        Callback = function()
            if selectedTeleportPosition then
                local character = game:GetService("Players").LocalPlayer.Character
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
            local args = {[1]="addPoints", [2]=statName, [3]=1, [4]=false}
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
        Title = "Auto Power",     Value = false,
        Callback = function(state) if state then StartStatLoop("Power")      else StopStatLoop("Power")      end end,
    })
    StatsTab:Toggle({
        Title = "Auto Vitality",  Value = false,
        Callback = function(state) if state then StartStatLoop("Vitality")   else StopStatLoop("Vitality")   end end,
    })
    StatsTab:Toggle({
        Title = "Auto Dexterity", Value = false,
        Callback = function(state) if state then StartStatLoop("Dexterity")  else StopStatLoop("Dexterity")  end end,
    })
    StatsTab:Toggle({
        Title = "Auto Mana",      Value = false,
        Callback = function(state) if state then StartStatLoop("Mana")       else StopStatLoop("Mana")       end end,
    })
    StatsTab:Toggle({
        Title = "Auto Luck",      Value = false,
        Callback = function(state) if state then StartStatLoop("Luck")       else StopStatLoop("Luck")       end end,
    })

    -- ════════════════════════════════════════════════════════════════
    -- CALLBACKS WINDOW (destruction propre)
    -- ════════════════════════════════════════════════════════════════
    Window:OnDestroy(function()
        AutoFarmEnabled  = false
        AutoWoodEnabled  = false
        AutoPotatoEnabled = false
        AutoSteakEnabled = false
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
-- AFFICHAGE DU GUI (clé pré-remplie si sauvegardée)
-- ══════════════════════════════════════════════════════════════════
if savedKeyClean then
    StatusLabel.Text = "🔑 Saved key detected — click Verify"
    StatusLabel.TextColor3 = Color3.fromRGB(99,102,241)
end

VerifyBtn.MouseButton1Click:Connect(function() TryVerify(InputBox.Text) end)