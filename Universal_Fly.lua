local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

print("Loading Services...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

print("Loading Variables...")

local flyEnabled = false
local flySpeed = 50
local bodyVelocity
local bodyGyro
local flightConnection

local function isTypingInChat()
    return UserInput:GetFocusedTextBox() ~= nil
end

local function enableFly()
    if flyEnabled then return end
    flyEnabled = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.P = 1250
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 3000
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    flightConnection = RunService.RenderStepped:Connect(function()
        if isTypingInChat() then
            bodyVelocity.Velocity = Vector3.zero
            return
        end

        local camCF = workspace.CurrentCamera.CFrame
        local dir = Vector3.zero

        if UserInput:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * flySpeed
        else
            bodyVelocity.Velocity = Vector3.zero
        end

        bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
    end)
end

local function disableFly()
    if not flyEnabled then return end
    flyEnabled = false

    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

player.CharacterRemoving:Connect(function()
    if flyEnabled then
        disableFly()
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

print("Loading UI...")

local Window = Rayfield:CreateWindow({
   Name = "Universal Fly Script",
   Icon = 0,
   LoadingTitle = "Universal Fly Script",
   LoadingSubtitle = "by prnxz69",
   ShowText = "Rayfield",
   Theme = "Default",

   ToggleUIKeybind = "P",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(state)
        if state then
            enableFly()
        else
            disableFly()
        end
    end
})

MainTab:CreateKeybind({
    Name = "Fly Toggle Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "FlyKeybind",
    Callback = function()
        if flyEnabled then
            disableFly()
        else
            enableFly()
        end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "Speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeed",
    Callback = function(value)
        flySpeed = value
    end
})

print("Starting UI...")

Rayfield:LoadConfiguration()


print("Success!")

