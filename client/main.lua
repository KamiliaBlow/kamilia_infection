local VORPcore = {}

TriggerEvent("getCore", function(core)
	VORPcore = core
end)

local isInfected = false

RegisterNetEvent('vorp_infection:cure')
AddEventHandler('vorp_infection:cure', function()
	isInfected = false
	ShakeGameplayCam(0.0)
	SetEntityMotionBlur(PlayerPedId(), false)
	Citizen.Wait(5000)
	local chanceToDie = math.random(0, 100)

	if chanceToDie < (Config.chanceToDie) then
		SetEntityHealth(PlayerPedId(), 0)
	end
end)

RegisterNetEvent('vorp_infection:infect')
AddEventHandler('vorp_infection:infect', function()
	-- if Config.useItem then
		-- TriggerEvent('skinchanger:getSkin', function(skin)
			-- if skin['mask_1'] == 0 then
				-- isInfected = true
			-- end
		-- end)
	-- else
		isInfected = true
	--end
end)

RegisterNetEvent("vorp_infection:getinfect")
AddEventHandler("vorp_infection:getinfect", function(infection)
	if infection then
		isInfected = true
	end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(10000)
        TriggerServerEvent("vorp_infection:getinfeserv")
    end
end)

Citizen.CreateThread(function()
	local playerPed = PlayerPedId()

	while true do
		math.randomseed(GetGameTimer())
		Citizen.Wait(math.random(Config.minTime, Config.maxTime))
		--print("isInfected: "..tostring(isInfected))
		if not IsPlayerDead(PlayerId()) then
			if isInfected then
					local closestPlayer, closestDistance = GetClosestPlayer()
					if closestPlayer ~= -1 and closestDistance < 5.0 then
						TriggerServerEvent('vorp_infection:infectPlayer', GetPlayerServerId(closestPlayer))
						TriggerServerEvent("vorp_infection:setinfeserv", GetPlayerServerId(closestPlayer), true)
					end

					if GetEntityHealth(playerPed) <= 150 and GetEntityHealth(playerPed) >= 51 then
						RequestAnimDict("ai_gestures@arthur@standing@speaker@lt_hand")
						TaskPlayAnim(playerPed, "ai_gestures@arthur@standing@speaker@lt_hand", "cough_high_r_002", 1.0, -8.0, 5500, 31, 0, false, false, false)
						Citizen.Wait(6000)
						TriggerServerEvent('vorp_infection:sneezeSync')
					elseif GetEntityHealth(playerPed) <= 50 and GetEntityHealth(playerPed) >= 5 then
						RequestAnimDict("amb_misc@world_human_vomit@male_a@idle_a")
						AnimpostfxPlay("DEADEYE")
						TaskPlayAnim(playerPed, "amb_misc@world_human_vomit@male_a@idle_a", "idle_a", 1.0, -8.0, 7500, 31, 0, false, false, false)
						Citizen.Wait(8000)
						AnimpostfxStop("DEADEYE")
					end
				
					Citizen.Wait(1000)
					local health = GetEntityHealth(playerPed)
					local newHealth = health - 5
					SetEntityHealth(playerPed, newHealth)
					ClearPedSecondaryTask(playerPed)
					local chanceToRagdoll = math.random(0, 100)

					if chanceToRagdoll < (Config.chanceToRagdoll) then
						SetPedToRagdoll(playerPed, 6000, 6000, 0, 0, 0, 0)
					end
			end
		else
			TriggerServerEvent("vorp_infection:setinfeserv", source, false)
			isInfected = false
		end
	end
end)

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false
    
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end
    
    for i=1, #players, 1 do
        local tgt = GetPlayerPed(players[i])
        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                if PlayerPedId() ~= GetPlayerPed(players[i]) then
                    closestPlayer = players[i]
                    closestDistance = distance
                end
            end
        end
    end
    return closestPlayer, closestDistance
end

