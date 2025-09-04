-- LOAD LIBRARY
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()
local Main = library:CreateWindow("MTLB KRUSH","Crimson")

-- CREATE TABS
local tabRage = Main:CreateTab("Rage")
local tabVisual = Main:CreateTab("Visual")
local tabAim = Main:CreateTab("Aim")
local tabMisc = Main:CreateTab("Misc")
local tabCredits = Main:CreateTab("Credits")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

---------------------------------------------------------
-- GUI MINIMIZE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        Main:Toggle()
    end
end)


---------------------------------------------------------
-- ESP CONFIG
local ESPEnabled = false
local ESPBoxEnabled = false
local ESPNameEnabled = false
local ESPDistanceEnabled = false
local MaxESPDistance = 800
local ESPs = {}

local function CreateESP(player)
    if ESPs[player] then return ESPs[player] end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255,0,0)
    box.Thickness = 2
    box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false
    name.Text = player.Name
    name.Color = Color3.fromRGB(255,255,255)
    name.Size = 18
    name.Center = true

    local distance = Drawing.new("Text")
    distance.Visible = false
    distance.Text = ""
    distance.Color = Color3.fromRGB(255,255,0)
    distance.Size = 16
    distance.Center = true

    ESPs[player] = {Box = box, Name = name, Distance = distance}
    return ESPs[player]
end

local function RemoveESP(player)
    if ESPs[player] then
        ESPs[player].Box:Remove()
        ESPs[player].Name:Remove()
        ESPs[player].Distance:Remove()
        ESPs[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateESP(p)
    end
end

---------------------------------------------------------
-- AIMBOT CONFIG
local AimbotEnabled = false
local AimFOV = 100
local AimTarget = "Head"

local AimCircle = Drawing.new("Circle")
AimCircle.Radius = AimFOV
AimCircle.Color = Color3.fromRGB(255,0,0)
AimCircle.Thickness = 2
AimCircle.Filled = false
AimCircle.Visible = false

local function getClosestPart()
    local mousePos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest = nil
    local minDist = AimFOV
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimTarget) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local headPos, onScreen = Camera:WorldToViewportPoint(player.Character[AimTarget].Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y)-mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player.Character[AimTarget]
                    end
                end
            end
        end
    end
    return closest
end

---------------------------------------------------------
-- TELEKILL CONFIG
local TelekillEnabled = false
local TelekillDistance = 5
local TelekillCooldown = 0.05
local TelekillRadius = 1000

local function getClosestPlayerForTelekill()
    local closestPlayer = nil
    local shortestDistance = TelekillRadius
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local localRoot = LocalPlayer.Character.HumanoidRootPart
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local root = player.Character.HumanoidRootPart
                    local dist = (root.Position - localRoot.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

spawn(function()
    while true do
        if TelekillEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPlayer = getClosestPlayerForTelekill()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = targetPlayer.Character.HumanoidRootPart
                local localRoot = LocalPlayer.Character.HumanoidRootPart
                local direction = (targetRoot.Position - localRoot.Position).Unit
                local newPosition = targetRoot.Position - direction * TelekillDistance
                localRoot.CFrame = CFrame.new(newPosition)
            end
        end
        wait(TelekillCooldown)
    end
end)

---------------------------------------------------------
-- SPINBOT CONFIG
local SpinbotEnabled = false
local SpinSpeed = 30

---------------------------------------------------------
-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    -- ESP
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local localRoot = LocalPlayer.Character.HumanoidRootPart
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local esp = CreateESP(player)
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.Distance.Visible = false
                    else
                        local distance = (char.HumanoidRootPart.Position - localRoot.Position).Magnitude
                        if distance > MaxESPDistance or not ESPEnabled then
                            esp.Box.Visible = false
                            esp.Name.Visible = false
                            esp.Distance.Visible = false
                        else
                            local points = {}
                            for _, part in pairs(char:GetChildren()) do
                                if part:IsA("BasePart") then
                                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                                    if onScreen then
                                        table.insert(points, Vector2.new(screenPos.X, screenPos.Y))
                                    end
                                end
                            end
                            if #points >= 2 then
                                local minX,maxX = math.huge,-math.huge
                                local minY,maxY = math.huge,-math.huge
                                for _,p in pairs(points) do
                                    minX = math.min(minX,p.X)
                                    maxX = math.max(maxX,p.X)
                                    minY = math.min(minY,p.Y)
                                    maxY = math.max(maxY,p.Y)
                                end
                                if ESPBoxEnabled then
                                    esp.Box.Position = Vector2.new(minX,minY)
                                    esp.Box.Size = Vector2.new(maxX-minX,maxY-minY)
                                    esp.Box.Visible = true
                                else
                                    esp.Box.Visible = false
                                end
                                if ESPNameEnabled then
                                    local head = char:FindFirstChild("Head")
                                    if head then
                                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                                        if onScreen then
                                            esp.Name.Position = Vector2.new(headPos.X, headPos.Y-18)
                                            esp.Name.Text = player.Name
                                            esp.Name.Visible = true
                                        else
                                            esp.Name.Visible = false
                                        end
                                    end
                                else
                                    esp.Name.Visible = false
                                end
                                if ESPDistanceEnabled then
                                    local head = char:FindFirstChild("Head")
                                    if head then
                                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                                        if onScreen then
                                            esp.Distance.Position = Vector2.new(headPos.X, headPos.Y)
                                            esp.Distance.Text = "["..math.floor(distance).."m]"
                                            esp.Distance.Visible = true
                                        else
                                            esp.Distance.Visible = false
                                        end
                                    end
                                else
                                    esp.Distance.Visible = false
                                end
                            else
                                esp.Box.Visible = false
                                esp.Name.Visible = false
                                esp.Distance.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end

    -- AIMBOT
    AimCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPart()
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- SPINBOT
    if SpinbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0))
    end
end)

---------------------------------------------------------
-- GUI RAGE
tabRage:CreateToggle("TeleKill", function(state)
    TelekillEnabled = state
end)

tabRage:CreateSlider("TP Distance", 1, 15, function(value)
    TelekillDistance = value
end)

tabRage:CreateToggle("Spinbot", function(state)
    SpinbotEnabled = state
end)

---------------------------------------------------------
-- MOD ARMA (Rage)
local armasPermitidas = {
    "Arma de Brinquedo","Glock","Classic Standard","Glock Candy Apple","GlockHalloween",
    "Pinker Gun","GlockMario","Pistola","Pistola Angel","Pistola Booster","Pistola Brinquedo",
    "Pistola Bunny","Pistola Demon","Pistola Demon Blue","Pistola Demon Pink","Pistola Ghost",
    "Pistola Hustle Blue","Pistola Grey","Pistola Hustle Blue-S","Pistola Hustle Pink",
    "Pistola Magnum","Pistola Hustle Pink-S","Pistola Purple Ghost","Pistola Maxwell",
    "Pistola Savage","Pistola Spectre","Pistola Standard","Pistola USP","Pistola White",
    "Fuzil","Parafal","Parafal Rosa","G3","Fuzil Safira","Fuzil Booster","AK"
}

local PADRAO = { FireRate = 0.2, FireType = "Semi", ReloadTime = 1.2 }
local MODS   = { FireRate = 0, FireType = "Auto", ReloadTime = 0 }

local originalValues, connectionsWP, WeaponPatcherEnabled = {}, {}, false

local function findValueInstance(root, name)
    if not root then return nil end
    local ok, inst = pcall(function() return root:FindFirstChild(name, true) end)
    if ok then return inst end
end

local function getValueFromInstance(inst)
    if inst:IsA("NumberValue") or inst:IsA("IntValue") then return inst.Value end
    if inst:IsA("StringValue") or inst:IsA("BoolValue") then return inst.Value end
end

local function setValueOnInstance(inst, value)
    if inst:IsA("NumberValue") or inst:IsA("IntValue") then inst.Value = tonumber(value) return true end
    if inst:IsA("StringValue") then inst.Value = tostring(value) return true end
    if inst:IsA("BoolValue") then inst.Value = (value == true or value == "true") return true end
end

local function trySetProperty(tool, prop, newValue)
    local inst = findValueInstance(tool, prop)
    if inst then
        originalValues[tool] = originalValues[tool] or {}
        if originalValues[tool][prop] == nil then
            originalValues[tool][prop] = getValueFromInstance(inst)
        end
        pcall(setValueOnInstance, inst, newValue)
        return true
    end
    local okAttr, attrVal = pcall(function() return tool:GetAttribute(prop) end)
    if okAttr and attrVal ~= nil then
        originalValues[tool] = originalValues[tool] or {}
        if originalValues[tool][prop] == nil then originalValues[tool][prop] = attrVal end
        pcall(function() tool:SetAttribute(prop, newValue) end)
        return true
    end
    local okProp, curProp = pcall(function() return tool[prop] end)
    if okProp then
        originalValues[tool] = originalValues[tool] or {}
        if originalValues[tool][prop] == nil then originalValues[tool][prop] = curProp end
        pcall(function() tool[prop] = newValue end)
        return true
    end
    return false
end

local function applyModsToTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    trySetProperty(tool,"FireRate",MODS.FireRate)
    trySetProperty(tool,"FireType",MODS.FireType)
    trySetProperty(tool,"ReloadTime",MODS.ReloadTime)
end

local function revertTool(tool)
    local orig = originalValues[tool]
    if orig then
        trySetProperty(tool,"FireRate",orig.FireRate or PADRAO.FireRate)
        trySetProperty(tool,"FireType",orig.FireType or PADRAO.FireType)
        trySetProperty(tool,"ReloadTime",orig.ReloadTime or PADRAO.ReloadTime)
        originalValues[tool] = nil
    else
        trySetProperty(tool,"FireRate",PADRAO.FireRate)
        trySetProperty(tool,"FireType",PADRAO.FireType)
        trySetProperty(tool,"ReloadTime",PADRAO.ReloadTime)
    end
end

local function isAllowed(tool)
    return tool and table.find(armasPermitidas, tool.Name) ~= nil
end

local function onToolAdded(child)
    if child:IsA("Tool") and isAllowed(child) then
        task.wait(0.05)
        applyModsToTool(child)
    end
end

local function checkContainerAndApply(container)
    for _,child in pairs(container:GetChildren()) do
        if child:IsA("Tool") and isAllowed(child) then
            task.spawn(function()
                task.wait(0.05)
                applyModsToTool(child)
            end)
        end
    end
end

local function onCharacterAdded(char)
    task.wait(0.2)
    checkContainerAndApply(char)
    local cconn = char.ChildAdded:Connect(onToolAdded)
    table.insert(connectionsWP, cconn)
end

tabRage:CreateToggle("Mod Arma", function(state)
    if state then
        if not WeaponPatcherEnabled then
            WeaponPatcherEnabled = true
            checkContainerAndApply(LocalPlayer.Backpack)
            if LocalPlayer.Character then
                onCharacterAdded(LocalPlayer.Character)
            end
            local bconn = LocalPlayer.Backpack.ChildAdded:Connect(onToolAdded)
            local cadd = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
            table.insert(connectionsWP, bconn)
            table.insert(connectionsWP, cadd)
        end
    else
        if WeaponPatcherEnabled then
            WeaponPatcherEnabled = false
            for _,c in pairs(connectionsWP) do pcall(function() c:Disconnect() end) end
            connectionsWP = {}
            for _,t in pairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and isAllowed(t) then revertTool(t) end
            end
            if LocalPlayer.Character then
                for _,t in pairs(LocalPlayer.Character:GetChildren()) do
                    if t:IsA("Tool") and isAllowed(t) then revertTool(t) end
                end
            end
        end
    end
end)

---------------------------------------------------------
-- GUI AIM
tabAim:CreateCheckbox("Aimbot", function(state)
    AimbotEnabled = state
    AimCircle.Visible = state
end)

tabAim:CreateSlider("Aim FOV", 1, 300, function(value)
    AimFOV = value
    AimCircle.Radius = value
end)

tabAim:CreateDropdown("Aimbot Rage", {"Head", "Torso", "Neck"}, function(selection)
    AimTarget = selection
end)


-------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AimLockEnabled = false

-- Função para alterar hitbox
local function modifyHitbox(player, size)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hitbox = player.Character.HumanoidRootPart
        hitbox.Size = size
        hitbox.Transparency = 1.0
    end
end

tabAim:CreateCheckbox("Silent Aim", function(state)
    AimLockEnabled = state
end)

-- Loop a cada frame
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if AimLockEnabled then
                modifyHitbox(player, Vector3.new(22, 39, 22)) -- Hitbox maior
            else
                modifyHitbox(player, Vector3.new(2, 2, 1)) -- Hitbox normal
            end
        end
    end
end)


---------------------------------------------------------
-- GUI VISUAL
tabVisual:CreateCheckbox("ESP", function(state)
    ESPEnabled = state
end)

tabVisual:CreateCheckbox("ESP Box", function(state)
    ESPBoxEnabled = state
end)

tabVisual:CreateCheckbox("ESP Name", function(state)
    ESPNameEnabled = state
end)

------------------

ESPTracerUpEnabled = false

tabVisual:CreateCheckbox("ESP Tracer", function(state)
    ESPTracerUpEnabled = state

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Tracers = {}

-- Cria o tracer para o player
local function CreateTracer(player)
    if player == LocalPlayer or Tracers[player] then return end

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1 -- Tornando a linha mais fina
    tracer.Color = Color3.fromRGB(252, 3, 36)
    tracer.Transparency = 1
    tracer.Visible = false

    Tracers[player] = tracer
end

-- Remove o tracer quando o player sai
local function RemoveTracer(player)
    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end
end

-- Atualiza os tracers na tela
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            if not Tracers[player] then
                CreateTracer(player)
            end

            local tracer = Tracers[player]
            local character = player.Character
            local head = character.Head
            local humanoid = character:FindFirstChild("Humanoid")

            if ESPTracerUpEnabled and humanoid.Health > 0 then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local topPos = Vector2.new(Camera.ViewportSize.X / 2, 10)  -- Alinha a linha no topo da tela

                if headPos.Z > 0 then
                    tracer.From = topPos
                    tracer.To = Vector2.new(headPos.X, headPos.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        elseif Tracers[player] then
            Tracers[player].Visible = false
        end
    end
end)

-- Eventos de jogador
Players.PlayerAdded:Connect(CreateTracer)
Players.PlayerRemoving:Connect(RemoveTracer)

-- Inicializar
for _, player in pairs(Players:GetPlayers()) do
    CreateTracer(player)
end

end)

--------------------------------------

tabVisual:CreateCheckbox("ESP Distance", function(state)
    ESPDistanceEnabled = state
end)

tabVisual:CreateSlider("Distance", 50, 1000, function(value)
    MaxESPDistance = value
end)

-------------------------------------------

tabVisual:CreateCheckbox("Radar MAP", function(state)
    RadarENABLED = state
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG
local radarSize = 150
local radarRange = 100  -- Quanto mais, maior o alcance
local radarPos = Vector2.new(1790, 200) -- posição do radar na tela

-- Radar círculo
local radarCircle = Drawing.new("Circle")
radarCircle.Position = radarPos
radarCircle.Radius = radarSize / 2
radarCircle.Color = Color3.fromRGB(255, 255, 255)
radarCircle.Thickness = 1
radarCircle.Filled = false
radarCircle.Visible = false

-- Ponto central
local centerDot = Drawing.new("Circle")
centerDot.Position = radarPos
centerDot.Radius = 2
centerDot.Color = Color3.fromRGB(255, 0, 0)
centerDot.Filled = true
centerDot.Visible = false

-- Lista de pontos dos players
local playerDots = {}

-- Limpar dots
local function clearDots()
	for _, dot in pairs(playerDots) do
		dot:Remove()
	end
	playerDots = {}
end

RunService.RenderStepped:Connect(function()
	clearDots()

	if not RadarENABLED then
		radarCircle.Visible = false
		centerDot.Visible = false
		return
	end

	radarCircle.Visible = true
	centerDot.Visible = true

	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

	local myPos = myChar.HumanoidRootPart.Position
	local camLook = Camera.CFrame.LookVector

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local offset = hrp.Position - myPos

			if offset.Magnitude <= radarRange then
				-- Direção baseada na CÂMERA (não personagem)
				local forward = Vector3.new(camLook.X, 0, camLook.Z).Unit
				local right = Vector3.new(-forward.Z, 0, forward.X) -- Perpendicular

				local x = right:Dot(offset)
				local z = forward:Dot(offset)

				local scaled = Vector2.new(x, z) / radarRange * (radarSize / 2)

				local dot = Drawing.new("Circle")
				dot.Radius = 3
				dot.Filled = true
				dot.Color = Color3.fromRGB(0, 255, 0)
				dot.Position = radarPos + scaled
				dot.Visible = true
				table.insert(playerDots, dot)
			end
		end
	end
end)

---------------------------------------------

-- GUI MISC
tabMisc:CreateButton("FUCKER PVP", function()
    local maps = workspace:FindFirstChild("ClientMaps")
    if maps and maps:FindFirstChild("/pvp") then
        maps["/pvp"]:Destroy()
        print("🔥 FUCKER PVP ativado: /pvp destruído")
    else
        warn("❌ /pvp não encontrado")
    end
end)

local PVP2Clone
tabMisc:CreateToggle("Bug PVP2", function(enabled)
    if enabled then
        local original = workspace.ClientMaps["/pvp2"]:GetChildren()[16]
        if original then
            PVP2Clone = original:Clone()
            PVP2Clone.Parent = workspace
            PVP2Clone.CFrame = CFrame.new(-11495.97, 18.06, 13188.85)
            PVP2Clone.Size = Vector3.new(1.96,120,99.44)
            if PVP2Clone:IsA("BasePart") then
                PVP2Clone.Transparency = 0.7
            elseif PVP2Clone.PrimaryPart then
                PVP2Clone.PrimaryPart.Transparency = 0.7
            end
        end
    else
        if PVP2Clone then
            PVP2Clone:Destroy()
            PVP2Clone = nil
        end
    end
end)

tabMisc:CreateButton("TP PVP2", function()
    if PVP2Clone and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PVP2Clone.Position + Vector3.new(0, PVP2Clone.Size.Y + 5, 0))
    end
end)

tabMisc:CreateToggle("WFucker Rua", function(enabled)
    if enabled then
        local rua = workspace.ClientMaps["/rua"]
        if not rua then return end
        local ruaParts = {
            {CFrame.new(3811.5, 91.6, -452.9), rua:GetChildren()[815]},
            {CFrame.new(3543.0, 86.1, -711.4), rua:GetChildren()[1038]},
            {CFrame.new(3642.5, 67.1, -776.1), rua:GetChildren()[1035]},
            {CFrame.new(3611.0, 67.1, -831.3), rua:GetChildren()[822]},
            {CFrame.new(3543.0, 97.5, -553.7), rua:GetChildren()[814]},
            {CFrame.new(3604.3, 83.5, -532.3), rua:GetChildren()[824]}
        }
        for _, info in ipairs(ruaParts) do
            local cf, antigo = info[1], info[2]
            local size = Vector3.new(10,10,10)
            if antigo and antigo:IsA("BasePart") then size = antigo.Size
            elseif antigo and antigo.PrimaryPart then size = antigo.PrimaryPart.Size end
            if antigo then antigo:Destroy() end
            local part = Instance.new("Part")
            part.CFrame = cf
            part.Size = size
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.4
            part.Color = Color3.fromRGB(255,0,0)
            part.Parent = rua
        end
    end
end)

tabMisc:CreateToggle("WFucker Predio", function(enabled)
    if enabled then
        local predioFolder = workspace.ClientMaps:FindFirstChild("/predio")
        if not predioFolder then return end
        local predio = predioFolder:FindFirstChild("parede invisivel predio")
        if predio then
            local size = predio.Size
            predio:Destroy()
            local part = Instance.new("Part")
            part.CFrame = CFrame.new(14130, 7120, -109.3)
            part.Size = size
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.4
            part.Color = Color3.fromRGB(255,0,0)
            part.Parent = predioFolder
        end
    end
end)

tabMisc:CreateButton("TP Predio", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(14130, 7120, -109.3)
    end
end)

tabMisc:CreateButton("Rejoin", function()
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local player = Players.LocalPlayer
    local placeId = game.PlaceId
    local jobId = game.JobId

    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end)

-------------------------------------------

local StarterGui = game:GetService("StarterGui")

tabCredits:CreateButton("LB Cheats", function()
    local discordLink = "https://discord.gg/7CAB4gHPQp"

    -- Copiar para a área de transferência (suportado apenas em alguns executores)
    if setclipboard then
        setclipboard(discordLink)
    end

    -- Notificação no Roblox
    StarterGui:SetCore("SendNotification", {
        Title = "Discord Copiado",
        Text = "Link copiado para a área de transferência!",
        Duration = 5
    })
end)

tabCredits:CreateButton("MathsScripts", function()
    local discordLink = "https://discord.gg/RKTfBBcT"

    -- Copiar para a área de transferência (suportado apenas em alguns executores)
    if setclipboard then
        setclipboard(discordLink)
    end

    -- Notificação no Roblox
    StarterGui:SetCore("SendNotification", {
        Title = "Discord Copiado",
        Text = "Link copiado para a área de transferência!",
        Duration = 5
    })
end)


tabRage:Show()

-- TOGGLE GUI COM INSERT
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Espera o ScreenGui da library existir
local function getMainGUI()
    return CoreGui:WaitForChild("By Shaddow", 10) -- espera até 10s
end

local mainGUI = getMainGUI()
local guiHidden = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        guiHidden = not guiHidden
        if mainGUI then
            mainGUI.Enabled = not guiHidden
        end
    end
end)

-- Toggle WalkSpeed Rage
local WalkSpeedEnabled = false
local WalkSpeedValue = 30
local OriginalWalkSpeed = 16
local CheckInterval = 0.1
local CheckDuration = 5

local function maintainWalkSpeed()
    if not WalkSpeedEnabled then return end -- só funciona se o toggle estiver ativo
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local checks = 0
        local maxChecks = CheckDuration / CheckInterval

        local connection
        connection = RunService.Heartbeat:Connect(function()
            if checks >= maxChecks or not WalkSpeedEnabled then
                connection:Disconnect()
                return
            end

            if humanoid.WalkSpeed ~= WalkSpeedValue then
                humanoid.WalkSpeed = WalkSpeedValue
            end

            checks = checks + 1
        end)
    end
end

-- Detecta quando soltar Shift
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        maintainWalkSpeed()
    end
end)

-- Reaplica WalkSpeed ao trocar de personagem
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = WalkSpeedEnabled and WalkSpeedValue or OriginalWalkSpeed
end)

-- Toggle na aba Rage
tabRage:CreateToggle("Speed Boost", function(state)
    WalkSpeedEnabled = state
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.WalkSpeed = WalkSpeedEnabled and WalkSpeedValue or OriginalWalkSpeed
    end
end)
