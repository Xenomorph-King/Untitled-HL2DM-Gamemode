if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "smg"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "MP7" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 120
SWEP.Primary.MaxClip = 300
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "SMG1"

SWEP.HeadshotMultiplier = 1.5

SWEP.EmptySound = "Weapon_SMG1.Empty"

SWEP.Primary.Recoil         = 0.5
SWEP.Primary.Damage = 11
SWEP.Primary.Cone = 0.04
SWEP.Primary.Delay = 0.08
SWEP.Primary.Sound = Sound("Weapon_SMG1.NPC_Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-6.45, -9.2, 4.54)
SWEP.IronSightsAng         = Vector(0,0,0)


function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights(false)
	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
		self:EmitSound( "Weapon_smg1.Reload" )
	end
end