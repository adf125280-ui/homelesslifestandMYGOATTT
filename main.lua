local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")


local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local localPlayer = game.Players.LocalPlayer

local floatDistance = 4    -- studs behind the target
local floatHeight = 13      -- Y height above target
local liftSpeed = 50       -- vertical teleport boost


local levitationAnimation = Instance.new("Animation")
levitationAnimation.AnimationId = "rbxassetid://616006778"


local levitationTrack = humanoid:LoadAnimation(levitationAnimation)
levitationTrack.Looped = true

local activity = "IDLE"
local isTravelling = false

local m1cooldown = 0.1 -- seconds
local m1lastfire = 0 -- last time the remote fired


local textChatService = game:GetService("TextChatService")
local generalChat = textChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local Player = Players.LocalPlayer

local trackedAnimations = {
    "rbxassetid://87671032450716",
    "rbxassetid://124067495485615",
    "rbxassetid://95313940608650",
    "rbxassetid://83975010227040",
    "rbxassetid://110804214522892",
    "rbxassetid://80539500731203"
}

local playerBlocking = {}


owner = "bleeding"
permowner = "bleeding"
prefix = "dog "

target = "none"


generalChat:SendAsync(owner.." owns me :3")




_G.HeadSize = 80
_G.Disabled = true

-- hitbox
game:GetService('RunService').RenderStepped:connect(function()
	if _G.Disabled then
		for i,v in next, game:GetService('Players'):GetPlayers() do
			if v.Name ~= game:GetService('Players').LocalPlayer.Name then
				pcall(function()
					v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
					v.Character.HumanoidRootPart.CanCollide = false
				end)
			end
		end
	end
end)




-- block tracker
local function isTrackedAnimation(animationId)
    for _, id in ipairs(trackedAnimations) do
        if id == animationId then
            return true
        end
    end
    return false
end

local function trackPlayerAnimations(player)
    local function onCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        local animator = humanoid:WaitForChild("Animator")
        local activeTracks = {}

        animator.AnimationPlayed:Connect(function(track)
            if track.Animation and isTrackedAnimation(track.Animation.AnimationId) then
                activeTracks[track] = true
                playerBlocking[player.Name] = true

                track.Stopped:Connect(function()
                    activeTracks[track] = nil
                    if next(activeTracks) == nil then
                        playerBlocking[player.Name] = false
                    end
                end)
            end
        end)
    end

    if player.Character then
        onCharacter(player.Character)
    end
    player.CharacterAdded:Connect(onCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
    trackPlayerAnimations(player)
end

Players.PlayerAdded:Connect(trackPlayerAnimations)

local function setCollision(enabled)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = enabled
		end
	end
end
function displaytoname(display) 
	for _,player in pairs(game.Players:GetPlayers()) do
		if string.lower(player.DisplayName) == string.lower(display) then
			return player.name
		end
	end
	return ""
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
			isTravelling = false
		end
	end


	
	while activity == "KILL" do
		task.wait()
		local ownerCharacter = game.Players[target].Character or game.Players[target].CharacterAdded:Wait()
		local targetRoot = ownerCharacter:WaitForChild("HumanoidRootPart")
		
		local localCharacter = player.Character or player.CharacterAdded:Wait()
		local localRoot = localCharacter:WaitForChild("HumanoidRootPart")
		
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if distance > 15 then
			if isTravelling == false then
				tptoPlayer(target)
				isTravelling = true
			end
		end
		if distance < 15 then
	        local now = tick()
	        if now - m1lastfire >= m1cooldown then
				local args = {}
				if (playerBlocking[target] == true) then
					args = {"M2"}
				else
					args = {"M1"}
				end
				task.wait(0.05)
	            game:GetService("ReplicatedStorage"):WaitForChild("CombatRemote"):FireServer(unpack(args))
	            m1lastfire = now 
				task.wait(0.05)
	        end
			
			local targetRoot = getTargetRoot(target)
		    if not targetRoot then return end
					
			local offset = -targetRoot.CFrame.LookVector
			local desiredPosition = targetRoot.Position + offset + Vector3.new(0, 10, 0)
			
			rootPart.CFrame = CFrame.lookAt(desiredPosition, targetRoot.Position + Vector3.new(0, 10, 0), Vector3.new(0,1,0))
			
			rootPart.Velocity = Vector3.new(0, liftSpeed, 0)

			isTravelling = false
		end
	end
	task.wait()
end



local function sendFormattedChat(message)
	generalChat:SendAsync("[DOG]: "..message)
end
local function sendCleanChat(message)
	generalChat:SendAsync(message)
end
local function findPlayer(playerNameRaw)
	local playerNameRaw = args[1]
	local playerName = nil
	for _,player in pairs(game.Players:GetPlayers()) do
		if string.lower(playerNameRaw) == string.lower(player.Name) then
			playerName = player.Name
		end
	end
	if playerName == nil then
		playerName = displaytoname(playerNameRaw)
	end
	if playerName == nil or playerName == " " or playerName == "" then
		return nil
	end
	return playerName

end
local function stop()
	sendFormattedChat("Stopping.")
	activity = "STOPPED"
	print ("Stopped.")
end
local function heartbeat()
	sendFormattedChat("alive")
end
local function changeowner(args)
	newOwnerRaw = args[1]
	newOwner = findPlayer(newOwnerRaw)
	if newOwner == nil then
		sendFormattedChat("Player does not exist "..newOwner)
	end
	sendFormattedChat("Changed owner to: "..newOwner)
	owner = newOwner
	activity = "IDLE"
end
local function say(args)
	sendFormattedChat(args[1])
end
local function sayclean(args)
	sendCleanChat(args[1])
end
local function help(args)
	local cmdname = args[1]
	sendFormattedChat("["..cmdname.."] - "..cmds[cmdname][2].. " takes ".. #cmds[cmdname].. " arguments.")
end
local function changeheight(args)
	local height = tonumber(args[1])
	if height == nil then
		sendFormattedChat("Height must be an int.")
	end
	floatHeight = height
end
local function kill(args)
	targetRaw = args[1]
	targetLocal = findPlayer(targetRaw)
	if targetLocal == nil then
		sendFormattedChat("Player does not exist "..targetLocal)
	end
	target = targetLocal
	sendFormattedChat("Killing player: "..targetLocal)
	activity = "KILL"
end
local function toidle()
	activity = "IDLE"
	sendFormattedChat("Returning to idle.")
end
cmds = {
	["stop"] = {stop, "Stops the bot.", nil},
	["heartbeat"] = {heartbeat, "Check if bot living", nil},
	["changeowner"] = {changeowner, "Change ownership of bot", {"newOwner"}},
	["say"] = {say, "Makes the bot send a message", {"message"}},
	["sayclean"] = {sayclean, "Makes the bot send a message without formatting", {"message"}},
	["changeheight"] = {changeheight, "Change the floating height", {"height"}},
	["help"] = {help, "Provides information about a command", {"commandname"}},
	["kill"] = {kill, "Kills player", {"playername"}},
	["idle"] = {toidle, "Returns bot to idle", nil},
}



local function onPlayerChatted(chattedPlayer)
    chattedPlayer.Chatted:Connect(function(message)
		print (message)
		message = message:lower()
		if chattedPlayer.Name == owner or chattedPlayer.Name == permowner then
			if string.find(message, "^dog ") then
				message = string.gsub(message, "dog ", "")
				--sendFormattedChat("recieved "..message)
				print (message)

				args = nil
				if string.find(message, " ") then
					args = {}
					full = string.split(message, " ")
					cmd = full[1]
					argss = full
					table.remove(argss, 1)
					for _,arg in pairs(argss) do
						print (arg)
						args[#args+1] = arg
					end
				else
					cmd = message
				end
				if not(cmds[cmd]) then
					sendFormattedChat("Invalid command: "..cmd)
					return
				end
				if not(cmds[cmd][3] == nil) and args == nil then
					sendFormattedChat(#cmds[cmd][3].." args expected, none recieved for: "..cmd)
					return
				end
				if not(args == nil) and not(#cmds[cmd][3] == #args) then
					sendFormattedChat("Incorrect amount of args recieved, "..#cmds[cmd][3].." expected, "..#args.." recieved.")
					return
				end

				targetFunc = cmds[cmd][1]
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
