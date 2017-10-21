if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "Shotgun"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "SPAS-12" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 24
SWEP.Primary.MaxClip = 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "Buckshot"
SWEP.HeadshotMultiplier = 1.5
SWEP.EmptySound = "Weapon_Shotgun.Empty"

SWEP.Primary.Damage			= 12

SWEP.Primary.Cone			= 0.06
SWEP.Primary.Delay			= 1.2
SWEP.Primary.NumShots		= 7
SWEP.Primary.Recoil			= 4
SWEP.Primary.Sound = Sound("Weapon_Shotgun.NPC_Single")
SWEP.Secondary.Sound = Sound("Weapon_Shotgun.Double")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.Cone			= 0.08
SWEP.Secondary.Delay		= 1.2
SWEP.Secondary.NumShots		= 12
SWEP.Secondary.Recoil		= 6

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-4.8, -9.2, 3)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)


SWEP.reloadtimer = 0

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "reloading")
	return self.BaseClass.SetupDataTables(self)
end

function SWEP:Reload()
	self:SetIronsights( false )

	if self.dt.reloading then return end
	if not IsFirstTimePredicted() then return end

	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
		if self:StartReload() then
			return
		end
	end
end

function SWEP:StartReload()
	if self.dt.reloading then
		return false
	end

	if not IsFirstTimePredicted() then return false end

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	local ply = self.Owner

	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then 
		return false
	end

	local wep = self.Weapon

	if wep:Clip1() >= self.Primary.ClipSize then
		return false
	end

	wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self.reloadtimer =  CurTime() + wep:SequenceDuration()
	self.dt.reloading = true
	return true
end

function SWEP:PerformReload()
	local ply = self.Owner

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end

	local wep = self.Weapon

	if wep:Clip1() >= self.Primary.ClipSize then return end

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self.Weapon:SetClip1( self.Weapon:Clip1() + 1 )

	wep:SendWeaponAnim(ACT_VM_RELOAD)
	self:EmitSound("Weapon_Shotgun.Reload")

	self.reloadtimer = CurTime() + wep:SequenceDuration()
end

function SWEP:FinishReload()
	self.dt.reloading = false

	local wep = self.Weapon
	wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	timer.Create("pump", 0.2, 1, function() self:Pump() end)
	self.reloadtimer = CurTime() + wep:SequenceDuration() + 0.2
end

function SWEP:Pump()
	self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
	if SERVER then self:EmitSound("/weapons/shotgun/shotgun_cock.wav", 40, 100, 1, CHAN_AUTO) end
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 then
		self:EmitSound("/weapons/shotgun/shotgun_empty.wav")
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
		return false
	end
	return true
end

function SWEP:CanSecondaryAttack()
	if self.Weapon:Clip1() <= 1 then
		self:EmitSound("/weapons/shotgun/shotgun_empty.wav")
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
		return false
	end
	return true
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	if not self:CanPrimaryAttack() then return end

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	local cone = self.Primary.Cone
	local bullet = {}
		bullet.Num       = self.Primary.NumShots
		bullet.Src       = self.Owner:GetShootPos()
		bullet.Dir       = self.Owner:GetAimVector()
		bullet.Spread    = Vector( cone, cone, 0 )
		bullet.Tracer    = 1
		bullet.Force     = 10
		bullet.Damage    = self.Primary.Damage
		bullet.TracerName = self.Tracer

	self.Owner:FireBullets(bullet)

	self:TakePrimaryAmmo(1)
	self:EmitSound(self.Primary.Sound)
	timer.Create("pump", 0.2, 1, function() self:Pump() end)

	if self.Owner:IsValid() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		if CLIENT and IsFirstTimePredicted() then
			local eyeang = self.Owner:EyeAngles()
			eyeang.pitch = eyeang.pitch - self.Primary.Recoil
			self.Owner:SetEyeAngles(eyeang)
		end
		self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0 ) )
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	if not self:CanSecondaryAttack() then return end

	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	
	local cone = self.Secondary.Cone
	local bullet = {}
		bullet.Num       = self.Secondary.NumShots
		bullet.Src       = self.Owner:GetShootPos()
		bullet.Dir       = self.Owner:GetAimVector()
		bullet.Spread    = Vector( cone, cone, 0 )
		bullet.Tracer    = 1
		bullet.Force     = 20
		bullet.Damage    = self.Primary.Damage
		bullet.TracerName = self.Tracer

	self.Owner:FireBullets(bullet)

	self:TakePrimaryAmmo(2)
	self:EmitSound(self.Secondary.Sound)
	timer.Create("pump", 0.5, 1, function() self:Pump() end)

	if self.Owner:IsValid() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		if CLIENT and IsFirstTimePredicted() then
			local eyeang = self.Owner:EyeAngles()
			eyeang.pitch = eyeang.pitch - self.Secondary.Recoil
			self.Owner:SetEyeAngles(eyeang)
		end
		self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Secondary.Recoil, math.Rand(-0.1,0.1) * self.Secondary.Recoil, 0 ) )
	end
end

function SWEP:Think()
	if self.dt.reloading and IsFirstTimePredicted() then
		if self.Owner:KeyDown(IN_ATTACK) then
		self:FinishReload()
		return
		end

		if self.reloadtimer <= CurTime() then

		if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
			self:FinishReload()
			elseif self.Weapon:Clip1() < self.Primary.ClipSize then
			self:PerformReload()
			else
			self:FinishReload()
			end
			return            
		end
	end
end

function SWEP:Deploy()
	self.dt.reloading = false
	self.reloadtimer = 0
	return self.BaseClass.Deploy(self)
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	local att = dmginfo:GetAttacker()
	if not att:IsValid() then return 3 end

	local dist = victim:GetPos():Distance(att:GetPos())
	local d = math.max(0, dist - 140)

	-- decay from 3.1 to 1 slowly as distance increases
	return 1 + math.max(0, (2.1 - 0.002 * (d ^ 1.25)))
end

function SWEP:OnRemove()
	timer.Stop("anim")
end