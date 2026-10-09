--[[
    OxygenUI Official
    API Version: 2.0
    Created By: Noctvrad
    Themes: Yellow / White
]]

local OxygenUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

OxygenUI.Config = {
    Name = "OxygenUI",
    Version = "2.0",
    Theme = "Yellow",
    ParticleImage = "rbxassetid://6523330152",
    ParticleCount = 22,
    Credits = "Created By Noctvrad",
}

OxygenUI.Themes = {
    Yellow = {
        Background = Color3.fromRGB(5, 5, 7),
        Panel = Color3.fromRGB(10, 10, 12),
        Content = Color3.fromRGB(38, 38, 40),
        Element = Color3.fromRGB(205, 205, 205),
        Accent = Color3.fromRGB(255, 166, 20),
        Text = Color3.fromRGB(255, 255, 255),
        ElementText = Color3.fromRGB(0, 0, 0),
        Muted = Color3.fromRGB(180, 180, 185),
        Border = Color3.fromRGB(240, 240, 240),
    },

    White = {
        Background = Color3.fromRGB(5, 5, 7),
        Panel = Color3.fromRGB(10, 10, 12),
        Content = Color3.fromRGB(38, 38, 40),
        Element = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        ElementText = Color3.fromRGB(0, 0, 0),
        Muted = Color3.fromRGB(180, 180, 185),
        Border = Color3.fromRGB(240, 240, 240),
    },
}

OxygenUI.Theme = OxygenUI.Themes.Yellow
OxygenUI.Tabs = {}
OxygenUI.Elements = {}

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
        CornerRadius = UDim.new(0, radius or 8),
    }, parent)
end

local function Stroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or OxygenUI.Theme.Border,
        Thickness = thickness or 1,
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
        Text = text or "",
        TextColor3 = color or OxygenUI.Theme.Text,
        TextSize = size or 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

--// Window
function OxygenUI:CreateWindow(options)
    options = options or {}

    local width = options.Width or 780
    local height = options.Height or 620
    local windowTitle = options.Title or "OxygenUI"

    local previous = PlayerGui:FindFirstChild("OxygenUI")
    if previous then
        previous:Destroy()
    end

    self.Tabs = {}
    self.Elements = {}
    self.Theme = self.Themes[self.Config.Theme] or self.Themes.Yellow

    local gui = Create("ScreenGui", {
        Name = "OxygenUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    self.Gui = gui

    local window = Create("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(width, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)

    self.Main = window
    Corner(window, 6)
    self.WindowStroke = Stroke(window, self.Theme.Border, 2)

    --// Particle layer
    local particleLayer = Create("Frame", {
        Name = "ParticleLayer",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1,
    }, window)

    local running = true
    self.Running = true

    self._connections = {}

    local function AddConnection(connection)
        table.insert(self._connections, connection)
        return connection
    end

    local function CreateParticle()
        if not running or not particleLayer.Parent then
            return
        end

        local dot = Create("ImageLabel", {
            Name = "Particle",
            BackgroundTransparency = 1,
            Image = self.Config.ParticleImage,
            ImageColor3 = self.Theme.Text,
            ImageTransparency = math.random(15, 55) / 100,
            Size = UDim2.fromOffset(
                math.random(3, 7),
                math.random(3, 7)
            ),
            Position = UDim2.new(
                math.random(1, 1000) / 1000,
                0,
                1,
                math.random(0, 20)
            ),
            ZIndex = 1,
        }, particleLayer)

        local duration = math.random(35, 75) / 10

        local animation = Tween(dot, duration, {
            Position = UDim2.new(
                dot.Position.X.Scale,
                0,
                0,
                -10
            ),
            ImageTransparency = 1,
        })

        animation.Completed:Connect(function()
            if dot.Parent then
                dot:Destroy()
            end
        end)
    end

    task.spawn(function()
        while running and gui.Parent do
            CreateParticle()
            task.wait(0.15)
        end
    end)

    --// Header
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, window)

    local title = MakeText(
        header,
        windowTitle,
        20,
        self.Theme.Text
    )

    title.Name = "Title"
    title.Position = UDim2.fromOffset(20, 5)
    title.Size = UDim2.new(0.7, 0, 0, 40)
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 5

    local minimize = Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.fromOffset(23, 23),
        Position = UDim2.new(1, -65, 0, 8),
        BackgroundColor3 = self.Theme.Accent,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, header)

    Corner(minimize, 100)
    Stroke(minimize, self.Theme.Border, 1.5)

    local close = Create("TextButton", {
        Name = "Close",
        Size = UDim2.fromOffset(23, 23),
        Position = UDim2.new(1, -34, 0, 8),
        BackgroundColor3 = Color3.fromRGB(255, 35, 35),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, header)

    Corner(close, 100)
    Stroke(close, self.Theme.Border, 1.5)

    --// Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(10, 53),
        Size = UDim2.new(0, 150, 1, -68),
        BackgroundColor3 = self.Theme.Panel,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, window)

    Corner(sidebar, 5)
    self.SidebarStroke = Stroke(sidebar, self.Theme.Border, 2)

    local tabButtons = Create("Frame", {
        Name = "TabButtons",
        Position = UDim2.fromOffset(5, 13),
        Size = UDim2.new(1, -10, 1, -26),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, sidebar)

    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabButtons)

    --// Content
    local content = Create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(178, 70),
        Size = UDim2.new(1, -198, 1, -105),
        BackgroundColor3 = self.Theme.Content,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, window)

    Corner(content, 5)
    self.ContentStroke = Stroke(content, self.Theme.Border, 1)

    local contentTitle = MakeText(
        content,
        "Main Tab",
        21,
        self.Theme.Text
    )

    contentTitle.Name = "PageTitle"
    contentTitle.Position = UDim2.fromOffset(20, 8)
    contentTitle.Size = UDim2.new(1, -30, 0, 30)
    contentTitle.Font = Enum.Font.Code
    contentTitle.ZIndex = 4

    --// Page container
    local pageContainer = Create("Frame", {
        Name = "PageContainer",
        Position = UDim2.fromOffset(10, 46),
        Size = UDim2.new(1, -20, 1, -56),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 3,
    }, content)

    --// Credits
    local credits = MakeText(
        window,
        self.Config.Credits,
        10,
        self.Theme.Text
    )

    credits.Name = "Credits"
    credits.AnchorPoint = Vector2.new(1, 1)
    credits.Position = UDim2.new(1, -20, 1, -7)
    credits.Size = UDim2.fromOffset(180, 15)
    credits.TextXAlignment = Enum.TextXAlignment.Right
    credits.Font = Enum.Font.GothamBold
    credits.ZIndex = 5

    self.Content = content
    self.TitleLabel = contentTitle
    self.TabButtons = tabButtons
    self.PageContainer = pageContainer
    self.ParticleLayer = particleLayer
    self.MinimizeButton = minimize
    self.CloseButton = close
    self.CreditsLabel = credits

    --// Theme registry
    self._themeObjects = {}

    local function Register(object, property, role)
        table.insert(self._themeObjects, {
            Object = object,
            Property = property,
            Role = role,
        })
    end

    Register(window, "BackgroundColor3", "Background")
    Register(sidebar, "BackgroundColor3", "Panel")
    Register(content, "BackgroundColor3", "Content")
    Register(title, "TextColor3", "Text")
    Register(contentTitle, "TextColor3", "Text")
    Register(credits, "TextColor3", "Text")
    Register(minimize, "BackgroundColor3", "Accent")

    self._registerTheme = Register

    --// Tabs
    local activeTab
    local SelectTab

    SelectTab = function(tab)
        if activeTab and activeTab ~= tab then
            activeTab.Page.Visible = false
            activeTab.Button.BackgroundColor3 = self.Theme.Element
            activeTab.Label.TextColor3 = self.Theme.ElementText
            activeTab.Icon.TextColor3 = self.Theme.ElementText
        end

        activeTab = tab
        tab.Page.Visible = true
        contentTitle.Text = tab.Name .. " Tab"

        tab.Button.BackgroundColor3 = self.Theme.Accent
        tab.Label.TextColor3 = self.Theme.ElementText
        tab.Icon.TextColor3 = self.Theme.ElementText

        self.ActiveTab = tab
    end

    self._selectTab = SelectTab

    function self:CreateTab(tabOptions)
        tabOptions = tabOptions or {}

        local tabName = tabOptions.Name or "Tab"
        local iconText = tabOptions.Icon or "✿"

        local button = Create("TextButton", {
            Name = tabName .. "Button",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = self.Theme.Element,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = #self.Tabs + 1,
            ZIndex = 4,
        }, tabButtons)

        Corner(button, 8)

        local icon = Create("TextLabel", {
            Name = "Icon",
            Position = UDim2.fromOffset(4, 0),
            Size = UDim2.fromOffset(29, 32),
            BackgroundTransparency = 1,
            Text = iconText,
            TextColor3 = self.Theme.ElementText,
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            ZIndex = 5,
        }, button)

        local label = Create("TextLabel", {
            Name = "Label",
            Position = UDim2.fromOffset(34, 0),
            Size = UDim2.new(1, -38, 1, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = self.Theme.ElementText,
            TextSize = 14,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        }, button)

        local page = Create("ScrollingFrame", {
            Name = tabName .. "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = self.Theme.Accent,
            CanvasSize = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, pageContainer)

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
        }, page)

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

        Register(button, "BackgroundColor3", "Element")
        Register(label, "TextColor3", "ElementText")
        Register(icon, "TextColor3", "ElementText")

        button.Activated:Connect(function()
            Tween(button, 0.12, {
                BackgroundColor3 = self.Theme.Accent,
            })

            SelectTab(tab)
        end)

        local function AddElement(object)
            table.insert(self.Elements, object)
            return object
        end

        local function NewElement(className, properties)
            properties.LayoutOrder = #page:GetChildren() + 1

            local object = Create(className, properties, page)
            return AddElement(object)
        end

        --// Section
        function tab:AddSection(text)
            local section = NewElement("TextLabel", {
                Name = "Section",
                Size = UDim2.new(1, -4, 0, 30),
                BackgroundTransparency = 1,
                Text = text or "Section",
                TextColor3 = self.Theme and self.Theme.Accent
                    or OxygenUI.Theme.Accent,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4,
            })

            Register(section, "TextColor3", "Accent")
            return section
        end

        --// Label
        function tab:AddLabel(text)
            local object = NewElement("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -4, 0, 25),
                BackgroundTransparency = 1,
                Text = text or "",
                TextColor3 = OxygenUI.Theme.Muted,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 4,
            })

            Register(object, "TextColor3", "Muted")
            return object
        end

        --// Button
        function tab:AddButton(options)
            options = options or {}

            local object = NewElement("TextButton", {
                Name = options.Name or "Button",
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = OxygenUI.Theme.Element,
                BorderSizePixel = 0,
                Text = options.Name or "Button",
                TextColor3 = OxygenUI.Theme.ElementText,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false,
                ZIndex = 4,
            })

            Corner(object, 7)

            Register(object, "BackgroundColor3", "Element")
            Register(object, "TextColor3", "ElementText")

            object.Activated:Connect(function()
                Tween(object, 0.12, {
                    BackgroundColor3 = OxygenUI.Theme.Accent,
                })

                task.delay(0.15, function()
                    if object.Parent then
                        Tween(object, 0.18, {
                            BackgroundColor3 = OxygenUI.Theme.Element,
                        })
                    end
                end)

                if options.Callback then
                    task.spawn(options.Callback)
                end
            end)

            return object
        end

        --// Toggle
        function tab:AddToggle(options)
            options = options or {}

            local state = options.Default == true

            local object = NewElement("TextButton", {
                Name = options.Name or "Toggle",
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = OxygenUI.Theme.Element,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 4,
            })

            Corner(object, 7)
            Register(object, "BackgroundColor3", "Element")

            local text = Create("TextLabel", {
                Name = "ToggleLabel",
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -55, 1, 0),
                BackgroundTransparency = 1,
                Text = options.Name or "Toggle",
                TextColor3 = OxygenUI.Theme.ElementText,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, object)

            Register(text, "TextColor3", "ElementText")

            local indicator = Create("Frame", {
                Name = "Indicator",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 15),
                BackgroundColor3 = state
                    and OxygenUI.Theme.Accent
                    or Color3.fromRGB(100, 100, 100),
                BorderSizePixel = 0,
                ZIndex = 5,
            }, object)

            Corner(indicator, 10)

            local function UpdateToggle()
                Tween(indicator, 0.15, {
                    BackgroundColor3 = state
                        and OxygenUI.Theme.Accent
                        or Color3.fromRGB(100, 100, 100),
                })

                if options.Callback then
                    task.spawn(options.Callback, state)
                end
            end

            object.Activated:Connect(function()
                state = not state
                UpdateToggle()
            end)

            local api = {}

            function api:Get()
                return state
            end

            function api:Set(value)
                state = value == true
                UpdateToggle()
            end

            api.Object = object
            return api
        end

        --// Input
        function tab:AddInput(options)
            options = options or {}

            local object = NewElement("TextBox", {
                Name = options.Name or "Input",
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = OxygenUI.Theme.Element,
                BorderSizePixel = 0,
                Text = options.Default or "",
                PlaceholderText = options.Placeholder or "Type here...",
                PlaceholderColor3 = OxygenUI.Theme.Muted,
                TextColor3 = OxygenUI.Theme.ElementText,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = false,
                ZIndex = 4,
            })

            Corner(object, 7)

            Register(object, "BackgroundColor3", "Element")
            Register(object, "TextColor3", "ElementText")

            object.FocusLost:Connect(function(enterPressed)
                if options.Callback then
                    task.spawn(
                        options.Callback,
                        object.Text,
                        enterPressed
                    )
                end
            end)

            return object
        end

        --// Dropdown
        function tab:AddDropdown(options)
            options = options or {}

            local values = options.Options or {}
            local index = 1

            local object = NewElement("TextButton", {
                Name = options.Name or "Dropdown",
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundColor3 = OxygenUI.Theme.Element,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 4,
            })

            Corner(object, 7)
            Register(object, "BackgroundColor3", "Element")

            local label = Create("TextLabel", {
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                Text = (options.Name or "Dropdown") .. ": "
                    .. tostring(values[index] or "None"),
                TextColor3 = OxygenUI.Theme.ElementText,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, object)

            Register(label, "TextColor3", "ElementText")

            object.Activated:Connect(function()
                if #values == 0 then
                    return
                end

                index = index % #values + 1
                label.Text = (options.Name or "Dropdown") .. ": "
                    .. tostring(values[index])

                if options.Callback then
                    options.Callback(values[index])
                end
            end)

            return {
                Get = function()
                    return values[index]
                end,

                Set = function(value)
                    for i, item in ipairs(values) do
                        if item == value then
                            index = i
                            label.Text = (options.Name or "Dropdown")
                                .. ": " .. tostring(value)
                            break
                        end
                    end
                end,

                Refresh = function(newValues)
                    values = newValues or {}
                    index = 1
                    label.Text = (options.Name or "Dropdown") .. ": "
                        .. tostring(values[index] or "None")
                end,

                Object = object,
            }
        end

        --// Slider
        function tab:AddSlider(options)
            options = options or {}

            local minimum = options.Min or 0
            local maximum = options.Max or 100
            local value = math.clamp(
                options.Default or minimum,
                minimum,
                maximum
            )

            local object = NewElement("Frame", {
                Name = options.Name or "Slider",
                Size = UDim2.new(1, -4, 0, 52),
                BackgroundColor3 = OxygenUI.Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 4,
            })

            Corner(object, 7)
            Register(object, "BackgroundColor3", "Element")

            local label = Create("TextLabel", {
                Position = UDim2.fromOffset(10, 3),
                Size = UDim2.new(1, -20, 0, 20),
                BackgroundTransparency = 1,
                Text = (options.Name or "Slider") .. ": " .. value,
                TextColor3 = OxygenUI.Theme.ElementText,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, object)

            Register(label, "TextColor3", "ElementText")

            local bar = Create("Frame", {
                Position = UDim2.new(0, 10, 0, 31),
                Size = UDim2.new(1, -20, 0, 6),
                BackgroundColor3 = Color3.fromRGB(110, 110, 110),
                BorderSizePixel = 0,
                ZIndex = 5,
            }, object)

            Corner(bar, 5)

            local fill = Create("Frame", {
                Size = UDim2.new(
                    (value - minimum) / math.max(maximum - minimum, 1),
                    0, 1, 0
                ),
                BackgroundColor3 = OxygenUI.Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, bar)

            Corner(fill, 5)

            local knob = Create("TextButton", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = OxygenUI.Theme.Accent,
                BorderSizePixel = 0,
                Text = "",
                ZIndex = 7,
            }, bar)

            Corner(knob, 100)

            local function SetValue(newValue)
                value = math.clamp(newValue, minimum, maximum)

                local percent = (value - minimum)
                    / math.max(maximum - minimum, 1)

                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, 0, 0.5, 0)
                label.Text = (options.Name or "Slider") .. ": " .. value

                if options.Callback then
                    options.Callback(value)
                end
            end

            local function UpdateFromInput(input)
                local percent = math.clamp(
                    (input.Position.X - bar.AbsolutePosition.X)
                        / math.max(bar.AbsoluteSize.X, 1),
                    0,
                    1
                )

                local newValue = minimum
                    + (maximum - minimum) * percent

                SetValue(math.floor(newValue + 0.5))
            end

            local dragging = false

            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateFromInput(input)
                end
            end)

            local sliderConnection = UserInputService.InputChanged:Connect(function(input)
                if dragging and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                ) then
                    UpdateFromInput(input)
                end
            end)

            table.insert(self._connections, sliderConnection)

            local endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            table.insert(self._connections, endConnection)

            return {
                Get = function()
                    return value
                end,

                Set = SetValue,
                Object = object,
            }
        end

        return tab
    end

    --// Minimize
    local minimized = false

    minimize.Activated:Connect(function()
        minimized = not minimized

        sidebar.Visible = not minimized
        content.Visible = not minimized
        credits.Visible = not minimized

        Tween(window, 0.2, {
            Size = minimized
                and UDim2.fromOffset(width, 46)
                or UDim2.fromOffset(width, height),
        })
    end)

    --// Close
    close.Activated:Connect(function()
        self:Destroy()
    end)

    --// Dragging
    local dragging = false
    local dragStart
    local startPosition

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = window.Position
        end
    end)

    AddConnection(UserInputService.InputChanged:Connect(function(input)
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

    AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    --// Entrance animation
    window.Size = UDim2.fromOffset(width * 0.92, height * 0.92)
    window.BackgroundTransparency = 1

    Tween(window, 0.35, {
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 0,
    })

    self._running = function()
        return running
    end

    self._stop = function()
        running = false
    end

    self._destroyed = false

    return self
end

--// Set Theme
function OxygenUI:SetTheme(themeName)
    local theme = self.Themes[themeName]

    if not theme then
        warn("[OxygenUI] Use Yellow or White.")
        return false
    end

    self.Theme = theme
    self.Config.Theme = themeName

    for _, entry in ipairs(self._themeObjects or {}) do
        if entry.Object and entry.Object.Parent then
            entry.Object[entry.Property] = theme[entry.Role]
        end
    end

    for _, tab in ipairs(self.Tabs) do
        if tab.Page and tab.Page.Parent then
            tab.Page.ScrollBarImageColor3 = theme.Accent
        end
    end

    if self.ActiveTab then
        self.ActiveTab.Button.BackgroundColor3 = theme.Accent
        self.ActiveTab.Label.TextColor3 = theme.ElementText
        self.ActiveTab.Icon.TextColor3 = theme.ElementText
    end

    if self.MinimizeButton then
        self.MinimizeButton.BackgroundColor3 = theme.Accent
    end

    if self.ParticleLayer then
        for _, particle in ipairs(self.ParticleLayer:GetChildren()) do
            if particle:IsA("ImageLabel") then
                particle.ImageColor3 = theme.Text
            end
        end
    end

    return true
end

--// Set Tab Icon
function OxygenUI:SetIcon(tabName, icon)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == tabName then
            tab.Icon.Text = tostring(icon)
            return true
        end
    end

    warn("[OxygenUI] Tab not found:", tabName)
    return false
end

--// Destroy
function OxygenUI:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true

    if self._stop then
        self._stop()
    end

    for _, connection in ipairs(self._connections or {}) do
        connection:Disconnect()
    end

    if self.Gui then
        self.Gui:Destroy()
    end
end

return OxygenUI
