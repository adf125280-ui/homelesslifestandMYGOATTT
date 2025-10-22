local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")


local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local localPlayer = game.Players.LocalPlayer

local floatDistance = 4    -- studs behind the target
local floatHeight = 10      -- Y height above target
local liftSpeed = 50       -- vertical teleport boost


local levitationAnimation = Instance.new("Animation")
levitationAnimation.AnimationId = "rbxassetid://616006778"


local levitationTrack = humanoid:LoadAnimation(levitationAnimation)
levitationTrack.Looped = true

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
local function getTargetRoot(targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if target and target.Character then
        return target.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
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
		if distance < 15 then
			humanoid.PlatformStand = true
			levitationTrack:Play()
			levitationTrack:AdjustSpeed(0)     
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
	["stop"] = {stop, "Stops the bot.", nil},
	["heartbeat"] = {heartbeat, "Check if bot living", nil},
	["changeOwnership"] = {changeOwnership, "Change ownership of bot", {newOwner}},
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

				args = nil
				if string.find(message, " ") then
					args = {}
					cmd = string.split(message, " ")[1]
					argss = string.split(argsr, " ")
					for arg in argss do
						print (arg)
						args[#args+1] = arg
					end
				else
					cmd = message
				end
				if not(cmd in cmds) then
					sendFormattedChat("Invalid command: "..cmd)
					return
				end

				if not(cmds[cmd][3] == nil) and args == nil then
					sendFormattedChat(#cmds[cmd][3]" args expected, none recieved for: "..cmd)
					return
				end
				if not(args == nil) and not(#cmds[cmd][3] == #args]) then
					sendFormattedChat("Incorrect amount of args recieved, "..#cmds[cmd][3]" expected, "..#args.." recieved.")
					return
				end

				targetFunc = cmds[cmd]
				if args then
					targetFunc(args)
				else
					targetFunc()
				end
			end
			
		end
    end)
end

--float animation
RunService.RenderStepped:Connect(function()
	if activity == "IDLE" and isTravelling == false then
	    local targetRoot = getTargetRoot(owner)
	    if not targetRoot then return end
		
	    local offset = -targetRoot.CFrame.LookVector * floatDistance
	    local desiredPosition = targetRoot.Position + offset + Vector3.new(0, floatHeight, 0)
	
	    rootPart.CFrame = CFrame.lookAt(desiredPosition, targetRoot.Position + Vector3.new(0, floatHeight, 0), Vector3.new(0,1,0))
	
	    rootPart.Velocity = Vector3.new(0, liftSpeed, 0)
	end
end)



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
