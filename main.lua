local players = game:GetService("Players")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")


local player = Players.LocalPlayer
local localPlayer = game.Players.LocalPlayer

local floatDistance = 4    -- studs behind the target
local floatHeight = 13      -- Y height above target
local floatOffset = 0
local killHeight = 10
local liftSpeed = 50       -- vertical teleport boost
local flyspeed = 100
local sideOffset = 0

local blockFloat = false

local levitationAnimation = Instance.new("Animation")
levitationAnimation.AnimationId = "rbxassetid://616006778"


local levitationTrack = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(levitationAnimation)
levitationTrack.Looped = true

local activity = "IDLE"
local isTravelling = false

local m1cooldown = 0.1 -- seconds
local m1lastfire = 0 -- last time the remote fired

local auracooldown = 18 -- seconds
local auralastfire = 0 -- last time the remote fired
local aura = true

local chatPrefix = string.upper((string.gsub(prefix, " ", "")))

local textChatService = game:GetService("TextChatService")
local generalChat = textChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local Player = Players.LocalPlayer


local owner = getgenv().owner
local permowner = getgenv().permowner
local prefix = getgenv().prefix


print (owner)
print (permowner)
print (prefix)

local trackedAnimations = {
    "rbxassetid://87671032450716",
    "rbxassetid://124067495485615",
    "rbxassetid://95313940608650",
    "rbxassetid://83975010227040",
    "rbxassetid://110804214522892",
    "rbxassetid://80539500731203"
}
local auraAnims = {
    "rbxassetid://123950272740243",
    "rbxassetid://73905788028883",
    "rbxassetid://81802926038486",
    "rbxassetid://86772309534383",
    "rbxassetid://104094476952316",
	"rbxassetid://81210570135375",
}

	

local playerBlocking = {}
local playerAura = {}

hitboxImmune = {"Default_1717", "lindabowman", "bleeding", "DaFedex"}




target = "none"


generalChat:SendAsync(owner.." owns me :3")


whitelistedHeadSize = Vector3.new(1,1,1)

_G.HeadSize = 80
_G.Disabled = true

-- hitbox
game:GetService('RunService').RenderStepped:connect(function()
	if _G.Disabled then
		for i,v in next, game:GetService('Players'):GetPlayers() do
			if v.Name ~= game:GetService('Players').LocalPlayer.Name then
				local whitelisted = false
				for i,player in pairs(hitboxImmune) do
					if player == v.Name then
						whitelisted = true
					end
				end
				if whitelisted == false then			
					pcall(function()
						v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
						v.Character.HumanoidRootPart.CanCollide = false
					end)
				end
				if whitelisted == true then
					pcall(function()
						v.Character.HumanoidRootPart.Size = whitelistedHeadSize
						v.Character.HumanoidRootPart.CanCollide = false
					end)
				end
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

-- aura tracker
local function isAuraAnimation(animationId)
    for _, id in ipairs(auraAnims) do
        if id == animationId then
            return true
        end
    end
    return false
end

local function trackPlayerAnimations(player)
	if player.Name == game.Players.LocalPlayer.Name then
		return
	end
    local function onCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        local animator = humanoid:WaitForChild("Animator")
        local activeTracks = {}
		local activeAuraTracks = {}	
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


			if track.Animation and isAuraAnimation(track.Animation.AnimationId) then
                activeAuraTracks[track] = true
                playerAura[player.Name] = true
				print (player.Name.." used aura")
				local hrp1 = game.Players:FindFirstChild(player.Name).Character:FindFirstChild("HumanoidRootPart")
				local hrp2 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp1 and hrp2 then
						if (hrp1.Position - hrp2.Position).Magnitude < 25 then
							print ("dodging aura")
							local lastactivity = activity
							activity = "DODGEAURA"
							print ("Changed activity")
							task.wait(2)
							activity = lastactivity
						end
				end
					
                track.Stopped:Connect(function()
                    activeAuraTracks[track] = nil
                    if next(activeTracks) == nil then
                        playerAura[player.Name] = false
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
	local character = player.Character or player.CharacterAdded:Wait()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = enabled
		end
	end
end

function findname(display)
	local search = string.lower(display)
	local bestMatch = nil
	local bestLength = 0

	for _, player in pairs(game.Players:GetPlayers()) do
		local disp = string.lower(player.DisplayName)
		if string.sub(disp, 1, #search) == search then
			if bestMatch == nil or #disp < bestLength then
				bestMatch = player
				bestLength = #disp
			end
		end
	end
	if not bestMatch then
		for _, player in pairs(game.Players:GetPlayers()) do
			local disp = string.lower(player.DisplayName)
			if string.find(disp, search, 1, true) then
				bestMatch = player
				break
			end
		end
	end

	return bestMatch and bestMatch.Name or ""
end

local function getTargetRoot(targetPlayerName)
	local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
	if not targetPlayer or not targetPlayer.Character then
		activity = "IDLE"
		return
	end
    local targetLocal = Players:FindFirstChild(targetPlayerName)
    if targetLocal and targetLocal.Character then
        return targetLocal.Character:FindFirstChild("HumanoidRootPart")
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
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	blockFloat = true
	local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
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
				local speed = math.clamp(distance * 10, flyspeed, flyspeed*3)
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

	print (activity)
	task.wait(0.1)

	while activity == "IDLE" do		
		task.wait()
		--print ("running idle")

		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		local ownerCharacter = game.Players:FindFirstChild(owner).Character or game.Players:FindFirstChild(owner).CharacterAdded:Wait()
		local targetRoot = ownerCharacter:FindFirstChild("HumanoidRootPart")
		
		local localCharacter = player.Character or player.CharacterAdded:Wait()
		local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
		
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if distance > 15 then
			if isTravelling == false then
				blockFloat = true
				tptoPlayer(owner)
				isTravelling = true			
			end
		end
		if distance < 15 then
			
			humanoid.PlatformStand = true
			levitationTrack:Play()
			levitationTrack:AdjustSpeed(0)
			isTravelling = false
			blockFloat = false

		end
		--print ("end of idle")
	end
	
	
	while activity == "KILL" do
		task.wait()
		--print ("running kill")
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		local targetPlayer = game.Players:FindFirstChild(target)
		if not targetPlayer or not targetPlayer.Character then
			activity = "IDLE"
			return
		end
		local targetCharacter = game.Players:FindFirstChild(target).Character or game.Players:FindFirstChild(target).CharacterAdded:Wait()
		local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
		
		local localCharacter = player.Character or player.CharacterAdded:Wait()
		local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")

		
		local distance = (targetRoot.Position - localRoot.Position).Magnitude
		if distance > 15 then
			if isTravelling == false then
				tptoPlayer(target)
				isTravelling = true
			end
		end
		if distance < 15 then
	        local now = tick()
			if now - auralastfire >= auracooldown and aura == true then
				task.wait(0.2)
				local args = {
					"Aura Farm"
				}
				game:GetService("ReplicatedStorage"):WaitForChild("ActionRemote"):FireServer(unpack(args))
				auralastfire = now
				task.wait(0.2)
			end
			
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

			local targetPlayer = game.Players:FindFirstChild(target)
			if not targetPlayer or not targetPlayer.Character then
				activity = "IDLE"
				return
			end
			local targetRoot = getTargetRoot(target)
		    if not targetRoot then return end
					
			local offset = -targetRoot.CFrame.LookVector
			local desiredPosition = targetRoot.Position + offset + Vector3.new(0, killHeight, 0)
			rootPart.CFrame = CFrame.lookAt(desiredPosition, targetRoot.Position + Vector3.new(0, killHeight, 0), Vector3.new(0,1,0))
			
			rootPart.Velocity = Vector3.new(0, liftSpeed, 0)

			isTravelling = false
		end
	end

	while activity == "DODGEAURA" do
		
		task.wait()
		--print ("running dodge")

		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		
		rootPart.CFrame = rootPart.CFrame * CFrame.new(0,30,0)
		rootPart.Velocity = Vector3.new(1000, 0, 0)
	end
	

	task.wait()
end



local function sendFormattedChat(message)
	generalChat:SendAsync("["..chatPrefix.."]: "..message)
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
		playerName = findname(playerNameRaw)
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
local function changekillheight(args)
	local height = tonumber(args[1])
	if height == nil then
		sendFormattedChat("Height must be an int.")
	end
	killHeight = height
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
local function immune()
	playerRaw = args[1]
	playerLocal = findPlayer(playerRaw)
	if playerLocal == nil then
		sendFormattedChat("Player does not exist "..playerLocal)
	end
	table.insert(hitboxImmune, playerLocal)
	game.Players:FindFirstChild(playerLocal).Character.HumanoidRootPart.Size = whitelistedHeadSize
	sendFormattedChat("Made player immune: "..playerLocal)
end
local function unimmune()
	playerRaw = args[1]
	playerLocal = findPlayer(playerRaw)
	if playerLocal == nil then
		sendFormattedChat("Player does not exist "..playerLocal)
	end
	for i, v in ipairs(hitboxImmune) do
		if v == playerLocal then
			table.remove(hitboxImmune, i)
		end
	end
	game.Players:FindFirstChild(playerLocal).Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
	sendFormattedChat("Removed player immune: "..playerLocal)
end
local function toggleaura(aurachoice)
	choice = args[1]
	if choice == "true" then
		aura = true
	else
		aura = false
	end
	sendFormattedChat("Toggled aura to: "..choice) 
end
local function bring(args)
	targetRaw = args[1]
	targetLocal = findPlayer(targetRaw)
	if targetLocal == nil then
		sendFormattedChat("Player does not exist "..targetLocal)
	end
	target = targetLocal
	sendFormattedChat("Bringing player: "..targetLocal)
	activity = "KILL"
	local targetChar = game.Players:FindFirstChild(targetLocal).Character or game.Players:FindFirstChild(targetLocal).CharacterAdded:Wait()
	while targetChar:WaitForChild("Humanoid").Health > 2 do
		task.wait()
	end
	activity = "NONE"
	task.wait(0.1)

	local targetRoot = targetChar:WaitForChild("HumanoidRootPart")
	local desiredPosition = targetRoot.Position

	
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")


	for i = 1, 10 do
		rootPart.Velocity = Vector3.new(0, 0, 0)
		rootPart.CFrame = CFrame.lookAt(targetRoot.Position, targetRoot.Position + Vector3.new(0, 2, 0))
		rootPart.Velocity = Vector3.new(0, 0, 0)
		task.wait(0.1)
	end
	
	local args = {
		"Carry"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("CombatRemote"):FireServer(unpack(args))
	
	for i = 1, 10 do
		rootPart.Velocity = Vector3.new(0, 0, 0)
		rootPart.CFrame = CFrame.lookAt(targetRoot.Position, targetRoot.Position + Vector3.new(0, 2, 0))
		rootPart.Velocity = Vector3.new(0, 0, 0)
		task.wait(0.1)
	end
	flyspeed = 40
	activity = "IDLE"


	local ownerCharacter = game.Players:FindFirstChild(owner).Character or game.Players:FindFirstChild(owner).CharacterAdded:Wait()
	local ownerRoot = ownerCharacter:WaitForChild("HumanoidRootPart")
		
	local localCharacter = player.Character or player.CharacterAdded:Wait()
	local localRoot = localCharacter:WaitForChild("HumanoidRootPart")


	local distance = (ownerRoot.Position - localRoot.Position).Magnitude
	print ("waiting distance")
	task.wait(4)
	print ((ownerRoot.Position - localRoot.Position).Magnitude)
	while ((ownerRoot.Position - localRoot.Position).Magnitude > 15 and isTravelling == false and (ownerRoot.Position - targetRoot.Position).Magnitude > 15) do
		task.wait()
	end
	print ((ownerRoot.Position - localRoot.Position).Magnitude)
	print ("distance hit, dropping")
	task.wait(4)
	local args = {
		"Carry"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("CombatRemote"):FireServer(unpack(args))

	sendFormattedChat("Here is "..targetLocal.."!")
	flyspeed = 100
	
end

function changesideoffset(args)
	local offset = tonumber(args[1])
	if offset == nil then
		sendFormattedChat("Offset must be an int.")
	end
	sideOffset = offset
end

function respawn()
	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if humanoid then
	    humanoid.PlatformStand = true 
	    humanoid.Health = 0 
	end
end

cmds = {
	["stop"] = {stop, "Stops the bot.", nil},
	["heartbeat"] = {heartbeat, "Check if bot living", nil},
	["changeowner"] = {changeowner, "Change ownership of bot", {"newOwner"}},
	["say"] = {say, "Makes the bot send a message", {"message"}},
	["sayclean"] = {sayclean, "Makes the bot send a message without formatting", {"message"}},
	["changeheight"] = {changeheight, "Change the floating height", {"height"}},
	["changekillheight"] = {changekillheight, "Change the killing height", {"height"}},
	["help"] = {help, "Provides information about a command", {"commandname"}},
	["kill"] = {kill, "Kills player", {"playername"}},
	["idle"] = {toidle, "Returns bot to idle", nil},
	["immune"] = {immune, "Prevents bot from damaging player.", {"playername"}},
	["unimmune"] = {unimmune, "Un-immunes player.", {"playername"}},
	["toggleaura"] = {toggleaura, "Toggles aura on/off.", {"true/false"}},
	["bring"] = {bring, "Brings target to you.", {"target"}},
	["changeoffset"] = {changesideoffset, "Changes side offset.", {"offset"}},
	["respawn"] = {respawn, "Respawns the bot.", nil},
}



local function onPlayerChatted(chattedPlayer)
    chattedPlayer.Chatted:Connect(function(message)
		print (message)
		message = message:lower()
		if chattedPlayer.Name == owner or chattedPlayer.Name == permowner then
			if string.find(message, "^"..prefix) then
				message = string.gsub(message, prefix, "")
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
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	if activity == "IDLE" and isTravelling == false and blockFloat == false then
	    local targetRoot = getTargetRoot(owner)
	    if not targetRoot then return end
		
	    local offset = -targetRoot.CFrame.LookVector * floatDistance
	    local desiredPosition = targetRoot.Position + offset + Vector3.new(0, floatHeight, 0)
	
	    rootPart.CFrame = CFrame.lookAt(desiredPosition, targetRoot.Position + Vector3.new(0, floatHeight, 0), Vector3.new(0,1,0))
	
	    rootPart.Velocity = Vector3.new(0, liftSpeed, 0)
	end
end)


local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        --activity = "IDLE"
		blockFloat = false
		isTravelling = false
		
    end)
	local args = {
		"Short Sword"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("EquippingRemote"):FireServer(unpack(args))
	local args = {
		"Katana"
	}
	game:GetService("ReplicatedStorage"):WaitForChild("EquippingRemote"):FireServer(unpack(args))
	blockFloat = false
	isTravelling = false
	activity = "IDLE"
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if game.Players.LocalPlayer.Character then
    onCharacterAdded(localPlayer.Character)
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
	--print ("running ml")
	pcall(function()
		mainLoop()
		end)
	if activity == "STOPPED" then 
		break
	end
	task.wait()
end
