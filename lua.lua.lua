--[[
    OxygenUI Official
    API Version: 1.0
    Theme: Yellow & White
    Particles: 6523330152
    Click Sounds: Disabled
]]

local OxygenUI = {}

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Configuration
OxygenUI.Config = {
	Name = "OxygenUI",
	Version = "1.0",
	Theme = "Yellow",
	ParticleImage = "rbxassetid://6523330152",
	Icons = {
		Main = "rbxassetid://8772194322",
		Config = "rbxassetid://17269884884",
		Settings = "rbxassetid://6966627582",
	},
	Discord = "https://discord.gg/This is Teste",
	YouTube = "https://www.youtube.com/This is Teste",
}

--// Themes
OxygenUI.Themes = {
	Yellow = {
		Background = Color3.fromRGB(8, 8, 8),
		Panel = Color3.fromRGB(24, 24, 24),
		Element = Color3.fromRGB(42, 42, 42),
		Accent = Color3.fromRGB(255, 190, 35),
		Text = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(175, 175, 175),
		Border = Color3.fromRGB(255, 255, 255),
	},

	White = {
		Background = Color3.fromRGB(12, 12, 12),
		Panel = Color3.fromRGB(28, 28, 28),
		Element = Color3.fromRGB(48, 48, 48),
		Accent = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(175, 175, 175),
		Border = Color3.fromRGB(255, 255, 255),
	},
}

OxygenUI.Theme = OxygenUI.Themes.Yellow
OxygenUI.Elements = {}
OxygenUI.Tabs = {}

--// Helpers
local function Create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function Corner(parent, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8)
	}, parent)
end

local function Stroke(parent, color, thickness)
	return Create("UIStroke", {
		Color = color or OxygenUI.Theme.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function Tween(object, duration, properties)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()
	return animation
end

local function MakeText(parent, text, size, color)
	return Create("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color or OxygenUI.Theme.Text,
		TextSize = size or 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, 0, 0, 24),
	}, parent)
end

--// UI creation
function OxygenUI:CreateWindow(options)
	options = options or {}

	local title = options.Title or "OxygenUI"
	local width = options.Width or 780
	local height = options.Height or 500

	local old = PlayerGui:FindFirstChild("OxygenUI_Official")
	if old then
		old:Destroy()
	end

	local gui = Create("ScreenGui", {
		Name = "OxygenUI_Official",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, PlayerGui)

	self.Gui = gui

	local main = Create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, gui)

	Corner(main, 10)
	Stroke(main, self.Theme.Border, 1.5)

	--// Header
	local header = Create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundTransparency = 1,
	}, main)

	local titleLabel = MakeText(header, title, 20, self.Theme.Text)
	titleLabel.Position = UDim2.fromOffset(18, 7)
	titleLabel.Size = UDim2.new(0.7, 0, 0, 30)
	titleLabel.Font = Enum.Font.GothamBold

	--// Window buttons
	local close = Create("TextButton", {
		Name = "Close",
		Position = UDim2.new(1, -38, 0, 12),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Color3.fromRGB(255, 65, 65),
		Text = "",
		AutoButtonColor = false,
	}, header)

	Corner(close, 100)
	Stroke(close, self.Theme.Text, 1)

	local minimize = Create("TextButton", {
		Name = "Minimize",
		Position = UDim2.new(1, -68, 0, 12),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = self.Theme.Accent,
		Text = "",
		AutoButtonColor = false,
	}, header)

	Corner(minimize, 100)
	Stroke(minimize, self.Theme.Text, 1)

	--// Sidebar
	local sidebar = Create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(8, 53),
		Size = UDim2.new(0, 150, 1, -68),
		BackgroundColor3 = self.Theme.Panel,
		BackgroundTransparency = 0.12,
		ClipsDescendants = true,
	}, main)

	Corner(sidebar, 10)
	Stroke(sidebar, self.Theme.Border, 1.5)

	local tabButtons = Create("Frame", {
		Name = "TabButtons",
		Position = UDim2.fromOffset(6, 8),
		Size = UDim2.new(1, -12, 1, -16),
		BackgroundTransparency = 1,
	}, sidebar)

	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabButtons)

	--// Content panel
	local content = Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(168, 53),
		Size = UDim2.new(1, -186, 1, -68),
		BackgroundColor3 = self.Theme.Panel,
		BackgroundTransparency = 0.12,
		ClipsDescendants = true,
	}, main)

	Corner(content, 10)
	Stroke(content, self.Theme.Border, 1)

	--// Particle layer
	local function AddParticles(parent, amount)
		local layer = Create("Frame", {
			Name = "ParticleLayer",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 1,
		}, parent)

		for i = 1, amount do
			task.spawn(function()
				while layer.Parent do
					local size = math.random(3, 7) / 10
					local particle = Create("ImageLabel", {
						Name = "Particle",
						BackgroundTransparency = 1,
						Image = self.Config.ParticleImage,
						ImageColor3 = self.Theme.Text,
						ImageTransparency = math.random(15, 55) / 100,
						Size = UDim2.fromOffset(size * 10, size * 10),
						Position = UDim2.new(
							math.random(3, 97) / 100, 0,
							1, math.random(0, 30)
						),
						ZIndex = 1,
					}, layer)

					local travelTime = math.random(45, 90) / 10

					Tween(particle, travelTime, {
						Position = UDim2.new(
							particle.Position.X.Scale,
							0,
							0,
							-15
						),
						ImageTransparency = 1,
					})

					task.wait(travelTime)
					particle:Destroy()
					task.wait(math.random(2, 12) / 10)
				end
			end)
		end

		return layer
	end

	AddParticles(sidebar, 12)
	AddParticles(content, 35)

	--// Tab selection
	local activeTab

	local function SelectTab(tab)
		if activeTab then
			activeTab.Page.Visible = false
			activeTab.Button.BackgroundColor3 = self.Theme.Element
			activeTab.Button.TextColor3 = self.Theme.Text
		end

		activeTab = tab
		tab.Page.Visible = true
		tab.Button.BackgroundColor3 = self.Theme.Accent
		tab.Button.TextColor3 = Color3.fromRGB(15, 15, 15)
	end

	function self:CreateTab(tabOptions)
		tabOptions = tabOptions or {}

		local tabName = tabOptions.Name or "Tab"
		local iconId = tabOptions.Icon or "rbxassetid://0"

		local button = Create("TextButton", {
			Name = tabName .. "Button",
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = self.Theme.Element,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = #self.Tabs + 1,
			ZIndex = 2,
		}, tabButtons)

		Corner(button, 7)

		local icon = Create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Image = iconId,
			Position = UDim2.fromOffset(7, 7),
			Size = UDim2.fromOffset(20, 20),
			ImageColor3 = self.Theme.Text,
			ZIndex = 3,
		}, button)

		local label = Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.new(1, -40, 1, 0),
			Text = tabName,
			TextColor3 = self.Theme.Text,
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
		}, button)

		local page = Create("ScrollingFrame", {
			Name = tabName .. "Page",
			Size = UDim2.new(1, -20, 1, -20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = self.Theme.Accent,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = 2,
		}, content)

		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)

		local tab = {
			Name = tabName,
			Button = button,
			Page = page,
			Icon = icon,
			Label = label,
		}

		table.insert(self.Tabs, tab)

		button.Activated:Connect(function()
			SelectTab(tab)
		end)

		function tab:AddSection(text)
			local section = MakeText(page, text, 15, self.Theme and self.Theme.Accent or OxygenUI.Theme.Accent)
			section.Font = Enum.Font.GothamBold
			section.Size = UDim2.new(1, -4, 0, 30)
			section.LayoutOrder = #page:GetChildren()
			return section
		end

		function tab:AddLabel(text)
			local labelObject = MakeText(page, text, 13, OxygenUI.Theme.Muted)
			labelObject.Size = UDim2.new(1, -4, 0, 25)
			labelObject.LayoutOrder = #page:GetChildren()
			return labelObject
		end

		function tab:AddButton(options)
			options = options or {}

			local buttonObject = Create("TextButton", {
				Size = UDim2.new(1, -4, 0, 36),
				BackgroundColor3 = OxygenUI.Theme.Element,
				Text = options.Name or "Button",
				TextColor3 = OxygenUI.Theme.Text,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 3,
			}, page)

			Corner(buttonObject, 7)

			buttonObject.Activated:Connect(function()
				Tween(buttonObject, 0.12, {
					BackgroundColor3 = OxygenUI.Theme.Accent
				})

				task.delay(0.15, function()
					if buttonObject.Parent then
						Tween(buttonObject, 0.18, {
							BackgroundColor3 = OxygenUI.Theme.Element
						})
					end
				end)

				if options.Callback then
					task.spawn(options.Callback)
				end
			end)

			return buttonObject
		end

		function tab:AddToggle(options)
			options = options or {}
			local state = options.Default or false

			local toggle = Create("TextButton", {
				Size = UDim2.new(1, -4, 0, 36),
				BackgroundColor3 = OxygenUI.Theme.Element,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 3,
			}, page)

			Corner(toggle, 7)

			local toggleLabel = MakeText(toggle, options.Name or "Toggle", 13)
			toggleLabel.Position = UDim2.fromOffset(10, 0)
			toggleLabel.Size = UDim2.new(1, -55, 1, 0)

			local indicator = Create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(28, 15),
				BackgroundColor3 = state and OxygenUI.Theme.Accent
					or Color3.fromRGB(80, 80, 80),
			}, toggle)

			Corner(indicator, 10)

			toggle.Activated:Connect(function()
				state = not state

				Tween(indicator, 0.15, {
					BackgroundColor3 = state and OxygenUI.Theme.Accent
						or Color3.fromRGB(80, 80, 80)
				})

				if options.Callback then
					options.Callback(state)
				end
			end)

			return {
				Get = function()
					return state
				end,
				Set = function(value)
					state = value == true
					indicator.BackgroundColor3 = state
						and OxygenUI.Theme.Accent
						or Color3.fromRGB(80, 80, 80)
				end,
			}
		end

		function tab:AddInput(options)
			options = options or {}

			local input = Create("TextBox", {
				Size = UDim2.new(1, -4, 0, 36),
				BackgroundColor3 = OxygenUI.Theme.Element,
				Text = options.Default or "",
				PlaceholderText = options.Placeholder or "Digite aqui...",
				PlaceholderColor3 = OxygenUI.Theme.Muted,
				TextColor3 = OxygenUI.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = false,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 3,
			}, page)

			Corner(input, 7)

			input.FocusLost:Connect(function(enterPressed)
				if options.Callback then
					options.Callback(input.Text, enterPressed)
				end
			end)

			return input
		end

		function tab:AddJobID()
			local id = game.JobId

			local field = Create("TextBox", {
				Size = UDim2.new(1, -4, 0, 36),
				BackgroundColor3 = OxygenUI.Theme.Element,
				Text = id ~= "" and id or "JobID indisponível",
				TextColor3 = OxygenUI.Theme.Text,
				TextSize = 12,
				Font = Enum.Font.Code,
				ClearTextOnFocus = false,
				TextEditable = true,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 3,
			}, page)

			Corner(field, 7)

			local copy = Create("TextButton", {
				Size = UDim2.new(1, -4, 0, 32),
				BackgroundColor3 = OxygenUI.Theme.Accent,
				Text = "Copiar JobID",
				TextColor3 = Color3.fromRGB(15, 15, 15),
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				LayoutOrder = #page:GetChildren(),
				ZIndex = 3,
			}, page)

			Corner(copy, 7)

			copy.Activated:Connect(function()
				field:CaptureFocus()
				field.CursorPosition = #field.Text + 1
				field.SelectionStart = 1
			end)

			return field
		end

		function tab:AddLink(options)
			options = options or {}

			return self:AddButton({
				Name = options.Name or "Abrir link",
				Callback = function()
					-- Roblox não permite abrir URLs arbitrárias
					-- por um TextButton padrão em todos os contextos.
					-- O link fica disponível para uso no teu loader.
					if options.Callback then
						options.Callback(options.Url)
					end
				end,
			})
		end

		return tab
	end

	--// Window behavior
	local minimized = false

	minimize.Activated:Connect(function()
		minimized = not minimized

		if minimized then
			Tween(main, 0.2, {
				Size = UDim2.fromOffset(width, 46)
			})
		else
			Tween(main, 0.2, {
				Size = UDim2.fromOffset(width, height)
			})
		end
	end)

	close.Activated:Connect(function()
		Tween(main, 0.18, {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(width * 0.95, height * 0.95),
		})

		task.wait(0.2)

		if gui.Parent then
			gui:Destroy()
		end
	end)

	--// Dragging
	do
		local dragging = false
		local dragStart
		local startPosition

		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then

				dragging = true
				dragStart = input.Position
				startPosition = main.Position
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then

				local delta = input.Position - dragStart

				main.Position = UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset + delta.X,
					startPosition.Y.Scale,
					startPosition.Y.Offset + delta.Y
				)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	--// Entrance animation
	main.Size = UDim2.fromOffset(width * 0.92, height * 0.92)
	main.BackgroundTransparency = 1

	Tween(main, 0.35, {
		Size = UDim2.fromOffset(width, height),
		BackgroundTransparency = 0,
	})

	self.Main = main
	self.Content = content
	self.Sidebar = sidebar

	return self
end

--// Theme API
function OxygenUI:SetTheme(themeName)
	local theme = self.Themes[themeName]

	if not theme then
		warn("[OxygenUI] Tema inválido:", themeName)
		return false
	end

	self.Theme = theme
	self.Config.Theme = themeName

	if self.Main then
		self.Main.BackgroundColor3 = theme.Background
	end

	if self.Sidebar then
		self.Sidebar.BackgroundColor3 = theme.Panel
	end

	if self.Content then
		self.Content.BackgroundColor3 = theme.Panel
	end

	for _, tab in ipairs(self.Tabs) do
		tab.Button.BackgroundColor3 = theme.Element
		tab.Button.TextColor3 = theme.Text
		tab.Icon.ImageColor3 = theme.Text
		tab.Label.TextColor3 = theme.Text
	end

	return true
end

--// Icon API
function OxygenUI:SetIcon(tabName, imageId)
	local id = tostring(imageId)

	if not id:match("^%d+$") then
		warn("[OxygenUI] O ID do ícone precisa ser numérico.")
		return false
	end

	for _, tab in ipairs(self.Tabs) do
		if tab.Name == tabName then
			tab.Icon.Image = "rbxassetid://" .. id
			return true
		end
	end

	warn("[OxygenUI] Aba não encontrada:", tabName)
	return false
end

--// Update log
function OxygenUI:SetUpdateLog(entries)
	self.UpdateLog = entries or {}
end

function OxygenUI:GetJobID()
	local jobId = game.JobId

	if not jobId or jobId == "" then
		return nil, "JobID indisponível neste servidor."
	end

	return jobId
end

return OxygenUI
