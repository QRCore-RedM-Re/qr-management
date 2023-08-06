
-- Get Closest Players --
lib.callback.register('qr-management:server:GetPlayers', function(source)
	local src = source
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	local players = QRCore.Functions.GetPlayers()
	local ClosestPlayers = {}

	for _, v in pairs(players) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QRCore.Functions.GetPlayer(v)
			ClosestPlayers[#players+1] = {
				id = v,
				coords = GetEntityCoords(targetped),
				name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
				citizenid = ped.PlayerData.citizenid,
				sources = GetPlayerPed(ped.PlayerData.source),
				sourceplayer = ped.PlayerData.source
			}
		end
	end
	return ClosestPlayers
end)

local qrs = {}

function qrs.ExploitBan(id, reason)
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

function qrs.GetAccount(account)
	return BossAccounts[account] or 0
end

function qrs.AddMoney(account, amount)
	if not BossAccounts[account] then
		BossAccounts[account] = 0
	end

	BossAccounts[account] = BossAccounts[account] + amount
	MySQL.insert('INSERT INTO management_funds (job_name, amount, type) VALUES (:job_name, :amount, :type) ON DUPLICATE KEY UPDATE amount = :amount',
		{
			['job_name'] = account,
			['amount'] = BossAccounts[account],
			['type'] = 'boss'
		})
end

function qrs.RemoveMoney(account, amount)
	local isRemoved = false
	if amount > 0 then
		if not BossAccounts[account] then
			BossAccounts[account] = 0
		end

		if BossAccounts[account] >= amount then
			BossAccounts[account] = BossAccounts[account] - amount
			isRemoved = true
		end

		MySQL.update('UPDATE management_funds SET amount = ? WHERE job_name = ? and type = "boss"', { BossAccounts[account], account })
	end
	return isRemoved
end

function qrs.GetGangAccount(account)
	return GangAccounts[account] or 0
end

function qrs.AddGangMoney(account, amount)
	if not GangAccounts[account] then
		GangAccounts[account] = 0
	end

	GangAccounts[account] = GangAccounts[account] + amount
	MySQL.insert('INSERT INTO management_funds (job_name, amount, type) VALUES (:job_name, :amount, :type) ON DUPLICATE KEY UPDATE amount = :amount',
		{
			['job_name'] = account,
			['amount'] = GangAccounts[account],
			['type'] = 'gang'
		})
end

function qrs.RemoveGangMoney(account, amount)
	local isRemoved = false
	if amount > 0 then
		if not GangAccounts[account] then
			GangAccounts[account] = 0
		end

		if GangAccounts[account] >= amount then
			GangAccounts[account] = GangAccounts[account] - amount
			isRemoved = true
		end

		MySQL.update('UPDATE management_funds SET amount = ? WHERE job_name = ? and type = "gang"', { GangAccounts[account], account })
	end
	return isRemoved
end

return qrs