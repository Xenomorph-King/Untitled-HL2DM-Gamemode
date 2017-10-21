if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "Grenade"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Smoke Grenade" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.MaxClip = 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "smokegrenade"

SWEP.HeadshotMultiplier = 1.5

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = Sound("Weapon_Grenade.Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false 

SWEP.Slot			= 4
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ProjectileEntity = "liro_grenade_smoke"
SWEP.NoSights = true

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:EmitSound("/weapons/ar2/ar2_altfire.wav")
	self:TakePrimaryAmmo(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	if (CLIENT) then return end
	self:Throw(20)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:EmitSound("/weapons/ar2/ar2_altfire.wav")
	self:TakePrimaryAmmo(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	if (CLIENT) then return end
	self:Throw(8)
end

function SWEP:Throw( shotPower )
	local tr = self.Owner:GetEyeTrace()
	local ply = self.Owner

	if (not SERVER) then return end

	local ent = ents.Create( "liro_grenade_smoke" )	

	local Forward = self.Owner:EyeAngles():Forward()
	--ent:SetPos( self.Owner:GetViewModel():GetAttachment(2).Pos + Forward * 0 )
	ent:SetPos( self.Owner:GetShootPos() + Forward * 1 )
	ent:SetAngles (self.Owner:EyeAngles())
	ent:Spawn()
	ent:SetOwner(self.Owner)
	ent:Activate()
	local ang = ply:EyeAngles()
    local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
	local target = ply:GetEyeTraceNoCursor().HitPos
    local tang = (target-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
      -- Makes the grenade go upgwards
    if tang.p < 90 then
    	tang.p = -10 + tang.p * ((90 + 10) / 90)
    else
    	tang.p = 360 - tang.p
    	tang.p = -10 + tang.p * -((90 + 10) / 90)
    end
    tang.p=math.Clamp(tang.p,-90,90) -- Makes the grenade not go backwards :/
    local vel = math.min(800, (90 - tang.p) * shotPower)
    local thr = tang:Forward() * vel + ply:GetVelocity()
	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter( thr )
	phys:SetVelocity( ply:GetAimVector() * shotPower * 50 * math.Rand( .8, 1 ) )
	if shotPower == 8 then
		ent:SetAngles(ang+Angle(0,0,90))
		phys:AddAngleVelocity( Vector(0,0,180) )
	else
		phys:AddAngleVelocity( Vector(0,180,180) )
	end
	phys:SetMaterial("icy")
	phys:SetMass(50)

	if ply:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		self:Remove()
	end
	if self and IsValid(self) then
		self:Reload()
	end
	timer.Simple(1, function()
		if self and IsValid(self) then
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

