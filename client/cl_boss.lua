local qrc = require('modules.client')

RegisterNetEvent('qr-bossmenu:client:Stash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerJob.name, { maxweight = 4000000, slots = 25, })
    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerJob.name)
end)

-- Menus / Inputs --
RegisterNetEvent('qr-bossmenu:client:OpenMenu', function()
    if not PlayerJob.name or not PlayerJob.isboss then return end
    local bossMenu = {
        {
            title = "Manage Employees",
            description = "Check your Employees List",
            icon = "fa-solid fa-list",
            event = "qr-bossmenu:client:employeelist",
        },
        {
            title = "Hire Employees",
            description = "Hire Nearby Civilians",
            icon = "fa-solid fa-hand-holding",
            event = "qr-bossmenu:client:HireMenu",
        },
        {
            title = "Storage Access",
            description = "Open Storage",
            icon = "fa-solid fa-box-open",
            event = "qr-bossmenu:client:Stash",
        },
        {
            title = "Outfits",
            description = "See Saved Outfits",
            icon = "fa-solid fa-shirt",
            event = "qr-management:client:Wardrobe",
        },
        {
            title = "Money Management",
            description = "Check your Company Balance",
            icon = "fa-solid fa-sack-dollar",
            event = "qr-bossmenu:client:SocietyMenu",
        },
    }

    lib.registerContext({
        id = 'boss_menu',
        title = "Boss Menu - " .. string.upper(PlayerJob.label),
        options = bossMenu
    })
    lib.showContext('boss_menu')
end)

RegisterNetEvent('qr-bossmenu:client:employeelist', function()
    local EmployeesMenu = {}
    local employees = lib.callback.await('qr-bossmenu:server:GetEmployees', false, PlayerJob.name)

    for _, v in pairs(employees) do
        EmployeesMenu[#EmployeesMenu + 1] = {
            title = v.name,
            description = v.grade.name,
            icon = "fa-solid fa-circle-user",
            event = "qr-bossmenu:client:ManageEmployee",
            args = { player = v, work = PlayerJob }
        }
    end

    lib.registerContext({
        id = 'employee_list',
        title = "Manage Employees - " .. string.upper(PlayerJob.label),
        menu = 'boss_menu',
        options = EmployeesMenu
    })
    lib.showContext('employee_list')
end)

RegisterNetEvent('qr-bossmenu:client:ManageEmployee', function(data)
    local EmployeeMenu = {}

    for x = 0, #SharedJobs[data.work.name].grades do
        local info = SharedJobs[data.work.name].grades[x]
        EmployeeMenu[#EmployeeMenu + 1] = {
            title  = info.name,
            description = "Grade: " .. x,
            serverEvent = "qr-bossmenu:server:GradeUpdate",
            icon = "fa-solid fa-file-pen",
            args = { cid = data.player.empSource, grade = tonumber(x), gradename = info.name }
        }
    end

    EmployeeMenu[#EmployeeMenu + 1] = {
        title = "Fire Employee",
        icon = "fa-solid fa-user-large-slash",
        serverEvent = "qr-bossmenu:server:FireEmployee",
        args = data.player.empSource
    }

    EmployeeMenu[#EmployeeMenu + 1] = {
        title = "Return",
        icon = "fa-solid fa-angle-left",
        event = "qr-bossmenu:client:OpenMenu",
    }

    lib.registerContext({
        id = 'manage_employee',
        title = "Manage " .. data.player.name .. " - " .. string.upper(PlayerJob.label),
        menu = 'boss_menu',
        options = EmployeeMenu
    })
    lib.showContext('manage_employee')
end)

RegisterNetEvent('qr-bossmenu:client:HireMenu', function()
    local HireMenu = {}
    local players = lib.callback.await('qr-management:server:GetPlayers', false)

    for _, v in pairs(players) do
        if v and v ~= cache.ped then
            HireMenu[#HireMenu + 1] = {
                title = v.name,
                description = "Citizen ID: " .. v.citizenid .. " - ID: " .. v.sourceplayer,
                icon = "fa-solid fa-user-check",
                serverEvent = "qr-bossmenu:server:HireEmployee",
                args = v.sourceplayer
            }
        end
    end

    lib.registerContext({
        id = 'hire_menu',
        title = "Hire Employees - " .. string.upper(PlayerJob.label),
        menu = 'boss_menu',
        options = HireMenu
    })
    lib.showContext('hire_menu')
end)

RegisterNetEvent('qr-bossmenu:client:SocietyMenu', function()
    local account = lib.callback.await('qr-bossmenu:server:GetAccount', false, PlayerJob.name)
    local SocietyMenu = {
        {
            title = "Deposit",
            icon = "fa-solid fa-money-bill-transfer",
            description = "Deposit Money into account",
            event = "qr-bossmenu:client:SocetyDeposit",
            args = qrc.comma_value(account)
        },
        {
            title = "Withdraw",
            icon = "fa-solid fa-money-bill-transfer",
            description = "Withdraw Money from account",
            event = "qr-bossmenu:client:SocetyWithDraw",
            args = qrc.comma_value(account)
        },
        {
            title = "Return",
            icon = "fa-solid fa-angle-left",
            event = "qr-bossmenu:client:OpenMenu",
        },
    }

    lib.registerContext({
        id = 'society_menu',
        title = "Balance: $" .. qrc.comma_value(account) .. " - " .. string.upper(PlayerJob.label),
        menu = 'boss_menu',
        options = SocietyMenu
    })
    lib.showContext('society_menu')
end)

RegisterNetEvent('qr-bossmenu:client:SocetyDeposit', function(money)
    local deposit = lib.inputDialog('Available Balance: $'..money, {
        { type = 'number', label = 'Amount', description = 'Deposit Funds', required = true },
    })
    if deposit then
        if not deposit[1] then return end
        TriggerServerEvent("qr-bossmenu:server:depositMoney", tonumber(deposit[1]))
    end
end)

RegisterNetEvent('qr-bossmenu:client:SocetyWithDraw', function(money)
    local withdraw = lib.inputDialog('Available Balance: $'..money, {
        { type = 'number', label = 'Amount', description = 'Withdraw Funds', required = true },
    })
    if withdraw then
        if not withdraw[1] then return end
        TriggerServerEvent("qr-bossmenu:server:withdrawMoney", tonumber(withdraw[1]))
    end
end)