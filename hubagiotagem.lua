--atualizado
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    if not Rayfield then error("Rayfield não inicializado corretamente") end
end)

if not success then
    warn("Erro ao carregar Rayfield: " .. err)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro Crítico",
        Text = "Falha ao carregar Rayfield. Verifique sua conexão ou executor. Tente novamente ou use um executor compatível.",
        Duration = 10
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Hub Agiotagem ",
    LoadingTitle = "Carregando Hub Agiotagem",
    LoadingSubtitle = "Versão 1.0 EM TESTE",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = true, -- Ativado o sistema de key
    KeySettings = {
        Title = "Chave de Autenticação",
        Subtitle = "Insira a chave para acessar o hub",
        Note = "Entre em nosso discord e pegue a key e coloque aqui link do discord https://discord.gg/bPqUnxs32S ",
        FileName = "AgiotagemKey",
        SaveKey = true,
        GrabKeyFromSite = false, -- Desativado para usar a key fixa
        Key = "DOCHEATS1230214194" -- Key fixa definida
    }
})

local Players, RunService, UserInputService, Workspace, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Workspace"), game:GetService("TweenService")
local player, camera = Players.LocalPlayer, Workspace.CurrentCamera

-- Variáveis globais
local ESPEnabled, ESPColor, ShowHealth, ShowDistance, ShowBoxes, ShowSkeletons, ESPRainbow = false, Color3.fromRGB(255, 0, 0), false, false, false, false, false
local ESPs, FlyEnabled, NoclipEnabled, GodmodeEnabled, WalkSpeedEnabled, SpeedHackEnabled = {}, false, false, false, false, false
local AimbotEnabled, AutoShootEnabled, AimbotFOV, WalkSpeedValue, FlySpeedValue, SpeedValue = false, false, 90, 16, 30, 1.5
local TeleportTarget, DebugMode = nil, false

-- Função de debug
local function debugLog(message)
    if DebugMode then print("[Debug] " .. message) end
end

-- Fly
local flyConnection
local keys = {w = false, s = false, a = false, d = false, space = false, leftControl = false}
local function startFly()
    if FlyEnabled then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = true
            flyConnection = RunService.RenderStepped:Connect(function(dt)
                local root = char.HumanoidRootPart
                local move = Vector3.new(0, 0, 0)
                if keys.w then move = move + camera.CFrame.LookVector * 0.5 end
                if keys.s then move = move - camera.CFrame.LookVector * 0.5 end
                if keys.a then move = move - camera.CFrame.RightVector * 0.5 end
                if keys.d then move = move + camera.CFrame.RightVector * 0.5 end
                if keys.space then move = move + Vector3.new(0, 0.5, 0) end
                if keys.leftControl then move = move + Vector3.new(0, -0.5, 0) end
                if move.Magnitude > 0 then root.Velocity = root.Velocity + (move.Unit * FlySpeedValue * dt) end
            end)
        end
    else
        if flyConnection then flyConnection:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W then keys.w = true elseif kc == Enum.KeyCode.S then keys.s = true
    elseif kc == Enum.KeyCode.A then keys.a = true elseif kc == Enum.KeyCode.D then keys.d = true
    elseif kc == Enum.KeyCode.Space then keys.space = true elseif kc == Enum.KeyCode.LeftControl then keys.leftControl = true end
end)

UserInputService.InputEnded:Connect(function(input)
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W then keys.w = false elseif kc == Enum.KeyCode.S then keys.s = false
    elseif kc == Enum.KeyCode.A then keys.a = false elseif kc == Enum.KeyCode.D then keys.d = false
    elseif kc == Enum.KeyCode.Space then keys.space = false elseif kc == Enum.KeyCode.LeftControl then keys.leftControl = false end
end)

-- Noclip
local noclipConn
local function toggleNoclip(val)
    NoclipEnabled = val
    if val then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if noclipConn then noclipConn:Disconnect() end if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end end
end

-- WalkSpeed e SpeedHack
local wsConn, speedConn
local function toggleWalkSpeed(val)
    WalkSpeedEnabled = val
    if val then if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = math.clamp(WalkSpeedValue, 16, 25)
        wsConn = RunService.Heartbeat:Connect(function() if hum.WalkSpeed ~= math.clamp(WalkSpeedValue, 16, 25) then hum.WalkSpeed = math.clamp(WalkSpeedValue, 16, 25) end end)
    end else if wsConn then wsConn:Disconnect() end if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end end
end

local function toggleSpeedHack(val)
    SpeedHackEnabled = val
    if val then
        speedConn = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local moveDir = root.Velocity.Unit
                if moveDir.Magnitude > 0 then root.Velocity = moveDir * (16 * math.clamp(SpeedValue, 1, 1.5)) end
            end
        end)
    else if speedConn then speedConn:Disconnect() end end
end

-- Godmode
local godConn
local function toggleGodmode(val)
    GodmodeEnabled = val
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if val then
            hum.MaxHealth, hum.Health = math.huge, math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum.BreakJointsOnDeath = false
            godConn = RunService.Heartbeat:Connect(function() if hum.Health < math.huge then hum.Health = math.huge end end)
        else if godConn then godConn:Disconnect() end hum.MaxHealth, hum.Health = 100, 100 hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) hum.BreakJointsOnDeath = true end
    end
end

-- ESP (fixed disable, no tracers)
local function createESP(plr)
    if plr.Character and plr ~= player then
        local char = plr.Character
        if char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            local hl = Instance.new("Highlight")
            hl.Name = "ESP_HL"
            hl.Adornee = char
            hl.FillColor, hl.OutlineColor = ESPColor, Color3.new(1, 1, 1)
            hl.FillTransparency, hl.OutlineTransparency = 0.5, 0
            hl.Parent = char
            local bb = Instance.new("BillboardGui")
            bb.Name = "ESP_BB"
            bb.Adornee = root
            bb.Size = UDim2.new(0, 150, 0, 80)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = root
            local nameL = Instance.new("TextLabel")
            nameL.Size, nameL.BackgroundTransparency = UDim2.new(1, 0, 0.25, 0), 1
            nameL.Text, nameL.TextColor3 = plr.Name, Color3.new(1, 1, 1)
            nameL.TextScaled, nameL.Font = true, Enum.Font.SourceSansBold
            nameL.Parent = bb
            local toolL = Instance.new("TextLabel")
            toolL.Size, toolL.Position, toolL.BackgroundTransparency = UDim2.new(1, 0, 0.25, 0), UDim2.new(0, 0, 0.25, 0), 1
            toolL.Text, toolL.TextColor3 = "Sem Tool", Color3.new(1, 0.5, 0)
            toolL.TextScaled, toolL.Font = true, Enum.Font.SourceSans
            toolL.Parent = bb
            local healthL = Instance.new("TextLabel")
            healthL.Size, healthL.Position, healthL.BackgroundTransparency = UDim2.new(1, 0, 0.25, 0), UDim2.new(0, 0, 0.5, 0), 1
            healthL.Text, healthL.TextColor3 = "", Color3.new(0, 1, 0)
            healthL.TextScaled, healthL.Font = true, Enum.Font.SourceSans
            healthL.Parent = bb
            local distL = Instance.new("TextLabel")
            distL.Size, distL.Position, distL.BackgroundTransparency = UDim2.new(1, 0, 0.25, 0), UDim2.new(0, 0, 0.75, 0), 1
            distL.Text, distL.TextColor3 = "", Color3.new(1, 1, 0)
            distL.TextScaled, distL.Font = true, Enum.Font.SourceSans
            distL.Parent = bb
            local box = Drawing.new("Square")
            box.Thickness = 1
            local skeleton = {}
            if ShowSkeletons then
                local parts = {
                    "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm",
                    "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg",
                    "RightUpperLeg", "RightLowerLeg"
                }
                for _, part in pairs(parts) do
                    skeleton[part] = Drawing.new("Line")
                    skeleton[part].Thickness, skeleton[part].Transparency = 1, 1
                    skeleton[part].Color = ESPColor
                end
            end
            ESPs[plr] = {hl = hl, bb = bb, toolL = toolL, healthL = healthL, distL = distL, hum = hum, box = box, skeleton = skeleton}
        end
    end
end

local function updateESP(plr)
    if ESPs[plr] and plr.Character and ESPEnabled then
        local char, root = plr.Character, plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tool = char:FindFirstChildOfClass("Tool")
        ESPs[plr].toolL.Text = tool and tool.Name or "Sem Tool"
        if ShowHealth and ESPs[plr].hum then ESPs[plr].healthL.Text = "HP: " .. math.floor(ESPs[plr].hum.Health) else ESPs[plr].healthL.Text = "" end
        if ShowDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            ESPs[plr].distL.Text = math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
        else ESPs[plr].distL.Text = "" end
        if ShowBoxes and ESPs[plr].box then
            local top, bottom = camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position), camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position)
            if top and bottom and top.Y > bottom.Y then
                ESPs[plr].box.Size = Vector2.new(50, math.max(10, top.Y - bottom.Y))
                ESPs[plr].box.Position = Vector2.new(top.X - 25, bottom.Y)
                ESPs[plr].box.Color = ESPColor
                ESPs[plr].box.Visible = true
            else
                ESPs[plr].box.Visible = false
            end
        end
        if ShowSkeletons and ESPs[plr].skeleton then
            for part, line in pairs(ESPs[plr].skeleton) do
                local p = char:FindFirstChild(part)
                if p and p:IsA("BasePart") then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Position)
                    if onScreen then
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Visible = true
                        if part == "Head" and char:FindFirstChild("UpperTorso") then
                            local torsoPos, onScreenTorso = camera:WorldToViewportPoint(char.UpperTorso.Position)
                            if onScreen and onScreenTorso then line.From = Vector2.new(torsoPos.X, torsoPos.Y) end
                        elseif part == "UpperTorso" and char:FindFirstChild("LowerTorso") then
                            local lowerPos, onScreenLower = camera:WorldToViewportPoint(char.LowerTorso.Position)
                            if onScreen and onScreenLower then line.From = Vector2.new(lowerPos.X, lowerPos.Y) end
                        end
                    else
                        line.Visible = false
                    end
                end
            end
        end
    end
end

local function removeESP(plr)
    if ESPs[plr] then
        pcall(function()
            ESPs[plr].hl:Destroy()
            ESPs[plr].bb:Destroy()
            if ESPs[plr].box then ESPs[plr].box:Remove() end
            if ESPs[plr].skeleton then
                for _, line in pairs(ESPs[plr].skeleton) do
                    if line then line:Remove() end
                end
            end
            ESPs[plr] = nil
        end)
    end
end

local function toggleESP(val)
    ESPEnabled = val
    if not val then
        for plr in pairs(ESPs) do removeESP(plr) end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and not ESPs[plr] and plr.Character then createESP(plr) end
        end
    end
end

local function updateESPColor()
    if ESPEnabled and ESPRainbow then
        ESPColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    elseif ESPEnabled then
        ESPColor = Color3.fromRGB(255, 0, 0)
    end
    for plr, esp in pairs(ESPs) do
        if esp.hl then esp.hl.FillColor = ESPColor end
        if esp.box and esp.box.Visible then esp.box.Color = ESPColor end
        if esp.skeleton then
            for _, line in pairs(esp.skeleton) do
                if line.Visible then line.Color = ESPColor end
            end
        end
    end
end

-- Aimbot Enhanced
local Aimbot = {
    Settings = {Enabled = false, TeamCheck = false, AliveCheck = true, WallCheck = false, LockMode = 1, LockPart = "Head", TriggerKey = Enum.UserInputType.MouseButton2, Toggle = false},
    FOVSettings = {Enabled = true, Visible = true, Radius = 90, NumSides = 60, Thickness = 1, Transparency = 1, Filled = false, Color = Color3.fromRGB(255, 255, 255), LockedColor = Color3.fromRGB(255, 150, 150)}
}
local FOVCircle, FOVCircleOutline = Drawing.new("Circle"), Drawing.new("Circle")
local AimbotLocked, RequiredDistance, Running = nil, 2000, false
local ServiceConnections = {}

local function CancelLock()
    AimbotLocked = nil
    pcall(function() FOVCircle.Color = Aimbot.FOVSettings.Color end)
    pcall(function() UserInputService.MouseDeltaSensitivity = 1 end)
end

local function GetClosestPlayer()
    if not AimbotLocked then
        RequiredDistance = Aimbot.FOVSettings.Enabled and Aimbot.FOVSettings.Radius or 2000
        for _, v in pairs(Players:GetPlayers()) do
            if v == player or table.find(Aimbot.Blacklisted or {}, v.Name) then continue end
            local char = v.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and char:FindFirstChild(Aimbot.Settings.LockPart) and hum.Health > 0 then
                local pos = char[Aimbot.Settings.LockPart].Position
                local vec, onScreen = camera:WorldToViewportPoint(pos)
                local dist = (UserInputService:GetMouseLocation() - Vector2.new(vec.X, vec.Y)).Magnitude
                if onScreen and dist < RequiredDistance then RequiredDistance, AimbotLocked = dist, v end
            end
        end
    elseif AimbotLocked and AimbotLocked.Character and AimbotLocked.Character:FindFirstChild(Aimbot.Settings.LockPart) then
        local dist = (UserInputService:GetMouseLocation() - Vector2.new(camera:WorldToViewportPoint(AimbotLocked.Character[Aimbot.Settings.LockPart].Position).X, camera:WorldToViewportPoint(AimbotLocked.Character[Aimbot.Settings.LockPart].Position).Y)).Magnitude
        if dist > RequiredDistance then CancelLock() end
    else CancelLock() end
end

local function LoadAimbot()
    ServiceConnections.RenderStepped = RunService.RenderStepped:Connect(function()
        local success, err = pcall(function()
            if Aimbot.Settings.Enabled and Aimbot.FOVSettings.Enabled then
                FOVCircle.Radius, FOVCircle.NumSides, FOVCircle.Thickness, FOVCircle.Transparency, FOVCircle.Filled = Aimbot.FOVSettings.Radius, Aimbot.FOVSettings.NumSides, Aimbot.FOVSettings.Thickness, Aimbot.FOVSettings.Transparency, Aimbot.FOVSettings.Filled
                FOVCircleOutline.Radius, FOVCircleOutline.NumSides, FOVCircleOutline.Thickness, FOVCircleOutline.Transparency, FOVCircleOutline.Filled = Aimbot.FOVSettings.Radius, Aimbot.FOVSettings.NumSides, Aimbot.FOVSettings.Thickness + 1, Aimbot.FOVSettings.Transparency, Aimbot.FOVSettings.Filled
                FOVCircle.Color = AimbotLocked and Aimbot.FOVSettings.LockedColor or Aimbot.FOVSettings.Color
                FOVCircleOutline.Color = Color3.fromRGB(0, 0, 0)
                FOVCircle.Position, FOVCircleOutline.Position = UserInputService:GetMouseLocation(), UserInputService:GetMouseLocation()
                FOVCircle.Visible, FOVCircleOutline.Visible = true, true
            else FOVCircle.Visible, FOVCircleOutline.Visible = false, false end
            if Running and Aimbot.Settings.Enabled then
                GetClosestPlayer()
                if AimbotLocked and AimbotLocked.Character and AimbotLocked.Character:FindFirstChild(Aimbot.Settings.LockPart) then
                    local targetPos = AimbotLocked.Character[Aimbot.Settings.LockPart].Position
                    if Aimbot.Settings.LockMode == 1 then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                    end
                    if AutoShootEnabled then
                        pcall(function() game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game) task.wait(0.1) game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game) end)
                    end
                end
            end
        end)
        if not success and DebugMode then debugLog("Aimbot Error: " .. err) end
    end)
    ServiceConnections.InputBegan = UserInputService.InputBegan:Connect(function(Input)
        if Typing then return end
        if (Input.UserInputType == Aimbot.Settings.TriggerKey) or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Aimbot.Settings.TriggerKey) then
            if Aimbot.Settings.Toggle then Running = not Running if not Running then CancelLock() end else Running = true end
        end
    end)
    ServiceConnections.InputEnded = UserInputService.InputEnded:Connect(function(Input)
        if Aimbot.Settings.Toggle or Typing then return end
        if (Input.UserInputType == Aimbot.Settings.TriggerKey) or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Aimbot.Settings.TriggerKey) then
            Running = false CancelLock()
        end
    end)
end

-- Teleport with player selection (fixed)
local function getPlayerList()
    local playersList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(playersList, plr.Name)
        end
    end
    return playersList
end

local function teleportToPlayer(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character:WaitForChild("HumanoidRootPart", 2) -- Aguarda até 2 segundos
        local playerRoot = player.Character:WaitForChild("HumanoidRootPart", 2) -- Aguarda até 2 segundos
        if targetRoot and playerRoot then
            task.wait(0.1) -- Pequeno atraso para garantir que o personagem esteja pronto
            local success, err = pcall(function()
                playerRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 2, 0))
            end)
            if success then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Sucesso",
                    Text = "Teletransportado para " .. name,
                    Duration = 3
                })
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Erro",
                    Text = "Falha ao teletransportar. Tente novamente. (Erro: " .. (err or "Desconhecido") .. ")",
                    Duration = 5
                })
                debugLog("Teleport Error: " .. (err or "Desconhecido"))
            end
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Erro",
                Text = "Jogador ou personagem não carregado corretamente.",
                Duration = 5
            })
        end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro",
            Text = "Jogador não encontrado ou não carregado.",
            Duration = 5
        })
    end
end

-- Reset Character
local function resetCharacter()
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Update Loop
RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                if not ESPs[plr] and plr.Character then createESP(plr) end
                updateESP(plr)
            end
        end
        updateESPColor()
    end
end)

-- Events
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESPEnabled then createESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if GodmodeEnabled then toggleGodmode(true) end
    if FlyEnabled then startFly() end
    if NoclipEnabled then toggleNoclip(true) end
    if WalkSpeedEnabled then toggleWalkSpeed(true) end
    if SpeedHackEnabled then toggleSpeedHack(true) end
    if ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and not ESPs[plr] and plr.Character then createESP(plr) end
        end
    end
end)

-- Tabs
local MainTab = Window:CreateTab("Main", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Main Tab
MainTab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly_Toggle", Callback = function(v) FlyEnabled = v startFly() end})
MainTab:CreateSlider({Name = "Fly Speed", Range = {16, 30}, Increment = 1, Suffix = "Speed", CurrentValue = 30, Flag = "Fly_Speed", Callback = function(v) FlySpeedValue = v end})
MainTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "Noclip_Toggle", Callback = function(v) toggleNoclip(v) end})
MainTab:CreateToggle({Name = "Godmode", CurrentValue = false, Flag = "God_Toggle", Callback = function(v) toggleGodmode(v) end})
MainTab:CreateToggle({Name = "WalkSpeed", CurrentValue = false, Flag = "WS_Toggle", Callback = function(v) toggleWalkSpeed(v) end})
MainTab:CreateSlider({Name = "Walk Speed", Range = {16, 25}, Increment = 1, Suffix = "Speed", CurrentValue = 16, Flag = "WS_Value", Callback = function(v) WalkSpeedValue = v end})
MainTab:CreateToggle({Name = "Speed Hack", CurrentValue = false, Flag = "Speed_Toggle", Callback = function(v) SpeedHackEnabled = v toggleSpeedHack(v) end})
MainTab:CreateSlider({Name = "Speed Multiplier", Range = {1, 1.5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Flag = "Speed_Value", Callback = function(v) SpeedValue = v end})

-- ESP Tab
ESPTab:CreateToggle({Name = "Ativar ESP", CurrentValue = false, Flag = "ESP_Toggle", Callback = function(v) toggleESP(v) end})
ESPTab:CreateColorPicker({Name = "Cor ESP", Color = Color3.fromRGB(255, 0, 0), Flag = "ESP_Color", Callback = function(c) if not ESPRainbow then ESPColor = c end end})
ESPTab:CreateToggle({Name = "ESP Rainbow", CurrentValue = false, Flag = "ESP_Rainbow", Callback = function(v) ESPRainbow = v updateESPColor() end})
ESPTab:CreateToggle({Name = "Mostrar Saúde", CurrentValue = false, Flag = "Health_Toggle", Callback = function(v) ShowHealth = v end})
ESPTab:CreateToggle({Name = "Mostrar Distância", CurrentValue = false, Flag = "Dist_Toggle", Callback = function(v) ShowDistance = v end})
ESPTab:CreateToggle({Name = "Caixas 2D", CurrentValue = false, Flag = "Boxes_Toggle", Callback = function(v) ShowBoxes = v end})
ESPTab:CreateToggle({Name = "Skeletons", CurrentValue = false, Flag = "Skeletons_Toggle", Callback = function(v) ShowSkeletons = v end})

-- Aimbot Tab
AimbotTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Flag = "Aim_Toggle", Callback = function(v) Aimbot.Settings.Enabled = v if v and not ServiceConnections.RenderStepped then pcall(LoadAimbot) end end})
AimbotTab:CreateToggle({Name = "Auto Shoot", CurrentValue = false, Flag = "AutoShoot_Toggle", Callback = function(v) AutoShootEnabled = v end})
AimbotTab:CreateSlider({Name = "FOV", Range = {50, 200}, Increment = 10, Suffix = "px", CurrentValue = 90, Flag = "Aim_FOV", Callback = function(v) Aimbot.FOVSettings.Radius = v end})
AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = false, Flag = "Team_Check", Callback = function(v) Aimbot.Settings.TeamCheck = v end})
AimbotTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Flag = "Wall_Check", Callback = function(v) Aimbot.Settings.WallCheck = v end})
AimbotTab:CreateDropdown({Name = "Lock Part", Options = {"Head", "Torso", "HumanoidRootPart"}, CurrentOption = "Head", Flag = "Lock_Part", Callback = function(v) Aimbot.Settings.LockPart = v end})
AimbotTab:CreateLabel("Use Botão Direito para lockar alvo.")
AimbotTab:CreateToggle({Name = "Debug Mode", CurrentValue = false, Flag = "Debug_Toggle", Callback = function(v) DebugMode = v end})

-- Misc Tab
MiscTab:CreateDropdown({Name = "Teleport to Player", Options = getPlayerList(), CurrentOption = "", Flag = "Teleport_Player", Callback = function(v) teleportToPlayer(v) end})
MiscTab:CreateButton({Name = "Reset Character", Callback = function() resetCharacter() end})

-- Update player list for dropdown
Players.PlayerAdded:Connect(function()
    local dropdown = MiscTab:GetDropdown("Teleport to Player")
    if dropdown then
        dropdown:SetOptions(getPlayerList())
    end
end)
Players.PlayerRemoving:Connect(function()
    local dropdown = MiscTab:GetDropdown("Teleport to Player")
    if dropdown then
        dropdown:SetOptions(getPlayerList())
    end
end)

-- Cleanup
MainTab:CreateButton({Name = "Fechar Menu", Callback = function()
    Rayfield:Destroy()
    for _, conn in pairs(ServiceConnections) do pcall(function() conn:Disconnect() end) end
    if FOVCircle then FOVCircle:Remove() end
    if FOVCircleOutline then FOVCircleOutline:Remove() end
    if flyConnection then flyConnection:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if wsConn then wsConn:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    if godConn then godConn:Disconnect() end
    toggleESP(false) -- Ensure ESP is fully disabled on cleanup
end})

Rayfield:Notify({Title = "Hub Agiotagem Carregado", Content = "Aimbot, Fly, Noclip, Godmode, ESP, Teleport funcionando!", Duration = 5, Image = 4483362458})

local PlayerGui = player:WaitForChild("PlayerGui")
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingGui"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 400, 0, 300)
loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
loadingFrame.BackgroundTransparency = 0.2
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = loadingGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Carregando Hub Agiotagem..."
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = loadingFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.1, 0)
statusLabel.Position = UDim2.new(0, 0, 0.9, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Iniciando..."
statusLabel.TextColor3 = Color3.new(1, 1, 0)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = loadingFrame

local startTime = tick()
spawn(function()
    repeat task.wait(0.1) statusLabel.Text = "Status: Carregando... (" .. math.floor(5 - (tick() - startTime)) .. "s)" until tick() - startTime >= 5
    statusLabel.Text = "Status: Pronto!"
    task.wait(1)
    loadingGui:Destroy()
end)
