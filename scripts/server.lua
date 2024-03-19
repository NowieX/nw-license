local canPurchaseLicense = {}

local function CreateRandomBSN()
    return math.random(100000000, 999999999)
end

local function isInRange(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local playerCoords = xPlayer.getCoords(true)
    for _, value in pairs(Config.CityHallNPC) do
        local distance = #(playerCoords - value.location)
        if distance <= value.targetDistance + 3.0 then
            return true
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = Config.Locales['error'], 
                description = Config.Locales['exploit'],
                position = Config.Notification.position,
                duration = Config.Notification.timer,
                type = 'error'})
            Wait(5000)
            DropPlayer(source, '['..GetCurrentResourceName()..' Trigger protection')
        end
    end
end

local function GetBSN_number_SYNC(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local response = MySQL.query.await('SELECT `bsn` FROM `users` WHERE `identifier` = ?', {
		xPlayer.getIdentifier()
	})
	return response[1].bsn
end

local function get_licenses(src)
	local xPlayer = ESX.GetPlayerFromId(src)
    MySQL.query('SELECT `type` FROM `user_licenses` WHERE `owner` = ?', {
        xPlayer.getIdentifier()
    }, function(response)
        if not response then
            return print("[^1"..GetCurrentResourceName().."]:^3 Could not get the driver license of the player: "..xPlayer".")
        end
    end)
end

AddEventHandler('onResourceStart', function()
	if (GetCurrentResourceName() ~= 'nw-license') then
        print("You have changed the name of the script. That's not allowed. Please rename the scrip to nw-license")
        return
	end

    -- Don't touch!
	MySQL.Sync.execute([[
		ALTER TABLE users
		ADD COLUMN IF NOT EXISTS bsn VARCHAR(9);
    ]])
end)

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
	if isNew then
		MySQL.update('UPDATE users SET bsn = ? WHERE identifier = ?', {
			CreateRandomBSN(), xPlayer.getIdentifier()
		})
	else
		MySQL.query('SELECT `bsn` FROM `users` WHERE `identifier` = ?', {
			xPlayer.getIdentifier()
		}, function(response)
			if not response then
				return print("[^1"..GetCurrentResourceName().."]:^3 Could not get the BSN number of the player with id: "..xPlayer".")
			end
			if response[1].bsn == nil then
				MySQL.update('UPDATE users SET bsn = ? WHERE identifier = ?', {
					CreateRandomBSN(), xPlayer.getIdentifier()
				})
			end
		end)
	end
end)

exports.ox_inventory:registerHook('createItem', function(payload)
	local src = payload.inventoryId
	local xPlayer = ESX.GetPlayerFromId(src)

	local metadata = payload.metadata
	local name = xPlayer.getName()
	local dob = xPlayer.get('dateofbirth')
	local gender = xPlayer.get('sex')
	local bsn_number = GetBSN_number_SYNC(src)

	if gender == "m" then
		gender = "Man"
	elseif gender == "w" then
		gender = "Vrouw"
	end

	metadata.label = Config.Licenses[1].title
	metadata.description = ('Naam: %s  \nGeboortedatum: %s  \nGeslacht: %s  \nBSN: %s'):format(name, dob, gender, bsn_number)

    return metadata
end, {
    itemFilter = {
        id_card = true
    }
})

exports.ox_inventory:registerHook('createItem', function(payload)
	local src = payload.inventoryId
	local xPlayer = ESX.GetPlayerFromId(src)

	local metadata = payload.metadata
	local name = xPlayer.getName()
	local dob = xPlayer.get('dateofbirth')
	local gender = xPlayer.get('sex')
	local bsn_number = GetBSN_number_SYNC(src)
    local driving_permit = get_licenses(src)

	if gender == "m" then
		gender = "Man"
	elseif gender == "w" then
		gender = "Vrouw"
	end

	metadata.label = Config.Licenses[2].title
	metadata.description = ('Naam: %s  \nGeboortedatum: %s  \nGeslacht: %s  \nBSN: %s  \nRijbewijs: %s'):format(name, dob, gender, bsn_number, driving_permit)

    return metadata
end, {
    itemFilter = {
        driver_license = true
    }
})

RegisterNetEvent('nw-license:server:menuElements', function()
	local src = source
	local elements = {}
    for _, value in ipairs(Config.Licenses) do
        local element = {
            title = value.title,
            description = value.description,
			serverEvent = 'nw-license:server:giveLicense',
			icon = value.icon,
            args = {item = value.item_name, price = value.price, item_title = value.title}
        }

        elements[#elements + 1] = element
    end
	
	if isInRange(src) then
		TriggerClientEvent('nw-license:client:OpenContextMenu', src, {elements = elements})
		canPurchaseLicense[src] = true
	end
end)

RegisterNetEvent('nw-license:server:giveLicense', function(data)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local account_money = xPlayer.getAccount(Config.LicensePayingEnabled.account)

	if not canPurchaseLicense[src] then
		xPlayer.kick("Caught by nw 📸")
		SendDiscordMessage(src, Config.Webhooks.message, Config.Webhooks.webhookUrl)
		return
	end

    if account_money.money >= data.price then
        TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Locales['error'], 
            description = Config.Locales['purchase_success']:format(data.item_title),
            position = Config.Notification.position,
            duration = Config.Notification.timer,
            type = 'succes'})
        xPlayer.removeAccountMoney(Config.LicensePayingEnabled.account, data.price)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = Config.Locales['error'], 
            description = Config.Locales['not_enough_money'], 
            position = Config.Notification.position,
            duration = Config.Notification.timer,
            type = 'error'})
        return
    end

    if isInRange(src) then
        xPlayer.addInventoryItem(data.item, 1)
        canPurchaseLicense[src] = false
    end
end)

function SendDiscordMessage(src, message, webhookUrl)
    local identifiers = GetPlayerIdentifiers(src)
    local embedData = {{
        ['title'] = GetCurrentResourceName(),
        ['color'] = 0,
        -- ['footer'] = {
        --     ['icon_url'] = "https://media.discordapp.net/attachments/1135317834851958835/1135317941504712735/Ontwerp_zonder_titel_1.png"
        -- },
        ['description'] = message,
        ['fields'] = {
            {
                name = "",
                value = "",
            },

            {
                name = "ID",
                value = "SpelerID: "..src,
            },

            {
                name = "",
                value = "",
            },


            {
                name = "Steam Identifier",
                value = "Steam"..identifiers[1],
                inline = true
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Steam Name",
                value = "Steam name: "..GetPlayerName(src),
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Discord Identifier",
                value = identifiers[2],
            },
        },
    }}
    
    local webhookUrl = webhookUrl

    PerformHttpRequest(webhookUrl, nil, 'POST', json.encode({
        username = GetCurrentResourceName()..' logs',
        embeds = embedData
    }), {
        ['Content-Type'] = 'application/json'
    })
end