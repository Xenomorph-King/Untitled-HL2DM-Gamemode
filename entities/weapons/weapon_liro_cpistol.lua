if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "revolver"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "P2" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel = "models/weapons/v_alyx_gun.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_cweaponry_pp.mdl"

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 80
SWEP.Primary.MaxClip = 200
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AR2"
SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1
SWEP.EmptySound = "Weapon_Pistol.Empty"
SWEP.Combine = true
SWEP.HeadshotMultiplier = 3

SWEP.Primary.Recoil         = 0.6
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.06
SWEP.Primary.Delay = 0.09
SWEP.Primary.Sound = Sound("weapons/combine_pistol/fire.wav")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-5.75, -9.2, 5.94)
SWEP.IronSightsAng         = Vector(0,-1,0)

SWEP.IronWalk = 150
SWEP.IronRun = 200



function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights( false )
	if CLIENT and self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then -- Again, reloads are normally clientside
		self:EmitSound( "Weapon_Pistol.Reload" )
	end
end