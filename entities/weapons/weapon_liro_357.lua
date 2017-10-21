if SERVER then
	AddCSLuaFile()

	SWEP.HeadshotMultiplier = 3
end
SWEP.HoldType = "revolver"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= ".357 Magnum" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_357.mdl"
SWEP.WorldModel			= "models/weapons/w_357.mdl"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 36
SWEP.Primary.MaxClip = 36
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "357"

SWEP.EmptySound = "Weapon_Pistol.Empty"

SWEP.HeadshotMultiplier = 20

SWEP.Primary.Recoil         = 7
SWEP.Primary.Damage = 30
SWEP.Primary.Cone = 0.0001
SWEP.Primary.Delay = 0.7
SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-5.93, -3.2, 4.34)
SWEP.IronSightsAng         = Vector(0,-1,0)

SWEP.IronWalk = 150
SWEP.IronRun = 200

function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights( false )
	if CLIENT and self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then -- Again, reloads are normally clientside
		self:EmitSound( "Weapon_357.Reload" )
	end
end