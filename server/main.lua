VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local VorpCore
TriggerEvent("getCore", function(core)
    VorpCore = core
end)

RegisterServerEvent('vorp_infection:infectPlayer')
AddEventHandler('vorp_infection:infectPlayer', function(playerId)
		TriggerClientEvent('vorp_infection:infect', playerId)
end)

VorpInv.RegisterUsableItem('vaccine', function(data)
	TriggerClientEvent('vorp_infection:cure', data.source)
end)

RegisterServerEvent("vorp_infection:getinfeserv")
AddEventHandler("vorp_infection:getinfeserv", function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter
    local u_charid = Character.charIdentifier

    exports.oxmysql:execute('SELECT infection FROM characters WHERE charidentifier = @charidentifier'
        , { ['charidentifier'] = u_charid }, function(result)
        if result[1] then
            local infection = result[1].infection
            TriggerClientEvent("vorp_infection:getinfect", _source, infection)
        end
    end)
end)

RegisterServerEvent("vorp_infection:setinfeserv")
AddEventHandler("vorp_infection:setinfeserv", function(target, animation)
    local infection = animation
	local User = VorpCore.getUser(target)
	if User  == nil then
		return '?'
	end
    local Character = User.getUsedCharacter 
    local charidentifier = Character.charIdentifier
    exports.oxmysql:execute("UPDATE characters Set infection=@infection WHERE charidentifier = @charidentifier"
        , { ['infection'] = infection,['charidentifier'] = charidentifier })
end)

RegisterCommand("infection", function(source, args) 
	if args ~= nil then	
		local User = VorpCore.getUser(source)
		local User2 = User.getGroup
		
		local id = args[1]

		if User2 == "admin" then
			VorpCore.NotifyBottomRight(source,"Вы заразили игрока: "..id,4000)
			TriggerEvent("vorp_infection:setinfeserv", id, true)
			TriggerEvent('vorp_infection:infectPlayer', id)
		end
	end
end)

RegisterCommand("cure", function(source, args) 
	if args ~= nil then	
		local User = VorpCore.getUser(source)
		local User2 = User.getGroup
		
		local id = args[1]

		if User2 == "admin" then
			VorpCore.NotifyBottomRight(source,"Вы вылечили игрока: "..id,4000)
			TriggerEvent("vorp_infection:setinfeserv", id, false)
			TriggerClientEvent('vorp_infection:cure', id)
		end
	end
end)