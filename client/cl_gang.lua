local qrc = require('modules.client')

RegisterNetEvent('qr-gangmenu:client:Stash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "gang_" .. PlayerGang.name, { maxweight = 4000000, slots = 100, })
    TriggerEvent("inventory:client:SetCurrentStash", "gang_" .. PlayerGang.name)
end)

-- Menus / Inputs --
RegisterNetEvent('qr-gangmenu:client:OpenMenu', function()
    if not PlayerGang.name or not PlayerGang.isboss then return end
    local gangMenu = {
        {
            title = "Manage Gang Members",
            icon = "fa-solid fa-list",
            description = "Recruit or Fire Gang Members",
            event = "qr-gangmenu:client:ManageGang",
        },
        {
            title = "Recruit Members",
            icon = "fa-solid fa-hand-holding",
            description = "Hire Gang Members",
            event = "qr-gangmenu:client:HireMembers",
        },
        {
            title = "Storage Access",
            icon = "fa-solid fa-box-open",
            description = "Open Gang Stash",
            event = "qr-gangmenu:client:Stash",
        },
        {
            title = "Outfits",
            description = "Change Clothes",
            icon = "fa-solid fa-shirt",
            event = "qr-management:client:Wardrobe",
        },
        {
            title = "Money Management",
            icon = "fa-solid fa-sack-dollar",
            description = "Check your Gang Balance",
            event = "qr-gangmenu:client:SocietyMenu",
        },
    }

    lib.registerContext({
        id = 'gang_menu',
        title = "Gang Management  - " .. string.upper(PlayerGang.label),
        options = gangMenu
    })
    lib.showContext('gang_menu')
end)

RegisterNetEvent('qr-gangmenu:client:ManageGang', function()
    local GangMembersMenu = {}
    local gangMembers = lib.callback.await('qr-gangmenu:server:GetEmployees', false, PlayerGang.name)

    for _, v in pairs(gangMembers) do
        GangMembersMenu[#GangMembersMenu + 1] = {
            title = v.name,
            description = v.grade.name,
            icon = "fa-solid fa-circle-user",
            event = "qr-gangmenu:lient:ManageMember",
            args = {
                player = v,
                work = PlayerGang
            }
        }
    end

    lib.registerContext({
        id = 'manage_gang_members',
        title = "Manage Gang Members - " .. string.upper(PlayerGang.label),
        menu = 'gang_menu',
        options = GangMembersMenu
    })
    lib.showContext('manage_gang_members')
end)

RegisterNetEvent('qr-gangmenu:lient:ManageMember', function(data)
    local MemberMenu = {}

    for k, v in pairs(SharedGangs[data.work.name].grades) do
        MemberMenu[#MemberMenu + 1] = {
            title = v.name,
            description = "Grade: " .. k,
            serverEvent = "qr-gangmenu:server:GradeUpdate",
            icon = "fa-solid fa-file-pen",
            args = {
                cid = data.player.empSource,
                grade = tonumber(k),
                gradename = v.name
            }
        }
    end

    MemberMenu[#MemberMenu + 1] = {
        title = "Fire",
        icon = "fa-solid fa-user-large-slash",
        serverEvent = "qr-gangmenu:server:FireMember",
        args = data.player.empSource
    }

    lib.registerContext({
        id = 'gang_members',
        title = "Manage " .. data.player.name .. " - " .. string.upper(PlayerGang.label),
        menu = 'gang_menu',
        options = MemberMenu
    })
    lib.showContext('gang_members')
end)

RegisterNetEvent('qr-gangmenu:client:HireMembers', function()
    local HireMembersMenu = {}
    local players = lib.callback.await('qr-management:server:GetPlayers')

    for _, v in pairs(players) do
        if v and v ~= PlayerId() then
            HireMembersMenu[#HireMembersMenu + 1] = {
                title = v.name,
                description = "Citizen ID: " .. v.citizenid .. " - ID: " .. v.sourceplayer,
                icon = "fa-solid fa-user-check",
                serverEvent = "qr-gangmenu:server:HireMember",
                args = v.sourceplayer
            }
        end
    end

    lib.registerContext({
        id = 'hire_gang_members',
        title = "Hire Employees - " .. string.upper(PlayerGang.label),
        menu = 'gang_menu',
        options = HireMembersMenu
    })
    lib.showContext('hire_gang_members')
end)

RegisterNetEvent('qr-gangmenu:client:SocietyMenu', function()
    local account = lib.callback.await('qr-gangmenu:server:GetAccount', false, PlayerGang.name)
    local SocietyMenu = {
        {
            title = "Deposit",
            icon = "fa-solid fa-money-bill-transfer",
            description = "Deposit Money",
            event = "qr-gangmenu:client:SocietyDeposit",
            args = qrc.comma_value(account)
        },
        {
            title = "Withdraw",
            icon = "fa-solid fa-money-bill-transfer",
            description = "Withdraw Money",
            event = "qr-gangmenu:client:SocietyWithdraw",
            args = qrc.comma_value(account)
        },
    }

    lib.registerContext({
        id = 'gang_society',
        title = "Balance: $" .. qrc.comma_value(account) .. " - " .. string.upper(PlayerGang.label),
        menu = 'gang_menu',
        options = SocietyMenu
    })
    lib.showContext('gang_society')
end)

RegisterNetEvent('qr-gangmenu:client:SocietyDeposit', function(saldoattuale)
    local deposit = lib.inputDialog('Available Balance: $'..saldoattuale, {
        { type = 'number', label = 'Amount', description = 'Deposit Funds', required = true },
    })
    if deposit then
        if not deposit[1] then return end
        TriggerServerEvent("qr-gangmenu:server:depositMoney", tonumber(deposit[1]))
    end
end)

RegisterNetEvent('qr-gangmenu:client:SocietyWithdraw', function(saldoattuale)
    local withdraw = lib.inputDialog('Available Balance: $'..saldoattuale, {
        { type = 'number', label = 'Amount', description = 'Withdraw Funds', required = true },
    })
    if withdraw then
        if not withdraw[1] then return end
        TriggerServerEvent("qr-gangmenu:server:withdrawMoney", tonumber(withdraw[1]))
    end
end)