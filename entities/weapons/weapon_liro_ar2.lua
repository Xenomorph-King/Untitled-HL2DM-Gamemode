if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "AR2"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "AR2" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_irifle.mdl"
SWEP.WorldModel			= "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.MaxClip = 300
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AR2"
SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1
SWEP.HeadshotMultiplier = 1.5
SWEP.Combine = true
SWEP.EmptySound = "Weapon_AR2.Empty"

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.01
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = Sound("Weapon_AR2.NPC_Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.MaxClip = 2
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "AR2AltFire"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-4.8, -9.2, 3)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)



function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 1.1 )
	if self:Clip2() == 0 and self:Ammo2() > 0 then
		self:SetClip2(1)
		self.Owner:SetAmmo(self:Ammo2()-1,"AR2AltFire")
	end
	if self:Clip2() <= 0 then
		self:EmitSound("Weapon_SMG1.Empty")
		return
	end
	self:EmitSound("weapons/cguard/charging.wav")
	timer.Simple(1, function() 
		if !IsValid(self) or !IsValid(self.Owner) then return end
		if self.Owner:GetActiveWeapon() != self then return end
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self:SetNextSecondaryFire( CurTime() + 3 )
		self:EmitSound("weapons/irifle/irifle_fire2.wav")
		if SERVER then
			self:TakeSecondaryAmmo(1)
			if self:Ammo2() > 0 then
				self:SetClip2(1)
				self.Owner:SetAmmo(self:Ammo2()-1,"AR2AltFire")
			end
			local ent = ents.Create( "liro_cball")	

			local Forward = self.Owner:EyeAngles():Forward()
			--ent:SetPos( self.Owner:GetViewModel():GetAttachment(2).Pos + Forward * 0 )
			ent:SetPos( self.Owner:GetShootPos() + Forward * 1 )
			ent:SetAngles (self.Owner:EyeAngles())
			ent:SetNWEntity("own",self.Owner)
			ent:Spawn()
			
			local phys = ent:GetPhysicsObject()
			local vel = math.min(800, (90) * 40)
	   		local thr = self.Owner:EyeAngles():Forward() * vel * 2		
			phys:ApplyForceCenter( thr )
		end
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - 10
		self.Owner:SetEyeAngles( eyeang )
	end)
end

if CLIENT then
	function SWEP:DrawHUD()
		local length = 40
		local gap = 10

		surface.SetDrawColor(0, 255, 0, 200)

		local x = ScrW()/1.25-63
		local y = ScrH() / 1.2

		if self:Ammo2() then
			local ammo = self:Ammo2() + self:Clip2()
			y = y
			local size = 54
			local w, h = ScrW()/6.2, 60
			if 1 > 0 then
				surface.SetDrawColor(44, 62, 80, 200)
				surface.DrawRect(x,y, 60, 200)
				y = y+2*(size+3)
				for i=0,2 do
					surface.SetDrawColor(255, 255, 255, i < ammo and 255 or 25)
					surface.SetMaterial(Material("vgui/cball.png"))
					surface.DrawTexturedRect(x+3, y-i*(size+3), size,size)
				end
			end
		end
		self.BaseClass.DrawHUD(self)
	end
end

/*
if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "AR2"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "AR2" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_irifle.mdl"
SWEP.WorldModel			= "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.MaxClip = 300
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AR2"
SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1
SWEP.HeadshotMultiplier = 1.5
SWEP.Combine = true
SWEP.EmptySound = "Weapon_AR2.Empty"

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.01
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = Sound("Weapon_AR2.NPC_Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.MaxClip = 2
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "AR2AltFire"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-4.8, -9.2, 3)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)


local ent = FindMetaTable("Weapon")
local old_func = ent.SetClip2 

function ent:SetClip2(num)
	PrintTable(debug.getinfo(2))
	old_func(self,num)
end

local vLaunch = Vector(500, 500, 500)
local cFlash = Color(255, 255, 255, 64)
local sk_weapon_ar2_alt_fire_radius = GetConVar("sk_weapon_ar2_alt_fire_radius")
local sk_weapon_ar2_alt_fire_duration = GetConVar("sk_weapon_ar2_alt_fire_duration")
local sk_weapon_ar2_alt_fire_mass = GetConVar("sk_weapon_ar2_alt_fire_mass")

function SWEP:GetShootAngles(iIndex)
	local pPlayer = self:GetOwner() 
	
	return pPlayer:EyeAngles() + pPlayer:GetViewPunchAngles()
end

function SWEP:GetShootDir(iIndex)
	return self:GetShootAngles(iIndex):Forward()
end

function SWEP:GetShootSrc(iIndex)
	return self:GetOwner():GetShootPos()
end

if SERVER then
	local ENTITY = FindMetaTable("Entity")
	function ENTITY:_SetAbsVelocity(vAbsVelocity)
		if (self:GetInternalVariable("m_vecAbsVelocity") ~= vAbsVelocity) then
			// The abs velocity won't be dirty since we're setting it here
			self:RemoveEFlags(EFL_DIRTY_ABSVELOCITY)
			
			// All children are invalid, but we are not
			local tChildren = self:GetChildren()
				
			for i = 1, #tChildren do
				tChildren[i]:AddEFlags(EFL_DIRTY_ABSVELOCITY)
			end
			
			self:SetSaveValue("m_vecAbsVelocity", vAbsVelocity)
			
			// NOTE: Do *not* do a network state change in this case.
			// m_vVelocity is only networked for the player, which is not manual mode
			local pMoveParent = self:GetMoveParent()
			
			if (pMoveParent:IsValid()) then
				// First subtract out the parent's abs velocity to get a relative
				// velocity measured in world space
				// Transform relative velocity into parent space
				--self:SetSaveValue("m_vecVelocity", (vAbsVelocity - pMoveParent:_GetAbsVelocity()):IRotate(pMoveParent:EntityToWorldTransform()))
				self:SetSaveValue("velocity", vAbsVelocity)
			else
				self:SetSaveValue("velocity", vAbsVelocity)
			end
		end
	end
end


function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 1.1 )
	if self:Clip2() == 0 and self:Ammo2() > 0 then
		self:SetClip2(1)
		self.Owner:SetAmmo(self:Ammo2()-1,"AR2AltFire")
	end
	if self:Clip2() <= 0 then
		self:EmitSound("Weapon_SMG1.Empty")
		return
	end
	self:EmitSound("weapons/cguard/charging.wav")
	timer.Simple(1, function() 
		if !IsValid(self) or !IsValid(self.Owner) then return end
		if self.Owner:GetActiveWeapon() != self then return end
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self:SetNextSecondaryFire( CurTime() + 3 )
		self:EmitSound("weapons/irifle/irifle_fire2.wav")
		local pPlayer = self:GetOwner()
		
		if (SERVER) then
			pPlayer:ScreenFade(SCREENFADE.IN, cFlash, 0.1, 0)
			
			// Create the grenade
			local pBall = ents.Create("prop_combine_ball")
			
			if (pBall:IsValid()) then
				pBall:SetSaveValue("m_flRadius", sk_weapon_ar2_alt_fire_radius:GetFloat())
				
				pBall:SetPos(self:GetShootSrc(iIndex))
				pBall:SetOwner(pPlayer)
				
				local vVelocity = self:GetShootDir(iIndex)
				vVelocity:Mul(1000)
				pBall:_SetAbsVelocity(vVelocity)
				pBall:Spawn() 
				
				local flTime = CurTime()
				pBall:SetSaveValue("m_flLastCaptureTime", flTime)
				pBall:SetSaveValue("m_nState", 2) -- STATE_THROWN
				pBall:SetSaveValue("m_flSpeed", vVelocity:Length())
				
				pBall:EmitSound("NPC_CombineBall.Launch")
				
				local pPhysObj = pBall:GetPhysicsObject()
				
				if (pPhysObj:IsValid()) then
					pPhysObj:AddGameFlag(FVPHYSICS_WAS_THROWN)
					pPhysObj:SetMass(sk_weapon_ar2_alt_fire_mass:GetFloat())
					pPhysObj:SetInertia(vLaunch)
				end
				
				-- WizzSoundThink seems to be set automatically, luckily!
				-- Otherwise, the entity would have to be pseudo-simulated by a grav gun
				-- And have all the values reset
				
				local sName = "GS-Weapons-HL2-Combine Ball Explode-" .. pBall:EntIndex()
				flTime = flTime + sk_weapon_ar2_alt_fire_duration:GetFloat()
				
				hook.Add("Tick", sName, function()
					if (not (pBall:IsValid() and pBall:GetSaveTable()["m_nState"] == 2)) then
						hook.Remove("Tick", sName)
					elseif (flTime <= CurTime()) then
						pBall:Fire("Explode")
						hook.Remove("Tick", sName)
					end
				end)
				
				pBall:SetSaveValue("m_bWeaponLaunched", true)
			end
		end
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - 10
		self.Owner:SetEyeAngles( eyeang )
	end)
end

if CLIENT then
	function SWEP:DrawHUD()
		local length = 40
		local gap = 10

		surface.SetDrawColor(0, 255, 0, 200)

		local x = ScrW()/1.25-63
		local y = ScrH() / 1.2

		if self:Ammo2() then
			local ammo = self:Ammo2() + self:Clip2()
			y = y
			local size = 54
			local w, h = ScrW()/6.2, 60
			if 1 > 0 then
				surface.SetDrawColor(44, 62, 80, 200)
				surface.DrawRect(x,y, 60, 200)
				y = y+2*(size+3)
				for i=0,2 do
					surface.SetDrawColor(255, 255, 255, i < ammo and 255 or 25)
					surface.SetMaterial(Material("vgui/cball.png"))
					surface.DrawTexturedRect(x+3, y-i*(size+3), size,size)
				end
			end
		end
	end
end

*/ 