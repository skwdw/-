vRPd = {}
Tunnel.bindInterface("caruby_audition",vRPd)
Proxy.addInterface("caruby_audition",vRPd)
Dserver = Tunnel.getInterface("caruby_audition","caruby_audition")
vRPserver = Tunnel.getInterface("vRP","caruby_audition")
vRP = Proxy.getInterface("vRP")

local game = {
	round = 0,
	count = 0,
	red = 0,
	rrate = 0,
	sname = "",
	sskip = 0,
	label = "",
}
local g = false
local gg = "~r~Bad!"
local isDisplay = false
local isFailed = false
local final = false
local gdance = false
local cn = 0

Citizen.CreateThread(function()
	while vRP == nil do
		TriggerEvent('vrp:getSharedObject', function(obj) vRP = obj end)
		Citizen.Wait(0)
	end	
end)

function LoadAnim(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

RegisterNetEvent('mkbuss:audition')
AddEventHandler('mkbuss:audition', function(options, cb)

	if not IsEntityDead(GetPlayerPed(-1)) then
		if not isDisplay then
		
			isDisplay = true
			isFailed = false
			
			local array = 0
			for i,v in ipairs(Config.Playlist) do array = array+1 end
			local num = math.random(0,array)
			
			game.round = options.round or 5
			game.count = 0
			game.sname = options.song or Config.Playlist[num].name
			game.sskip = Config.Playlist[num].skip  or 0
			game.label = options.label or "Audition"
			game.red = options.red or 0
			game.rrate = options.rrate or 0
			gdance = options.disable_dance or false
			cn = options.npc or 0
			
			SetNuiFocus(true,true)
			SendNUIMessage({
				action = "showGame",
				game = game
			})
			
			fdance()
			
			Citizen.CreateThread(function ()
                while isDisplay do Citizen.Wait(0) end
                if cb ~= nil then
                    cb(isFailed)
                end
            end)
			
		end
	end
	
end)

RegisterNetEvent("mkbuss:audition:fail")
AddEventHandler("mkbuss:audition:fail", function()
    isDisplay = false
    isFailed = true

    SendNUIMessage({
        action = "closeGame"
    })
end)

function dance()
	if not gdance then
		ClearPedTasks(GetPlayerPed(-1))
		ClearPedTasks(cn)
		local array = 0
		for i,v in ipairs(Config.Dances) do array = array+1 end
		local num = math.random(1,array)
		
		LoadAnim(Config.Dances[num].dict)
		TaskPlayAnim(cn, Config.Dances[num].dict,Config.Dances[num].anim,2.0, 2.0, -1, 1, 0, false, false, false )
		TaskPlayAnim(GetPlayerPed(-1), Config.Dances[num].dict,Config.Dances[num].anim,2.0, 2.0, -1, 1, 0, false, false, false )
		RemoveAnimDict(Config.Dances[num].dict)
	end
end

function fdance()
	if not gdance then
		ClearPedTasks(GetPlayerPed(-1))
		ClearPedTasks(cn)
		
		LoadAnim(Config.Dances[0].dict)
		TaskPlayAnim(cn, Config.Dances[0].dict,Config.Dances[0].anim,2.0, 2.0, -1, 1, 0, false, false, false )
		TaskPlayAnim(GetPlayerPed(-1), Config.Dances[0].dict,Config.Dances[0].anim,2.0, 2.0, -1, 1, 0, false, false, false )
		RemoveAnimDict(Config.Dances[0].dict)
	end
end

RegisterNUICallback('mkbuss:NUIoff', function(data, cb)
	isDisplay = false
    isFailed = data.fail

	ClearPedTasks(GetPlayerPed(-1))
	ClearPedTasks(cn)
	
	SetNuiFocus(false,false)
    SendNUIMessage({
        action = "closeGame"
    })
end)

RegisterNUICallback('mkbuss:NUIfail', function(data, cb)
	gg = data.gg
	g = true
	vRP.SetTimeout(2000, function()
		g = false
	end)
	
	fdance()
	
	if final then
		TriggerEvent("mkbuss:audition:fail")
	else
		SendNUIMessage({
			action = "check",
			game = game
		})
	end
	
end)

RegisterNUICallback('mkbuss:NUIsuccess', function(data, cb)
	gg = data.gg
	g = true
	vRP.SetTimeout(2000, function()
		g = false
	end)
	game.count = game.count + 1
	dance()
	
	if game.count + 1 == game.round then
		final = true
	end
	
	if game.count >= game.round then
	
		SetNuiFocus(false,false)
		SendNUIMessage({
			action = "closeGame"
		})
		
		Wait(3000)
		
		ClearPedTasks(cn)
		ClearPedTasks(GetPlayerPed(-1))
	else
		
		SendNUIMessage({
			action = "check",
			game = game
		})
		
	end
	
end)

Citizen.CreateThread(function()

	while true do
	
		local sleep = 1000
		if isDisplay then
			sleep = 50
			SendNUIMessage({
				action = "update"
			})
		end
		
		Citizen.Wait(sleep)
	end
	
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

Citizen.CreateThread(function()

	while true do
	
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local coords2 = GetEntityCoords(cn)
		local x,y,z = table.unpack(coords)
		local x2,y2,z2 = table.unpack(coords2)
		
		if g then
			DrawText3Ds(x,y,z+1, gg)
			DrawText3Ds(x2,y2,z2+1, gg)
		end 
		
		Citizen.Wait(1)
	end
	
end)

