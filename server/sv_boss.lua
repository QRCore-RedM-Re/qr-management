local QRCore = exports['qr-core']:GetCoreObject()
local Accounts = {}

function ExploitBan(id, reason)
	MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
		GetPlayerName(id),
		QRCore.Functions.GetIdentifier(id, 'license'),
		QRCore.Functions.GetIdentifier(id, 'discord'),
		QRCore.Functions.GetIdentifier(id, 'ip'),
		reason,
		2147483647,
		'qr-management'
	})
	TriggerEvent('qr-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(id), 'qr-management', reason), true)
	DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

function GetAccount(account)
	return Accounts[account] or 0
end

function AddMoney(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	Accounts[account] = Accounts[account] + amount
	MySQL.insert('INSERT INTO management_funds (job_name, amount, type) VALUES (:job_name, :amount, :type) ON DUPLICATE KEY UPDATE amount = :amount',
		{
			['job_name'] = account,
			['amount'] = Accounts[account],
			['type'] = 'boss'
		})
end

function RemoveMoney(account, amount)
	local isRemoved = false
	if amount > 0 then
		if not Accounts[account] then
			Accounts[account] = 0
		end

		if Accounts[account] >= amount then
			Accounts[account] = Accounts[account] - amount
			isRemoved = true
		end

		MySQL.update('UPDATE management_funds SET amount = ? WHERE job_name = ? and type = "boss"', { Accounts[account], account })
	end
	return isRemoved
end

MySQL.ready(function ()
	local bossmenu = MySQL.query.await('SELECT job_name,amount FROM management_funds WHERE type = "boss"', {})
	if not bossmenu then return end

	for _,v in ipairs(bossmenu) do
		Accounts[v.job_name] = v.amount
	end
end)

RegisterNetEvent("qr-bossmenu:server:withdrawMoney", function(amount)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'withdrawMoney Exploiting') return end

	local job = Player.PlayerData.job.name
	if RemoveMoney(job, amount) then
		Player.Functions.AddMoney("cash", amount, 'Boss menu withdraw')
		TriggerEvent('qr-log:server:CreateLog', 'bossmenu', 'Withdraw Money', "blue", Player.PlayerData.name.. "Withdrawal $" .. amount .. ' (' .. job .. ')', false)
		TriggerClientEvent('QRCore:Notify', src, "You have withdrawn: $" ..amount, "success")
	else
		TriggerClientEvent('QRCore:Notify', src, "You dont have enough money in the account!", "error")
	end

	TriggerClientEvent('qr-bossmenu:client:OpenMenu', src)
end)

RegisterNetEvent("qr-bossmenu:server:depositMoney", function(amount)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'depositMoney Exploiting') return end

	if Player.Functions.RemoveMoney("cash", amount) then
		local job = Player.PlayerData.job.name
		AddMoney(job, amount)
		TriggerEvent('qr-log:server:CreateLog', 'bossmenu', 'Deposit Money', "blue", Player.PlayerData.name.. "Deposit $" .. amount .. ' (' .. job .. ')', false)
		TriggerClientEvent('QRCore:Notify', src, "You have deposited: $" ..amount, "success")
	else
		TriggerClientEvent('QRCore:Notify', src, "You dont have enough money to add!", "error")
	end

	TriggerClientEvent('qr-bossmenu:client:OpenMenu', src)
end)

QRCore.Functions.CreateCallback('qr-bossmenu:server:GetAccount', function(_, cb, jobname)
	local result = GetAccount(jobname)
	cb(result)
end)

-- Get Employees
QRCore.Functions.CreateCallback('qr-bossmenu:server:GetEmployees', function(source, cb, jobname)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'GetEmployees Exploiting') return end

	local employees = {}
	local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%".. jobname .."%'", {})
	if players[1] ~= nil then
		for _, value in pairs(players) do
			local isOnline = QRCore.Functions.GetPlayerByCitizenId(value.citizenid)

			if isOnline then
				employees[#employees+1] = {
				empSource = isOnline.PlayerData.citizenid,
				grade = isOnline.PlayerData.job.grade,
				isboss = isOnline.PlayerData.job.isboss,
				name = '🟢 ' .. isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
				}
			else
				employees[#employees+1] = {
				empSource = value.citizenid,
				grade =  json.decode(value.job).grade,
				isboss = json.decode(value.job).isboss,
				name = '❌ ' ..  json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
				}
			end
		end
		table.sort(employees, function(a, b)
            return a.grade.level > b.grade.level
        end)
	end
	cb(employees)
end)

-- Grade Change
RegisterNetEvent('qr-bossmenu:server:GradeUpdate', function(data)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)
	local Employee = QRCore.Functions.GetPlayerByCitizenId(data.cid)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'GradeUpdate Exploiting') return end
	if data.grade > Player.PlayerData.job.grade.level then TriggerClientEvent('QRCore:Notify', src, "You cannot promote to this rank!", "error") return end
	
	if Employee then
		if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grade) then
			TriggerClientEvent('QRCore:Notify', src, "Sucessfulluy promoted!", "success")
			TriggerClientEvent('QRCore:Notify', Employee.PlayerData.source, "You have been promoted to" ..data.gradename..".", "success")
		else
			TriggerClientEvent('QRCore:Notify', src, "Promotion grade does not exist.", "error")
		end
	else
		TriggerClientEvent('QRCore:Notify', src, "Civilian not in city.", "error")
	end
	TriggerClientEvent('qr-bossmenu:client:OpenMenu', src)
end)

-- Fire Employee
RegisterNetEvent('qr-bossmenu:server:FireEmployee', function(target)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)
	local Employee = QRCore.Functions.GetPlayerByCitizenId(target)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'FireEmployee Exploiting') return end

	if Employee then
		if target ~= Player.PlayerData.citizenid then
			if Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then TriggerClientEvent('QRCore:Notify', src, "You cannot fire this citizen!", "error") return end
			if Employee.Functions.SetJob("unemployed", '0') then
				TriggerEvent("qr-log:server:CreateLog", "bossmenu", "Job Fire", "red", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false)
				TriggerClientEvent('QRCore:Notify', src, "Employee fired!", "success")
				TriggerClientEvent('QRCore:Notify', Employee.PlayerData.source , "You have been fired! Good luck.", "error")
			else
				TriggerClientEvent('QRCore:Notify', src, "Error..", "error")
			end
		else
			TriggerClientEvent('QRCore:Notify', src, "You can\'t fire yourself", "error")
		end
	else
		local player = MySQL.query.await('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { target })
		if player[1] ~= nil then
			Employee = player[1]
			Employee.job = json.decode(Employee.job)
			if Employee.job.grade.level > Player.PlayerData.job.grade.level then TriggerClientEvent('QRCore:Notify', src, "You cannot fire this citizen!", "error") return end
			local job = {}
			job.name = "unemployed"
			job.label = "Unemployed"
			job.payment = QRCore.Shared.Jobs[job.name].grades['0'].payment or 500
			job.onduty = true
			job.isboss = false
			job.grade = {}
			job.grade.name = nil
			job.grade.level = 0
			MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), target })
			TriggerClientEvent('QRCore:Notify', src, "Employee fired!", "success")
			TriggerEvent("qr-log:server:CreateLog", "bossmenu", "Job Fire", "red", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false)
		else
			TriggerClientEvent('QRCore:Notify', src, "Civilian not in city.", "error")
		end
	end
	TriggerClientEvent('qr-bossmenu:client:OpenMenu', src)
end)

-- Recruit Player
RegisterNetEvent('qr-bossmenu:server:HireEmployee', function(recruit)
	local src = source
	local Player = QRCore.Functions.GetPlayer(src)
	local Target = QRCore.Functions.GetPlayer(recruit)

	if not Player.PlayerData.job.isboss then ExploitBan(src, 'HireEmployee Exploiting') return end

	if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
		TriggerClientEvent('QRCore:Notify', src, "You hired " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. " come " .. Player.PlayerData.job.label .. "", "success")
		TriggerClientEvent('QRCore:Notify', Target.PlayerData.source , "You were hired as " .. Player.PlayerData.job.label .. "", "success")
		TriggerEvent('qr-log:server:CreateLog', 'bossmenu', 'Recruit', "lightgreen", (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname).. " successfully recruited " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' .. Player.PlayerData.job.name .. ')', false)
	end
	TriggerClientEvent('qr-bossmenu:client:OpenMenu', src)
end)

-- Get closest player sv
QRCore.Functions.CreateCallback('qr-bossmenu:getplayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(QRCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QRCore.Functions.GetPlayer(v)
			players[#players+1] = {
			id = v,
			coords = GetEntityCoords(targetped),
			name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
			citizenid = ped.PlayerData.citizenid,
			sources = GetPlayerPed(ped.PlayerData.source),
			sourceplayer = ped.PlayerData.source
			}
		end
	end
		table.sort(players, function(a, b)
			return a.name < b.name
		end)
	cb(players)
end)
