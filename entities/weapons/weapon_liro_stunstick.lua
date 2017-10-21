if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "melee"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Stunstick" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_stunstick.mdl"
SWEP.WorldModel			= "models/weapons/w_stunbaton.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.MaxClip = -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.HeadshotMultiplier = 1

SWEP.EmptySound = "Weapon_AR2.Empty"
SWEP.HideAmmo = true

SWEP.Primary.Recoil         = 1.2
SWEP.Primary.Damage = 20
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.8
SWEP.Primary.Sound = Sound("Weapon_StunStick.Swing")
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
				local edata = EffectData()

				edata:SetEntity(hitEnt)
				edata:SetMagnitude(3)
				edata:SetScale(2)

				util.Effect("TeslaHitBoxes", edata)

				if SERVER and hitEnt:IsPlayer() then
					local eyeang = hitEnt:EyeAngles()

					local j = 2
					eyeang.pitch = math.Clamp(eyeang.pitch + math.Rand(-j, j), -90, 90)
					eyeang.yaw = math.Clamp(eyeang.yaw + math.Rand(-j, j), -90, 90)
					hitEnt:SetEyeAngles(eyeang)
				end
				self.Owner:EmitSound("Weapon_StunStick.Melee_Hit")
				util.Effect("BloodImpact", edata)
				self.Owner:LagCompensation(false)
				self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
			else
				self.Owner:EmitSound("Weapon_StunStick.Melee_HitWorld")
				util.Effect("StunstickImpact", edata)
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

function SWEP:Deploy()
	self.Owner:EmitSound("weapons/stunstick/spark1.wav")
	return true
end

function SWEP:Holster()
	self.Owner:EmitSound("weapons/stunstick/spark2.wav")
	return true
end

local STUNSTICK_GLOW_MATERIAL = Material("effects/stunstick")
local STUNSTICK_GLOW_MATERIAL2 = Material("effects/blueflare1")
local STUNSTICK_GLOW_MATERIAL_NOZ = Material("sprites/light_glow02_add_noz")

local color_glow = Color(128, 128, 128)

function SWEP:DrawWorldModel()
	self:DrawModel()

	if self.Owner:IsValid() then
		local size = math.Rand(4.0, 6.0)
		local glow = math.Rand(0.6, 0.8) * 255
		local color = Color(glow, glow, glow)
		local attachment = self:GetAttachment(1)

		if (attachment) then
			local position = attachment.Pos

			render.SetMaterial(STUNSTICK_GLOW_MATERIAL2)
			render.DrawSprite(position, size * 2, size * 2, color)

			render.SetMaterial(STUNSTICK_GLOW_MATERIAL)
			render.DrawSprite(position, size, size + 3, color_glow)
		end
	end
end

local NUM_BEAM_ATTACHEMENTS = 9
local BEAM_ATTACH_CORE_NAME	= "sparkrear"

function SWEP:PostDrawViewModel()

	local viewModel = LocalPlayer():GetViewModel()

	if (!IsValid(viewModel)) then

		return
	end

	cam.Start3D(EyePos(), EyeAngles())
		local size = math.Rand(3.0, 4.0)
		local color = Color(255, 255, 255, 50 + math.sin(RealTime() * 2)*20)

		STUNSTICK_GLOW_MATERIAL_NOZ:SetFloat("$alpha", color.a / 255)

		render.SetMaterial(STUNSTICK_GLOW_MATERIAL_NOZ)

		local attachment = viewModel:GetAttachment(viewModel:LookupAttachment(BEAM_ATTACH_CORE_NAME))

		if (attachment) then
			
			render.DrawSprite(attachment.Pos, size * 10, size * 15, color)
		end

		for i = 1, NUM_BEAM_ATTACHEMENTS do
			local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark"..i.."a"))

			size = math.Rand(2.5, 5.0)

			if (attachment and attachment.Pos) then
				render.DrawSprite(attachment.Pos, size, size, color)
			end

			local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark"..i.."b"))

			size = math.Rand(2.5, 5.0)

			if (attachment and attachment.Pos) then
				render.DrawSprite(attachment.Pos, size, size, color)
			end
		end
	cam.End3D()
end