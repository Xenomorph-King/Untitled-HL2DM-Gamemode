AnnouncedNotEnough = false
function util.SafeRemoveHook(event, name)
   local h = hook.GetTable()
   if h and h[event] and h[event][name] then
      hook.Remove(event, name)
   end
end

local function CleanUp() // borrowed from TTT
	game.CleanUpMap()
	GAMEMODE:InitPostEntity()

	-- Strip players now, so that their weapons are not seen by ReplaceEntities
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:StripWeapons()
			v:KillSilent()
			v:setTeam(TEAM_UNSPEC)
			v:setClass(CLASS_UNSPEC)
			v:SetKills(0)
			v:SetDeath(0)
			timer.Simple(0.1, function()
				v:ConCommand("gm_openspawnmenu")
			end)
		end
	end

	-- a different kind of cleanup
	util.SafeRemoveHook("PlayerSay", "ULXMeCheck")
end

function GM:RoundStart()
	SetGlobalInt("round_time",CurTime()+RoundTime)
	SetGlobalInt("round_state",ROUND_ACTIVE)
	timer.Create("LIRO_RoundTimer", RoundTime, 1, function()
		self:RoundEnd()
	end)
end

function GM:CheckPlayers()
	timer.Simple(2, function()
		self:RoundPrep()	
	end)
end


function GM:RoundPrep()
	if #player.GetAll() < 2 then
		self:CheckPlayers()
		if !AnnouncedNotEnough then
			GlobalChatMessage("Not enough users!")
			AnnouncedNotEnough = true
		end
		SetGlobalInt("round_state",ROUND_WAIT) 
		return
	end
	self.AnnouncedNotEnough = false
	CleanUp()
	local round = GetGlobalInt("round_limit",6)
	round = round - 1
	if round <= 1 then
		SetGlobalBool("round_last", true)
	end
	if timer.Exists("LIRO_RoundTimer") then
		timer.Remove("LIRO_RoundTimer")
	end
	SetGlobalInt("round_limit",round)
	SetGlobalInt("round_time",CurTime()+RoundPrepTime)
	SetGlobalInt("round_state",ROUND_PREP)
	timer.Create("LIRO_RoundTimer", RoundPrepTime, 1, function()
		self:RoundStart()
	end)
end

function GM:RoundEnd()
	SetGlobalInt("round_time",CurTime()+RoundPrepTime)
	SetGlobalInt("round_state",ROUND_END)
	timer.Create("LIRO_RoundTimer", RoundPrepTime, 1, function()
		self:RoundPrep()
	end)
end


