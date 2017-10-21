util.AddNetworkString("liro_SendChat")
util.AddNetworkString("liro_OverlayText")
util.AddNetworkString("liro_SendSound")
util.AddNetworkString("liro_getPost")
util.AddNetworkString("liro_getPosts")
util.AddNetworkString("liro_changeTeam")
util.AddNetworkString("liro_changeClass")
util.AddNetworkString("requestUpdate_Posts")
util.AddNetworkString("liro_HitMarker")

local combinePainSounds = {	
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
}

local deathSounds = {
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}

local painSounds = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav"
}

local combineDeathSounds = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
}

local combineOtherDeath = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
}



GM.posts = {}

function sendPosts(ply)
	net.Start("liro_getPosts")
		net.WriteTable(GAMEMODE.posts)

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function updatePost(ent,ply)
	if not IsValid(ent) then return end
	local pos = ent:GetPos() + ent:GetUp()*30 + ent:GetForward()*1
	local num = #GAMEMODE.posts+1
	local combine = ent:GetNWInt("team",1) == 1 and true or false
	local taking = ent:GetNWBool("taking",false) 
	local pos = ent:GetPos() + ent:GetUp()*50 + ent:GetForward()*1
	local num = ent:GetNWInt("cnum",0)
	local taking = ent:GetNWBool("taking",false) 

	local time = timer.Exists(ent:EntIndex() .. "_CheckpointTimer")

	if time then
		time = ent:GetNWInt("time",0)
	end
	ent.time = time or 1
 
	local t = {}
	t.pos = pos
	t.team = ent:GetNWInt("team",1)
	t.taking = taking
	t.time = time
	t.ent = ent
	t.num = num

	GAMEMODE.posts[ent:EntIndex() or num] = t
	sendPosts(ply)
end


 
function updatePosts(ply)
	/*print("SPAWNING")
	for k,ent in pairs(ents.FindByClass("liro_checkpoint")) do
		if not IsValid(ent) then continue end 
		print("spawned ".. ent:EntIndex())
		updatePost(ent,ply)
	end
	*/
	GAMEMODE.posts = {}
	for k,ent in pairs(ents.FindByClass("liro_checkpoint")) do
		local pos = ent:GetPos() + ent:GetUp()*30 + ent:GetForward()*1
		local num = ent:GetNWInt("cnum",1)
		local taking = ent:GetNWBool("taking",false) 
		local time = timer.Exists(ent:EntIndex() .. "_CheckpointTimer")
		if time then
			time = ent:GetNWInt("time",0)
		end
		ent.time = time or 1
		local t = {}
		t.pos = pos
		t.team = ent:GetNWInt("team",1)
		t.taking = taking
		t.time = time
		t.ent = ent
		t.num = num
		GAMEMODE.posts[ent:EntIndex() or num] = t
	end
	sendPosts(ply)
end


 
 net.Receive("requestUpdate_Posts", function()
	local ply = net.ReadEntity()
	updatePosts(ply)
	//ply:ChatPrint("Update Sent!")
end)


 
local function getPainSounds(client)
	if client:getTeam() == TEAM_COMBINE then
		return combinePainSounds
	else
		return painSounds
	end
end

local function getDeathSounds(client)
	if client:getTeam() == TEAM_COMBINE then
		if client:getClass() == CLASS_SCOUT then
			return combineOtherDeath		
		else
			return combineDeathSounds
		end
	else
		return deathSounds
	end
end

function createCorpse(ply,attacker,dmginfo)
   if not IsValid(ply) then return end

   local rag = ents.Create("prop_ragdoll")
   if not IsValid(rag) then return nil end

   rag:SetSkin(ply:GetSkin())
   rag:SetPos(ply:GetPos())
   rag:SetModel(ply:GetModel())
   rag:SetAngles(ply:GetAngles())
   rag:SetColor(ply:GetColor())

   rag:Spawn()
   rag:Activate()

   -- nonsolid to players, but can be picked up and shot
   rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
   timer.Simple( 1, function() if IsValid( rag ) then rag:CollisionRulesChanged() end end )

   -- flag this ragdoll as being a player's
   rag.player_ragdoll = true
   rag.sid = ply:SteamID()

   rag.was_headshot = (ply.was_headshot and dmginfo:IsBulletDamage())

   -- position the bones
   local num = rag:GetPhysicsObjectCount()-1
   local v = ply:GetVelocity()

   -- bullets have a lot of force, which feels better when shooting props,
   -- but makes bodies fly, so dampen that here
   if dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_PREVENT_PHYSICS_FORCE) then
      v = v / 5
   end

   for i=0, num do
      local bone = rag:GetPhysicsObjectNum(i)
      if IsValid(bone) then
         local bp, ba = ply:GetBonePosition(rag:TranslatePhysBoneToBone(i))
         if bp and ba then
            bone:SetPos(bp)
            bone:SetAngles(ba)
         end

         -- not sure if this will work:
         bone:SetVelocity(v)
      end
   end
   timer.Simple(30, function()
   		if rag and rag:IsValid() then
   			rag:Remove()
   		end
   	end)

   return rag -- we'll be speccing this
end



local function CreateDeathEffect(ent, marked)
   local pos = ent:GetPos() + Vector(0, 0, 20)

   local jit = 35.0

   local jitter = Vector(math.Rand(-jit, jit), math.Rand(-jit, jit), 0)
   util.PaintDown(pos + jitter, "Blood", ent)

   if marked then
      util.PaintDown(pos, "Cross", ent)
   end
end
local digitsToWords = {
	[0] = "zero",
	[1] = "one",
	[2] = "two",
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven",
	[8] = "eight",
	[9] = "nine"
}


function makeDigits()
	local num1 = tostring(math.random(1,9))
	local num2 = tostring(math.random(1,9))
	local num3 = tostring(math.random(1,9))
	local num4 = tostring(math.random(1,9))
	local num5 = tostring(math.random(1,9))
	return num1..num2..num3..num4..num5
end
 
local combineSpawn = {Vector(-4952.781738, -3277.307617, 250.031250), Vector(-4951.808105, -3117.909668, 250.031250), Vector(-4951.205078, -3019.045410, 250.031250),
 Vector(-4950.080566, -2835.295410, 250.031250)}

function GM:PlayerSpawn(ply)
	ply:UnSpectate()
	updatePosts(ply) 
	if ply:IsBot() then
		ply:setTeam(math.random(1,2))
		ply:setClass(math.random(1,6))
	end
	local loadout = playerLoadout[ply:getTeam()][ply:getClass()]

	if loadout then
		if ply:getTeam() == TEAM_COMBINE then
			ply:SetModel(table.Random(loadout[3])) 
			ply:SetHealth(200)
			ply:SetWalkSpeed(200)
			ply:SetRunSpeed(250)
			ply:SetNWInt("origin_speed",200)
			ply:SetNWInt("origin_rspeed",250)
			ply:SetMaxHealth(200)
			ply:SetMaxArmor(loadout[1])
			ply:SetArmor(loadout[1])
			ply:SetNWString("digits", makeDigits())
			ply:SetPos(table.Random(combineSpawn))
			ply:SetPlayerColor( Vector( 1, 0, 0 ) )
		elseif ply:getTeam() == TEAM_REBELS then
			ply:SetModel(table.Random(loadout[3]))
			ply:SetHealth(200)
			ply:SetMaxHealth(200)
			ply:SetMaxArmor(loadout[1])
			ply:SetArmor(loadout[1])
			ply:SetNWInt("origin_speed",250) 
			ply:SetNWInt("origin_rspeed",300)
		end
		ply:SetNWInt("run_override",1)
		ply:SetNWBool("cripple_rleg",false)
		ply:SetNWBool("cripple_lleg",false)
		ply:SetNWBool("cripple_rarm",false)
		ply:SetNWBool("cripple_larm",false)
		ply:SetRun(1,true,true)
		if playerLoadout[ply:getTeam()] then
			for k,wep in pairs(loadout[2]) do
				ply:Give(wep)
			end
		end
		if loadout[4] then
			loadout[4](ply)
		end
	end
end 



function GM:PlayerInitialSpawn(ply)
	ply:setTeam(0)
	timer.Simple(10, function()
		updatePosts(ply) 
	end)
end 

function GM:PlayerHurt(client, attacker, health, damage)
	if ((client.nextPain or 0) < CurTime()) then
		local painSound = table.Random(getPainSounds(client))

		if (client:Female() and !painSound:find("female")) then
			painSound = painSound:gsub("male", "female")
		end

		client:EmitSound(painSound,110)
		client.nextPain = CurTime() + 0.33
	end
end

-- The GetFallDamage hook does not get called until around 600 speed, which is a
-- rather high drop already. Hence we do our own fall damage handling in
-- OnPlayerHitGround.
function GM:GetFallDamage(ply, speed)
   return 0
end

local fallsounds = {
   Sound("player/damage1.wav"),
   Sound("player/damage2.wav"),
   Sound("player/damage3.wav")
};

function GM:EntityTakeDamage( ent, dmginfo )
	if ent:IsPlayer() and dmginfo:GetInflictor():IsPlayer() and dmginfo:GetInflictor():IsValid() and dmginfo:GetInflictor() != NULL and dmginfo:GetInflictor() then
		if dmginfo:GetInflictor():GetActiveWeapon():GetClass() == "weapon_liro_spas12" or dmginfo:GetDamageType() == DMG_FALL or dmginfo:GetDamageType() == DMG_BLAST then
			local armor = ent:Armor()
			local dmg = dmginfo:GetDamage()
			local add_dmg = math.Clamp(armor,0,30)
			add_dmg = math.Clamp(add_dmg-math.random(1,8),0,30)
			local new_armor = math.Clamp(armor-add_dmg,0,255)

			ent:SetArmor(new_armor)
			dmginfo:SetDamage(dmg+add_dmg)
		end
	end
end

function GM:OnPlayerHitGround(ply, in_water, on_floater, speed)
   if in_water or speed < 450 or not IsValid(ply) then return end

   -- Everything over a threshold hurts you, rising exponentially with speed
   local damage = math.pow(0.05 * (speed - 420), 1.75)

   -- I don't know exactly when on_floater is true, but it's probably when
   -- landing on something that is in water.
   if on_floater then damage = damage / 2 end

   -- if we fell on a dude, that hurts (him)
   local ground = ply:GetGroundEntity()
   if IsValid(ground) and ground:IsPlayer() then
      if math.floor(damage) > 0 then
         local att = ply

         -- if the faller was pushed, that person should get attrib
         local push = ply.was_pushed
         if push then
            -- TODO: move push time checking stuff into fn?
            if math.max(push.t or 0, push.hurt or 0) > CurTime() - 4 then
               att = push.att
            end
         end

         local dmg = DamageInfo()

         if att == ply then
            -- hijack physgun damage as a marker of this type of kill
            dmg:SetDamageType(DMG_CRUSH + DMG_PHYSGUN)
         else
            -- if attributing to pusher, show more generic crush msg for now
            dmg:SetDamageType(DMG_CRUSH)
         end

         dmg:SetAttacker(att)
         dmg:SetInflictor(att)
         dmg:SetDamageForce(Vector(0,0,-1))
         dmg:SetDamage(damage)

         ground:TakeDamageInfo(dmg)
      end

      -- our own falling damage is cushioned
      damage = damage / 3
   end

   if math.floor(damage) > 0 then
      local dmg = DamageInfo()
      dmg:SetDamageType(DMG_FALL)
      dmg:SetAttacker(game.GetWorld())
      dmg:SetInflictor(game.GetWorld())
      dmg:SetDamageForce(Vector(0,0,1))
      dmg:SetDamage(damage)

      ply:TakeDamageInfo(dmg)

      -- play CS:S fall sound if we got somewhat significant damage
      if damage > 40 and ply:Alive() then
      	local prob = math.random(1,100)
      	local prob2 = math.random(1,100)
      //	print(prob,prob2)
      	if prob <= 60 and ply:GetNWBool("cripple_rleg",false) == false then
      		ply:SetNWBool("cripple_rleg",true)
			ply:SetRun(0.7,true)
			ply:chatMessage("Right leg crippled!")
		end
		if prob2 <= 60 and ply:GetNWBool("cripple_lleg",false) == false then
			ply:SetNWBool("cripple_lleg",true)
			ply:SetRun(0.7,true)	
			ply:chatMessage("Left leg crippled!")
		end


      elseif damage > 5 then
         sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
      end
   end
end

function GM:ScalePlayerDamage(ply, hit, dmginfo)
	if (hit == HITGROUP_RIGHTLEG or (dmginfo:GetDamageType() == DMG_BLAST and math.random(1,100)<50)) and !ply:GetNWBool("cripple_rleg",false)  then
		ply:SetNWBool("cripple_rleg",true)
		ply:SetRun(0.8,true)
		ply:chatMessage("Right leg crippled!")
		dmginfo:ScaleDamage( 0.30 )
	elseif (hit == HITGROUP_LEFTLEG or (dmginfo:GetDamageType() == DMG_BLAST and math.random(1,100)<50)) and !ply:GetNWBool("cripple_lleg",false) then
		ply:SetNWBool("cripple_lleg",true)
		ply:SetRun(0.8,true)	
		ply:chatMessage("Left leg crippled!")
		dmginfo:ScaleDamage( 0.30 )
	elseif (hit == HITGROUP_RIGHTARM or (dmginfo:GetDamageType() == DMG_BLAST and math.random(1,100)<20)) and !ply:GetNWBool("cripple_rarm",false) then
		ply:SetNWBool("cripple_rarm",true)
		ply:chatMessage("Right arm crippled!")
	elseif (hit == HITGROUP_LEFTARM or (dmginfo:GetDamageType() == DMG_BLAST and math.random(1,100)<20))and !ply:GetNWBool("cripple_larm",false) then
		ply:SetNWBool("cripple_larm",true)
		ply:chatMessage("Left arm crippled!")
	elseif hit == HITGROUP_GEAR then
		dmginfo:ScaleDamage( 0.15 )
	elseif ( hit == HITGROUP_HEAD ) then
		local play = dmginfo:GetAttacker()
		if play:IsPlayer() then
			local plyWep = play:GetActiveWeapon()
			if plyWep and IsValid(plyWep) and plyWep.HeadshotMultiplier then
				headshot = plyWep.HeadshotMultiplier
			end
		end		
		dmginfo:ScaleDamage( headshot )
	elseif ( hit == HITGROUP_CHEST ) then
		dmginfo:ScaleDamage( 1 )
	elseif ( hit == HITGROUP_STOMACH ) then
		dmginfo:ScaleDamage( 1.1 )
	end
	if dmginfo:GetAttacker() and dmginfo:GetAttacker():IsPlayer() then
		local kill = false
		if ply:Health()-dmginfo:GetDamage() <= 0 then
			kill = true 
		end
		net.Start("liro_HitMarker")
			net.WriteBool(kill)
		net.Send(dmginfo:GetAttacker())
	end
end

function GM:PlayerDeathSound()
	return true
end


function GM:DoPlayerDeath(ply, attacker, dmginfo)
	if ply:getTeam() == TEAM_UNSPEC then return end	
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.DyingShot and not ply.was_headshot and dmginfo:IsBulletDamage() then
    	local fired = wep:DyingShot()
		if fired then
			return
		end
 	end
 	local dissolve = false
 	if dmginfo:IsDamageType(DMG_DISSOLVE) then dissolve = true end
	for k, wep in pairs(ply:GetWeapons()) do

		ply:dropWeapon(wep, true, dissolve) -- with ammo in them
		if wep.DampenDrop then
			wep:DampenDrop()
		end
	end

	local rag = createCorpse(ply, attacker, dmginfo)
	ply.server_ragdoll = rag -- nil if clientside
	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		local bones = rag:GetPhysicsObjectCount()
					 
		for i=0,bones-1 do 
			rag:GetPhysicsObjectNum(i):EnableGravity(false)
		end
		rag:Dissolve()
	end
	CreateDeathEffect(ply, false)

	util.StartBleeding(rag, dmginfo:GetDamage(), 15)

end



function doCombineSound(ply)
	if ply:getTeam() != TEAM_COMBINE then return end
	local digits = ply:GetNWString("digits", "12345")
	local queue = {"npc/combine_soldier/vo/on".. math.random(1,2) ..".wav"}
	queue[#queue + 1] = "npc/overwatch/radiovoice/lostbiosignalforunit.wav"
	SendOverlayText("BIOSIGNAL LOSS FOR ".. classNames[ply:getClass()]:upper() .. " UNIT "..digits.."!", Color(180, 25, 0), {ply})
	if (tonumber(digits)) then
		for i = 1, #digits do
			local digit = tonumber(digits:sub(i, i))
			local word = digitsToWords[digit]
			queue[#queue + 1] = "npc/overwatch/radiovoice/"..word..".wav"
		end

		queue[#queue + 1] = table.Random( { "npc/overwatch/radiovoice/allunitsdeliverterminalverdict.wav", "npc/overwatch/radiovoice/reinforcementteamscode3.wav", "npc/overwatch/radiovoice/remainingunitscontain.wav", "npc/overwatch/radiovoice/completesentencingatwill.wav" })
		queue[#queue + 1] = {"npc/combine_soldier/vo/off".. math.random(1,3) ..".wav", nil, 0.25}

		for k, v in ipairs(player.GetAll()) do
			if (v:getTeam() == TEAM_COMBINE) and v != ply then
				emitQueuedSounds(v, queue, 2, nil, v == ply and 100 or 65)
				//v:chatMessage("COMBINE ".. classNames[ply:getClass()]:upper() .." UNIT ".. digits .. " HAS BEEN KILLED")
			end
		end
	end
end

local function punct(str)
	if str[1]:lower() == "a" or str[1]:lower() == "e" or str[1]:lower() == "i" or str[1]:lower() == "o" or str[1]:lower() == "u" then
		return "an ".. str
	end    
	return "a ".. str
end

function GM:PlayerDeath(client, inflictor, attacker)

	local deathSound = table.Random(getDeathSounds(client))

	if (client:Female() and !deathSound:find("female")) then
		deathSound = deathSound:gsub("male", "female")
	end
	sound.Play(deathSound or "",client:GetPos(), 150)

	doCombineSound(client)
	client:Freeze(false)
	//client:SetRagdollSpec(true)
	client:Spectate(OBS_MODE_IN_EYE) 

	local rag_ent = client.server_ragdoll or client:GetRagdollEntity()
	client:SpectateEntity(rag_ent)

	client:Flashlight(false)
	client:Extinguish()
	local text = ""
	if attacker and attacker:IsValid() and attacker:IsPlayer() then
		if attacker:getTeam() != client:getTeam() then
			attacker:AddKill()
		else
			attacker:TakeKill()
		end
		text = attacker:Nick() .. " [" .. teamNames[attacker:getTeam()]:upper() .. "]"
	elseif attacker and attacker:IsValid() and !attacker:IsPlayer() then
		text = attacker:GetClass()
	end
	local killer = IsValid(inflictor) and inflictor:GetClass() or "worldspawn"
	if killer:find("liro") then
		killer = inflictor.PrintName
		if tonumber(client:GetInfo("liro_death_class")) == 1 then
			killer = killer  .. " (".. killer .. ")"or killer
		end
	elseif killer == "player" and attacker:IsPlayer() and attacker != client then
		killer = attacker:GetActiveWeapon().PrintName
		if tonumber(client:GetInfo("liro_death_class")) == 1 then
			killer = killer  .. " (".. attacker:GetActiveWeapon():GetClass() .. ")"
		end
	end
	text = text .. " has killed ".. client:Nick() .. " [" .. teamNames[client:getTeam()]:upper() .. "] using ".. punct(killer)
	Msg("KILL: ".. text .. "\n")
	local col = Color(255,255,255)
	local killer2 = "The World"
	if attacker:IsPlayer() then
		if attacker:getTeam() == TEAM_COMBINE then
			col = Color(52, 152, 219)
		elseif attacker:getTeam() == TEAM_REBELS then
			col = Color(230, 126, 34)
		end
		killer2 = attacker:Nick()
		if attacker == client then
			killer2 = "yourself"
		end
	end
	client:AddDeath() 
	client:chatMessage("You were killed by ", col, killer2, color_white, " using ", Color(255, 0, 0), killer, color_white, "!")

	if attacker:IsPlayer() and attacker != client then
		if client:getTeam() == TEAM_COMBINE then
			col = Color(52, 152, 219)
		elseif client:getTeam() == TEAM_REBELS then
			col = Color(230, 126, 34)
		end
		attacker:chatMessage("You killed ", col, client:Nick(), color_white, " using ", Color(0, 255, 0), punct(killer), color_white, "!")
	end
end

function GM:PlayerFootstep(client, position, foot, soundName, volume)
	if true then
		if (client:getTeam() == TEAM_COMBINE) then
			client:EmitSound("npc/combine_soldier/gear"..math.random(1, 6)..".wav", volume * 150)

			return true
		end
	end
end


function SendRebelMessage(str)
	if SERVER then
		for k,ply in pairs(player.GetAll()) do
			if ply:getTeam() != TEAM_REBELS then continue end
			ply:chatMessage(str)
			ply:SendSound("common/warning.wav")
		end
	end
end
 

function GM:InitPostEntity()
	for k,v in pairs(ents.FindByClass([[liro_*]])) do v:Remove() end 
	for k,v in pairs(ents.FindByClass([[prop_*]])) do if v.liro then v:Remove() end end
	local ent = ents.Create("liro_checkpoint")
	ent:SetAngles(Angle(0, 0, 0.000000))
	ent:SetPos(Vector(-5220.968750, -2880.375000, 255.031250))
	ent:Spawn() 
	ent.monitor:SetAngles(Angle(0, 0, 0))
	ent:Activate()   

	local ent = ents.Create("liro_checkpoint")
	ent:SetAngles(Angle(0, 180, 0))
	ent:SetPos(Vector(1095.637207, 844.617249, -143.968750))
	ent:Spawn()
	ent.monitor:SetAngles(Angle(0, 180, 0))
	ent:Activate()  
	ent:SetNWInt("team", TEAM_REBELS)  

	local ent = ents.Create("liro_ammo")
	ent:SetAngles(Angle(0, 180, 0))
	ent:SetPos(Vector(1099.637207, 753.617249, -128.968750))
	ent:SetNWString("ammotype","smg1") 
	ent:Spawn()
	ent:Activate() 

	local ent = ents.Create("liro_ammo")
	ent:SetAngles(Angle(0, 00, 0)) 
	ent:SetPos(Vector(-5230.968750, -2800.375000, 272.031250))  
	ent:SetNWString("ammotype","ar2") 
	ent:Spawn()
	ent:Activate() 
   

   local clamp = ents.Create('prop_physics')
	clamp:SetModel('models/props_combine/combine_barricade_short01a.mdl')
	clamp:SetPos(Vector(-4922.200684, -2539.285889, 290.000000))
	clamp:SetAngles(Angle(0, 45, 0))
	clamp:Spawn()
	clamp:DropToFloor()
	clamp.liro = true

		-- Freeze it.
	if IsValid(clamp:GetPhysicsObject()) then
		clamp:GetPhysicsObject():EnableMotion(false)
	end

	local ent2 = ents.Create("liro_ar3")
	ent2:SetPos(clamp:GetPos() + clamp:GetUp()*10 - clamp:GetForward()*4)
	ent2:SetAngles(clamp:GetAngles())
	ent2:SetParent(ent) -- parent it to the clamp. 
	ent2:Spawn()
	//ent2:Activate()
	ent2:SetMaxHealth(1000)
	ent2:SetHealth(1000)
	ent2:SetNWEntity("clamp",ent)
	clamp:SetNWEntity("gun",ent2)
	clamp:DeleteOnRemove(ent2)
  

 
end 

 
function GM:ShowTeam(ply)
	ply:ConCommand("gm_openspawnmenu")
end
 


 ---- Weapon switching
local function ForceWeaponSwitch(ply, cmd, args)
   if not ply:IsPlayer() or not args[1] then return end
   -- Turns out even SelectWeapon refuses to switch to empty guns, gah.
   -- Worked around it by giving every weapon a single Clip2 round.
   -- Works because no weapon uses those.
   local wepname = args[1]
   if not wepname then return end
   if not ply.SelectWeapon then return end
   local wep = ply:GetWeapon(wepname)
   if IsValid(wep) then
      -- Weapons apparently not guaranteed to have this
     // if wep.SetClip2 then
        // wep:SetClip2(1)
     // end
      ply:SelectWeapon(wepname)
   end
end
concommand.Add("wepswitch2", ForceWeaponSwitch)

function GM:Think()
	local count = #ents.FindByClass("weapon_*")
	for k,ent in ipairs(ents.FindByClass("weapon_*")) do
		if !ent.Owner then
			if count > 30 then
				//ent:Remove()
			end
		end
	end
end