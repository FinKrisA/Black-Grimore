-- ==================== HYPER HUB v3.0 - WindUI FINAL ====================
local Config = {
    ApiUrl = "https://hyperhub-bot.onrender.com/verify",
    ApiToken = "lolilol980",
    ValidKeys = {},
}
local Players = game:GetService("Players")
local HTTP = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local SaveFolder = "HyperHub"
local SaveFile = SaveFolder .. "/" .. tostring(Player.UserId) .. ".key"

local function SaveKey(key)
    pcall(function()
        if not isfolder(SaveFolder) then makefolder(SaveFolder) end
        writefile(SaveFile, key)
    end)
end

local function LoadSavedKey()
    local ok, result = pcall(function()
        if isfolder(SaveFolder) and isfile(SaveFile) then
            return readfile(SaveFile)
        end
        return nil
    end)
    return ok and result or nil
end

local function ValidateKey(cleanKey)
    for _, validKey in ipairs(Config.ValidKeys) do
        if cleanKey == validKey:upper() then
            return true, {valid = true, type = "perm", expiresAt = nil}
        end
    end
    local success, response = pcall(function()
        return HTTP:RequestAsync({
            Url = Config.ApiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = Config.ApiToken,
            },
            Body = HTTP:JSONEncode({
                key = cleanKey,
                userId = tostring(Player.UserId),
                username = Player.Name,
            }),
        })
    end)
    if not success then return false, {reason = "Erreur de connexion"} end
    local ok, data = pcall(function()
        return HTTP:JSONDecode(response.Body)
    end)
    if ok and data and data.valid then
        return true, data
    end
    return false, (ok and data) or {reason = "Cle invalide"}
end

-- ================================================================
-- GAME IDs
-- ================================================================
local GAME_CDR = 110314964312495
local GAME_BG  = 4632627223

local isCarDrivingRussia = (game.PlaceId == GAME_CDR)
local isBlackGrimoire    = (game.PlaceId == GAME_BG)

-- ================================================================
-- CAR DRIVING RUSSIA HUB
-- ================================================================
local function BuildCarDrivingRussiaHub(Window, isPerm)

    local farming = false
    local loopCount = 0
    local inkUtils, zapravka2, endBase = nil, nil, nil

    pcall(function()
        inkUtils = workspace:WaitForChild("Utilities", 5):WaitForChild("Inkasator", 5)
        zapravka2 = inkUtils:WaitForChild("StartPoints", 5):WaitForChild("Zapravka2", 5)
        endBase = inkUtils:WaitForChild("EndPoints", 5):WaitForChild("Base", 5)
    end)

    local function getCar()
        local cars = workspace:FindFirstChild("Cars")
        if not cars then return nil end
        return cars:FindFirstChild(Player.Name .. "sCar")
    end

    local function waitForCar(timeout)
        local t = 0
        while t < (timeout or 8) do
            local car = getCar()
            if car and car:FindFirstChild("DriveSeat") then return car end
            task.wait(0.3)
            t = t + 0.3
        end
        return getCar()
    end

    local function sitInDriveSeat()
        local car = getCar()
        if not car then return false end
        local seat = car:FindFirstChild("DriveSeat")
        if not seat then return false end
        local char = Player.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        if hum.SeatPart == seat then return true end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0) end
        task.wait(0.2)
        seat:Sit(hum)
        task.wait(0.5)
        return hum.SeatPart == seat
    end

    local function teleportCar(targetCF)
        local car = getCar()
        if not car then return false end
        local seat = car:FindFirstChild("DriveSeat")
        if not seat then return false end
        car.PrimaryPart = seat
        local parts = {}
        for _, p in ipairs(car:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(parts, {Part = p, WasAnchored = p.Anchored})
            end
        end
        local _, targetYRot, _ = targetCF:ToEulerAnglesYXZ()
        local uprightCF = CFrame.new(targetCF.Position) * CFrame.Angles(0, targetYRot, 0)
        for _, d in ipairs(parts) do pcall(function()
            d.Part.AssemblyLinearVelocity = Vector3.zero
            d.Part.AssemblyAngularVelocity = Vector3.zero
            d.Part.Velocity = Vector3.zero
            d.Part.RotVelocity = Vector3.zero
        end) end
        for _, d in ipairs(parts) do pcall(function() d.Part.Anchored = true end) end
        task.wait(0.05)
        for i = 1, 8 do pcall(function() car:PivotTo(uprightCF) end) task.wait() end
        task.wait(0.2)
        for _, d in ipairs(parts) do pcall(function()
            d.Part.AssemblyLinearVelocity = Vector3.zero
            d.Part.AssemblyAngularVelocity = Vector3.zero
            d.Part.Velocity = Vector3.zero
            d.Part.RotVelocity = Vector3.zero
        end) end
        for _, d in ipairs(parts) do pcall(function() d.Part.Anchored = d.WasAnchored end) end
        task.spawn(function()
            for i = 1, 10 do
                pcall(function()
                    seat.AssemblyLinearVelocity = Vector3.zero
                    seat.AssemblyAngularVelocity = Vector3.zero
                    seat.Velocity = Vector3.zero
                    seat.RotVelocity = Vector3.zero
                    car:PivotTo(uprightCF)
                end)
                task.wait()
            end
        end)
        task.wait(0.3)
        return true
    end

    local function findAndFirePrompt(targetPart)
        local function searchIn(parent)
            if not parent then return false end
            for _, desc in ipairs(parent:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(desc) end)
                    return true
                end
            end
            return false
        end
        if searchIn(targetPart) then return true end
        if searchIn(targetPart.Parent) then return true end
        if searchIn(inkUtils) then return true end
        local car = getCar()
        if car and searchIn(car) then return true end
        local pos = targetPart.Position
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                local p = desc.Parent
                if p and p:IsA("BasePart") and (p.Position - pos).Magnitude < 50 then
                    pcall(function() fireproximityprompt(desc) end)
                    return true
                end
            end
        end
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ClickDetector") then
                local p = desc.Parent
                if p and p:IsA("BasePart") and (p.Position - pos).Magnitude < 50 then
                    pcall(function() fireclickdetector(desc) end)
                    return true
                end
            end
        end
        return false
    end

    local function firePromptRetry(targetPart, retries)
        retries = retries or 8
        for i = 1, retries do
            if findAndFirePrompt(targetPart) then return true end
            task.wait(0.3)
        end
        return false
    end

    local function startRoute()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("InkasatorEvents"):WaitForChild("Trucker"):FireServer("startroute", "2")
        end)
    end

    local statusRef = {text = "⏸ Prêt", step = "", count = 0}
    local function setStatus(txt) statusRef.text = txt end
    local function setStep(txt) statusRef.step = txt end

    local function farmLoop()
        while farming do
            setStatus("🔄 Démarrage route...") setStep("[1/7] FireServer")
            startRoute() task.wait(1.5)
            if not farming then break end
            setStatus("⏳ Attente voiture...") setStep("[2/7] Recherche...")
            local car = waitForCar(8)
            if not car then setStatus("❌ Voiture introuvable !") task.wait(2) continue end
            if not farming then break end
            setStatus("🪑 Montée voiture...") setStep("[3/7] Sit DriveSeat")
            sitInDriveSeat() task.wait(0.5)
            if not farming then break end
            setStatus("📍 TP → Chargement...") setStep("[4/7] TP Zapravka2")
            if zapravka2 then
                if not teleportCar(zapravka2.CFrame * CFrame.new(0, 5, 0)) then
                    setStatus("❌ Échec TP") task.wait(1) continue
                end
            end
            task.wait(0.5)
            if not farming then break end
            setStatus("💵 Récupérer argent...") setStep("[5/7] Prompt Zapravka2")
            if zapravka2 then firePromptRetry(zapravka2, 8) end
            for i = 4, 1, -1 do
                if not farming then break end
                setStatus("⏳ Chargement... " .. i .. "s") task.wait(1)
            end
            if not farming then break end
            setStatus("📍 TP → Dépôt...") setStep("[6/7] TP Base")
            if endBase then
                if not teleportCar(endBase.CFrame * CFrame.new(0, 5, 0)) then
                    setStatus("❌ Échec TP dépôt") task.wait(1) continue
                end
            end
            task.wait(0.5)
            if not farming then break end
            setStatus("🏦 Interagir...") setStep("[7/7] Prompt Base")
            if endBase then firePromptRetry(endBase, 8) end
            task.wait(0.5)
            loopCount += 1
            statusRef.count = loopCount
            setStatus("✅ Boucle " .. loopCount .. " OK!")
            setStep("Redémarrage...") task.wait(1)
        end
        setStatus("⏸ Arrêté") setStep("")
    end

    local MainSection = Window:Section({
        Title = "Car Driving Russia",
        Expanded = true,
    })

    local FarmTab = MainSection:Tab({
        Title = "Inkasator Farm",
        Icon = "solar:money-bag-bold",
        IconColor = Color3.fromHex("#f59e0b"),
        IconShape = "Square",
        Border = true,
    })

    FarmTab:Toggle({
        Title = "Auto Farm",
        Desc = "Démarre/Arrête l'autofarm Inkasator",
        Icon = "repeat",
        Default = false,
        Callback = function(val)
            farming = val
            if farming then
                task.spawn(farmLoop)
                WindUI:Notify({Title = "💰 Inkasator Farm", Content = "Autofarm démarré !", Icon = "check", Duration = 3})
            else
                WindUI:Notify({Title = "💰 Inkasator Farm", Content = "Autofarm arrêté.", Icon = "x", Duration = 2})
            end
        end,
    })

    local statusLabel = FarmTab:Label({Title = "Statut : ⏸ Prêt", Desc = "", Icon = "activity"})
    local stepLabel   = FarmTab:Label({Title = "Étape : --", Desc = "", Icon = "list"})
    local countLabel  = FarmTab:Label({Title = "🔄 Boucles : 0", Desc = "", Icon = "refresh-cw"})

    FarmTab:Divider()

    FarmTab:Button({
        Title = "TP → Chargement", Desc = "Téléporte la voiture au point Zapravka2",
        Icon = "map-pin", Color = Color3.fromHex("#6366f1"), Justify = "Center", IconAlign = "Left",
        Callback = function()
            if zapravka2 and getCar() then
                teleportCar(zapravka2.CFrame * CFrame.new(0, 5, 0))
                WindUI:Notify({Title = "TP", Content = "→ Zapravka2", Icon = "check", Duration = 2})
            else
                WindUI:Notify({Title = "Erreur", Content = "Voiture ou point introuvable !", Icon = "x", Duration = 2})
            end
        end,
    })

    FarmTab:Button({
        Title = "TP → Dépôt", Desc = "Téléporte la voiture au point de dépôt",
        Icon = "map-pin", Color = Color3.fromHex("#22c55e"), Justify = "Center", IconAlign = "Left",
        Callback = function()
            if endBase and getCar() then
                teleportCar(endBase.CFrame * CFrame.new(0, 5, 0))
                WindUI:Notify({Title = "TP", Content = "→ Base", Icon = "check", Duration = 2})
            else
                WindUI:Notify({Title = "Erreur", Content = "Voiture ou point introuvable !", Icon = "x", Duration = 2})
            end
        end,
    })

    FarmTab:Button({
        Title = "Monter dans la voiture", Desc = "S'asseoir dans le DriveSeat",
        Icon = "car", Color = Color3.fromHex("#f59e0b"), Justify = "Center", IconAlign = "Left",
        Callback = function()
            local ok = sitInDriveSeat()
            WindUI:Notify({Title = "Voiture", Content = ok and "Assis !" or "Échec - voiture introuvable", Icon = ok and "check" or "x", Duration = 2})
        end,
    })

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                statusLabel:SetTitle("Statut : " .. statusRef.text)
                stepLabel:SetTitle("Étape : " .. (statusRef.step ~= "" and statusRef.step or "--"))
                countLabel:SetTitle("🔄 Boucles : " .. tostring(statusRef.count))
            end)
        end
    end)

    Player.CharacterAdded:Connect(function()
        if farming then task.wait(2) if farming then sitInDriveSeat() end end
    end)

    task.wait(0.1)
    pcall(function() MainSection:Expand() end)
    pcall(function() FarmTab:Select() end)
end

-- ================================================================
-- BLACK GRIMOIRE HUB (PlaceId: 4632627223)
-- ================================================================
local function BuildBlackGrimoireHub(Window, isPerm)

    local AutoFarmEnabled = false
    local AutoFarmSpeed = 0.2
    local selectedMobName = ""
    local selectedToolName = ""
    local lastFarmHeight = 0
    local originalToolSize = nil
    local originalMobSizes = {}
    local floatingBodyPos = nil
    local StatsRunning = {}
    local AutoMoneyEnabled = false
    local ActiveQuestData = nil
    local AutoQuestRunning = false
    local QuestToggles = {}

    -- ── Utilitaires ──
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
        if #names == 0 then table.insert(names, "Aucun mob trouve") end
        return names
    end

    local function getToolNames()
        local tools = {}
        local searchLocations = {}
        if Player.Character then table.insert(searchLocations, {Player.Character, "Character"}) end
        if Player:FindFirstChild("Backpack") then table.insert(searchLocations, {Player.Backpack, "Backpack"}) end
        if Player:FindFirstChild("StarterGear") then table.insert(searchLocations, {Player.StarterGear, "StarterGear"}) end
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
                        if t == obj.Name .. " [" .. locName .. "]" then alreadyFound = true break end
                    end
                    if not alreadyFound then
                        table.insert(tools, obj.Name .. " [" .. locName .. "]")
                    end
                end
            end
        end
        if #tools == 0 then table.insert(tools, "Aucun tool trouve") end
        return tools
    end

    local function getToolByName(name)
        local cleanName = name:match("^(.+) %[") or name
        local searchLocations = {}
        if Player.Character then table.insert(searchLocations, Player.Character) end
        if Player:FindFirstChild("Backpack") then table.insert(searchLocations, Player.Backpack) end
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
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:EquipTool(tool) end
        end
    end

    local function applyToolHitbox(toolName)
        if originalToolSize then
            pcall(function()
                local oldTool = getToolByName(selectedToolName)
                if oldTool then
                    local handle = oldTool:FindFirstChild("Handle")
                    if handle then handle.Size = originalToolSize end
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
                if hrp then hrp.Size = originalSize end
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
            pcall(function() floatingBodyPos:Destroy() end)
            floatingBodyPos = nil
        end
    end

    local function floatAtHeight(height)
        removeFloat()
        local char = Player.Character
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

    -- Stats
    local function SendStat(statName)
        pcall(function()
            local args = {"addPoints", statName, 1, false}
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
    
    -- Teleport locations
    local TeleportLocations = {
        {Name = "Magic Tree",     Position = Vector3.new(-1037.99, 67.40, -2099)},
        {Name = "Clever Village", Position = Vector3.new(-0.98, 45.30, -404.23)},
        {Name = "Tower",          Position = Vector3.new(85.70, 55.07, -1093.18)},
    }
    local selectedTeleportName = TeleportLocations[1].Name
    local selectedTeleportPosition = TeleportLocations[1].Position
    local function getTeleportNames()
        local names = {}
        for _, loc in ipairs(TeleportLocations) do table.insert(names, loc.Name) end
        return names
    end
    local function getPositionByName(name)
        for _, loc in ipairs(TeleportLocations) do
            if loc.Name == name then return loc.Position end
        end
        return nil
    end

    -- Auto Quest fonctions
    local function SendQuest(questData)
        pcall(function()
            local args = {
                [1] = "pcgamer4",
                [2] = {
                    ["Extra"] = questData.Extra,
                    ["Type"] = "questpls",
                    ["NpcName"] = questData.NpcName
                }
            }
            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
        end)
    end
    local function StartQuestLoop()
        if AutoQuestRunning then return end
        AutoQuestRunning = true
        task.spawn(function()
            while AutoQuestRunning and ActiveQuestData do
                SendQuest(ActiveQuestData)
                task.wait(5)
            end
            AutoQuestRunning = false
        end)
    end
    local function StopQuestLoop()
        AutoQuestRunning = false
        ActiveQuestData = nil
    end
    local function DisableOtherToggles(currentKey)
        for key, toggle in pairs(QuestToggles) do
            if key ~= currentKey then
                pcall(function() toggle:Set(false) end)
            end
        end
    end

    -- Auto Farm loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if AutoFarmEnabled and selectedMobName ~= "" and selectedMobName ~= "Aucun mob trouve" then
                local folder = findBadEntitiesFolder()
                if not folder then continue end
                local myChar = Player.Character
                if not myChar then Player.CharacterAdded:Wait() task.wait(2) myChar = Player.Character end
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myHRP then Player.CharacterAdded:Wait() task.wait(2) myChar = Player.Character myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart") if not myHRP then continue end end
                local humanoid = myChar:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then removeFloat() Player.CharacterAdded:Wait() task.wait(2) continue end
                if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                    local tool = getToolByName(selectedToolName)
                    if not tool then
                        removeFloat()
                        pcall(function() local hum = myChar:FindFirstChildOfClass("Humanoid") if hum then hum.Health = 0 end end)
                        Player.CharacterAdded:Wait() task.wait(2) continue
                    end
                end
                if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then
                    local tool = getToolByName(selectedToolName)
                    if tool then
                        pcall(function()
                            for _, part in ipairs(tool:GetDescendants()) do
                                if part:IsA("BasePart") then part.Transparency = 1 end
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
                            if dist < closestDist then closestDist = dist targetMob = mob end
                        end
                    end
                end
                if not targetMob then
                    for _, mob in ipairs(folder:GetChildren()) do
                        if mob.Name == selectedMobName then
                            local hum = mob:FindFirstChildOfClass("Humanoid")
                            local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
                            if hum and hum.Health > 0 and hrp then targetMob = mob break end
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
                                if tool.Parent ~= myChar then equipTool(tool) task.wait(0.1) end
                                pcall(function() tool:Activate() end)
                            end
                        end
                        task.wait(AutoFarmSpeed)
                    else
                        task.wait(0.1)
                    end
                else
                    if lastFarmHeight > 0 then
                        if not floatingBodyPos then floatAtHeight(lastFarmHeight) end
                        myHRP.Velocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    task.wait(0.5)
                end
            end
        end
    end)

    -- ════ CONSTRUCTION HUB ════
    local MainSection = Window:Section({
        Title = "Black Grimoire",
        Opened = true,
    })

    -- ── AUTO-FARM ──
    local CombatTab = MainSection:Tab({Title = "Auto-Farm", Icon = "swords"})
    CombatTab:Section({Title = "Auto-Farm", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})
    local mobDropdown = CombatTab:Dropdown({
        Title = "Mob cible", Values = getMobNames(), Value = "",
        Callback = function(value) selectedMobName = value end,
    })
    CombatTab:Button({Title = "Rafraichir les mobs", Icon = "refresh-cw", Callback = function()
        local newMobs = getMobNames()
        mobDropdown:Refresh(newMobs)
    end})
    CombatTab:Toggle({
        Title = "Activer Auto-Farm", Value = false,
        Callback = function(state)
            AutoFarmEnabled = state
            if not state then removeFloat() restoreMobHitboxes() restoreToolHitbox()
            else if selectedToolName ~= "" and selectedToolName ~= "Aucun tool trouve" then applyToolHitbox(selectedToolName) end end
        end,
    })
    CombatTab:Slider({
        Title = "Vitesse d'attaque", Value = {Min = 0.05, Max = 2, Default = 0.2}, Step = 0.05,
        Callback = function(value) AutoFarmSpeed = value end,
    })
    CombatTab:Divider()
    CombatTab:Section({Title = "Tools", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})
    local toolDropdown = CombatTab:Dropdown({
        Title = "Tool a utiliser", Values = getToolNames(), Value = "",
        Callback = function(value)
            restoreToolHitbox()
            selectedToolName = value
            if value ~= "Aucun tool trouve" then applyToolHitbox(value) end
        end,
    })
    CombatTab:Button({Title = "Rafraichir les tools", Icon = "refresh-cw", Callback = function()
        local newTools = getToolNames()
        toolDropdown:Refresh(newTools)
    end})

    -- ── AUTO QUEST ──
    local QuestTab = MainSection:Tab({Title = "Quest", Icon = "scroll-text"})
    QuestTab:Section({Title = "Auto Quest", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})

    QuestToggles["DefeatThief"] = QuestTab:Toggle({
        Title = "Defeat Thief lvl 200", Value = false,
        Callback = function(state)
            if state then
                DisableOtherToggles("DefeatThief")
                ActiveQuestData = {Extra = "DefeatThief", NpcName = "Johnny"}
                StartQuestLoop()
            else
                if ActiveQuestData and ActiveQuestData.Extra == "DefeatThief" then StopQuestLoop() end
            end
        end,
    })
    QuestToggles["DefeatFireBoar"] = QuestTab:Toggle({
        Title = "Defeat Fire Boar lvl 300", Value = false,
        Callback = function(state)
            if state then
                DisableOtherToggles("DefeatFireBoar")
                ActiveQuestData = {Extra = "DefeatFire Boar", NpcName = "Renna"}
                StartQuestLoop()
            else
                if ActiveQuestData and ActiveQuestData.Extra == "DefeatFire Boar" then StopQuestLoop() end
            end
        end,
    })
    QuestToggles["DefeatGolem"] = QuestTab:Toggle({
        Title = "Defeat Golem lvl 1200", Value = false,
        Callback = function(state)
            if state then
                DisableOtherToggles("DefeatGolem")
                ActiveQuestData = {Extra = "DefeatGolem", NpcName = "Davrqwy"}
                StartQuestLoop()
            else
                if ActiveQuestData and ActiveQuestData.Extra == "DefeatGolem" then StopQuestLoop() end
            end
        end,
    })
    QuestToggles["Licht"] = QuestTab:Toggle({
        Title = "Licht lvl 9000", Value = false,
        Callback = function(state)
            if state then
                DisableOtherToggles("Licht")
                ActiveQuestData = {Extra = "Licht", NpcName = "Patolli"}
                StartQuestLoop()
            else
                if ActiveQuestData and ActiveQuestData.Extra == "Licht" then StopQuestLoop() end
            end
        end,
    })
    QuestToggles["DefeatSecurityGolem"] = QuestTab:Toggle({
        Title = "Defeat Security Golem lvl 2500", Value = false,
        Callback = function(state)
            if state then
                DisableOtherToggles("DefeatSecurityGolem")
                ActiveQuestData = {Extra = "DefeatSecurityGolem", NpcName = "ahmedBOOM234"}
                StartQuestLoop()
            else
                if ActiveQuestData and ActiveQuestData.Extra == "DefeatSecurityGolem" then StopQuestLoop() end
            end
        end,
    })

    -- ── OTHER QUESTS ──
    local MoneyTab = MainSection:Tab({Title = "Other Quests", Icon = "scroll-text"})
    MoneyTab:Section({Title = "Other Quests", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})()

    -- Cut Woods lvl 1
    local AutoWoodEnabled = false
    MoneyTab:Toggle({
        Title = "Cut Woods lvl 1",
        Value = false,
        Callback = function(state)
            AutoWoodEnabled = state
            if state then
                task.spawn(function()
                    local player = game:GetService("Players").LocalPlayer
                    local TreePositions = {
                        {Position = Vector3.new(-92.12, 45.75, -526.68), LookAt = Vector3.new(-92.12, 45.75, -527.68)},
                        {Position = Vector3.new(-106.17, 45.75, -526.59), LookAt = Vector3.new(-106.17, 45.75, -527.59)},
                        {Position = Vector3.new(-92.00, 45.75, -537.22), LookAt = Vector3.new(-92.00, 45.75, -538.22)},
                        {Position = Vector3.new(-106.09, 45.75, -535.37), LookAt = Vector3.new(-106.09, 45.75, -536.37)},
                        {Position = Vector3.new(-92.12, 45.75, -526.68), LookAt = Vector3.new(-92.12, 45.75, -527.68)},
                    }
                    local NpcPosition = Vector3.new(-118.06, 45.25, -532.47)
                    local NpcLookAt = Vector3.new(-119.06, 45.25, -532.47)
                    local function SendWoodQuest()
                        pcall(function()
                            local args = {[1] = "pcgamer4", [2] = {["Extra"] = "CutWoods", ["Type"] = "questpls", ["NpcName"] = "Father Orfi"}}
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end
                    local function findMAxe()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then local tool = backpack:FindFirstChild("MAxe") if tool then return tool end end
                        local char = player.Character
                        if char then local tool = char:FindFirstChild("MAxe") if tool then return tool end end
                        return nil
                    end
                    while AutoWoodEnabled do
                        local character = player.Character
                        if not character then player.CharacterAdded:Wait() task.wait(1) continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait() task.wait(1) continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait() task.wait(1) continue end
                        hrp.CFrame = CFrame.new(NpcPosition, NpcLookAt)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.5)
                        SendWoodQuest()
                        task.wait(2)
                        if not AutoWoodEnabled then break end
                        local axe = nil
                        local waitTime = 0
                        while not axe and waitTime < 5 and AutoWoodEnabled do
                            axe = findMAxe()
                            if not axe then task.wait(0.3) waitTime = waitTime + 0.3 end
                        end
                        if not axe or not AutoWoodEnabled then continue end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid and axe.Parent ~= character then humanoid:EquipTool(axe) task.wait(0.3) end
                        if not AutoWoodEnabled then break end
                        for i, treeData in ipairs(TreePositions) do
                            if not AutoWoodEnabled then break end
                            character = player.Character
                            hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then break end
                            axe = findMAxe()
                            if axe then
                                if axe.Parent ~= character then humanoid:EquipTool(axe) task.wait(0.2) end
                            end
                            hrp.CFrame = CFrame.new(treeData.Position, treeData.LookAt)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            task.wait()
                            axe = findMAxe()
                            if axe then pcall(function() axe:Activate() end) end
                            task.wait(2)
                        end
                        if not AutoWoodEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        hrp.CFrame = CFrame.new(NpcPosition, NpcLookAt)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        task.wait(3)
                        if not AutoWoodEnabled then break end
                    end
                end)
            end
        end,
    })

    -- Auto Farm Potatoes lvl 30
    local AutoPotatoEnabled = false
    MoneyTab:Toggle({
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
                            local args = {[1] = "pcgamer4", [2] = {["Extra"] = "GetPotatoes", ["Type"] = "questpls", ["NpcName"] = "Chris"}}
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end
                    local function findHoe()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then local tool = backpack:FindFirstChild("Hoe") if tool then return tool end end
                        local char = player.Character
                        if char then local tool = char:FindFirstChild("Hoe") if tool then return tool end end
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
                        if not character then player.CharacterAdded:Wait() task.wait(1) continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait() task.wait(1) continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait() task.wait(1) continue end
                        local chrisCFrame = getChrisPosition()
                        if chrisCFrame then
                            local chrisPos = chrisCFrame.Position
                            hrp.CFrame = CFrame.new(chrisPos + Vector3.new(0, 0, 3), chrisPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                        task.wait(0.5)
                        SendPotatoQuest()
                        task.wait(2)
                        if not AutoPotatoEnabled then break end
                        local hoe = nil
                        local waitTime = 0
                        while not hoe and waitTime < 5 and AutoPotatoEnabled do
                            hoe = findHoe()
                            if not hoe then task.wait(0.3) waitTime = waitTime + 0.3 end
                        end
                        if not hoe or not AutoPotatoEnabled then continue end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid and hoe.Parent ~= character then humanoid:EquipTool(hoe) task.wait(0.3) end
                        if not AutoPotatoEnabled then break end
                        local harvestCount = 0
                        while harvestCount < HARVEST_NEEDED and AutoPotatoEnabled do
                            character = player.Character
                            hrp = character and character:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then break end
                            local potatoes = findPotatoes()
                            if #potatoes == 0 then task.wait(1) continue end
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
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                task.wait(0.3)
                                hoe = findHoe()
                                if hoe then
                                    if hoe.Parent ~= character then humanoid:EquipTool(hoe) task.wait(0.2) end
                                    pcall(function() hoe:Activate() end)
                                end
                                harvestCount = harvestCount + 1
                                task.wait(1)
                            end
                        end
                        if not AutoPotatoEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        chrisCFrame = getChrisPosition()
                        if chrisCFrame then
                            local chrisPos = chrisCFrame.Position
                            hrp.CFrame = CFrame.new(chrisPos + Vector3.new(0, 0, 3), chrisPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                        task.wait(3)
                        if not AutoPotatoEnabled then break end
                    end
                end)
            end
        end,
    })

    -- Auto Farm Steak lvl 60
    local AutoSteakEnabled = false
    local allDeliveredCitizens = {}
    MoneyTab:Toggle({
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
                            local args = {[1] = "pcgamer4", [2] = {["Extra"] = "DeliverSteak", ["Type"] = "questpls", ["NpcName"] = "Chef Jack"}}
                            game:GetService("ReplicatedStorage").MainRemote:FireServer(unpack(args))
                        end)
                    end
                    local function findPlate()
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, tool in ipairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") and (tool.Name == "Plat" or tool.Name == "Plate" or tool.Name:lower():find("plat")) then return tool end
                            end
                        end
                        local char = player.Character
                        if char then
                            for _, tool in ipairs(char:GetChildren()) do
                                if tool:IsA("Tool") and (tool.Name == "Plat" or tool.Name == "Plate" or tool.Name:lower():find("plat")) then return tool end
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
                        local part = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc:FindFirstChild("Torso")
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
                                    if allDeliveredCitizens[npc] or allDeliveredCitizens[citizenID] then continue end
                                    local npcPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc:FindFirstChild("Torso") or npc:FindFirstChild("UpperTorso")
                                    if not npcPart and npc:IsA("Model") then npcPart = npc.PrimaryPart end
                                    if not npcPart then
                                        for _, part in ipairs(npc:GetDescendants()) do
                                            if part:IsA("BasePart") then npcPart = part break end
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
                        if not character then player.CharacterAdded:Wait() task.wait(1) continue end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if not hrp then player.CharacterAdded:Wait() task.wait(1) continue end
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then player.CharacterAdded:Wait() task.wait(1) continue end
                        local total = countTotalCitizens()
                        local delivered = countDelivered()
                        if delivered >= total and total > 0 then allDeliveredCitizens = {} end
                        local available = findAvailableCitizens()
                        if #available < 5 then allDeliveredCitizens = {} task.wait(0.5) end
                        local jackCFrame = getChefJackPosition()
                        if jackCFrame then
                            local jackPos = jackCFrame.Position
                            hrp.CFrame = CFrame.new(jackPos + Vector3.new(0, 0, 3), jackPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                        task.wait(0.5)
                        SendSteakQuest()
                        task.wait(3)
                        if not AutoSteakEnabled then break end
                        local plate = nil
                        local waitTime = 0
                        while not plate and waitTime < 10 and AutoSteakEnabled do
                            plate = findPlate()
                            if not plate then plate = findQuestTool() end
                            if not plate then task.wait(0.5) waitTime = waitTime + 0.5 end
                        end
                        if not plate then task.wait(1) continue end
                        if not AutoSteakEnabled then break end
                        character = player.Character
                        humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            if plate.Parent ~= character then humanoid:EquipTool(plate) end
                            task.wait(0.5)
                        end
                        if not AutoSteakEnabled then break end
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
                                if #citizens == 0 then task.wait(1) continue end
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
                                    if plate.Parent ~= character then humanoid:EquipTool(plate) task.wait(0.3) end
                                end
                                local citizenPos = citizen.Part.Position
                                hrp.CFrame = CFrame.new(citizenPos + Vector3.new(0, 0, -3), citizenPos)
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                pcall(function()
                                    firetouchinterest(hrp, citizen.Part, 0)
                                    task.wait(0.1)
                                    firetouchinterest(hrp, citizen.Part, 1)
                                end)
                                allDeliveredCitizens[citizen.Model] = true
                                allDeliveredCitizens[citizen.ID] = true
                                deliverCount = deliverCount + 1
                                task.wait(0.5)
                            end
                        end
                        if not AutoSteakEnabled then break end
                        character = player.Character
                        hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        jackCFrame = getChefJackPosition()
                        if jackCFrame then
                            local jackPos = jackCFrame.Position
                            hrp.CFrame = CFrame.new(jackPos + Vector3.new(0, 0, 3), jackPos)
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                        task.wait(3)
                        if not AutoSteakEnabled then break end
                    end
                end)
            end
        end,
    })

    -- ── TELEPORT ──
    local TeleportTab = MainSection:Tab({Title = "Teleport", Icon = "map-pin"})
    TeleportTab:Section({Title = "Teleport", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})
    TeleportTab:Dropdown({
        Title = "Destination", Values = getTeleportNames(), Value = selectedTeleportName,
        Callback = function(value)
            selectedTeleportName = value
            selectedTeleportPosition = getPositionByName(value)
        end,
    })
    TeleportTab:Button({
        Title = "Teleporter", Icon = "navigation",
        Callback = function()
            if selectedTeleportPosition then
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(selectedTeleportPosition) end
            end
        end,
    })

    -- ── STATS ──
    local StatsTab = MainSection:Tab({Title = "Stats", Icon = "chart-no-axes-combined"})
    StatsTab:Section({Title = "Auto Stats", TextSize = 18, FontWeight = Enum.FontWeight.SemiBold})
    for _, stat in ipairs({"Power", "Vitality", "Dexterity", "Mana", "Luck"}) do
        local statName = stat
        StatsTab:Toggle({
            Title = "Auto " .. statName, Value = false,
            Callback = function(state)
                if state then StartStatLoop(statName) else StopStatLoop(statName) end
            end,
        })
    end

    task.wait(0.1)
    pcall(function() CombatTab:Select() end)
end

-- ================================================================
-- HUB GÉNÉRIQUE
-- ================================================================
local function BuildGenericHub(Window, isPerm)
    local MainTab = Window:Tab({Title = "Principal", Icon = "solar:home-2-bold", IconColor = Color3.fromHex("#6366f1"), IconShape = "Square", Border = true})
    local InfoTab = Window:Tab({Title = "Infos", Icon = "solar:info-square-bold", IconColor = Color3.fromHex("#83889E"), IconShape = "Square", Border = true})
    MainTab:Label({Title = "Hyper Hub v3.0", Desc = "Aucun jeu spécifique détecté.", Icon = "info"})
    InfoTab:Label({Title = "Hyper Hub v3.0", Desc = "Licence activée avec succès !", Icon = "shield-check"})
    InfoTab:Label({Title = Player.Name, Desc = "UserId : " .. tostring(Player.UserId), Icon = "user"})
    InfoTab:Label({Title = isPerm and "🔑 Permanent Key" or "⏱ Temporaire", Desc = isPerm and "Acces illimite" or "Acces temporaire", Icon = isPerm and "infinity" or "clock"})
    InfoTab:Divider()
    InfoTab:Button({Title = "Fermer le Hub", Desc = "Ferme le hub", Icon = "x", Callback = function() Window:Destroy() end})
    task.wait(0.1)
    pcall(function() MainTab:Select() end)
end

-- ================================================================
-- OPEN MAIN HUB
-- ================================================================
local function OpenMainHub(licenseData)
    local licenseType = licenseData and licenseData.type or "perm"
    local expiresAt = licenseData and licenseData.expiresAt
    local function GetRemainingTime()
        if not expiresAt then return "??:??:??" end
        local remaining = math.max(0, expiresAt - os.time())
        local h = math.floor(remaining / 3600)
        local m = math.floor((remaining % 3600) / 60)
        local s = remaining % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    local isPerm = (licenseType == "perm")
    local licenseText = isPerm and "🔑 Permanent Key" or ("⏱ " .. GetRemainingTime())
    local Window = WindUI:CreateWindow({
        Title = "Hyper Hub", Author = "by HyperHub Team", Folder = SaveFolder,
        Icon = "zap", NewElements = true, HideSearchBar = false,
        OpenButton = {
            Title = "Hyper Hub", CornerRadius = UDim.new(1, 0), StrokeThickness = 3,
            Enabled = true, Draggable = true, OnlyMobile = false, Scale = 0.5,
            Color = ColorSequence.new(Color3.fromHex("#6366f1"), Color3.fromHex("#a855f7")),
        },
        Topbar = {Height = 44, ButtonsType = "Mac"},
    })
    Window:Tag({Title = "v3.0", Icon = "zap", Color = Color3.fromHex("#6366f1"), Border = true})
    local licenseTag = Window:Tag({
        Title = licenseText, Icon = isPerm and "shield-check" or "clock",
        Color = isPerm and Color3.fromHex("#22c55e") or Color3.fromHex("#f59e0b"), Border = true,
    })
    if not isPerm then
        task.spawn(function()
            while task.wait(1) do pcall(function() licenseTag:SetTitle("⏱ " .. GetRemainingTime()) end) end
        end)
    end
    if isCarDrivingRussia then
        WindUI:Notify({Title = "🔍 Jeu détecté", Content = "Car Driving Russia — Chargement...", Icon = "search", Duration = 3})
        task.wait(0.5)
        BuildCarDrivingRussiaHub(Window, isPerm)
    elseif isBlackGrimoire then
        WindUI:Notify({Title = "🔍 Jeu détecté", Content = "Black Grimoire — Chargement...", Icon = "search", Duration = 3})
        task.wait(0.5)
        BuildBlackGrimoireHub(Window, isPerm)
    else
        BuildGenericHub(Window, isPerm)
    end
end

-- ================================================================
-- KEY SYSTEM GUI
-- ================================================================
local IsActivating = false
local OldGui = PlayerGui:FindFirstChild("HyperHubKey")
if OldGui then OldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperHubKey"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local savedKey = LoadSavedKey()
local savedKeyClean = savedKey and savedKey:upper():gsub("%s+", "") or nil

local Blur = Instance.new("BlurEffect")
Blur.Size = 24
Blur.Parent = game:GetService("Lighting")

local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.4
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 5
Overlay.Parent = ScreenGui

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local W = IsMobile and 290 or 420
local H = IsMobile and 400 or 480

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.fromOffset(W, H)
KeyFrame.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
KeyFrame.BorderSizePixel = 0
KeyFrame.ZIndex = 10
KeyFrame.Active = true
KeyFrame.Parent = ScreenGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 16)

local kfStroke = Instance.new("UIStroke")
kfStroke.Color = Color3.fromRGB(60, 60, 90)
kfStroke.Thickness = 1.5
kfStroke.Parent = KeyFrame

local dragging, dragStart, startPos = false, nil, nil
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = KeyFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 48)
Topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
Topbar.BorderSizePixel = 0
Topbar.ZIndex = 11
Topbar.Parent = KeyFrame
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 16)

local TopbarPatch = Instance.new("Frame")
TopbarPatch.Size = UDim2.new(1, 0, 0, 16)
TopbarPatch.Position = UDim2.new(0, 0, 1, -16)
TopbarPatch.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
TopbarPatch.BorderSizePixel = 0
TopbarPatch.ZIndex = 11
TopbarPatch.Parent = Topbar

local MacButtons = Instance.new("Frame")
MacButtons.Size = UDim2.new(0, 60, 0, 14)
MacButtons.Position = UDim2.new(0, 14, 0.5, -7)
MacButtons.BackgroundTransparency = 1
MacButtons.ZIndex = 12
MacButtons.Parent = Topbar
local macLayout = Instance.new("UIListLayout")
macLayout.FillDirection = Enum.FillDirection.Horizontal
macLayout.Padding = UDim.new(0, 8)
macLayout.VerticalAlignment = Enum.VerticalAlignment.Center
macLayout.Parent = MacButtons

for i, color in ipairs({"#F4695F", "#F4C948", "#60C762"}) do
    local dot = Instance.new("TextButton")
    dot.Size = UDim2.fromOffset(13, 13)
    dot.BackgroundColor3 = Color3.fromHex(color)
    dot.BorderSizePixel = 0
    dot.Text = ""
    dot.AutoButtonColor = false
    dot.ZIndex = 13
    dot.Parent = MacButtons
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    if i == 1 then
        dot.MouseButton1Click:Connect(function()
            Tween(KeyFrame, {BackgroundTransparency = 1}, 0.3)
            Tween(Overlay, {BackgroundTransparency = 1}, 0.3)
            task.wait(0.35) ScreenGui:Destroy() Blur:Destroy()
        end)
    end
end

local TagFrame = Instance.new("Frame")
TagFrame.Size = UDim2.fromOffset(IsMobile and 52 or 64, 24)
TagFrame.Position = UDim2.new(1, IsMobile and -64 or -76, 0.5, -12)
TagFrame.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
TagFrame.BorderSizePixel = 0
TagFrame.ZIndex = 12
TagFrame.Parent = Topbar
Instance.new("UICorner", TagFrame).CornerRadius = UDim.new(0, 7)

local TagText = Instance.new("TextLabel")
TagText.Size = UDim2.new(1, 0, 1, 0)
TagText.BackgroundTransparency = 1
TagText.Text = "⚡ v3.0"
TagText.TextColor3 = Color3.fromRGB(255, 255, 255)
TagText.Font = Enum.Font.GothamBold
TagText.TextSize = IsMobile and 9 or 11
TagText.TextXAlignment = Enum.TextXAlignment.Center
TagText.ZIndex = 13
TagText.Parent = TagFrame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 48)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
Divider.BorderSizePixel = 0
Divider.ZIndex = 11
Divider.Parent = KeyFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -44, 1, -62)
Content.Position = UDim2.new(0, 22, 0, 56)
Content.BackgroundTransparency = 1
Content.ZIndex = 11
Content.Parent = KeyFrame

local HubNameLabel = Instance.new("TextLabel")
HubNameLabel.Size = UDim2.new(1, 0, 0, IsMobile and 24 or 30)
HubNameLabel.Position = UDim2.new(0, 0, 0, IsMobile and 2 or 4)
HubNameLabel.BackgroundTransparency = 1
HubNameLabel.Text = "⚡ Hyper Hub"
HubNameLabel.TextColor3 = Color3.fromRGB(99, 102, 241)
HubNameLabel.Font = Enum.Font.GothamBold
HubNameLabel.TextSize = IsMobile and 17 or 22
HubNameLabel.TextXAlignment = Enum.TextXAlignment.Center
HubNameLabel.ZIndex = 12
HubNameLabel.Parent = Content

local CenterIcon = Instance.new("TextLabel")
CenterIcon.Size = UDim2.new(1, 0, 0, IsMobile and 38 or 50)
CenterIcon.Position = UDim2.new(0, 0, 0, IsMobile and 30 or 38)
CenterIcon.BackgroundTransparency = 1
CenterIcon.Text = "🔑"
CenterIcon.TextSize = IsMobile and 30 or 38
CenterIcon.TextXAlignment = Enum.TextXAlignment.Center
CenterIcon.ZIndex = 12
CenterIcon.Parent = Content

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, IsMobile and 22 or 28)
TitleLabel.Position = UDim2.new(0, 0, 0, IsMobile and 72 or 92)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Activation de Licence"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = IsMobile and 15 or 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.ZIndex = 12
TitleLabel.Parent = Content

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, 0, 0, 18)
SubLabel.Position = UDim2.new(0, 0, 0, IsMobile and 96 or 122)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Entrez votre cle de licence pour continuer"
SubLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = IsMobile and 9 or 12
SubLabel.TextXAlignment = Enum.TextXAlignment.Center
SubLabel.ZIndex = 12
SubLabel.Parent = Content

local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(1, 0, 0, IsMobile and 38 or 46)
InputContainer.Position = UDim2.new(0, 0, 0, IsMobile and 122 or 154)
InputContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
InputContainer.BorderSizePixel = 0
InputContainer.ZIndex = 12
InputContainer.Parent = Content
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 12)

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(45, 45, 68)
InputStroke.Thickness = 1.2
InputStroke.Parent = InputContainer

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 1, 0)
InputBox.Position = UDim2.new(0, 10, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.Text = savedKeyClean or ""
InputBox.PlaceholderText = "Ex: XXXX-XXXX-XXXX-XXXX"
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 95)
InputBox.Font = Enum.Font.GothamBold
InputBox.TextSize = IsMobile and 11 or 13
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 13
InputBox.Parent = InputContainer

InputBox.Focused:Connect(function()
    Tween(InputStroke, {Color = Color3.fromRGB(99, 102, 241)})
    Tween(InputContainer, {BackgroundColor3 = Color3.fromRGB(30, 30, 50)})
end)
InputBox.FocusLost:Connect(function()
    Tween(InputStroke, {Color = Color3.fromRGB(45, 45, 68)})
    Tween(InputContainer, {BackgroundColor3 = Color3.fromRGB(26, 26, 40)})
end)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(1, 0, 0, IsMobile and 38 or 48)
VerifyBtn.Position = UDim2.new(0, 0, 0, IsMobile and 170 or 212)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
VerifyBtn.Text = "Verifier la cle"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = IsMobile and 12 or 15
VerifyBtn.BorderSizePixel = 0
VerifyBtn.AutoButtonColor = false
VerifyBtn.ZIndex = 12
VerifyBtn.Parent = Content
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 12)

local verifyGrad = Instance.new("UIGradient")
verifyGrad.Color = ColorSequence.new(Color3.fromHex("#6366f1"), Color3.fromHex("#8b5cf6"))
verifyGrad.Rotation = 90
verifyGrad.Parent = VerifyBtn

VerifyBtn.MouseEnter:Connect(function()
    if not IsActivating then Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(120, 124, 255)}) end
end)
VerifyBtn.MouseLeave:Connect(function()
    if not IsActivating then Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(99, 102, 241)}) end
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 26)
StatusLabel.Position = UDim2.new(0, 0, 0, IsMobile and 216 or 270)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = IsMobile and 10 or 12
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.ZIndex = 12
StatusLabel.Parent = Content

local CloseKeyBtn = Instance.new("TextButton")
CloseKeyBtn.Size = UDim2.new(1, 0, 0, IsMobile and 34 or 42)
CloseKeyBtn.Position = UDim2.new(0, 0, 0, IsMobile and 250 or 306)
CloseKeyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
CloseKeyBtn.Text = ""
CloseKeyBtn.BorderSizePixel = 0
CloseKeyBtn.AutoButtonColor = false
CloseKeyBtn.ZIndex = 12
CloseKeyBtn.Parent = Content
Instance.new("UICorner", CloseKeyBtn).CornerRadius = UDim.new(0, 12)

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(60, 60, 90)
closeStroke.Thickness = 1.2
closeStroke.Parent = CloseKeyBtn

local CloseIcon = Instance.new("TextLabel")
CloseIcon.Size = UDim2.new(0, 20, 1, 0)
CloseIcon.Position = UDim2.new(0.5, -38, 0, 0)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "✕"
CloseIcon.TextColor3 = Color3.fromRGB(200, 80, 80)
CloseIcon.Font = Enum.Font.GothamBold
CloseIcon.TextSize = IsMobile and 13 or 15
CloseIcon.TextXAlignment = Enum.TextXAlignment.Center
CloseIcon.ZIndex = 13
CloseIcon.Parent = CloseKeyBtn

local CloseText = Instance.new("TextLabel")
CloseText.Size = UDim2.new(0, 60, 1, 0)
CloseText.Position = UDim2.new(0.5, -18, 0, 0)
CloseText.BackgroundTransparency = 1
CloseText.Text = "Fermer"
CloseText.TextColor3 = Color3.fromRGB(180, 180, 210)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = IsMobile and 11 or 13
CloseText.TextXAlignment = Enum.TextXAlignment.Left
CloseText.ZIndex = 13
CloseText.Parent = CloseKeyBtn

CloseKeyBtn.MouseEnter:Connect(function()
    Tween(CloseKeyBtn, {BackgroundColor3 = Color3.fromRGB(50, 22, 22)})
    Tween(closeStroke, {Color = Color3.fromRGB(180, 50, 50)})
    Tween(CloseText, {TextColor3 = Color3.fromRGB(239, 68, 68)})
end)
CloseKeyBtn.MouseLeave:Connect(function()
    Tween(CloseKeyBtn, {BackgroundColor3 = Color3.fromRGB(28, 28, 42)})
    Tween(closeStroke, {Color = Color3.fromRGB(60, 60, 90)})
    Tween(CloseText, {TextColor3 = Color3.fromRGB(180, 180, 210)})
end)
CloseKeyBtn.MouseButton1Click:Connect(function()
    Tween(KeyFrame, {BackgroundTransparency = 1}, 0.3)
    Tween(Overlay, {BackgroundTransparency = 1}, 0.3)
    task.wait(0.35) ScreenGui:Destroy() Blur:Destroy()
end)

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(1, 0, 0, 18)
DiscordLabel.Position = UDim2.new(0, 0, 0, IsMobile and 292 or 358)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "discord.gg/hyperhub"
DiscordLabel.TextColor3 = Color3.fromRGB(50, 50, 75)
DiscordLabel.Font = Enum.Font.Gotham
DiscordLabel.TextSize = IsMobile and 9 or 10
DiscordLabel.TextXAlignment = Enum.TextXAlignment.Center
DiscordLabel.ZIndex = 12
DiscordLabel.Parent = Content

if savedKeyClean then
    task.spawn(function()
        StatusLabel.Text = "⏳ Verification de la cle sauvegardee..."
        StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 160)
        VerifyBtn.Text = "Verification..."
        Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 80)})
        IsActivating = true
        local valid, data = ValidateKey(savedKeyClean)
        if valid then
            StatusLabel.Text = "✔ Cle sauvegardee valide !"
            StatusLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
            VerifyBtn.Text = "✔ Ouverture..."
            Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(34, 197, 94)})
            task.wait(1.2)
            Tween(KeyFrame, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -W/2, 0.42, -H/2)}, 0.4)
            Tween(Overlay, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.45) ScreenGui:Destroy() Blur:Destroy() OpenMainHub(data)
        else
            local reason = (data and data.reason) or "Cle invalide ou expiree"
            StatusLabel.Text = "✘ " .. reason
            StatusLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
            VerifyBtn.Text = "Verifier la cle"
            Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(99, 102, 241)})
            InputBox.Text = ""
            pcall(function() if isfile(SaveFile) then writefile(SaveFile, "") end end)
            IsActivating = false
        end
    end)
end

VerifyBtn.MouseButton1Click:Connect(function()
    if IsActivating then return end
    local key = InputBox.Text
    if key == "" then
        StatusLabel.Text = "⚠ Veuillez entrer une cle de licence"
        StatusLabel.TextColor3 = Color3.fromRGB(234, 179, 8)
        return
    end
    IsActivating = true
    VerifyBtn.Text = "Verification en cours..."
    Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 80)})
    StatusLabel.Text = "Connexion au serveur..."
    StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 140)
    task.spawn(function()
        local cleanKey = key:upper():gsub("%s+", "")
        local valid, data = ValidateKey(cleanKey)
        if valid then
            SaveKey(cleanKey)
            StatusLabel.Text = "✔ Cle valide ! Ouverture..."
            StatusLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
            VerifyBtn.Text = "✔ Activée !"
            Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(34, 197, 94)})
            task.wait(0.8)
            Tween(KeyFrame, {BackgroundTransparency = 1, Position = UDim2.new(0.5, -W/2, 0.42, -H/2)}, 0.4)
            Tween(Overlay, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.45) ScreenGui:Destroy() Blur:Destroy() OpenMainHub(data)
        else
            local reason = (data and data.reason) or "Cle de licence invalide."
            StatusLabel.Text = "✘ " .. reason
            StatusLabel.TextColor3 = Color3.fromRGB(239, 68, 68)
            VerifyBtn.Text = "Verifier la cle"
            Tween(VerifyBtn, {BackgroundColor3 = Color3.fromRGB(99, 102, 241)})
            IsActivating = false
        end
    end)
end)