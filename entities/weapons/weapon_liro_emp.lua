if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "Slam"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "EMP Device" -- This will be shown in the spawn menu, and in the weapon selection menu
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

SWEP.NoSights = true

local function CheckIfEmpty(vec,ang)
	if ang then 
		//print(ang.x)
		if math.Round(ang.x) != 90 then return false end
	end
	return true
end



if CLIENT then
	local model
	local function initModel(self)
		model = ClientsideModel("models/props_lab/reciever01b.mdl", RENDERGROUP_TRANSLUCENT)
		model:SetRenderMode(RENDERMODE_TRANSALPHA)
		model:SetMaterial("models/debug/debugwhite")
		model.Weapon = self
		local ang = Angle(0, LocalPlayer():GetAngles().y, 0)
		model:SetAngles(ang)
	end
	function SWEP:Think()
		if !IsValid(model) then initModel(self) end
		local tr = self.Owner:GetEyeTrace()
		tr.HitPos.z = tr.HitPos.z + 0
		
		model:SetPos(tr.HitPos + model:GetUp()*4)

		local ang = tr.HitNormal:Angle()
		ang.pitch = ang.pitch + 90
		model:SetAngles(ang)
		if tr.HitPos:Distance(self:GetPos()) > 102.5 or !CheckIfEmpty(tr.HitPos,ang) then
			model:SetColor(Color(255, 0, 0, 125))
			return
		end
		model:SetColor(Color(0, 255, 0, 125))

	
	end
	function SWEP:OnRemove()
		if IsValid(model) then
			model:Remove()
		end
	end
	function SWEP:Holster()
		if IsValid(model) then
			model:Remove()
		end
		return true
	end
	timer.Create("sentry_marker_delete", 2, 0, function()
		if !IsValid(model) or !model.Weapon or !LocalPlayer():IsValid() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if wep and wep != model.Weapon then model:Remove() end
	end)
end



function SWEP:PrimaryAttack()
	if CLIENT then return end
	local tr = self.Owner:GetEyeTrace()
	if tr.HitPos:Distance(self:GetPos()) > 100 or !CheckIfEmpty(tr.HitPos) then return end
	local tbl = player.GetAll()
	for i=1, #tbl do
		if tbl[i]:GetPos():Distance(tr.HitPos) < 25 then return end
	end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	//self.Weapon:EmitSound("/weapons/ar2/ar2_altfire.wav")
	self:TakePrimaryAmmo(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	//if (CLIENT) then return end

	self:Place()
end

function SWEP:SecondaryAttack()

end

function SWEP:Place()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then return end

		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()
      
		local vthrow = vvel + vang * 200

		local emp = ents.Create("liro_emp")
		if IsValid(emp) then
			local tr = self.Owner:GetEyeTrace()
			tr.HitPos.z = tr.HitPos.z + 3
			local ang = tr.HitNormal:Angle()
			ang.pitch = ang.pitch + 90
			emp:SetPos(tr.HitPos + emp:GetForward()*4)
			emp:SetAngles(ang)
			emp:Spawn()

	 		//health:PhysWake()
			local phys = emp:GetPhysicsObject()
			if IsValid(phys) then
			//	phys:SetVelocity(vthrow)
				phys:EnableMotion(false)
			end   
			self.Owner:EmitSound(throwsound)
			self:Remove()

 		end
	end
	
end



