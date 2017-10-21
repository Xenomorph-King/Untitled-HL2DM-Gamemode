if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "Slam"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Medkit" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel = Model( "models/weapons/v_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_medkit.mdl" )
SWEP.ViewModelFOV = 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.HeadshotMultiplier = 1.5

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 2.9
SWEP.Primary.Sound = Sound("Weapon_Grenade.Single")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 1

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false 

SWEP.Slot			= 5
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.Charge = 100
SWEP.regenHeal = CurTime()
SWEP.lastHeal = CurTime()

SWEP.NoAmmo = true 

local HealSound = Sound( "HealthKit.Touch" )
local DenySound = Sound( "WallHealth.Deny" )

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

SWEP.ProjectileEntity = "liro_medkit"
SWEP.NoSights = true

function SWEP:PrimaryAttack()
	if self.Charge-25 < 0 then
		self.Owner:EmitSound(DenySound)
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.3)
		return
	end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:EmitSound("/weapons/ar2/ar2_altfire.wav")
	self:TakePrimaryAmmo(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	//if (CLIENT) then return end

	self:Drop()
end

function SWEP:SecondaryAttack()
	//self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )


	//if (CLIENT) then return end
	
	local ent = self.Owner:GetEyeTrace().Entity
	if ent:GetPos():Distance(self.Owner:GetPos()) < 50 and ent:IsPlayer() then
		if CurTime()-self.lastHeal < 1 then return end
		self.lastHeal = CurTime()
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self:SendWeaponAnim(ACT_VM_THROW)
		local charge = self.Charge
		local hamo = charge
		if charge > 25 then hamo = 25 end
		local plyH = ent:Health()
		local plyHM = ent:GetMaxHealth()
		if plyH > plyHM-25 then
			hamo = math.Clamp(plyHM-plyH,0,charge)
		end
		local new = math.Clamp(plyH+hamo,0,plyHM)
		if new == plyH or charge == 0 then self.Owner:EmitSound(DenySound) return end
		//print("CHARGE: ".. charge)
		//print("AMOUNT: ".. hamo)
		//print("NEW: ".. new)
		//print("NEW CHARGE: ".. charge-hamo)
		ent:SetHealth(new)
		self.Owner:EmitSound(HealSound)
		self.Charge = self.Charge-hamo
		self.regenHeal = CurTime()
	end
end

function SWEP:Drop()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then return end

		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()
      
		local vthrow = vvel + vang * 200

		local health = ents.Create("liro_healthkit")
		if IsValid(health) then
			health:SetPos(vsrc + vang * 10)
			health:Spawn()

	 		health:PhysWake()
			local phys = health:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vthrow)
			end   
			//self:Remove()

 		end
	end
	self.Charge = self.Charge-25
	self.regenHeal = CurTime()
	self.Owner:EmitSound(throwsound)
end

function SWEP:Think()
	local healtime = self.regenHeal
	//print(CurTime()-healtime)
	if CurTime()-healtime > 3 and self.Charge < 100 then
		self.Charge = math.Clamp(self.Charge + 1,0,100)
		self.regenHeal = CurTime()-2.9
	end
end


if CLIENT then
	function SWEP:DrawHUD()
		local length = 40
		local gap = 10

		surface.SetDrawColor(0, 255, 0, 200)

		local x = ScrW() / 2.0
		local y = ScrH() / 1.6

		surface.SetFont("DefaultFixedDropShadow")
		surface.SetTextColor(0, 255, 0, 200)
		surface.SetTextPos( x + length, y - length )
     // surface.DrawText("LEVEL " .. self.dt.zoom)


		if self.Charge then
			y = y + (y / 2)

			local w, h = 300, 60

			surface.SetDrawColor(255, 0 , 0, 255)
			surface.DrawRect(x - w/2, y - h, w, h)

			surface.SetDrawColor(0, 255, 0, 255)
			local pct = math.Clamp(self.Charge / 100, 0, 1)
			surface.DrawRect(x - w/2, y - h, w * pct, h)

			surface.SetTextColor(color_white)
			surface.SetFont("Borg40")
			local w2,y2 = surface.GetTextSize("CHARGE - "..self.Charge .. "%")
			surface.SetTextPos(x-w2/2, y-h/2-y2/2)
			surface.DrawText("CHARGE - "..self.Charge .. "%")
		end
	end
end