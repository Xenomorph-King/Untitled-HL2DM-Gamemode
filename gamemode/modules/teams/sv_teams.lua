net.Receive("liro_changeTeam", function()
	local ply = net.ReadEntity()
	local t = net.ReadBool() and 1 or 2

	ply:setTeam(t)
	ply:setClass(0)
	ply:KillSilent()
	//ply:chatMessage("You are now playing as the ".. teamNames[t])
end)  

net.Receive("liro_changeClass", function()
	local ply = net.ReadEntity()
	local t = net.ReadUInt(16) or 1
	ply:setClass(t)
	ply:chatMessage("You are now playing as a ".. classNames[t].."!")
	if ply:Alive() then ply:KillSilent() end
	timer.Simple(0, function()
		ply:Spawn()
	end)
end)  