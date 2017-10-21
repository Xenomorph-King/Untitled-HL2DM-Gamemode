if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "melee"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Crowbar" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.MaxClip = -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.HeadshotMultiplier = 1

SWEP.EmptySound = "Weapon_AR2.Empty"
SWEP.HideAmmo = true

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 15
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.4
SWEP.Primary.Sound = Sound("Weapon_Crowbar.Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.NoAmmo = true

SWEP.IronSightsPos         = Vector(-4.8, -9.2, 3)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not IsValid(self.Owner) then return end

	if self.Owner.LagCompensation then -- for some reason not always true
		self.Owner:LagCompensation(true)
	end

	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 70)

	local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	local hitEnt = tr_main.Entity

	self.Weapon:EmitSound(self.Primary.Sound)
   
	if SERVER then --record to player's last shot, for damage log use
		self.Owner.LastShot = { CurTime(), wepname }
	end

	if IsValid(hitEnt) or tr_main.HitWorld then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
 			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetEntity(hitEnt)

			if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
				util.Effect("BloodImpact", edata)
				self.Owner:LagCompensation(false)
				self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
			else
				util.Effect("Impact", edata)
			end
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end


	if SERVER then

		local tr_all = nil
		tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})
      
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		if hitEnt and hitEnt:IsValid() then
			local dmgam = self.Primary.Damage
			local dmg = DamageInfo()
			dmg:SetDamage(dmgam)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self.Owner)
			dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
			dmg:SetDamagePosition(self.Owner:GetPos())
			dmg:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)
		else
			if tr_all.Entity and tr_all.Entity:IsValid() then
				self:OpenEnt(tr_all.Entity)
			end
		end
	end

	if self.Owner.LagCompensation then
		self.Owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
 // self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )
end