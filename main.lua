local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local MAX_DISTANCE = 600
local BAR_LENGTH = 50
local BEAM_STACK = 2

-- Colores
local COLOR_GUI = Color3.fromRGB(150, 200, 250)
local COLOR_LABEL = Color3.fromRGB(90, 140, 200)
local COLOR_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_BORDER = Color3.fromRGB(255, 255, 255)
local COLOR_BEAM = Color3.fromRGB(80, 150, 220)

local activeBars = {}      -- plr.Name -> {attach0, attach1, beams}
local persistentBars = {}  -- plr.Name -> true

-- Crear barra
local function createBar(plr)
	local character = plr.Character
	if not character then return end
	local torso = character:FindFirstChild("HumanoidRootPart") 
		or character:FindFirstChild("UpperTorso") 
		or character:FindFirstChild("Torso")
	if not torso then return end

	-- Borrar barra vieja si existía
	if activeBars[plr.Name] then
		local info = activeBars[plr.Name]
		for _, b in ipairs(info.beams or {}) do b:Destroy() end
		if info.attach0 then info.attach0:Destroy() end
		if info.attach1 then info.attach1:Destroy() end
	end

	local attach0 = Instance.new("Attachment")
	attach0.Name = "BarOrigin"
	attach0.Parent = torso

	local attach1 = Instance.new("Attachment")
	attach1.Name = "BarEnd"
	attach1.Parent = workspace

	local beams = {}
	for i = 1, BEAM_STACK do
		local beam = Instance.new("Beam")
		beam.Attachment0 = attach0
		beam.Attachment1 = attach1
		beam.Width0 = 0.6
		beam.Width1 = 0.6
		beam.Color = ColorSequence.new(COLOR_BEAM)
		beam.FaceCamera = true
		beam.LightEmission = 1
		beam.Transparency = NumberSequence.new(0.05)
		beam.Enabled = true
		beam.Parent = workspace
		table.insert(beams, beam)
	end

	activeBars[plr.Name] = {attach0 = attach0, attach1 = attach1, beams = beams}

	RunService.RenderStepped:Connect(function()
		if not localPlayer.Character or not torso.Parent then
			for _, b in ipairs(beams) do b.Enabled = false end
			return
		end
		local myRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end
		local distance = (myRoot.Position - torso.Position).Magnitude
		if distance > MAX_DISTANCE then
			for _, b in ipairs(beams) do b.Enabled = false end
			return
		end
		local dir = (myRoot.Position - torso.Position).Unit
		attach1.WorldPosition = torso.Position + dir * BAR_LENGTH
		for _, b in ipairs(beams) do b.Enabled = true end
	end)
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BarraGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local MainBorder = Instance.new("Frame")
MainBorder.Size = UDim2.new(0, 220, 0, 180)
MainBorder.Position = UDim2.new(0.5, -110, 0.5, -90)
MainBorder.BackgroundColor3 = COLOR_BORDER
MainBorder.BorderSizePixel = 0
MainBorder.Parent = screenGui

local cornerBorder = Instance.new("UICorner")
cornerBorder.CornerRadius = UDim.new(0,8)
cornerBorder.Parent = MainBorder

local Main = Instance.new("Frame")
Main.Size = UDim2.new(1, -4, 1, -4)
Main.Position = UDim2.new(0,2,0,2)
Main.BackgroundColor3 = COLOR_GUI
Main.BorderSizePixel = 0
Main.Parent = MainBorder

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0,8)
cornerMain.Parent = Main

-- Movible
local dragging = false
local dragInput, mousePos, framePos

MainBorder.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = MainBorder.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainBorder.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		MainBorder.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

-- Título
local TitleBorder = Instance.new("Frame")
TitleBorder.Size = UDim2.new(1,0,0,25)
TitleBorder.Position = UDim2.new(0,0,0,5)
TitleBorder.BackgroundColor3 = COLOR_LABEL
TitleBorder.BorderSizePixel = 0
TitleBorder.Parent = Main

local cornerTitleBorder = Instance.new("UICorner")
cornerTitleBorder.CornerRadius = UDim.new(0,5)
cornerTitleBorder.Parent = TitleBorder

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -4,1,-4)
title.Position = UDim2.new(0,2,0,2)
title.BackgroundColor3 = COLOR_LABEL
title.BorderSizePixel = 0
title.Text = "Barra Manager"
title.TextColor3 = COLOR_TEXT
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = TitleBorder

local cornerTitle = Instance.new("UICorner")
cornerTitle.CornerRadius = UDim.new(0,5)
cornerTitle.Parent = title

-- TextBox Usuario
local BoxBorder = Instance.new("Frame")
BoxBorder.Size = UDim2.new(0, 180, 0, 30)
BoxBorder.Position = UDim2.new(0,20,0,40)
BoxBorder.BackgroundColor3 = COLOR_BORDER
BoxBorder.BorderSizePixel = 0
BoxBorder.Parent = Main

local cornerBoxBorder = Instance.new("UICorner")
cornerBoxBorder.CornerRadius = UDim.new(0,5)
cornerBoxBorder.Parent = BoxBorder

local usuarioBox = Instance.new("TextBox")
usuarioBox.Size = UDim2.new(1, -4,1,-4)
usuarioBox.Position = UDim2.new(0,2,0,2)
usuarioBox.BackgroundColor3 = COLOR_LABEL
usuarioBox.BorderSizePixel = 0
usuarioBox.PlaceholderText = "Usuario"
usuarioBox.Text = ""
usuarioBox.ClearTextOnFocus = false
usuarioBox.TextColor3 = COLOR_TEXT
usuarioBox.TextScaled = true
usuarioBox.Font = Enum.Font.GothamBold
usuarioBox.Parent = BoxBorder

local cornerBox = Instance.new("UICorner")
cornerBox.CornerRadius = UDim.new(0,5)
cornerBox.Parent = usuarioBox

-- Botones
local function crearBoton(nombre, posY, callback)
	local BtnBorder = Instance.new("Frame")
	BtnBorder.Size = UDim2.new(0, 180, 0, 35)
	BtnBorder.Position = UDim2.new(0,20,0,posY)
	BtnBorder.BackgroundColor3 = COLOR_BORDER
	BtnBorder.BorderSizePixel = 0
	BtnBorder.Parent = Main

	local cornerBtnBorder = Instance.new("UICorner")
	cornerBtnBorder.CornerRadius = UDim.new(0,5)
	cornerBtnBorder.Parent = BtnBorder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 1, -4)
	btn.Position = UDim2.new(0,2,0,2)
	btn.BackgroundColor3 = COLOR_LABEL
	btn.BorderSizePixel = 0
	btn.Text = nombre
	btn.TextColor3 = COLOR_TEXT
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.Parent = BtnBorder
	btn.MouseButton1Click:Connect(callback)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,5)
	corner.Parent = btn
end

crearBoton("Aplicar Barra (Usuario)", 80, function()
	local nombre = usuarioBox.Text
	local plr = Players:FindFirstChild(nombre)
	if plr then
		persistentBars[plr.Name] = true
		if plr.Character then
			local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				createBar(plr)
			end
		end
	end
end)

crearBoton("Desactivar Barra (Usuario)", 125, function()
	local nombre = usuarioBox.Text
	local plr = Players:FindFirstChild(nombre)
	if plr then
		if activeBars[plr.Name] then
			local info = activeBars[plr.Name]
			for _, b in ipairs(info.beams or {}) do b:Destroy() end
			if info.attach0 then info.attach0:Destroy() end
			if info.attach1 then info.attach1:Destroy() end
			activeBars[plr.Name] = nil
		end
		persistentBars[plr.Name] = nil
	end
end)

-- Animación abrir/ocultar con T
local visibleT = true
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		visibleT = not visibleT
		if visibleT then
			MainBorder.Visible = true
			MainBorder.Size = UDim2.new(0,0,0,0)
			TweenService:Create(
				MainBorder,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Size = UDim2.new(0, 220, 0, 180)}
			):Play()
		else
			local tween = TweenService:Create(
				MainBorder,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{Size = UDim2.new(0, 0, 0, 0)}
			)
			tween:Play()
			tween.Completed:Connect(function()
				MainBorder.Visible = false
			end)
		end
	end
end)

-- Función para reaplicar barra segura
local function reaplicarBarra(plr)
	plr.CharacterAdded:Connect(function(char)
		local rootPart = char:WaitForChild("HumanoidRootPart", 10) -- espera máximo 10s
		if rootPart and persistentBars[plr.Name] then
			createBar(plr)
		end
	end)
	if plr.Character then
		local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
		if rootPart and persistentBars[plr.Name] then
			createBar(plr)
		end
	end
end

-- Aplicar a todos los jugadores actuales y futuros
for _, plr in ipairs(Players:GetPlayers()) do
	reaplicarBarra(plr)
end

Players.PlayerAdded:Connect(function(plr)
	reaplicarBarra(plr)
end)
