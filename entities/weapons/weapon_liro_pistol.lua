if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "revolver"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "9MM USP" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 80
SWEP.Primary.MaxClip = 200
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "Pistol"

SWEP.EmptySound = "Weapon_Pistol.Empty"

SWEP.HeadshotMultiplier = 3

SWEP.Primary.Recoil         = 0.7
SWEP.Primary.Damage = 15
SWEP.Primary.Cone = 0.03
SWEP.Primary.Delay = 0.15
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
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