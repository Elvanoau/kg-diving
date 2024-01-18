local QBCore = exports['qb-core']:GetCoreObject()
local isDiving = false
local lastCoords = nil
local oxgenlevell = 0
local iswearingsuit = false

local currentGear = {
    mask = 0,
    tank = 0,
    oxygen = 0,
    enabled = false
}

local function IsFarEnough(last, current)
    if last.x + 1 <= current.x then
        if last.y + 1 <= current.y then
            return true
        end
    elseif last.x - 1 >= current.x then
        if last.y - 1 >= current.y then
            return true
        end
    end

    return false
end

local function deleteGear()
	if currentGear.mask ~= 0 then
        DetachEntity(currentGear.mask, 0, 1)
        DeleteEntity(currentGear.mask)
		currentGear.mask = 0
    end
	if currentGear.tank ~= 0 then
        DetachEntity(currentGear.tank, 0, 1)
        DeleteEntity(currentGear.tank)
		currentGear.tank = 0
	end

end

local function gearAnim()
    RequestAnimDict("clothingshirt")
    while not HasAnimDictLoaded("clothingshirt") do
        Wait(0)
    end
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

RegisterNetEvent('kg-diving:Search', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local hfg = GetEntityHeightAboveGround(ped)
    local depthNeeded = Config.depthNeeded

    if isDiving == true then return end

    if hfg > depthNeeded then
        return
    end

    if IsPedSwimmingUnderWater(ped) then
    else
        return
    end

    if lastCoords == nil then
        lastCoords = coords
    else
        if IsFarEnough(lastCoords, coords) == false then return end
    end

    FreezeEntityPosition(ped, true)
    isDiving = true
    QBCore.Functions.Progressbar('dig', 'Digging...', Config.SearchTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
        }, {}, {}, {}, function() -- Complete
            TriggerServerEvent('kg-diving:Reward')
            FreezeEntityPosition(ped, false)
            isDiving = false
        end, function() -- Cancel
            FreezeEntityPosition(ped, false)
            isDiving = false
    end)
end)

Citizen.CreateThread(function ()
    if not Config.UseJimRecycle then
        exports ["qb-target"]:AddTargetModel("s_m_y_xmech_01", {
            options = {
                {
                type = "server",
                event = "kg-diving:SellCans",
                icon = "fas fa-dot",
                label = "Sell Cans / Bottles",
                }
            },
            distance = 2.0})

        local FishMarketv3 = vector3(1679.33, 4863.86, 42.05)
        local FishMarket = AddBlipForCoord(FishMarketv3.x, FishMarketv3.y, FishMarketv3.z)
        SetBlipSprite (FishMarket, 814)
        SetBlipDisplay(FishMarket, 4)
        SetBlipScale  (FishMarket, 0.6)
        SetBlipAsShortRange(FishMarket, true)
        SetBlipColour(FishMarket, 18)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Sell Cans")
        EndTextCommandSetBlipName(FishMarket)

        local FishMarket2v3 = vector3(-503.82, -737.18, 32.65)
        local FishMarket2 = AddBlipForCoord(FishMarket2v3.x, FishMarket2v3.y, FishMarket2v3.z)
        SetBlipSprite (FishMarket2, 814)
        SetBlipDisplay(FishMarket2, 4)
        SetBlipScale  (FishMarket2, 0.6)
        SetBlipAsShortRange(FishMarket2, true)
        SetBlipColour(FishMarket2, 18)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Sell Cans")
        EndTextCommandSetBlipName(FishMarket2)
    end
end)

RegisterNetEvent('kg-diving:client:UseGear', function()
    local ped = PlayerPedId()
    if iswearingsuit == false then
        if oxgenlevell > 0 then
            iswearingsuit = true
            if not IsPedSwimming(ped) and not IsPedInAnyVehicle(ped) then
                gearAnim()
                QBCore.Functions.Progressbar("equip_gear", Lang:t("info.put_suit"), 5000, false, true, {}, {}, {}, {},
                    function() -- Done
                        deleteGear()
                        local maskModel = `p_d_scuba_mask_s`
                        local tankModel = `p_s_scuba_tank_s`
                        RequestModel(tankModel)
                        while not HasModelLoaded(tankModel) do
                            Wait(0)
                        end
                        currentGear.tank = CreateObject(tankModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone1 = GetPedBoneIndex(ped, 24818)
                        AttachEntityToEntity(currentGear.tank, ped, bone1, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 1, 1, 0,
                            0, 2, 1)

                        RequestModel(maskModel)
                        while not HasModelLoaded(maskModel) do
                            Wait(0)
                        end
                        currentGear.mask = CreateObject(maskModel, 1.0, 1.0, 1.0, 1, 1, 0)
                        local bone2 = GetPedBoneIndex(ped, 12844)
                        AttachEntityToEntity(currentGear.mask, ped, bone2, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2
                            , 1)
                        SetEnableScuba(ped, true)
                        SetPedMaxTimeUnderwater(ped, 2000.00)
                        currentGear.enabled = true
                        ClearPedTasks(ped)
                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                        oxgenlevell = oxgenlevell
                        Citizen.CreateThread(function()
                            while currentGear.enabled do
                                if IsPedSwimmingUnderWater(PlayerPedId()) then
                                    oxgenlevell = oxgenlevell - 1
                                    if oxgenlevell == 90 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 80 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 70 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 60 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 50 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 40 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 30 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 20 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 10 then
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "breathdivingsuit", 0.25)
                                    elseif oxgenlevell == 0 then
                                        --   deleteGear()
                                        SetEnableScuba(ped, false)
                                        SetPedMaxTimeUnderwater(ped, 1.00)
                                        currentGear.enabled = false
                                        iswearingsuit = false
                                        TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
                                    end
                                end
                                Wait(1000)
                            end
                        end)
                    end)
            else
                QBCore.Functions.Notify(Lang:t("error.not_standing_up"), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t("error.need_otube"), 'error')
        end
    elseif iswearingsuit == true then
        gearAnim()
        QBCore.Functions.Progressbar("remove_gear", Lang:t("info.pullout_suit"), 5000, false, true, {}, {}, {}, {},
            function() -- Done
                SetEnableScuba(ped, false)
                SetPedMaxTimeUnderwater(ped, 50.00)
                currentGear.enabled = false
                ClearPedTasks(ped)
                deleteGear()
                QBCore.Functions.Notify(Lang:t("success.took_out"))
                TriggerServerEvent("InteractSound_SV:PlayOnSource", nil, 0.25)
                iswearingsuit = false
                oxgenlevell = oxgenlevell
            end)
    end
end)

RegisterNetEvent("kg-diving:client:setoxygenlevel", function()
    if oxgenlevell == 0 then
       oxgenlevell = Config.oxygenlevel -- oxygenlevel
       QBCore.Functions.Notify(Lang:t("success.tube_filled"), 'success')
       TriggerServerEvent('kg-diving:server:removeItemAfterFill')
    else
        QBCore.Functions.Notify(Lang:t("error.oxygenlevel", {oxygenlevel = oxgenlevell}), 'error')
    end
end)

RegisterCommand("anchor_boat", function(source)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if GetVehicleClass(veh) == 14 then
        if IsBoatAnchoredAndFrozen(veh) then
            SetBoatAnchor(veh, false)
            SetBoatFrozenWhenAnchored(veh, false)
            SetForcedBoatLocationWhenAnchored(veh, false)
            QBCore.Functions.Notify(Lang:t("anchor.remove"), 'success')
        else
            SetBoatAnchor(veh, true)
            SetBoatFrozenWhenAnchored(veh, true)
            SetForcedBoatLocationWhenAnchored(veh, true)
            QBCore.Functions.Notify(Lang:t("anchor.place"), 'success')
        end
    end
end)

RegisterKeyMapping("anchor_boat", "Anchors Boat", "KEYBOARD", "G")