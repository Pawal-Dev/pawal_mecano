ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_society:registerSociety', 'mechanic', 'mechanic', 'society_mechanic', 'society_mechanic', 'society_mechanic', {type = 'private'})

RegisterServerEvent('mechanicouvert')
AddEventHandler('mechanicouvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'mechanic', '~r~Annonce', 'Le mechanic est ~g~ouvert', 'CHAR_CARSITE3', 6)
	end
end)

RegisterServerEvent('mechanicfermer')
AddEventHandler('mechanicfermer', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'mechanic', '~r~Annonce', 'Le mechanic est ~r~fermer', 'CHAR_CARSITE3', 6)
	end
end)

RegisterServerEvent('mechanicpause')
AddEventHandler('mechanicpause', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'mechanic', '~r~Annonce', 'Le mechanic est en ~o~pause', 'CHAR_CARSITE3', 6)
	end
end)
      

-------------------- Stock

RegisterServerEvent('pawal:fabricationkit')
AddEventHandler('pawal:fabricationkit', function(price, item, nombre) 
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= price then
	xPlayer.removeMoney(price)
    	xPlayer.addInventoryItem(item, nombre) 
        TriggerClientEvent('esx:showNotification', source, "Fabrication ~g~~h~Terminer !", "", 1)
     else 
         TriggerClientEvent('esx:showNotification', source, "Pas assez ~r~~h~d'argent pour achetez les pièces")    
        end
end)  