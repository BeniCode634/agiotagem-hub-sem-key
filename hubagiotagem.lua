-- Hub Agiotagem by ghost dod (Aimbot Exunys V3 Enhanced - Anti-Cheat Optimized)
-- Versão com chave de ativação e novas funcionalidades
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Erro ao carregar Rayfield: " .. err)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Falha ao carregar Rayfield. Verifique seu executor ou conexão.",
        Duration = 5
    })
    return
end

-- Verificar ID do jogo e chave de ativação
local Key = "KEY112301491248DODI" -- Chave fixa
if game.PlaceId ~= 125761045780459 or not Key or Key ~= "KEY112301491248DODI" then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro",
        Text = "Chave inválida ou jogo incorreto. Use KEY112301491248DODI no jogo ID 125761045780459.",
        Duration = 5
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Hub Agiotagem",
    LoadingTitle = "Carregando Hub Agiotagem",
    LoadingSubtitle = "Versão 2025 Anti-Cheat",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

local Players, RunService, UserInputService, Workspace, TweenService = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Workspace"), game:GetService("TweenService")
local player, camera = Players.LocalPlayer, Workspace.CurrentCamera

-- Variáveis globais
local ESPEnabled, ESPColor, ShowHealth, ShowDistance, ShowTracers, ShowBoxes, ShowSkeletons, ESPRainbow = false, Color3.fromRGB(255, 0, 0), false, false, false, false, false, false
local ESPs, FlyEnabled, NoclipEnabled, GodmodeEnabled, WalkSpeedEnabled, SpeedHackEnabled = {}, false, false, false, false, false
local AimbotEnabled, AutoShootEnabled, AimbotFOV, WalkSpeedValue, FlySpeedValue, SpeedValue = false, false, 90, 16, 30, 1.5
local TeleportTarget, DebugMode = nil, false

-- Função de debug
local function debugLog(message)
    if DebugMode then print("[Debug] " .. message) end
end

-- Fly (otimizado para anti-cheat)
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
    else if flyConnection then flyConnection:Disconnect() end if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.PlatformStand = false end end
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

-- WalkSpeed e SpeedHack (otimizado para anti-cheat)
local wsConn, speedConn
local function toggleWalkSpeed(val)
    WalkSpeedEnabled = val
    if val then if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = math.clamp(WalkSpeedValue, 16, 25) -- Limite para evitar detecção
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
                if moveDir.Magnitude > 0 then root.Velocity = moveDir * (16 * math.clamp(SpeedValue, 1, 1.5)) end -- Limite de 1.5x
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

-- ESP
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
            local tracer = Drawing.new("Line")
            tracer.From, tracer.To = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y), Vector2.new(0, 0)
            tracer.Color, tracer.Thickness, tracer.Transparency, tracer.Visible = ESPColor, 2, 1, ShowTracers
            local box = Drawing.new("Square")
            box.Thickness, box.Visible = 1, ShowBoxes
            local skeleton = {}
            if ShowSkeletons then
                for _, part in pairs({"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}) do
                    skeleton[part] = Drawing.new("Line")
                    skeleton[part].Thickness, skeleton[part].Transparency = 1, 1
                end
            end
            ESPs[plr] = {hl = hl, bb = bb, toolL = toolL, healthL = healthL, distL = distL, hum = hum, tracer = tracer, box = box, skeleton = skeleton}
        end
    end
end

local function updateESP(plr)
    if ESPs[plr] and plr.Character then
        local char, root = plr.Character, plr.Character.HumanoidRootPart
        local tool = char:FindFirstChildOfClass("Tool")
        ESPs[plr].toolL.Text = tool and tool.Name or "Sem Tool"
        if ShowHealth and ESPs[plr].hum then ESPs[plr].healthL.Text = "HP: " .. math.floor(ESPs[plr].hum.Health) else ESPs[plr].healthL.Text = "" end
        if ShowDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            ESPs[plr].distL.Text = math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
        else ESPs[plr].distL.Text = "" end
        if ShowTracers and ESPs[plr].tracer then
            local pos, onScreen = camera:WorldToViewportPoint(root.Position)
            if onScreen then ESPs[plr].tracer.To = Vector2.new(pos.X, pos.Y) ESPs[plr].tracer.Visible = true else ESPs[plr].tracer.Visible = false end
        end
        if ShowBoxes and ESPs[plr].box then
            local top, bottom = camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, 3, 0)).Position), camera:WorldToViewportPoint((root.CFrame * CFrame.new(0, -3, 0)).Position)
            ESPs[plr].box.Size = Vector2.new(50, top.Y - bottom.Y)
            ESPs[plr].box.Position = Vector2.new(top.X - 25, bottom.Y)
            ESPs[plr].box.Color = ESPColor
            ESPs[plr].box.Visible = true
        end
        if ShowSkeletons and ESPs[plr].skeleton then
            for part, line in pairs(ESPs[plr].skeleton) do
                local p = char:FindFirstChild(part)
                if p and p:IsA("BasePart") then
                    local pos, onScreen = camera:WorldToViewportPoint(p.Position)
                    if onScreen then line.To = Vector2.new(pos.X, pos.Y) line.Visible = true line.Color = ESPColor else line.Visible = false end
                end
            end
        end
    end
end

local function removeESP(plr)
    if ESPs[plr] then
        ESPs[plr].hl:Destroy()
        ESPs[plr].bb:Destroy()
        if ESPs[plr].tracer then ESPs[plr].tracer:Remove() end
        if ESPs[plr].box then ESPs[plr].box:Remove() end
        if ESPs[plr].skeleton then for _, line in pairs(ESPs[plr].skeleton) do if line then line:Remove() end end end
        ESPs[plr] = nil
    end
end

local function toggleESP(val)
    ESPEnabled = val
    if val then for _, plr in pairs(Players:GetPlayers()) do if plr ~= player then createESP(plr) end end
    else for plr in pairs(ESPs) do removeESP(plr) end end
end

local function updateESPColor()
    if ESPRainbow then
        ESPColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    else
        ESPColor = Color3.fromRGB(255, 0, 0) -- Padrão se não for rainbow
    end
    for plr, esp in pairs(ESPs) do
        if esp.hl then esp.hl.FillColor = ESPColor end
        if esp.tracer then esp.tracer.Color = ESPColor end
        if esp.box then esp.box.Color = ESPColor end
        if esp.skeleton then for _, line in pairs(esp.skeleton) do line.Color = ESPColor end end
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

-- Teleport (novo com input de nome)
local function teleportToPlayerByName(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro",
            Text = "Jogador não encontrado ou não carregado.",
            Duration = 5
        })
    end
end

-- Kill Aura
local killAuraConn
local function toggleKillAura(val)
    if val then
        killAuraConn = RunService.Heartbeat:Connect(function()
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local distance = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if distance < 10 then
                        v.Character.Humanoid.Health = 0
                    end
                end
            end
        end)
    else if killAuraConn then killAuraConn:Disconnect() end end
end

-- Auto Farm (exemplo genérico)
local autoFarmConn
local function toggleAutoFarm(val)
    if val then
        autoFarmConn = RunService.Heartbeat:Connect(function()
            -- Substitua por lógica específica do jogo (ex.: coletar itens)
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = root.CFrame + Vector3.new(0, 0, -1) end
        end)
    else if autoFarmConn then autoFarmConn:Disconnect() end end
end

-- Reset Character
local function resetCharacter()
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Loop de atualização
RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then updateESP(plr) end
        end
        updateESPColor()
    end
end)

-- Eventos
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
ESPTab:CreateToggle({Name = "Tracers", CurrentValue = false, Flag = "Tracers_Toggle", Callback = function(v) ShowTracers = v end})
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
MiscTab:CreateInput({Name = "Teleport to Player", PlaceholderText = "Digite o nome do jogador", RemoveTextAfterFocusLost = false, Callback = function(text) teleportToPlayerByName(text) end})
MiscTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Flag = "Kill_Aura", Callback = function(v) toggleKillAura(v) end})
MiscTab:CreateToggle({Name = "Auto Farm", CurrentValue = false, Flag = "Auto_Farm", Callback = function(v) toggleAutoFarm(v) end})
MiscTab:CreateButton({Name = "Reset Character", Callback = function() resetCharacter() end})

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
    if killAuraConn then killAuraConn:Disconnect() end
    if autoFarmConn then autoFarmConn:Disconnect() end
end})

Rayfield:Notify({Title = "Hub Agiotagem Carregado", Content = "Aimbot, Fly, Noclip, Godmode, ESP, Teleport e mais funcionando!", Duration = 5, Image = 4483362458})

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
