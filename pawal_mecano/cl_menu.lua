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

	ESX.PlayerData = ESX.GetPlayerData()
end)
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
    Citizen.Wait(5000)
end)

------------------------- Blips --------------------------

local blips = {
    {title="mechanic", colour=25, id=85, x = -1886.52, y = 2062.68, z = 139.98},
}
	  
Citizen.CreateThread(function()    
	Citizen.Wait(0)    
  local bool = true     
  if bool then    
		 for _, info in pairs(blips) do      
			 info.blip = AddBlipForCoord(info.x, info.y, info.z)
						 SetBlipSprite(info.blip, info.id)
						 SetBlipDisplay(info.blip, 4)
						 SetBlipScale(info.blip, 1.1)
						 SetBlipColour(info.blip, info.colour)
						 SetBlipAsShortRange(info.blip, true)
						 BeginTextCommandSetBlipName("STRING")
						 AddTextComponentString(info.title)
						 EndTextCommandSetBlipName(info.blip)
		 end        
	 bool = false     
   end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- SCRIPT -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenBillingMenu()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'facture',
        {
            title = 'Donner une facture'
        },
        function(data, menu)

            local amount = tonumber(data.value)

            if amount == nil or amount <= 0 then
                ESX.ShowNotification('Montant invalide')
            else
                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Pas de joueurs proche')
                else
                    local playerPed        = GetPlayerPed(-1)

                    Citizen.CreateThread(function()
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mechaniccie', 'mechaniccie', amount)
                        ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
                    end)
                end
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

------ Coffre

function OpenGetStocksmechanicMenu()
	ESX.TriggerServerCallback('e_mechanic:prendreitem', function(items)
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
					TriggerServerEvent('e_mechanic:prendreitems', itemName, count)

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

function OpenPutStocksmechanicMenu()
	ESX.TriggerServerCallback('e_mechanic:inventairejoueur', function(inventory)
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
            css      = 'e_mechanic',
			title    = 'inventaire',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'e_mechanic',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('e_mechanic:stockitem', itemName, count)

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

local objec = {
     "Plot",
	 "Boîte à outils"
}

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu F6 ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local menuf6 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "MENU INTERACTION" },
    Data = { currentMenu = "Liste des actions :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Facturation" then   
                OpenBillingMenu()
            elseif btn.name == "Annonce" then
                OpenMenu("annonce")
            elseif btn.name == "🟢 Ouvert" then
                TriggerServerEvent("mechanicouvert")
			elseif btn.name == "🟠 En Pause" then
			    TriggerServerEvent("mechanicpause")
            elseif btn.name == "🔴 Fermer" then
                TriggerServerEvent("mechanicfermer")
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
			elseif btn.name == "                        ~h~~r~ → Fermer le menu ←" then
			    CloseMenu()
			elseif btn.name == "~r~→ ~s~Gestion Facture/Tarif" then
			    OpenMenu("citoyens")
			elseif btn.name == "~r~→ ~s~Gestion Véhicule" then
			    OpenMenu("véhicule")
			elseif btn.name == "~r~→ ~s~Gestion Annonce" then
			    OpenMenu("annonce")
			elseif btn.name == "Menu Tarif" then
			    OpenMenu("tarif")
		    elseif btn.name == "🚨 Mettre en fourrière" then
			    local playerPed = PlayerPedId()


			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)

				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Mise en fourrière ~h~~g~Terminer", 'CHAR_CARSITE3', 7)
					ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Vous devez être sur la place conducteur !", 'CHAR_CARSITE3', 7)
				end
			else
				local vehicle = ESX.Game.GetVehicleInDirection()

				if DoesEntityExist(vehicle) then
					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Mise en fourrière ~h~~g~Terminer", 'CHAR_CARSITE3', 7)
					ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Vous devez être prêt d'un véhicule pour commencer la mise en fourrière", 'CHAR_CARSITE3', 7)
				end
			end

				
			 
			elseif btn.name == "🔑 Crocheter le véhicule" then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Vous ne pouvez pas faire cette action depuis un véhicule", 'CHAR_CARSITE3', 7)
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(10000)

					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Crochetage ~h~~g~Terminer", 'CHAR_CARSITE3', 7)
					isBusy = false
				end)
			else
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Aucun véhicule à proximité", 'CHAR_CARSITE3', 7)
			end
				
			elseif btn.name == "🔧 Réparer le véhicule" then
			    			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Vous ne pouvez pas faire cette action depuis un véhicule", 'CHAR_CARSITE3', 7)
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(20000)

					SetVehicleFixed(vehicle)
					SetVehicleDeformationFixed(vehicle)
					SetVehicleUndriveable(vehicle, false)
					SetVehicleEngineOn(vehicle, true, true)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Réparation ~h~~g~Terminer", 'CHAR_CARSITE3', 7)
					isBusy = false
				end)
			else
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Aucun véhicule à proximité", 'CHAR_CARSITE3', 7)
			end
			
			elseif btn.name == "🧼 Nettoyer le véhicule" then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Vous ne pouvez pas faire cette action depuis un véhicule", 'CHAR_CARSITE3', 7)
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
				Citizen.CreateThread(function()
					Citizen.Wait(10000)

					SetVehicleDirtLevel(vehicle, 0)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Nettoyage ~h~~g~Terminer ", 'CHAR_CARSITE3', 7)
					isBusy = false
				end)
			else
				ESX.ShowAdvancedNotification('mechanic', '~r~Notification', "Aucun véhicule à proximité", 'CHAR_CARSITE3', 7)
			end
            end 
    end,
},
    Menu = {
        ["Liste des actions :"] = {
            b = {
			    {name = "~r~→ ~s~Gestion Annonce", ask = '>>', askX = true},
				{name = "~r~→ ~s~Gestion Véhicule", ask = '>>', askX = true},
				{name = "~r~→ ~s~Gestion Facture/Tarif", ask = '>>', askX = true},
				{name = "                        ~h~~r~ → Fermer le menu ←", ask = "", askX = true},
				

            }
        },
        ["véhicule"] = {
            b = {
			    {name = "                              ~h~~r~ → ~s~Entretien ~r~←", ask = "", askX = true},
				{name = "🔧 Réparer le véhicule", ask = '>>', askX = true},
				{name = "🧼 Nettoyer le véhicule", ask = '>>', askX = true},
				{name = "                       ~h~~r~ → ~s~Outil de dépannage~r~←", ask = "", askX = true},
				{name = "🔑 Crocheter le véhicule", ask = '>>', askX = true},
				{name = "                                  ~h~~r~ → ~s~Autre~r~←", ask = "", askX = true},
				{name = "🚨 Mettre en fourrière", ask = '>>', askX = true},
            }
        },
		["citoyens"] = {
            b = {
			    {name = "                                 ~h~~r~ → ~s~Tarif ~r~←", ask = "", askX = true},
                {name = "Menu Tarif", ask = '>>', askX = true},
				{name = "                               ~h~~r~ → ~s~Facture ~r~←", ask = "", askX = true},
                {name = "Facturation", ask = '>>', askX = true},
            }
        },
		["annonce"] = {
            b = {
                {name = "🟢 Ouvert", ask = '>>', askX = true},
				{name = "🟠 En Pause", ask = '>>', askX = true},
                {name = "🔴 Fermer", ask = '>>', askX = true},
            }
        },
		["tarif"] = {
            b = {
			    {name = "                            ~h~~r~ → ~s~Réparation ~r~←", ask = "", askX = true},
			    {name = "Réparation Standard : ~r~$100",  ask = '>>', askX = true},
				{name = "Réparation Avancer : ~r~$250",  ask = '>>', askX = true},
				{name = "Réparation Complet [Moteur + carosserie] : ~r~$300",  ask = '>>', askX = true},
				{name = "                          ~h~~r~ → ~s~Customisation ~r~←", ask = "", askX = true},
				{name = "Taxe Customisation Esthétique : ~r~10%",  ask = '>>', askX = true},
				{name = "Taxe Customisation Performance : ~r~15%",  ask = '>>', askX = true},
            }
        },
    }
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(0,167) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			CreateMenu(menuf6)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Coffre -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local coffre = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Coffre entreprise" },
    Data = { currentMenu = "Coffre :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Stock" then   
                OpenMenu("stock")
            elseif btn.name == "Coffre" then
                OpenMenu("coffre")
            elseif btn.name == "Prendre" then
                OpenGetStocksmechanicMenu()
                CloseMenu()
            elseif btn.name == "Deposer" then
                OpenPutStocksmechanicMenu()
                CloseMenu()
            elseif btn.name == "Kit de réparation : ~r~$50" then
                TriggerServerEvent('prendre:kitrepar')
                CloseMenu()
            elseif btn.name == "Kit Carrosserie  : ~r~$50" then
                TriggerServerEvent("prendre:kitcar")
                CloseMenu()
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
            end 
    end,
},
    Menu = {
        ["Coffre :"] = {
            b = {
                {name = "Stock", ask = '>>', askX = true},
                {name = "Coffre", ask = '>>', askX = true},
            }
        },
        ["coffre"] = {
            b = {
                {name = "Prendre", ask = '>>', askX = true},
                {name = "Deposer", ask = '>>', askX = true},
            }
        },
        ["stock"] = {
            b = {
                {name = "Kit de réparation : ~r~$50", ask = '>>', askX = true},
                {name = "Kit Carrosserie  : ~r~$50", ask = '>>', askX = true},
            }
        }
    }
} 

local stock = { 
    {x=0, y=0, z=0} --Position coffre
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(stock) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, stock[k].x, stock[k].y, stock[k].z)
            if dist <= 1.5 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic'  then
                DrawMarker(23, 364.13, -586.98, 28.69, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour accéder au armoire~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(coffre)
         end end end end end)  

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- GARAGE -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local voiture = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "GARAGE mechanic" },
    Data = { currentMenu = "Liste des véhicules :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Dépanneuse" then   
                spawnCar("towtruck")
				CloseMenu()
            elseif btn.name == "Véhicule de déplacement" then
                spawnCar("kamacho")
				CloseMenu()
			elseif btn.name == "                       ~h~~r~ → ~s~Fermer le menu ~r~←" then
			    CloseMenu()
            end 
    end,
},
    Menu = {
        ["Liste des véhicules :"] = {
            b = {
                {name = "Dépanneuse", ask = '>>', askX = true},
                {name = "Véhicule de déplacement", ask = '>>', askX = true},
                {name = "                       ~h~~r~ → ~s~Fermer le menu ~r~←", ask = ">", askX = true},
            }
        }
    }
} 



function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)   
    end


    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, -194.53, -1306.63, 31.29, 268.47, true, false)   ---- spawn du vehicule (position) 
    ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Vous venez de sortir un véhicule du garage ~r~mechanic.", 'CHAR_CARSITE3', 7)
    TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
    SetEntityAsNoLongerNeeded(vehicle)
    SetVehicleNumberPlateText(vehicle, "mechanic")





end 

local garagemecan = { 
    {x=-200.80, y=-1308.92, z=30.49} -- Point pour sortir le vehicule
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(garagemecan) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garagemecan[k].x, garagemecan[k].y, garagemecan[k].z)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic'  then
                DrawMarker(6, -200.80, -1308.92, 30.34, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 0, 0, 200, 0, 1, 2, 0, nil, nil, 0)
			if dist <= 1.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
                ESX.ShowHelpNotification("~s~Appuyez sur ~INPUT_PICKUP~ pour accéder au garage ~r~mechanic~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(voiture)
       end end end end end end)  
	   
	   
	   
-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Ranger votre véhicule -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local voiture2 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "GARAGE mechanic" },
    Data = { currentMenu = "Liste des véhicules :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Dépanneuse" then   
                spawnCar("towtruck")
				CloseMenu()
            elseif btn.name == "Véhicule de déplacement" then
                spawnCar("kamacho")
			    CloseMenu()
			elseif btn.name == "                       ~h~~r~ → ~s~Fermer le menu ~r~←" then
			    CloseMenu()
            end 
    end,
},
    Menu = {
        ["Liste des véhicules :"] = {
            b = {
            }
        }
    }
} 



function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)   
    end


    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, -194.53, -1306.63, 31.29, 268.47, true, false)   ---- spawn du vehicule (position) 
    ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Vous venez de sortir un véhicule du garage ~r~mechanic.", 'CHAR_CARSITE3', 7)
	SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
	SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0) 
	SetVehicleCustomSecondaryColour(vehicle, 0, 0, 0)  
    SetEntityAsNoLongerNeeded(vehicle)
    SetVehicleNumberPlateText(vehicle, "mechanic")





end 

local garagemecan = { 
    {x=-190.05, y=-1306.91, z=30.36}
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(garagemecan) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garagemecan[k].x, garagemecan[k].y, garagemecan[k].z)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic'  then
                DrawMarker(6, -190.05, -1306.91, 30.36, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 0, 0, 150, 0, 1, 2, 0, nil, nil, 0)
			if dist <= 2.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
               ESX.ShowHelpNotification("Appuyez sur [~r~E~s~] ~s~ pour ranger votre véhicule. ")  			
             if IsControlJustPressed(1,38) then 
               TriggerEvent('esx:deleteVehicle')
 
				

       end end end end end end)  

-------------------------------------------------------- Fabrication -------------------------------------------------------

local Fabrication = {   
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_Green}, HeaderColor = {255, 255, 255}, --[[R, G, B   R = red G = Green B = Blue ]]Title = 'Fabrication'},
	Data = { currentMenu = "Action Fabrication :", GetPlayerName()},
    Events = { 
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
      PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
      local btn = btn.name
          
		  if btn == "Kit de : ~r~~h~Réparation" then 
          local playerPed = PlayerPedId()
		  TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				Citizen.CreateThread(function()
                    ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Fabrication ~g~~h~en cours...", 'CHAR_CARSITE3', 7)
					Citizen.Wait(7500)
					ClearPedTasksImmediately(playerPed)
					Citizen.Wait(100)
                     TriggerServerEvent('pawal:fabricationkit', 20, 'fixkit', 2)
				end)

  
             end 
		  if btn == "Kit de : ~r~~h~Carroserie" then 
          local playerPed = PlayerPedId()
		  TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				Citizen.CreateThread(function()
                    ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Fabrication ~g~~h~en cours...", 'CHAR_CARSITE3', 7)
					Citizen.Wait(7500)
					ClearPedTasksImmediately(playerPed)
					Citizen.Wait(100)
                    TriggerServerEvent('pawal:fabricationkit', 20, 'carokit', 2)
				end)		  
             end 
	        end,     
	},    
	Menu = {  
		["Action Fabrication :"] = { 
			b = { 
        {name = "Kit de : ~r~~h~Réparation", ask = "~r~$20", askX = true},  
        {name = "Kit de : ~r~~h~Carroserie", ask = "~r~$20", askX = true},  
		
			}  
		}

	}
}    


local fabricationpawal = {
  {x = -227.47, y= -1327.31, z=30.89}
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0) 
      for k in pairs(fabricationpawal) do
          local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
          local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, fabricationpawal[k].x, fabricationpawal[k].y, fabricationpawal[k].z)
		  if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
     DrawMarker(6, -227.47, -1327.31, 29.89, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200)
          if dist <= 1.0 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then  
              ESX.ShowHelpNotification("Appuyez sur [~r~E~s~] pour accedez à la ~r~fabrication de kit")
              if IsControlJustPressed(1,38) then 			
               CreateMenu(Fabrication)    
                  end
              end 
          end
		 end
	 end
  end)
-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Vestiaire --------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local vestiaire = {   
	Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_Green}, HeaderColor = {255, 255, 255}, --[[R, G, B   R = red G = Green B = Blue ]]Title = 'Vestiaire'},
	Data = { currentMenu = "Vestiaire :", GetPlayerName()},
    Events = { 
		onSelected = function(self, _, btn, PMenu, menuData, currentButton, currentBtn, currentSlt, result, slide)
      PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
      local btn = btn.name
           if btn == "~h~~s~[~g~→~s~]~g~ Prise de service" then
            serviceon()
			ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Vous venez de prendre votre ~h~~g~Prise de service.", 'CHAR_CARSITE3', 7)
          elseif btn == "~h~~s~[~r~←~s~]~r~ Fin de service" then
            serviceoff()
			ESX.ShowAdvancedNotification('Tropico Base ~r~V1', '~r~Notification', "Vous venez de prendre votre ~h~~r~Fin de service.", 'CHAR_CARSITE3', 7)
		   elseif btn == "                       ~h~~r~ → ~s~Fermer le menu ~r~←" then
		      CloseMenu()
   
             end 
	        end,     
	},    

	Menu = {  
		["Vestiaire :"] = { 
			b = { 
	     {name = "~h~~s~[~g~→~s~]~g~ Prise de service", ask = "", askX = true},
        {name = "~h~~s~[~r~←~s~]~r~ Fin de service", ask = "", askX = true},
        {name = "                       ~h~~r~ → ~s~Fermer le menu ~r~←", ask = "", askX = true}
     
			}  
		},
	}
}    
local template = {
  {x = -224.05, y= -1320.66, z=30.89}
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0) 
      for k in pairs(template) do
          local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
          local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, template[k].x, template[k].y, template[k].z)
          if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
     DrawMarker(6, -224.05, -1320.66, 29.89, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200)
	       if dist <= 1.0 then
              ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accedez au ~h~~r~Vestiaire")
              if IsControlJustPressed(1,38) then 			
               CreateMenu(vestiaire)    
                  end
				 end
              end 
          end
      end
  end)

  function  serviceon()
    local model = GetEntityModel(GetPlayerPed(-1))
    TriggerEvent('skinchanger:getSkin', function(skin)
        if model == GetHashKey("mp_m_freemode_01") then
            clothesSkin = {
              ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
              ['torso_1'] = 65,   ['torso_2'] = 0,
              ['arms'] = 0,
              ['pants_1'] = 38,   ['pants_2'] = 0,
              ['shoes_1'] = 25,   ['shoes_2'] = 0,
              ['helmet_1'] = -1,  ['helmet_2'] = 0,
              ['chain_1'] = 0,    ['chain_2'] = 0,
              ['ears_1'] = -1,     ['ears_2'] = 0
            }
        else
            clothesSkin = {
              ['tshirt_1'] = 68,  ['tshirt_2'] = 0,
              ['torso_1'] = 37,   ['torso_2'] = 0, 
              ['arms'] = 4,
              ['pants_1'] = 38,   ['pants_2'] = 0,
              ['shoes_1'] = 6,   ['shoes_2'] = 0,  
              ['helmet_1'] = -1,  ['helmet_2'] = 0,
              ['chain_1'] = 0,    ['chain_2'] = 0,
              ['ears_1'] = -1,     ['ears_2'] = 0
            }
        end
        TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
    end)
end

function serviceoff()
  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
      TriggerEvent('skinchanger:loadSkin', skin)
     end)
  end


-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu BOSS --------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
local boss = { 
    {x=-207.54, y=-1341.13, z=34.89}
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(boss) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and ESX.PlayerData.job.grade_name == 'boss'   then
                DrawMarker(6, -207.54, -1341.13, 33.89, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 0, 0, 200, 0, 1, 2, 0, nil, nil, 0)
                if dist <= 1.0 then
                ESX.ShowHelpNotification("Appuyez sur [~r~E~s~] pour accedez au ~h~~r~Coffre de l'entreprise")
                if IsControlJustPressed(1,38) then 			
                    TriggerEvent('esx_society:openBossMenu', 'mechanic', function(data2, menu2)
                        menu2.close()
                    end, {wash = false})
         end end end end end end) 
