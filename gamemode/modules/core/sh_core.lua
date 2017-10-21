local plymeta = FindMetaTable("Player")

game.AddAmmoType( {
	name = "smokegrenade",
	dmgtype = DMG_BLAST,
	tracer = TRACER_LINE,
	maxcarry = 12,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

if CLIENT then
	local function message(t)
		chat.AddText(Color(255,100,0), "[LIRO] ", color_white, unpack(t))
	end

	net.Receive("liro_SendChat", function()
		local t = net.ReadTable()
		message(t)
	end)

	net.Receive("liro_SendSound", function()
		local snd = net.ReadString() or ""
		surface.PlaySound(snd)
	end)
end

if SERVER then 
	concommand.Add("noclip2", function(ply,cmd,args)
		if ply:GetMoveType() != MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_NOCLIP)
		else
			ply:SetMoveType(MOVETYPE_WALK)
		end
	end)
end

function gDev()
	return player.GetBySteamID("STEAM_0:0:30088168")
end

function plymeta:chatMessage(...)
	if SERVER then
		net.Start("liro_SendChat")
			net.WriteTable({...})
		net.Send(self)
		//print(...)
	else
		message({...})
	end
end

function plymeta:Female()
	if self:getTeam() != TEAM_REBELS then return false end
	if string.find(self:GetModel(),"female") then
		return true
	end
	return false
end


if SERVER then

	function GlobalChatMessage(...)
		net.Start("liro_SendChat")
			net.WriteTable({...})
		net.Broadcast()
	end

	function plymeta:SetRun(rat,override,reset)
		rat = rat or 1
		rat = rat*self:GetNWInt("run_override",1)
		
		self:SetWalkSpeed(self:GetNWInt("origin_speed",200)*rat)
		self:SetRunSpeed(self:GetNWInt("origin_rspeed",250)*rat)
		if override then
			self:SetNWInt("run_override",rat)
		end
		if reset then
			self:SetNWInt("run_override",1)
			self:SetWalkSpeed(self:GetNWInt("origin_speed",200))
			self:SetRunSpeed(self:GetNWInt("origin_rspeed",250))
		end
	end

end

local entmeta = FindMetaTable( "Entity" )	
function entmeta:Dissolve()
	if self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
	dissolver:SetPos( self:LocalToWorld(self:OBBCenter()) )
	dissolver:SetKeyValue( "dissolvetype", 0 )
	dissolver:Spawn()
	dissolver:Activate()
	
	local name = "Dissolving_"..math.random()
	self:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	dissolver:Fire( "Kill", self, 0.10 )
	
end

function plymeta:dropWeapon(wep,deathdrop,dissolve)
	if IsValid(self) and IsValid(wep) then
		if wep.PreDrop then
			wep:PreDrop(death_drop)
		end
		if wep:GetClass() == "weapon_liro_crowbar" then wep:Remove() return end

		if not IsValid(wep) then return end

		wep.IsDropped = true
		if !dissolve then
			self:DropWeapon(wep)
		else
			if SERVER then
				local ent = ents.Create("prop_physics")
				local mdl = weapons.GetStored( wep:GetClass() ).WorldModel
				ent:SetModel(mdl)
				ent:SetPos(self:GetShootPos())
				ent:Spawn()
				timer.Simple(0, function()
					ent:GetPhysicsObject():EnableGravity(false)
					ent:GetPhysicsObject():SetVelocity(Vector(math.random(50,150),math.random(50,150),math.random(50,150)))
					ent:Dissolve()
				end)
			end
		end

		wep:PhysWake()

		//ply:SelectWeapon("weapon_ttt_unarmed")
	end
end

function util.PaintDown(start, effname, ignore)
   local btr = util.TraceLine({start=start, endpos=(start + Vector(0,0,-256)), filter=ignore, mask=MASK_SOLID})

   util.Decal(effname, btr.HitPos+btr.HitNormal, btr.HitPos-btr.HitNormal)
end

local function DoBleed(ent)
   if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror())) then
      return
   end

   local jitter = VectorRand() * 30
   jitter.z = 20

   util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
end

-- Something hurt us, start bleeding for a bit depending on the amount
function util.StartBleeding(ent, dmg, t)
   if dmg < 5 or not IsValid(ent) then
      return
   end

   if ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror()) then
      return
   end

   local times = math.Clamp(math.Round(dmg / 15), 1, 20)

   local delay = math.Clamp(t / times , 0.1, 2)

   if ent:IsPlayer() then
      times = times * 2
      delay = delay / 2
   end

   timer.Create("bleed" .. ent:EntIndex(), delay, times,
                function() DoBleed(ent) end)
end

local ADJUST_SOUND = SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/"

function emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
	-- Let there be a delay before any sound is played.
	delay = delay or 0
	spacing = spacing or 0.1

	-- Loop through all of the sounds.
	for k, v in ipairs(sounds) do
		local postSet, preSet = 0, 0

		-- Determine if this sound has special time offsets.
		if (type(v) == "table") then
			postSet, preSet = v[2] or 0, v[3] or 0
			v = v[1]
		end

		-- Get the length of the sound.
		local length = SoundDuration(ADJUST_SOUND..v)
		-- If the sound has a pause before it is played, add it here.
		delay = delay + preSet

		-- Have the sound play in the future.
		timer.Simple(delay, function()
			-- Check if the entity still exists and play the sound.
			if (IsValid(entity)) then
				entity:EmitSound(v, volume, pitch)
			end
		end)

		-- Add the delay for the next sound.
		delay = delay + length + postSet + spacing
	end

	-- Return how long it took for the whole thing.
	return delay
end

local vectorLength2D = FindMetaTable("Vector").Length2D

function plymeta:isRunning()
	return vectorLength2D(self.GetVelocity(self)) > (self.GetWalkSpeed(self) + 10)
end

function plymeta:SetMaxArmor(num)
	self:SetNWInt("maxarmor", num)
end 

function plymeta:GetMaxArmor()
	return self:GetNWInt("maxarmor", 255)
end

if SERVER then

	function SendOverlayText(txt, col, blacklist)
		local tb = {}
		blacklist = blacklist or {}
		for k,v in pairs(player.GetAll()) do
			if v:getTeam() == TEAM_COMBINE and not table.HasValue(blacklist, v) then
				table.insert(tb, v)
			end
		end
		net.Start("liro_OverlayText")
			net.WriteTable({txt,col})
		net.Send(tb)
	end

end
function plymeta:OverlayText( txt, col )
	net.Start("liro_OverlayText")
		net.WriteTable( {txt, col} )
	net.Send(self)
end

function plymeta:SetKills( num )
	self:SetNWInt("kills", num)
end

function plymeta:GetKills()
	return self:GetNWInt("kills",0)
end

function plymeta:AddKill(num)
	num = num or 1
	self:SetKills(self:GetKills()+num)
end

function plymeta:TakeKill(num)
	num = num and -1*num or -1
	self:AddKill(num) 
end

function plymeta:SetDeath( num )
	self:SetNWInt("deaths", num)
end

function plymeta:GetDeaths()
	return self:GetNWInt("deaths",0)
end

function plymeta:AddDeath(num)
	num = num or 1
	self:SetDeath(self:GetDeaths()+num)
end

function plymeta:TakeDeath(num)
	num = -num or -1
	self:AddDeath(num)
end

if SERVER then
	function plymeta:SendSound(snd)
		net.Start("liro_SendSound")
			net.WriteString(snd)
		net.Send(self)
	end
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if not IsValid(wep) or not IsValid(ply) then return end
	if !ply:Alive() then return false end

 	local plywep = ply:GetWeapon(wep:GetClass())
 	local tookammo = false
 	local slotTable = {}

 	for k,ent in pairs(ply:GetWeapons()) do
 		if not ent or not IsValid(ent) then continue end
 		slotTable[ent.Slot] = (slotTable[ent.Slot] or 0) + 1
 	end
 	if slotTable[wep.Slot] and slotTable[wep.Slot] >= 2 and !ply:HasWeapon(wep:GetClass()) then
		return
	end
 	//PrintTable(slotTable)
	if plywep and plywep:IsValid() then
		local add = wep.StoredAmmo or wep.Primary.DefaultClip
		local max = wep.Primary.MaxClip-wep.Primary.ClipSize
		local plyamm = plywep:Ammo1()

		if plyamm+add > max then
			add = max-plyamm
		end
		if add != 0 then tookammo = true end
		ply:GiveAmmo(add,wep:GetPrimaryAmmoType())
   	  
		if wep.StoredAmmo2 then
			add = wep.StoredAmmo2 or wep.Secondary.DefaultClip
			max = wep.Secondary.MaxClip or 3
			plyamm = plywep:Ammo2()+plywep:Clip2()
			if wep:GetClass() == "weapon_liro_ar2" then
				max = 3
			end

			if plyamm+add > max then
				add = max-plyamm
			end
			if add != 0 then tookammo = true end

			ply:GiveAmmo(add,wep:GetSecondaryAmmoType())
		end
		if tookammo then
			wep:Remove()
		end
		return false
   end



	local tr = util.TraceEntity({start=wep:GetPos(), endpos=ply:GetShootPos(), mask=MASK_SOLID}, wep)
	if tr.Fraction == 1.0 or tr.Entity == ply then
		wep:SetPos(ply:GetShootPos())
	end
	return true
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
concommand.Add("wepswitch", ForceWeaponSwitch)

function GM:PlayerNoClip( pl, on )
	
	-- Don't allow if player is in vehicle
	if ( !IsValid( pl ) || pl:InVehicle() || !pl:Alive() ) then return false end
	
	-- Always allow to turn off noclip, and in single player
	if ( !on || game.SinglePlayer() ) then return true end

	return pl:IsSuperAdmin()
	
end