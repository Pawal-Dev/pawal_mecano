ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('pawal:GetStockItem')
AddEventHandler('pawal:GetStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if count > 0 and inventoryItem.count >= count then

			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, "Vous venez de retiré~r~~h~ x"..count.." "..inventoryItem.label.."")
			end
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~~h~Quantité Invalide")
		end
	end)
end)


RegisterNetEvent('pawal:stockitem')
AddEventHandler('pawal:stockitem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "Vous venez de déposé~g~~h~ x"..count.." "..inventoryItem.label.."")
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~~h~Quantité Invalide")
		end
	end)
end)


ESX.RegisterServerCallback('pawal:playerinventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('pawal:takeitem', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanic', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('pawal:getinventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	cb({
		items = items
	})
end)


ESX.RegisterServerCallback('pawal:getStockItem', function(source, cb) 
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mechanico', function(inventory)
        cb(inventory.items) 
    end)     
end)       










