local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('waterproof_metaldetector', function(source, item)
    TriggerClientEvent('kg-diving:Search', source)
end)

QBCore.Functions.CreateUseableItem('locked_case', function(source, item)
    TriggerEvent('kg-diving:openLockedCase', source)
end)

RegisterServerEvent('kg-diving:Reward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Items[math.random(1, #Config.Items)]
    local rand = math.random()

    if rand <= Config.CaseChance then
        item = 'locked_case'
    end

    Player.Functions.AddItem(item, 1)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[item], "add", 1)
end)

RegisterServerEvent('kg-diving:openLockedCase', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local item = Config.LockCaseItems[math.random(1, #Config.LockCaseItems)]
    local amount = math.random(item.min, item.max)
    Player.Functions.AddItem(item, amount)
    Player.Functions.RemoveItem('locked_case', 1)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[item], "add", amount)
end)

RegisterServerEvent('kg-diving:SellCans', function ()
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.Functions.GetItemByName('can')
    local price = 0

    if amount then
        amount = amount.amount
    else
        TriggerEvent('kg-diving:SellBottles', 0, source)
        return
    end

    price = (Config.CanPrice * amount)

    Player.Functions.RemoveItem('can', amount)
    Player.Functions.AddMoney('cash', price)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['can'], "remove", amount)

    TriggerEvent('kg-diving:SellBottles', price, source)
end)

RegisterServerEvent('kg-diving:SellBottles', function (cost, source)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Player.Functions.GetItemByName('bottle')
    local price = cost

    if amount then
        amount = amount.amount
    else
        return
    end

    price = price + (Config.BottlePrice * amount)

    Player.Functions.RemoveItem('bottle', amount)
    Player.Functions.AddMoney('cash', price)
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items['bottle'], "remove", amount)

end)

RegisterNetEvent('kg-diving:server:removeItemAfterFill', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("diving_fill", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["diving_fill"], "remove")
end)


-- Items

QBCore.Functions.CreateUseableItem("diving_gear", function(source)
    TriggerClientEvent("kg-diving:client:UseGear", source)
end)

QBCore.Functions.CreateUseableItem("diving_fill", function(source)
    TriggerClientEvent("kg-diving:client:setoxygenlevel", source)
end)
