--[[
    OxygenUI - Standalone API
    Criador: Noctvrad
    Local: LocalScript em StarterPlayerScripts
    Sem ModuleScript, sem require e sem acesso ao CoreGui.

    API:
    Window:CreateTab()
    Tab:AddSection()
    Tab:AddLabel()
    Tab:AddButton()
    Tab:AddToggle()
    Tab:AddInput()
    Tab:AddJobID()
    Tab:AddLink()
    Window:SetTheme()
    Window:SetIcon()
    Window:SetUpdateLog()
    Window:GetJobID()
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    error("OxygenUI precisa ser executado no cliente.")
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Evita interfaces duplicadas.
local previous = PlayerGui:FindFirstChild("OxygenUI")
if previous then
    previous:Destroy()
end

local OxygenUI = {}
OxygenUI.__index = OxygenUI

local Themes = {
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

local function create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
    }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Color3.new(1, 1, 1),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function tween(object, duration, properties)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out),
        properties
    )

    animation:Play()
    return animation
end

local function makeText(parent, text, size, position, dimensions, options)
    options = options or {}

    return create("TextLabel", {
        Name = options.Name or "Text",
        BackgroundTransparency = 1,
        Position = position or UDim2.new(),
        Size = dimensions or UDim2.new(1, 0, 0, 30),
        Font = options.Font or Enum.Font.Gotham,
        Text = text or "",
        TextSize = size or 14,
        TextColor3 = options.Color or Color3.new(1, 1, 1),
        TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = options.Wrapped or false,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function normalizeTheme(name)
    if typeof(name) == "string" and Themes[name] then
        return name
    end
    return "Yellow"
end

function OxygenUI:CreateWindow(options)
    options = options or {}

    local self = setmetatable({}, OxygenUI)
    self.Title = options.Title or "OxygenUI"
    self.ThemeName = normalizeTheme(options.Theme or "Yellow")
    self.Theme = Themes[self.ThemeName]
    self.Tabs = {}
    self.TabOrder = {}
    self.StyleObjects = {}
    self.Closed = false
    self.Minimized = false
    self.CurrentTab = nil
    self.UpdateLog = "Bem-vindo à OxygenUI."

    local screen = create("ScreenGui", {
        Name = "OxygenUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    }, PlayerGui)

    self.Screen = screen

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1024, 768)

    local width = math.clamp(tonumber(options.Width) or 780, 340, viewport.X - 20)
    local height = math.clamp(tonumber(options.Height) or 620, 300, viewport.Y - 20)

    local window = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screen)

    self.WindowFrame = window
    corner(window, 10)
    self.MainStroke = stroke(window, self.Theme.Border, 2)

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
    }, window)

    self.Topbar = topbar

    makeText(topbar, self.Title, 17,
        UDim2.fromOffset(15, 0), UDim2.new(1, -110, 1, 0), {
            Font = Enum.Font.GothamBold,
        })

    local minimize = create("TextButton", {
        Name = "Minimize",
        Position = UDim2.new(1, -67, 0, 10),
        Size = UDim2.fromOffset(23, 23),
        BackgroundColor3 = Color3.fromRGB(255, 175, 40),
        Text = "-",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = true,
    }, topbar)
    corner(minimize, 20)
    stroke(minimize, Color3.new(1, 1, 1), 1)

    local close = create("TextButton", {
        Name = "Close",
        Position = UDim2.new(1, -36, 0, 10),
        Size = UDim2.fromOffset(23, 23),
        BackgroundColor3 = Color3.fromRGB(230, 65, 65),
        Text = "×",
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = true,
    }, topbar)
    corner(close, 20)
    stroke(close, Color3.new(1, 1, 1), 1)

    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(10, 53),
        Size = UDim2.new(0, 150, 1, -65),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
    }, window)
    corner(sidebar, 8)
    stroke(sidebar, self.Theme.Border, 1)

    local tabList = create("ScrollingFrame", {
        Name = "TabList",
        Position = UDim2.fromOffset(7, 8),
        Size = UDim2.new(1, -14, 1, -48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)

    create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)

    local credits = makeText(sidebar, "Created By Noctvrad", 10,
        UDim2.new(0, 7, 1, -32), UDim2.new(1, -14, 0, 22), {
            Color = self.Theme.Muted,
            Alignment = Enum.TextXAlignment.Center,
        })

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 170, 0, 53),
        Size = UDim2.new(1, -180, 1, -65),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
    }, window)
    corner(content, 8)
    stroke(content, self.Theme.Border, 1)

    local pageTitle = makeText(content, "Main", 18,
        UDim2.fromOffset(15, 8), UDim2.new(1, -30, 0, 30), {
            Font = Enum.Font.GothamBold,
        })

    local pageContainer = create("Frame", {
        Name = "PageContainer",
        Position = UDim2.fromOffset(10, 45),
        Size = UDim2.new(1, -20, 1, -55),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, content)

    self.Sidebar = sidebar
    self.TabList = tabList
    self.Content = content
    self.PageTitle = pageTitle
    self.PageContainer = pageContainer
    self.Credits = credits

    -- Registra objetos para atualizar as cores quando o tema mudar.
    local function register(object, property, themeKey)
        table.insert(self.StyleObjects, {
            Object = object,
            Property = property,
            Key = themeKey,
        })
    end

    self.RegisterStyle = register
    register(window, "BackgroundColor3", "Background")
    register(topbar, "BackgroundColor3", "Panel")
    register(sidebar, "BackgroundColor3", "Panel")
    register(content, "BackgroundColor3", "Panel")
    register(self.MainStroke, "Color", "Border")
    register(credits, "TextColor3", "Muted")

    -- Arrastar a janela pelo topo, sem usar CoreGui.
    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    local savedSize = window.Size

    minimize.Activated:Connect(function()
        self.Minimized = not self.Minimized

        if self.Minimized then
            savedSize = window.Size
            tween(window, 0.2, {
                Size = UDim2.fromOffset(width, 43),
            })
            sidebar.Visible = false
            content.Visible = false
            minimize.Text = "+"
        else
            window.Size = UDim2.fromOffset(width, 43)
            sidebar.Visible = true
            content.Visible = true
            tween(window, 0.2, { Size = savedSize })
            minimize.Text = "-"
        end
    end)

    close.Activated:Connect(function()
        self.Closed = true
        screen:Destroy()
    end)

    function self:ApplyTheme(themeName)
        self.ThemeName = normalizeTheme(themeName)
        self.Theme = Themes[self.ThemeName]

        for _, item in ipairs(self.StyleObjects) do
            if item.Object and item.Object.Parent then
                local color = self.Theme[item.Key]
                if color then
                    item.Object[item.Property] = color
                end
            end
        end
    end

    function self:SetTheme(themeName)
        if not Themes[themeName] then
            warn("OxygenUI: tema inválido. Use 'Yellow' ou 'White'.")
            return false
        end

        self:ApplyTheme(themeName)
        return true
    end

    function self:GetJobID()
        return game.JobId
    end

    function self:SetUpdateLog(message)
        self.UpdateLog = tostring(message or "")
        local tab = self.Tabs["Update Log"]

        if tab and tab.UpdateLabel then
            tab.UpdateLabel.Text = self.UpdateLog
        end
    end

    function self:SetIcon(tabName, imageId)
        local tab = self.Tabs[tabName]
        if not tab then
            warn("OxygenUI: aba não encontrada:", tabName)
            return false
        end

        tab.IconValue = imageId

        if tab.IconObject then
            if typeof(imageId) == "string"
                and (string.find(imageId, "rbxassetid://", 1, true)
                or string.match(imageId, "^%d+$")) then

                local asset = imageId
                if string.match(asset, "^%d+$") then
                    asset = "rbxassetid://" .. asset
                end

                tab.IconObject.Image = asset
                tab.IconObject.Visible = true
                tab.IconText.Visible = false
            else
                tab.IconObject.Visible = false
                tab.IconText.Text = tostring(imageId or "")
                tab.IconText.Visible = true
            end
        end

        return true
    end

    function self:CreateTab(tabOptions)
        tabOptions = tabOptions or {}

        local name = tostring(tabOptions.Name or "Tab")
        if self.Tabs[name] then
            warn("OxygenUI: já existe uma aba chamada:", name)
            return self.Tabs[name]
        end

        local tab = {
            Name = name,
            IconValue = tabOptions.Icon or "•",
            Window = self,
            Elements = {},
        }

        local tabButton = create("TextButton", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = self.Theme.Element,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #self.TabOrder + 1,
        }, tabList)
        corner(tabButton, 6)

        local iconText = makeText(tabButton, tostring(tab.IconValue), 15,
            UDim2.fromOffset(8, 0), UDim2.fromOffset(25, 36), {
                Alignment = Enum.TextXAlignment.Center,
            })

        local iconImage = create("ImageLabel", {
            Name = "IconImage",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.fromOffset(20, 20),
            Image = "",
            Visible = false,
            ScaleType = Enum.ScaleType.Fit,
        }, tabButton)

        makeText(tabButton, name, 12,
            UDim2.fromOffset(38, 0), UDim2.new(1, -43, 1, 0), {})

        local page = create("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, pageContainer)

        create("UIListLayout", {
            Padding = UDim.new(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 5),
        }, page)

        tab.Button = tabButton
        tab.Page = page
        tab.IconObject = iconImage
        tab.IconText = iconText
        tab.UpdateLabel = nil

        self.Tabs[name] = tab
        table.insert(self.TabOrder, tab)

        self.RegisterStyle(tabButton, "BackgroundColor3", "Element")

        local function selectTab()
            if self.Closed then
                return
            end

            for _, otherTab in ipairs(self.TabOrder) do
                otherTab.Page.Visible = false
                tween(otherTab.Button, 0.12, {
                    BackgroundColor3 = self.Theme.Element,
                })
            end

            tab.Page.Visible = true
            self.CurrentTab = tab
            self.PageTitle.Text = tab.Name

            tween(tabButton, 0.12, {
                BackgroundColor3 = self.Theme.Accent,
            })

            -- Contraste do texto da aba selecionada.
            for _, child in ipairs(tabButton:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = self.ThemeName == "White"
                        and Color3.fromRGB(10, 10, 10)
                        or Color3.fromRGB(15, 15, 15)
                end
            end
        end

        tabButton.Activated:Connect(selectTab)

        local function addRow(rowName, height)
            local row = create("Frame", {
                Name = rowName or "Element",
                Size = UDim2.new(1, -2, 0, height or 38),
                BackgroundColor3 = self.Theme.Element,
                BorderSizePixel = 0,
            }, page)

            corner(row, 6)
            self.RegisterStyle(row, "BackgroundColor3", "Element")
            return row
        end

        function tab:AddSection(text)
            local section = makeText(page, tostring(text or "Section"), 13,
                UDim2.new(), UDim2.new(1, -2, 0, 27), {
                    Font = Enum.Font.GothamBold,
                    Color = self.Window.Theme.Accent,
                })

            table.insert(self.Elements, section)
            return section
        end

        function tab:AddLabel(text)
            local row = addRow("Label", 36)

            local label = makeText(row, tostring(text or ""), 12,
                UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), {})

            self.Window.RegisterStyle(label, "TextColor3", "Text")
            table.insert(self.Elements, label)
            return label
        end

        function tab:AddButton(buttonOptions)
            if typeof(buttonOptions) == "string" then
                buttonOptions = { Name = buttonOptions }
            end
            buttonOptions = buttonOptions or {}

            local row = addRow("Button", 38)
            local button = create("TextButton", {
                Name = "Action",
                Position = UDim2.fromOffset(4, 4),
                Size = UDim2.new(1, -8, 1, -8),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0,
                Text = tostring(buttonOptions.Name or "Button"),
                TextColor3 = self.Window.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                AutoButtonColor = true,
            }, row)
            corner(button, 5)
            self.Window.RegisterStyle(button, "BackgroundColor3", "Panel")
            self.Window.RegisterStyle(button, "TextColor3", "Text")

            button.Activated:Connect(function()
                if typeof(buttonOptions.Callback) == "function" then
                    local ok, err = pcall(buttonOptions.Callback)
                    if not ok then
                        warn("OxygenUI button callback:", err)
                    end
                end
            end)

            table.insert(self.Elements, button)
            return button
        end

        function tab:AddToggle(toggleOptions)
            toggleOptions = toggleOptions or {}

            local state = toggleOptions.Default == true
            local row = addRow("Toggle", 38)

            makeText(row, tostring(toggleOptions.Name or "Toggle"), 12,
                UDim2.fromOffset(10, 0), UDim2.new(1, -65, 1, 0), {})

            local toggleButton = create("TextButton", {
                Name = "ToggleButton",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(38, 22),
                BackgroundColor3 = state and self.Window.Theme.Accent
                    or self.Window.Theme.Panel,
                BorderSizePixel = 0,
                Text = state and "ON" or "OFF",
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = Color3.new(1, 1, 1),
                AutoButtonColor = true,
            }, row)
            corner(toggleButton, 5)

            local function setState(newState, invokeCallback)
                state = newState == true
                toggleButton.Text = state and "ON" or "OFF"
                toggleButton.BackgroundColor3 = state
                    and self.Window.Theme.Accent or self.Window.Theme.Panel

                if invokeCallback and typeof(toggleOptions.Callback) == "function" then
                    local ok, err = pcall(toggleOptions.Callback, state)
                    if not ok then
                        warn("OxygenUI toggle callback:", err)
                    end
                end
            end

            toggleButton.Activated:Connect(function()
                setState(not state, true)
            end)

            table.insert(self.Elements, toggleButton)

            return {
                Set = function(_, value)
                    setState(value, true)
                end,
                Get = function()
                    return state
                end,
                Button = toggleButton,
            }
        end

        function tab:AddInput(inputOptions)
            inputOptions = inputOptions or {}

            local row = addRow("Input", 40)

            local box = create("TextBox", {
                Name = "InputBox",
                Position = UDim2.fromOffset(7, 5),
                Size = UDim2.new(1, -14, 1, -10),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                PlaceholderText = tostring(inputOptions.Placeholder or "Digite aqui..."),
                PlaceholderColor3 = self.Window.Theme.Muted,
                Text = tostring(inputOptions.Default or ""),
                TextColor3 = self.Window.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            corner(box, 5)

            create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }, box)

            self.Window.RegisterStyle(box, "BackgroundColor3", "Panel")
            self.Window.RegisterStyle(box, "TextColor3", "Text")

            box.FocusLost:Connect(function(enterPressed)
                if typeof(inputOptions.Callback) == "function" then
                    local ok, err = pcall(
                        inputOptions.Callback,
                        box.Text,
                        enterPressed
                    )
                    if not ok then
                        warn("OxygenUI input callback:", err)
                    end
                end
            end)

            table.insert(self.Elements, box)
            return box
        end

        function tab:AddJobID()
            local jobId = game.JobId
            local row = addRow("JobID", 38)

            local label = makeText(row,
                jobId ~= "" and ("Job ID: " .. jobId) or "Job ID indisponível no Studio",
                10, UDim2.fromOffset(8, 0), UDim2.new(1, -16, 1, 0), {})

            label.TextTruncate = Enum.TextTruncate.AtEnd
            table.insert(self.Elements, label)
            return label
        end

        function tab:AddLink(linkOptions)
            if typeof(linkOptions) == "string" then
                linkOptions = { Name = linkOptions }
            end
            linkOptions = linkOptions or {}

            local row = addRow("Link", 38)
            local button = create("TextButton", {
                Name = "LinkButton",
                Position = UDim2.fromOffset(4, 4),
                Size = UDim2.new(1, -8, 1, -8),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0,
                Text = tostring(linkOptions.Name or linkOptions.Url or "Link"),
                TextColor3 = self.Window.Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                AutoButtonColor = true,
            }, row)
            corner(button, 5)

            button.Activated:Connect(function()
                if typeof(linkOptions.Callback) == "function" then
                    local ok, err = pcall(
                        linkOptions.Callback,
                        linkOptions.Url
                    )
                    if not ok then
                        warn("OxygenUI link callback:", err)
                    end
                else
                    warn("OxygenUI: defina Callback para tratar este link.")
                end
            end)

            table.insert(self.Elements, button)
            return button
        end

        if name == "Update Log" then
            tab.UpdateLabel = makeText(page, self.UpdateLog, 12,
                UDim2.new(), UDim2.new(1, -2, 0, 100), {
                    Wrapped = true,
                })
        end

        if not self.CurrentTab then
            selectTab()
        end

        return tab
    end

    return self
end

-- =========================================================
-- CRIAÇÃO INICIAL DA OXYGENUI
-- A API já está disponível acima para ser usada neste arquivo.
-- =========================================================

local Window = OxygenUI:CreateWindow({
    Title = "OxygenUI",
    Width = 780,
    Height = 620,
    Theme = "Yellow",
})

local Main = Window:CreateTab({
    Name = "Main",
    Icon = "⌂",
})

Main:AddSection("Main Features")
Main:AddLabel("OxygenUI carregada com sucesso.")
Main:AddButton({
    Name = "Verificar API",
    Callback = function()
        print("OxygenUI: API funcionando.")
    end,
})

Main:AddToggle({
    Name = "Exemplo de Toggle",
    Default = false,
    Callback = function(enabled)
        print("Toggle:", enabled)
    end,
})

Main:AddInput({
    Placeholder = "Digite algo e pressione Enter...",
    Callback = function(text, enterPressed)
        if enterPressed then
            print("Texto digitado:", text)
        end
    end,
})

local Config = Window:CreateTab({
    Name = "Config",
    Icon = "⚙",
})

Config:AddSection("Aparência")

Config:AddButton({
    Name = "Tema Yellow",
    Callback = function()
        Window:SetTheme("Yellow")
    end,
})

Config:AddButton({
    Name = "Tema White",
    Callback = function()
        Window:SetTheme("White")
    end,
})

local Settings = Window:CreateTab({
    Name = "Settings",
    Icon = "✿",
})

Settings:AddSection("Informações")
Settings:AddJobID()
Settings:AddLabel("Criado por Noctvrad.")

Settings:AddButton({
    Name = "Mostrar Update Log",
    Callback = function()
        Window:SetUpdateLog("OxygenUI carregada. API pronta para uso.")
        print(Window.UpdateLog)
    end,
})

-- Para adicionar outras abas e elementos, continue usando:
-- local Extra = Window:CreateTab({Name = "Extra", Icon = "★"})
-- Extra:AddSection("Minha seção")
-- Extra:AddButton({Name = "Executar", Callback = function()
--     print("Funcionou!")
-- end})

-- Não usamos CoreGui, ModuleScript ou require.
