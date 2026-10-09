--[[
    OxygenUI | Noctvrad
    Biblioteca standalone para Roblox Luau.
    Retorna a tabela OxygenUI para o script carregador.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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

local function make(className, props, parent)
    local object = Instance.new(className)

    for property, value in pairs(props or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function round(object, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
    }, object)
end

local function outline(object, color, thickness)
    return make("UIStroke", {
        Color = color or Color3.new(1, 1, 1),
        Thickness = thickness or 1,
    }, object)
end

local function label(parent, text, size, position, dimensions, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Position = position or UDim2.new(),
        Size = dimensions or UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Gotham,
        Text = tostring(text or ""),
        TextSize = size or 12,
        TextColor3 = color or Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    }, parent)
end

local function safeCallback(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[OxygenUI] Callback error:", err)
    end
end

function OxygenUI:CreateWindow(options)
    options = options or {}

    local player = Players.LocalPlayer
    assert(player, "OxygenUI: CreateWindow precisa ser chamado no cliente.")

    local playerGui = player:WaitForChild("PlayerGui")

    local self = setmetatable({}, OxygenUI)

    self.Title = options.Title or "OxygenUI"
    self.ThemeName = Themes[options.Theme] and options.Theme or "Yellow"
    self.Theme = Themes[self.ThemeName]
    self.Tabs = {}
    self.TabOrder = {}
    self.CurrentTab = nil
    self.Closed = false
    self.Minimized = false
    self.UpdateLog = "OxygenUI carregada."
    self.Connections = {}
    self.StyleObjects = {}

    local previous = playerGui:FindFirstChild("OxygenUI")
    if previous then
        previous:Destroy()
    end

    local screen = make("ScreenGui", {
        Name = "OxygenUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    }, playerGui)

    self.Screen = screen

    local width = math.clamp(tonumber(options.Width) or 780, 340, 1200)
    local height = math.clamp(tonumber(options.Height) or 620, 300, 900)

    local window = make("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screen)

    self.WindowFrame = window
    round(window, 9)
    self.WindowStroke = outline(window, self.Theme.Border, 2)

    -- Partículas: pontos que sobem e desaparecem.
    local particleLayer = make("Frame", {
        Name = "ParticleLayer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        ClipsDescendants = true,
    }, window)

    self.ParticleLayer = particleLayer

    -- Barra superior.
    local topbar = make("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, window)

    self.Topbar = topbar

    label(
        topbar,
        self.Title,
        17,
        UDim2.fromOffset(15, 0),
        UDim2.new(1, -110, 1, 0),
        self.Theme.Text
    ).Font = Enum.Font.GothamBold

    local minimize = make("TextButton", {
        Name = "Minimize",
        Position = UDim2.new(1, -67, 0, 10),
        Size = UDim2.fromOffset(23, 23),
        BackgroundColor3 = Color3.fromRGB(255, 175, 40),
        Text = "-",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 4,
    }, topbar)

    round(minimize, 20)
    outline(minimize, Color3.new(1, 1, 1), 1)

    local close = make("TextButton", {
        Name = "Close",
        Position = UDim2.new(1, -36, 0, 10),
        Size = UDim2.fromOffset(23, 23),
        BackgroundColor3 = Color3.fromRGB(230, 65, 65),
        Text = "×",
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 4,
    }, topbar)

    round(close, 20)
    outline(close, Color3.new(1, 1, 1), 1)

    -- Barra lateral.
    local sidebar = make("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(10, 53),
        Size = UDim2.new(0, 150, 1, -65),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, window)

    round(sidebar, 8)
    outline(sidebar, self.Theme.Border, 1)

    local tabList = make("ScrollingFrame", {
        Name = "TabList",
        Position = UDim2.fromOffset(7, 8),
        Size = UDim2.new(1, -14, 1, -43),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ZIndex = 4,
    }, sidebar)

    make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabList)

    label(
        sidebar,
        "Created By Noctvrad",
        10,
        UDim2.new(0, 7, 1, -30),
        UDim2.new(1, -14, 0, 22),
        self.Theme.Muted
    ).TextXAlignment = Enum.TextXAlignment.Center

    -- Área de conteúdo.
    local content = make("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 170, 0, 53),
        Size = UDim2.new(1, -180, 1, -65),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, window)

    round(content, 8)
    outline(content, self.Theme.Border, 1)

    local pageTitle = label(
        content,
        "Main",
        18,
        UDim2.fromOffset(15, 8),
        UDim2.new(1, -30, 0, 30),
        self.Theme.Text
    )

    pageTitle.Font = Enum.Font.GothamBold

    local pageContainer = make("Frame", {
        Name = "PageContainer",
        Position = UDim2.fromOffset(10, 45),
        Size = UDim2.new(1, -20, 1, -55),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 4,
    }, content)

    self.Sidebar = sidebar
    self.TabList = tabList
    self.Content = content
    self.PageTitle = pageTitle
    self.PageContainer = pageContainer

    local function registerStyle(object, property, key)
        table.insert(self.StyleObjects, {
            Object = object,
            Property = property,
            Key = key,
        })
    end

    self.RegisterStyle = registerStyle

    registerStyle(window, "BackgroundColor3", "Background")
    registerStyle(topbar, "BackgroundColor3", "Panel")
    registerStyle(sidebar, "BackgroundColor3", "Panel")
    registerStyle(content, "BackgroundColor3", "Panel")
    registerStyle(self.WindowStroke, "Color", "Border")

    -- Sistema de partículas.
    task.spawn(function()
        while screen.Parent and particleLayer.Parent do
            local particle = make("Frame", {
                Name = "Particle",
                Size = UDim2.fromOffset(
                    math.random(3, 5),
                    math.random(3, 5)
                ),
                Position = UDim2.new(
                    math.random(2, 98) / 100,
                    0,
                    1,
                    0
                ),
                BackgroundColor3 = self.Theme.Accent,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                ZIndex = 2,
            }, particleLayer)

            round(particle, 20)

            local duration = math.random(30, 50) / 10
            local targetPosition = UDim2.new(
                particle.Position.X.Scale,
                0,
                -0.05,
                0
            )

            local animation = TweenService:Create(
                particle,
                TweenInfo.new(duration, Enum.EasingStyle.Linear),
                {
                    Position = targetPosition,
                    BackgroundTransparency = 1,
                }
            )

            animation:Play()

            task.delay(duration + 0.1, function()
                if particle.Parent then
                    particle:Destroy()
                end
            end)

            task.wait(math.random(25, 50) / 10)
        end
    end)

    -- Arrastar a janela pelo topo.
    local dragging = false
    local dragStart
    local startPosition

    table.insert(self.Connections, topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = window.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end))

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))

    local expandedSize = window.Size

    table.insert(self.Connections, minimize.Activated:Connect(function()
        if self.Closed then
            return
        end

        self.Minimized = not self.Minimized

        if self.Minimized then
            expandedSize = window.Size
            sidebar.Visible = false
            content.Visible = false
            minimize.Text = "+"
            TweenService:Create(window, TweenInfo.new(0.2), {
                Size = UDim2.fromOffset(width, 43),
            }):Play()
        else
            window.Size = UDim2.fromOffset(width, 43)
            sidebar.Visible = true
            content.Visible = true
            minimize.Text = "-"
            TweenService:Create(window, TweenInfo.new(0.2), {
                Size = expandedSize,
            }):Play()
        end
    end))

    table.insert(self.Connections, close.Activated:Connect(function()
        self:Destroy()
    end))

    function self:Destroy()
        if self.Closed then
            return
        end

        self.Closed = true

        for _, connection in ipairs(self.Connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end

        if self.Screen and self.Screen.Parent then
            self.Screen:Destroy()
        end
    end

    function self:SetTheme(name)
        if not Themes[name] then
            warn("[OxygenUI] Use somente Yellow ou White.")
            return false
        end

        self.ThemeName = name
        self.Theme = Themes[name]

        for _, item in ipairs(self.StyleObjects) do
            if item.Object and item.Object.Parent then
                local color = self.Theme[item.Key]
                if color then
                    item.Object[item.Property] = color
                end
            end
        end

        for _, tab in ipairs(self.TabOrder) do
            for _, element in ipairs(tab.ThemeElements) do
                if element.Object and element.Object.Parent then
                    local color = self.Theme[element.Key]
                    if color then
                        element.Object[element.Property] = color
                    end
                end
            end

            if tab.ToggleRefresh then
                for _, refresh in ipairs(tab.ToggleRefresh) do
                    refresh()
                end
            end
        end

        for _, tab in ipairs(self.TabOrder) do
            if tab == self.CurrentTab then
                tab.Button.BackgroundColor3 = self.Theme.Accent
            end
        end

        return true
    end

    function self:SetIcon(tabName, imageId)
        local tab = self.Tabs[tabName]
        if not tab then
            warn("[OxygenUI] Aba não encontrada:", tabName)
            return false
        end

        tab.IconValue = imageId

        if typeof(imageId) == "string"
            and (string.match(imageId, "^%d+$")
            or string.find(imageId, "rbxassetid://", 1, true)) then

            if string.match(imageId, "^%d+$") then
                imageId = "rbxassetid://" .. imageId
            end

            tab.IconImage.Image = imageId
            tab.IconImage.Visible = true
            tab.IconText.Visible = false
        else
            tab.IconText.Text = tostring(imageId or "")
            tab.IconText.Visible = true
            tab.IconImage.Visible = false
        end

        return true
    end

    function self:SetUpdateLog(message)
        self.UpdateLog = tostring(message or "")

        local tab = self.Tabs["Update Log"]
        if tab and tab.UpdateLabel then
            tab.UpdateLabel.Text = self.UpdateLog
        end
    end

    function self:GetJobID()
        return game.JobId
    end

    function self:CreateTab(tabOptions)
        tabOptions = tabOptions or {}

        local name = tostring(tabOptions.Name or "Tab")

        if self.Tabs[name] then
            warn("[OxygenUI] Essa aba já existe:", name)
            return self.Tabs[name]
        end

        local tab = {
            Name = name,
            Window = self,
            IconValue = tabOptions.Icon or "•",
            ThemeElements = {},
            ToggleRefresh = {},
        }

        local button = make("TextButton", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = self.Theme.Element,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = true,
            LayoutOrder = #self.TabOrder + 1,
            ZIndex = 5,
        }, tabList)

        round(button, 6)

        local iconText = label(
            button,
            tostring(tab.IconValue),
            15,
            UDim2.fromOffset(5, 0),
            UDim2.fromOffset(27, 36),
            self.Theme.Text
        )

        iconText.TextXAlignment = Enum.TextXAlignment.Center
        iconText.ZIndex = 6

        local iconImage = make("ImageLabel", {
            Name = "IconImage",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.fromOffset(20, 20),
            Image = "",
            Visible = false,
            ZIndex = 6,
        }, button)

        label(
            button,
            name,
            12,
            UDim2.fromOffset(36, 0),
            UDim2.new(1, -40, 1, 0),
            self.Theme.Text
        ).ZIndex = 6

        local page = make("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 5,
        }, pageContainer)

        make("UIListLayout", {
            Padding = UDim.new(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        make("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 5),
        }, page)

        tab.Button = button
        tab.Page = page
        tab.IconText = iconText
        tab.IconImage = iconImage

        self.Tabs[name] = tab
        table.insert(self.TabOrder, tab)

        self.RegisterStyle(button, "BackgroundColor3", "Element")

        local function selectTab()
            if self.Closed then
                return
            end

            for _, other in ipairs(self.TabOrder) do
                other.Page.Visible = false
                other.Button.BackgroundColor3 = self.Theme.Element
            end

            tab.Page.Visible = true
            tab.Button.BackgroundColor3 = self.Theme.Accent
            self.CurrentTab = tab
            self.PageTitle.Text = tab.Name
        end

        table.insert(self.Connections, button.Activated:Connect(selectTab))

        local function addRow(rowName, height)
            local row = make("Frame", {
                Name = rowName,
                Size = UDim2.new(1, -2, 0, height or 38),
                BackgroundColor3 = self.Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 5,
            }, page)

            round(row, 6)

            table.insert(tab.ThemeElements, {
                Object = row,
                Property = "BackgroundColor3",
                Key = "Element",
            })

            return row
        end

        local function registerTabStyle(object, property, key)
            table.insert(tab.ThemeElements, {
                Object = object,
                Property = property,
                Key = key,
            })
        end

        function tab:AddSection(text)
            local section = label(
                page,
                text or "Section",
                13,
                UDim2.new(),
                UDim2.new(1, -2, 0, 27),
                self.Theme.Accent
            )

            section.Font = Enum.Font.GothamBold
            registerTabStyle(section, "TextColor3", "Accent")

            return section
        end

        function tab:AddLabel(text)
            local row = addRow("Label", 36)

            local textLabel = label(
                row,
                text or "",
                12,
                UDim2.fromOffset(10, 0),
                UDim2.new(1, -20, 1, 0),
                self.Window.Theme.Text
            )

            registerTabStyle(textLabel, "TextColor3", "Text")
            return textLabel
        end

        function tab:AddButton(options)
            if typeof(options) == "string" then
                options = { Name = options }
            end
            options = options or {}

            local row = addRow("Button", 38)

            local buttonObject = make("TextButton", {
                Name = "Action",
                Position = UDim2.fromOffset(4, 4),
                Size = UDim2.new(1, -8, 1, -8),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0,
                Text = tostring(options.Name or "Button"),
                TextColor3 = self.Window.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                ZIndex = 6,
            }, row)

            round(buttonObject, 5)
            registerTabStyle(buttonObject, "BackgroundColor3", "Panel")
            registerTabStyle(buttonObject, "TextColor3", "Text")

            table.insert(self.Window.Connections, buttonObject.Activated:Connect(function()
                safeCallback(options.Callback)
            end))

            return buttonObject
        end

        function tab:AddToggle(options)
            options = options or {}

            local state = options.Default == true
            local row = addRow("Toggle", 38)

            local textLabel = label(
                row,
                options.Name or "Toggle",
                12,
                UDim2.fromOffset(10, 0),
                UDim2.new(1, -65, 1, 0),
                self.Window.Theme.Text
            )

            registerTabStyle(textLabel, "TextColor3", "Text")

            local toggleButton = make("TextButton", {
                Name = "ToggleControl",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(40, 22),
                BackgroundColor3 = state
                    and self.Window.Theme.Accent
                    or self.Window.Theme.Panel,
                BorderSizePixel = 0,
                Text = state and "ON" or "OFF",
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = state and Color3.fromRGB(15, 15, 15)
                    or self.Window.Theme.Text,
                ZIndex = 6,
            }, row)

            round(toggleButton, 5)

            local function refreshToggle()
                toggleButton.BackgroundColor3 = state
                    and self.Window.Theme.Accent
                    or self.Window.Theme.Panel

                toggleButton.Text = state and "ON" or "OFF"

                toggleButton.TextColor3 = state
                    and Color3.fromRGB(15, 15, 15)
                    or self.Window.Theme.Text
            end

            table.insert(tab.ToggleRefresh, refreshToggle)

            local function setState(value, invokeCallback)
                state = value == true
                refreshToggle()

                if invokeCallback then
                    safeCallback(options.Callback, state)
                end
            end

            table.insert(self.Window.Connections, toggleButton.Activated:Connect(function()
                setState(not state, true)
            end))

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

        function tab:AddInput(options)
            options = options or {}

            local row = addRow("Input", 40)

            local box = make("TextBox", {
                Name = "InputBox",
                Position = UDim2.fromOffset(7, 5),
                Size = UDim2.new(1, -14, 1, -10),
                BackgroundColor3 = self.Window.Theme.Panel,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                PlaceholderText = options.Placeholder or "Digite aqui...",
                PlaceholderColor3 = self.Window.Theme.Muted,
                Text = options.Default or "",
                TextColor3 = self.Window.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
            }, row)

            round(box, 5)

            make("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }, box)

            registerTabStyle(box, "BackgroundColor3", "Panel")
            registerTabStyle(box, "TextColor3", "Text")

            table.insert(self.Window.Connections, box.FocusLost:Connect(function(enterPressed)
                safeCallback(options.Callback, box.Text, enterPressed)
            end))

            return box
        end

        function tab:AddJobID()
            local jobId = game.JobId
            local row = addRow("JobID", 38)

            local textLabel = label(
                row,
                jobId ~= "" and ("Job ID: " .. jobId)
                    or "Job ID indisponível no Studio",
                10,
                UDim2.fromOffset(8, 0),
                UDim2.new(1, -16, 1, 0),
                self.Window.Theme.Text
            )

            registerTabStyle(textLabel, "TextColor3", "Text")
            return textLabel
        end

        function tab:AddLink(options)
            if typeof(options) == "string" then
                options = { Name = options }
            end
            options = options or {}

            return self:AddButton({
                Name = options.Name or options.Url or "Link",
                Callback = function()
                    safeCallback(options.Callback, options.Url)
                end,
            })
        end

        if name == "Update Log" then
            tab.UpdateLabel = tab:AddLabel(self.UpdateLog)
            tab.UpdateLabel.Size = UDim2.new(1, -2, 0, 100)
        end

        if not self.CurrentTab then
            selectTab()
        end

        return tab
    end

    return self
end

return OxygenUI
