fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'QR-Management'

client_scripts { 'modules/client.lua', 'client/*.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'modules/server.lua', 'server/*.lua' }
shared_scripts { '@ox_lib/init.lua', 'config.lua' }

server_exports {
    'AddMoney',
    'AddGangMoney',
    'RemoveMoney',
    'RemoveGangMoney',
    'GetAccount',
    'GetGangAccount',
}

lua54 'yes'
