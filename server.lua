ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Concessionaire

ESX.RegisterServerCallback('pConcessjob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

ESX.RegisterServerCallback('pConcessjob:ifhaveitem', function(source,cb,itemname)
	local xPlayer = ESX.GetPlayerFromId(source)
  
  	if xPlayer.getInventoryItem(itemname).count >= 1 then
    	xPlayer.removeInventoryItem(itemname,1)
		cb(true)
    else
      	cb(false)
    end
end)

RegisterServerEvent('pConcessjob:removeItem')
AddEventHandler('pConcessjob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem(item, 1)
end)

-- Coffre

ESX.RegisterServerCallback('pConcessjob:playerinventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	local all_items = {}
	
	for k,v in pairs(items) do
		if v.count > 0 then
			table.insert(all_items, {label = v.label, item = v.name,nb = v.count})
		end
	end
	cb(all_items)
end)

ESX.RegisterServerCallback('pConcessjob:getStockItems', function(source, cb)
	local all_items = {}
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
		for k,v in pairs(inventory.items) do
			if v.count > 0 then
				table.insert(all_items, {label = v.label,item = v.name, nb = v.count})
			end
		end
	end)
	cb(all_items)
end)

RegisterServerEvent('pConcessjob:putStockItems')
AddEventHandler('pConcessjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local item_in_inventory = xPlayer.getInventoryItem(itemName).count

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
		if item_in_inventory >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez déposer ~y~"..itemName.."~s~ au nombre de ~y~"..count.."~s~.")
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, "~r~Vous n'avez pas cette quantité.")
		end
	end)
end)

RegisterServerEvent('pConcessjob:takeStockItems')
AddEventHandler('pConcessjob:takeStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
			xPlayer.addInventoryItem(itemName, count)
			inventory.removeItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez retirer ~y~"..itemName.."~s~ au nombre de ~y~"..count.."~s~.")
	end)
end)

-- Fournisseur

RegisterServerEvent('pConcessjob:giveItem')
AddEventHandler('pConcessjob:giveItem', function(Nom, Item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local qtty = xPlayer.getInventoryItem(Item).count

		if qtty < 10 then
			xPlayer.addInventoryItem(Item, 1)
			TriggerClientEvent('esx:showNotification', _source, 'Tu as recu un ~y~' ..Nom.. '~s~ !')
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~Vous avez atteints la limite !")
		end
	end)

-- Boss

RegisterServerEvent('pConcessjob:withdrawMoney')
AddEventHandler('pConcessjob:withdrawMoney', function(society, amount, money_soc)
	local xPlayer = ESX.GetPlayerFromId(source)
	local src = source
  
	TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
	  if account.money >= tonumber(amount) then
		  xPlayer.addMoney(amount)
		  account.removeMoney(amount)
		  TriggerClientEvent("esx:showNotification", src, "Vous avez retirer~g~ "..amount.."$")
	  else
		  TriggerClientEvent("esx:showNotification", src, "~rL'entreprise n'as pas asser d'argent.")
	  end
	end)
	  
  end)

RegisterServerEvent('pConcessjob:depositMoney')
AddEventHandler('pConcessjob:depositMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)
	local money = xPlayer.getMoney()
	local src = source
  
	TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
	  if money >= tonumber(amount) then
		  xPlayer.removeMoney(amount)
		  account.addMoney(amount)
		  TriggerClientEvent("esx:showNotification", src, "Vous avez déposer~r~ "..amount.."$")
	  else
		  TriggerClientEvent("esx:showNotification", src, "~rVous n'avez pas asser d'argent.")
	  end
	end)
	
end)

ESX.RegisterServerCallback('pConcessjob:getSocietyMoney', function(source, cb, soc)
	local money = nil
		MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @society ', {
			['@society'] = soc,
		}, function(data)
			for _,v in pairs(data) do
				money = v.money
			end
			cb(money)
		end)
end)

-- Vente

ESX.RegisterServerCallback('pConcessjob:achat', function(source, cb, prix)
    TriggerEvent('esx_addonaccount:getSharedAccount', "society_concess", function (account)
        if account.money >= prix then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('pConcessjob:ventevehiculejoueur')
AddEventHandler('pConcessjob:ventevehiculejoueur', function (playerId, vehicleProps, Prix, Model)
    local xPlayer = ESX.GetPlayerFromId(playerId) 
	local Vendeur = ESX.GetPlayerFromId(source)
	local src = source

    TriggerEvent('esx_addonaccount:getSharedAccount', "society_concess", function (account)
        account.removeMoney(Prix)
    end)

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
	{
		['@owner']   = xPlayer.identifier,
		['@plate']   = vehicleProps.plate,
		['@vehicle'] = json.encode(vehicleProps)
	}, function (rowsChanged)

    TriggerClientEvent("esx:showNotification", src, "Vous avez vendu un ~y~nouveau véhicule~s~.")
    
    end)
end)

RegisterServerEvent('pConcessjob:achatpersonnel')
AddEventHandler('pConcessjob:achatpersonnel', function(vehicleProps, Prix, Model)
    local xPlayer = ESX.GetPlayerFromId(source)
    local src = source

    TriggerEvent('esx_addonaccount:getSharedAccount', "society_concess", function (account)
        account.removeMoney(Prix)
    end)

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps)
    }, function(rowsChange)

	TriggerClientEvent("esx:showNotification", src, "Vous avez reçu les clés d'un ~y~nouveau véhicule~s~.")
    
    end)
end)

ESX.RegisterServerCallback('pConcessjob:verifierplaquedispo', function (source, cb, plate)
    MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function (result)
        cb(result[1] ~= nil)
    end)
end)

-- Contrat de vente

RegisterServerEvent('pConcessjob:sellVehicle')
AddEventHandler('pConcessjob:sellVehicle', function(target, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local _target = target
	local tPlayer = ESX.GetPlayerFromId(_target)
	local result = MySQL.Sync.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
			['@identifier'] = xPlayer.identifier,
			['@plate'] = plate
		})
	if result[1] ~= nil then
		MySQL.Async.execute('UPDATE owned_vehicles SET owner = @target WHERE owner = @owner AND plate = @plate', {
			['@owner'] = xPlayer.identifier,
			['@plate'] = plate,
			['@target'] = tPlayer.identifier
		}, function (rowsChanged)
			if rowsChanged ~= 0 then
				TriggerClientEvent('pConcessjob:showAnim', _source)
				Wait(22000)
				TriggerClientEvent('pConcessjob:showAnim', _target)
				Wait(22000)
				TriggerClientEvent("esx:showNotification", _source, "Vous avez vendu le ~y~véhicule~s~.")
				TriggerClientEvent("esx:showNotification", _target, "Vous avez acheter un ~y~ nouveau véhicule~s~.")
				xPlayer.removeInventoryItem('contract', 1)
			end
		end)
	else
		TriggerClientEvent("esx:showNotification", src, "~r~Ce n'est pas votre véhicule.")
	end
end)

ESX.RegisterUsableItem('contract', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('pConcessjob:getVehicle', _source)
end)