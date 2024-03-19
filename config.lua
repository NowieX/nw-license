Config = {}

Config.Webhooks = {
    webhookUrl = "",
    message = "**The player with the information underneath triggered an event from nw-license that he got his license, go check on him fast.**"
}

Config.Notification = {
    position = 'top-right',
    timer = 7500,
}

Config.LicensePayingEnabled = {
    enabled = true,
    account = 'bank' -- The account from which the money is debited, can be money, bank. If you are weird you use black_money haha ;)
}

Config.CityHallNPC = {
    {
        location = vec3(-545.0424, -204.2590, 38.2152),
        heading = 210.0172,
        model = 'cs_fbisuit_01',
        targetDistance = 2.0
    },
}

Config.Licenses = {
    {
        title = "ID Kaart",
        description = "Prijs: €500",
        price = 500,
        icon = 'fa fa-id-card',
        item_name = 'id_card',
    },
    {
        title = "Rijbewijs",
        description = "Prijs: €1000",
        price = 1000,
        icon = 'fa fa-id-card',
        item_name = 'driver_license', -- You have to create the item manually in ox_inventory > data > items.lua
    },
}

Config.Locales = {
    ['succes'] = "Success",
    ['error'] = "Error",
    ['exploit'] = "Probeer je nou een id kaart script te hacken?",
    ['license_center'] = "Gemeentehuis",
    ['open_city_hall'] = "Open gemeentehuis",
    ['not_enough_money'] = "Niet genoeg geld!",
    ['purchase_success'] = "Je hebt een %s gekocht!", -- Important to leave the %s on the place where you want the item name to come. If you don't want the item name you can replace it.
}