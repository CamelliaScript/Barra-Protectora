	--// SERVICIOS
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")

	local localPlayer = Players.LocalPlayer

	--// CONFIG
	local MAX_DISTANCE = 600
	local BAR_LENGTH = 50
	local BEAM_STACK = 2

	--// COLORES GUI
	local COLOR_GUI = Color3.fromRGB(150,200,250)
	local COLOR_LABEL = Color3.fromRGB(90,140,200)
	local COLOR_TEXT = Color3.fromRGB(255,255,255)
	local COLOR_BORDER = Color3.fromRGB(255,255,255)

	--// COLORES BARRA
	local BAR_COLORS = {
		Color3.fromRGB(0,190,255),
		Color3.fromRGB(0,255,0),
		Color3.fromRGB(255,105,180),
		Color3.fromRGB(255,0,0),
		Color3.fromRGB(255,230,0),
		Color3.fromRGB(120,220,255)
	}

	--// ESTADOS
	local activeBars = {}
	local persistentBars = {}
	local connections = {}
	local playerColor = {}
	local applyCounter = 0
	local barraGeneralActiva = false

	--// COLOR POR JUGADOR
	local function getColor(name)
		if playerColor[name] then return playerColor[name] end
		applyCounter += 1
		local i = ((applyCounter - 1) % #BAR_COLORS) + 1
		playerColor[name] = BAR_COLORS[i]
		return playerColor[name]
	end

	--// LIMPIAR BARRA
	local function clearBar(name)
		if connections[name] then
			connections[name]:Disconnect()
			connections[name] = nil
		end
		if activeBars[name] then
			for _, b in ipairs(activeBars[name].beams) do b:Destroy() end
			activeBars[name].attach0:Destroy()
			activeBars[name].attach1:Destroy()
			activeBars[name] = nil
		end
	end

	--// CREAR BARRA
	local function createBar(plr)
		if activeBars[plr.Name] then return end
		if not plr.Character then return end

		local root = plr.Character:WaitForChild("HumanoidRootPart", 5)
		if not root then return end

		local color = getColor(plr.Name)

		local a0 = Instance.new("Attachment", root)
		local a1 = Instance.new("Attachment", workspace)

		local beams = {}
		for i = 1, BEAM_STACK do
			local beam = Instance.new("Beam")
			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Width0 = 0.7
			beam.Width1 = 0.7
			beam.Color = ColorSequence.new(color)
			beam.LightEmission = 1
			beam.Transparency = NumberSequence.new(0.1)
			beam.FaceCamera = true
			beam.Parent = workspace
			table.insert(beams, beam)
		end

		activeBars[plr.Name] = {attach0 = a0, attach1 = a1, beams = beams}

		connections[plr.Name] = RunService.RenderStepped:Connect(function()
			if not localPlayer.Character or not root.Parent then
				for _, b in ipairs(beams) do b.Enabled = false end
				return
			end

			local myRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end

			local dist = (myRoot.Position - root.Position).Magnitude
			if dist > MAX_DISTANCE then
				for _, b in ipairs(beams) do b.Enabled = false end
				return
			end

			local dir = (myRoot.Position - root.Position).Unit
			a1.WorldPosition = root.Position + dir * BAR_LENGTH
			for _, b in ipairs(beams) do b.Enabled = true end
		end)
	end

	--// GUI
	local gui = Instance.new("ScreenGui", localPlayer.PlayerGui)
	gui.Name = "BarraGUI"
	gui.ResetOnSpawn = false

	local Border = Instance.new("Frame", gui)
	Border.Size = UDim2.new(0,220,0,220)
	Border.Position = UDim2.new(0.5,-110,0.5,-110)
	Border.BackgroundColor3 = COLOR_BORDER
	Border.BorderSizePixel = 0
	Instance.new("UICorner", Border).CornerRadius = UDim.new(0,8)

	local Main = Instance.new("Frame", Border)
	Main.Size = UDim2.new(1,-4,1,-4)
	Main.Position = UDim2.new(0,2,0,2)
	Main.BackgroundColor3 = COLOR_GUI
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)

	--// DRAG
	do
		local dragging, dragStart, startPos
		Border.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = Border.Position
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				Border.Position = startPos + UDim2.new(0,delta.X,0,delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	--// TITLE
	local Title = Instance.new("TextLabel", Main)
	Title.Size = UDim2.new(1,-10,0,25)
	Title.Position = UDim2.new(0,5,0,5)
	Title.BackgroundColor3 = COLOR_LABEL
	Title.Text = "Barra Manager"
	Title.TextColor3 = COLOR_TEXT
	Title.TextScaled = true
	Title.Font = Enum.Font.GothamBold
	Title.BorderSizePixel = 0
	Instance.new("UICorner", Title).CornerRadius = UDim.new(0,5)

	--// TEXTBOX
	local Box = Instance.new("TextBox", Main)
	Box.Size = UDim2.new(0,180,0,30)
	Box.Position = UDim2.new(0,20,0,45)
	Box.BackgroundColor3 = COLOR_LABEL
	Box.PlaceholderText = "Usuario"
	Box.Text = ""
	Box.ClearTextOnFocus = false
	Box.TextColor3 = COLOR_TEXT
	Box.TextScaled = true
	Box.Font = Enum.Font.GothamBold
	Box.BorderSizePixel = 0
	Instance.new("UICorner", Box).CornerRadius = UDim.new(0,5)

	local function boton(txt,y)
		local b = Instance.new("TextButton", Main)
		b.Size = UDim2.new(0,180,0,35)
		b.Position = UDim2.new(0,20,0,y)
		b.BackgroundColor3 = COLOR_LABEL
		b.Text = txt
		b.TextColor3 = COLOR_TEXT
		b.TextScaled = true
		b.Font = Enum.Font.GothamBold
		b.BorderSizePixel = 0
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
		return b
	end

	--// BOTONES
	local btnAplicar = boton("Aplicar Barra (Usuario)",85)
	btnAplicar.MouseButton1Click:Connect(function()
		local plr = Players:FindFirstChild(Box.Text)
		if not plr then return end
		persistentBars[plr.Name] = true
		clearBar(plr.Name)
		task.wait()
		createBar(plr)
	end)

	local btnQuitar = boton("Desactivar Barra (Usuario)",130)
	btnQuitar.MouseButton1Click:Connect(function()
		local plr = Players:FindFirstChild(Box.Text)
		if not plr then return end
		persistentBars[plr.Name] = nil
		clearBar(plr.Name)
	end)

	local btnGeneral = boton("Barra General",175)
	btnGeneral.MouseButton1Click:Connect(function()
		barraGeneralActiva = not barraGeneralActiva
		if barraGeneralActiva then
			btnGeneral.Text = "Barra Normal"
			for _, plr in ipairs(Players:GetPlayers()) do
				persistentBars[plr.Name] = true
				clearBar(plr.Name)
				task.wait()
				createBar(plr)
			end
		else
			btnGeneral.Text = "Barra General"
			barraGeneralActiva = false
			for _, plr in ipairs(Players:GetPlayers()) do
				persistentBars[plr.Name] = nil
				clearBar(plr.Name)
			end
		end
	end)

	--// RESPAWN (FIX FINAL)
	local function setup(plr)
		plr.CharacterAdded:Connect(function()
			-- SI EL USUARIO FUE APLICADO MANUALMENTE, SIEMPRE REAPLICA
			if persistentBars[plr.Name] then
				clearBar(plr.Name)
				task.wait(0.15)
				createBar(plr)
				return
			end

			-- SI NO, SOLO RESPETA BARRA GENERAL
			if not barraGeneralActiva then
				clearBar(plr.Name)
			end
		end)
	end

	for _,p in ipairs(Players:GetPlayers()) do setup(p) end
	Players.PlayerAdded:Connect(setup)

	--// ANIMACIÓN CON T
	local guiVisible = true
	local originalSize = Border.Size

	UserInputService.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.T then
			guiVisible = not guiVisible
			if guiVisible then
				Border.Visible = true
				Border.Size = UDim2.new(0,0,0,0)
				TweenService:Create(
					Border,
					TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
					{Size = originalSize}
				):Play()
			else
				local tw = TweenService:Create(
					Border,
					TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),
					{Size = UDim2.new(0,0,0,0)}
				)
				tw:Play()
				tw.Completed:Once(function()
					Border.Visible = false
				end)
			end
		end
	end)
