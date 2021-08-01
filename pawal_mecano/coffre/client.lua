ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    Citizen.Wait(5000)
end)


function OpenGetStocksMenu()

    ESX.TriggerServerCallback('nehco:getStockItems', function(items)

        local elements = {}

        for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
        {
            title    = _U('mechanic_stock'),
            align    = 'top-left',
            elements = elements
        }, function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                title = _U('quantity')
            }, function(data2, menu2)

                local count = tonumber(data2.value)

                if count == nil then
                    ESX.ShowNotification(_U('quantity_invalid'))
                else
                    menu2.close()
                    menu.close()
                    TriggerServerEvent('nehco:getStockItem', itemName, count)

                    Citizen.Wait(300)
                    OpenGetStocksMenu()
                end

            end, function(data2, menu2)
                menu2.close()
            end)

        end, function(data, menu)
            menu.close()
        end)

    end)

end

function OpenPutStockspharmaMenu()
	ESX.TriggerServerCallback('pawal:playerinventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'pawal',
			title    = 'inventaire',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'pawal',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('pawal:stockitem', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenGetStockspharmaMenu()
	ESX.TriggerServerCallback('pawal:takeitem', function(items)
		local elements = {}

		for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'police',
			title    = 'stockage',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                css      = 'police',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('pawal:GetStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

pawalcoffre = {
  Base = {Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255} , Title = "Coffre mechanic" },
  Data = {currentMenu = "Stock :"}, 
  Events = {
      onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)

        if btn.name == "~r~→ ~s~~h~Action Coffre" then
		   OpenMenu('Action Coffre')
		   
		elseif btn.name == "                         ~h~→ ~r~Fermer le menu ~s~←" then
		   CloseMenu()
		
		elseif btn.name == "[~g~→~s~] Déposer objets" then
            OpenPutStockspharmaMenu()
            CloseMenu(pawalcoffre)
			  
			  elseif btn.name == "[~r~←~s~] Retirer objets" then
                OpenGetStockspharmaMenu()
                CloseMenu(pawalcoffre)
                
         
      end
	  end
          },
  Menu = {
      ["Stock :"] = {
          b = {
            {name = "~r~→ ~s~~h~Action Coffre", ask = ">", askX = true},
            {name = "                         ~h~→ ~r~Fermer le menu ~s~←", ask = "", askX = true},           
          }
      },
      ["Action Coffre"] = { 
          b = {
            {name = "[~g~→~s~] Déposer objets", ask = ">", askX = true},
            {name = "[~r~←~s~] Retirer objets", ask = ">", askX = true}

          } 
      },
      ["Déposer des objets"] = { 
        b = {  

         } 
     },

    ["Retirer un objet"] = {
         b = {
         } 
      },
  }
}


local pos = { 
{x = -196.95,   y = -1318.17,  z = 31.08}, 

}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)

      for k in pairs(pos) do

          local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
          local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)
          if PlayerData.job and PlayerData.job.name == 'mechanic' then
     DrawMarker(6, -196.95, -1318.17, 30.08, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200)
         else
             Citizen.Wait(500)
      end 
          if dist <= 1.0 and PlayerData.job and PlayerData.job.name == 'mechanic' then
              ESX.ShowHelpNotification("Appuyez sur [~r~E~s~] pour accéder au Stockage du ~r~Mécano.")
       if IsControlJustPressed(1,51)  then      
                  CreateMenu(pawalcoffre) 
      end
          end
      end
  end  
end)
