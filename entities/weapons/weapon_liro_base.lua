if SERVER then
	AddCSLuaFile()
end
SWEP.Base = "weapon_base"
SWEP.HoldType = "ar2"

SWEP.PrintName			= "LIRO Base Swep" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_irifle.mdl"
SWEP.WorldModel			= "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.MaxClip = 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"
SWEP.HeadKill = false

SWEP.Primary.Recoil         = 0.5
SWEP.Primary.Cone = 0.05
SWEP.Primary.Delay = 0.1
SWEP.Primary.Sound = Sound("Weapon_AR2.Single")
SWEP.Primary.SoundLevel = 100
SWEP.HeadshotMultiplier = 2.7

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


SWEP.IronSightsPos         = Vector(-7.58, -9.2, 0.55)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)

if CLIENT then
   function SWEP:DrawHUD()
      local client = LocalPlayer()
      if not IsValid(client) then return end
      if !self.DrawCrosshair then return end
      local sights = (not self.NoSights) and self:GetIronsights()
      local x = math.floor(ScrW() / 2.0)
      local y = math.floor(ScrH() / 2.0)
      local scale = math.max(0.2,  10 * self:GetPrimaryCone())

      local LastShootTime = self:LastShootTime()
      scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

      local alpha = 1
      local bright = 1

      local alphafactor = 1
      -- somehow it seems this can be called before my player metatable
      -- additions have loaded
      if client:getTeam() == TEAM_COMBINE then
         local r,g,b = 255,0,0
         surface.SetDrawColor( r, g, b, 255 * alphafactor)
      else
         surface.SetDrawColor( 0, 255, 0, 255 * alphafactor)
      end

      local gap = math.floor(20 * scale *  (sights and 0.3 or 1))
      local length = math.floor(gap + (25 * 0.5) * scale)*2

      local tr = client:GetEyeTrace()
      if tr.Entity and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
         gap = gap/2
         length = length/2
      end

      surface.DrawLine( x - length, y, x - gap, y )
      surface.DrawLine( x + length, y, x + gap, y )
      surface.DrawLine( x, y - length, x, y - gap )
      surface.DrawLine( x, y + length, x, y + gap )
      surface.SetDrawColor( 0, 255, 0, 255 )
      surface.DrawRect( x-1, y-1, 2, 2 )
   end
end

function SWEP:PrimaryAttack()
   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   if not worldsnd then
      self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
   elseif SERVER then
      sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
   end

   self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShot, self:GetPrimaryCone() )

   self:TakePrimaryAmmo( 1 )

   local owner = self.Owner
   if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

   owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) * self.Primary.Recoil, 0 ) )
end

local function Sparklies(attacker, tr, dmginfo)
   if CLIENT then
      if tr.HitWorld and tr.MatType == MAT_METAL and !attacker:GetActiveWeapon().Combine and tr.Entity:GetClass() != "liro_shield" then
         local eff = EffectData()
         eff:SetOrigin(tr.HitPos)
         eff:SetNormal(tr.HitNormal)
         util.Effect("cball_bounce", eff)
      elseif attacker:GetActiveWeapon().Combine and tr.Entity:GetClass() != "liro_shield" then
         local eff = EffectData()
         eff:SetOrigin(tr.HitPos)
         eff:SetNormal(tr.HitNormal)
         util.Effect("AR2Impact", eff)
      end
      if tr.Entity:GetClass() == "liro_shield" then
         local effectdata = EffectData()
         effectdata:SetOrigin(tr.HitPos)
         effectdata:SetEntity(tr.Entity)
         effectdata:SetScale(50)
         util.Effect("shield",effectdata)
         tr.Entity:EmitSound("combine mech/shieldHit.mp3",85,math.random(80,120))
         return true
      end
   end
   if tr.Entity and tr.Entity:IsPlayer() and tr.HitGroup == HITGROUP_HEAD and attacker:GetActiveWeapon().HeadKill then
      dmginfo:ScaleDamage(10)
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

   self.Owner:MuzzleFlash()
   self.Owner:SetAnimation( PLAYER_ATTACK1 )

   --if not IsFirstTimePredicted() then return end

   numbul = numbul or 1
   cone   = cone   or 0.01
   if self.Owner:GetNWBool("cripple_rarm",false) then
      cone = cone * 1.2
   end
   if self.Owner:GetNWBool("cripple_larm",false) then
      cone = cone * 1.2
   end
   //print(cone)
   local sights = self:GetIronsights()
   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = self.TracerNum or 2
   bullet.TracerName = self.Tracer or "Tracer"
   bullet.Force  = 10
   bullet.Damage = dmg
      bullet.Callback = Sparklies


   self.Owner:FireBullets( bullet )
  
   -- Owner can die after firebullets
	if (not IsValid(self.Owner)) or (not self.Owner:Alive()) or self.Owner:IsNPC() then return end

	if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then

		recoil = sights and (recoil * 0.6) or recoil
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	end

end


function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self.Owner then
      self:EmitSound( self.EmptySound or "Weapon_SMG1.Empty" )
   end

   setnext(self, CurTime() + 0.2)

   //self:Reload()
end

function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end

   if self:Clip2() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return false
   end
   return true
end

function SWEP:GetPrimaryCone()
   local cone = self.Primary.Cone or 0.2
   -- 10% accuracy bonus when sighting
   return self:GetIronsights() and (cone * 0.85) or cone
end


function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   return self.HeadshotMultiplier
end



function SWEP:SecondaryAttack()
	if self.NoSights or (not self.IronSightsPos) then return end

	self:SetIronsights(not self:GetIronsights())
   if SERVER then
      if self and IsValid(self.Owner) and IsValid(self) and self.GetIronsights and self:GetIronsights() then
         self.Owner:SetRun(0.5)
      elseif self and IsValid(self.Owner) and IsValid(self) then
         self.Owner:SetRun(1)
      end
   end
	self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Deploy()
   self:SetIronsights(false)
   return true
end

function SWEP:Reload()
   if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:SetIronsights( false )
   self:DefaultReload(self.ReloadAnim or ACT_VM_RELOAD)
end


function SWEP:OnRestore()
   self.NextSecondaryAttack = 0
   self:SetIronsights( false )
end

function SWEP:GetIronsights() return false end
function SWEP:SetIronsights() end

function SWEP:SetupDataTables()
   -- Put it in the last slot, least likely to interfere with derived weapon's
   -- own stuff.
   self:NetworkVar("Bool", 3, "Ironsights")
end



function SWEP:Initialize()
   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
   elseif SERVER then
      self:SetIronsights(false)
   end



   -- compat for gmod update
   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end
end

function SWEP:DyingShot()
   local fired = false
   if self:GetIronsights() then
      self:SetIronsights(false)

      if self:GetNextPrimaryFire() > CurTime() then
         return fired
      end

      -- Owner should still be alive here
      if IsValid(self.Owner) then
         local punch = self.Primary.Recoil or 5

         -- Punch view to disorient aim before firing dying shot
         local eyeang = self.Owner:EyeAngles()
         eyeang.pitch = eyeang.pitch - math.Rand(-punch, punch)
         eyeang.yaw = eyeang.yaw - math.Rand(-punch, punch)
         self.Owner:SetEyeAngles( eyeang )


         self.Owner.dying_wep = self

         self:PrimaryAttack(true)

         fired = true
      end
   end

   return fired
end

local LOWER_POS = Vector(0, 0, -2)

local IRONSIGHT_TIME = 0.25
function SWEP:GetViewModelPosition( pos, ang )
   if not self.IronSightsPos then return pos, ang end

   local bIron = self:GetIronsights()

   if bIron != self.bLastIron then
      self.bLastIron = bIron
      self.fIronTime = CurTime()

      if bIron then
         self.SwayScale = 0.3
         self.BobScale = 0.1
      else
         self.SwayScale = 1.0
         self.BobScale = 1.0
      end

   end

   local fIronTime = self.fIronTime or 0
   if (not bIron) and fIronTime < CurTime() - IRONSIGHT_TIME then
      return pos, ang
   end

   local mul = 1.0

   if fIronTime > CurTime() - IRONSIGHT_TIME then

      mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )

      if not bIron then mul = 1 - mul end
   end

   local offset = self.IronSightsPos + (LOWER_POS or vector_origin)

   if self.IronSightsAng then
      ang = ang * 1
      ang:RotateAroundAxis( ang:Right(),    self.IronSightsAng.x * mul )
      ang:RotateAroundAxis( ang:Up(),       self.IronSightsAng.y * mul )
      ang:RotateAroundAxis( ang:Forward(),  self.IronSightsAng.z * mul )
   end

   pos = pos + offset.x * ang:Right() * mul
   pos = pos + offset.y * ang:Forward() * mul
   pos = pos + offset.z * ang:Up() * mul

   return pos, ang
end


local old_setiron = SWEP.SetIronsights

function SWEP:Think()
   if self:Ammo1() > self.Primary.MaxClip-self.Primary.ClipSize then
      self.Owner:SetAmmo( self.Primary.MaxClip-self.Primary.ClipSize, self:GetPrimaryAmmoType() )
   end
end


function SWEP:DampenDrop()
   -- For some reason gmod drops guns on death at a speed of 400 units, which
   -- catapults them away from the body. Here we want people to actually be able
   -- to find a given corpse's weapon, so we override the velocity here and call
   -- this when dropping guns on death.
   local phys = self:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocityInstantaneous(Vector(0,0,-75) + phys:GetVelocity() * 0.001)
      phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
   end
end

function SWEP:PreDrop()
   if CLIENT then
      if self.holster then
         self.holster:Remove()
      end
   end
   if SERVER and IsValid(self.Owner) and self.Primary.Ammo != "none" then
      local ammo = self:Ammo1()

      -- Do not drop ammo if we have another gun that uses this type
      for _, w in pairs(self.Owner:GetWeapons()) do
         if IsValid(w) and w != self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
            ammo = 0
         end
      end

      self.StoredAmmo = ammo+self:Clip1()
      self.StoredAmmo2 = self:Ammo2()+self:Clip2()
      if self:Clip2() == -1 then
         self.StoredAmmo2 = nil
      end
      if ammo > 0 then
         self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
      end
   end
end

function SWEP:OnRemove()
   if CLIENT then
      if self.holster then
         self.holster:Remove()
      end
   end
end