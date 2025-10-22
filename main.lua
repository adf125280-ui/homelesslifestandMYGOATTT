local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")


local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local localPlayer = game.Players.LocalPlayer


local activity = "IDLE"
local isTravelling = false




local textChatService = game:GetService("TextChatService")
local generalChat = textChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local message = "a"
generalChat:SendAsync(message)

owner = "bleeding"
prefix = "dog "


local function setCollision(enabled)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = enabled
		end
	end
end

local function NoclipLoop()
	if Clip == false and localPlayer.Character ~= nil then
		for _, child in pairs(localPlayer.Character:GetDescendants()) do
			if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
				child.CanCollide = false
			end
		end
	end
end

RunService.Stepped:Connect(NoclipLoop)

local function tptoPlayer(targetPlayerName)
	local targetPlayer = game.Players[targetPlayerName]
	if not targetPlayer or not targetPlayer.Character then return end
	local targetRoot = targetPlayer.Character:WaitForChild("HumanoidRootPart")

	local flying = true
	local stage = "travel"

	humanoid.PlatformStand = true
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	setCollision(false)

	rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 50, 0)
	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not flying then return end
		if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			flying = false
			return
		end

		local targetPos = targetRoot.Position
		local currentPos = rootPart.Position

		if stage == "travel" then
			local undergroundTarget = Vector3.new(targetPos.X, currentPos.Y, targetPos.Z)
			local distance = (undergroundTarget - currentPos).Magnitude

			if distance > 5 then
				rootPart.CFrame = CFrame.new(currentPos, undergroundTarget)
				local direction = (undergroundTarget - currentPos).Unit
				local speed = math.clamp(distance * 10, 100, 300)
				rootPart.Velocity = direction * speed
			else
				rootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y, targetPos.Z)
				flying = false
				rootPart.Velocity = Vector3.zero
				humanoid.PlatformStand = false
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				setCollision(true)
				connection:Disconnect()
				isTravelling = false
			end
		end
	end)
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.L then
        print("Script stopped!")
        activity = "STOPPED"
    end
end)

local function mainLoop()
	while activity == "IDLE" do
		task.wait()
		local ownerCharacter = game.Players[owner].Character or game.Players[owner].CharacterAdded:Wait()
		local targetRoot = ownerCharacter:WaitForChild("HumanoidRootPart")
		
		local localCharacter = player.Character or player.CharacterAdded:Wait()
		local localRoot = localCharacter:WaitForChild("HumanoidRootPart")
		
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if distance > 15 then
			if isTravelling == false then
				tptoPlayer(owner)
				isTravelling = true
			end
		end
	end
	task.wait()
end
local function sendFormattedChat(message)
	generalChat:SendAsync("[DOG]: "..message)
end



local function stop()
	sendFormattedChat("Stopping.")
	activity = "STOPPED"
	print ("Stopped.")
end
local function heartbeat()
	sendFormattedChat("alive")
end


cmds = {
	["stop"] = stop,
	["heartbeat"] = heartbeat,
}



local function onPlayerChatted(chattedPlayer)
    chattedPlayer.Chatted:Connect(function(message)
		print (message)
		message = message:lower()
		if chattedPlayer.Name == owner then
			if string.find(message, "^dog ") then
				message = string.gsub(message, "dog ", "")
				sendFormattedChat("recieved "..message)
				print (message)
				targetFunc = cmds[message]
				targetFunc()
			end
			
		end
    end)
end

game.Players.PlayerAdded:Connect(function(plr)
	print ("chatted")
    onPlayerChatted(plr)
end)

for _,player in pairs(game.Players:GetPlayers()) do
	onPlayerChatted(player)
end


print ("Starting!")
while true do
	mainLoop()
	if activity == "STOPPED" then 
		break
	end
	task.wait()
end
