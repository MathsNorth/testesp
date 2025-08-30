-- CONFIGURAÇÕES
_G.ESPVisible = true
_G.TeamCheck = false
_G.TextColor = Color3.fromRGB(255, 80, 10)
_G.BoxColor = Color3.fromRGB(255, 0, 0)
_G.TextSize = 14
_G.DisableKey = Enum.KeyCode.Q
_G.SendNotifications = true
_G.Outline = true
_G.OutlineColor = Color3.fromRGB(0,0,0)

-- CHECAR SE O EXECUTOR SUPORTA DRAWING
if not Drawing then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ESP Loader",
        Text = "Seu executor não suporta Drawing.",
        Duration = 5
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPs = {}

-- CRIAR ESP PARA UM PLAYER
local function createESP(player)
    if player == LocalPlayer then return end
    local text = Drawing.new("Text")
    local box = Drawing.new("Square")
    
    ESPs[player] = {Text = text, Box = box}
    
    -- Configurações iniciais
    text.Size = _G.TextSize
    text.Color = _G.TextColor
    text.Outline = _G.Outline
    text.OutlineColor = _G.OutlineColor
    text.Center = true
    text.Visible = _G.ESPVisible
    
    box.Color = _G.BoxColor
    box.Thickness = 2
    box.Filled = false
    box.Visible = _G.ESPVisible
end

-- REMOVER ESP AO SAIR
Players.PlayerRemoving:Connect(function(player)
    if ESPs[player] then
        ESPs[player].Text:Remove()
        ESPs[player].Box:Remove()
        ESPs[player] = nil
    end
end)

-- CRIAR ESP PARA JOGADORES EXISTENTES
for _,player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

-- CRIAR ESP PARA NOVOS PLAYERS
Players.PlayerAdded:Connect(createESP)

-- TOGGLE ESP COM TECLA
local Typing = false
UserInputService.TextBoxFocused:Connect(function() Typing = true end)
UserInputService.TextBoxFocusReleased:Connect(function() Typing = false end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == _G.DisableKey and not Typing then
        _G.ESPVisible = not _G.ESPVisible
        for _,esp in pairs(ESPs) do
            esp.Text.Visible = _G.ESPVisible
            esp.Box.Visible = _G.ESPVisible
        end
        if _G.SendNotifications then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "ESP Loader",
                Text = "ESP agora: "..tostring(_G.ESPVisible),
                Duration = 3
            })
        end
    end
end)

-- LOOP ÚNICO PARA ATUALIZAR ESP
RunService.RenderStepped:Connect(function()
    for player,esp in pairs(ESPs) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if _G.TeamCheck and player.Team == LocalPlayer.Team then
                esp.Text.Visible = false
                esp.Box.Visible = false
            elseif onScreen then
                esp.Text.Position = Vector2.new(pos.X, pos.Y - 40)
                esp.Text.Text = string.format("(%d) %s [%d]", math.floor(dist), player.Name, hum.Health)
                esp.Text.Visible = _G.ESPVisible
                
                esp.Box.Size = Vector2.new(30,40)
                esp.Box.Position = Vector2.new(pos.X-15,pos.Y-40)
                esp.Box.Visible = _G.ESPVisible
            else
                esp.Text.Visible = false
                esp.Box.Visible = false
            end
        else
            esp.Text.Visible = false
            esp.Box.Visible = false
        end
    end
end)

if _G.SendNotifications then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ESP Loader",
        Text = "ESP carregado com sucesso!",
        Duration = 3
    })
end
