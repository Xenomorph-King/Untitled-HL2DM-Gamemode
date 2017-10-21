if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "Crossbow"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Crossbow" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel			= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel			= "models/weapons/w_crossbow.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.MaxClip = 21
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "XBowBolt"
//SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1
SWEP.HeadshotMultiplier = 1.5
SWEP.Combine = false
SWEP.EmptySound = ""

SWEP.Primary.Recoil         = 0.6
SWEP.Primary.Damage = 8
SWEP.Primary.Cone = 0.01
SWEP.Primary.Delay = 0.9
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Primary.SoundLevel = 100

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true


SWEP.IronSightsPos         = Vector(-4.8, -9.2, 3)
SWEP.IronSightsAng         = Vector(2.599, -1.3, -3.6)

function SWEP:Reload()
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights(false,self.Owner)
	self:SetZoom(false)
    self:SetIronsights( false )
	if CLIENT and self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then -- Again, reloads are normally clientside
		self.Owner:EmitSound( "Weapon_Crossbow.Reload" )
		timer.Simple(0.8, function() 
			self.Owner:EmitSound("Weapon_Crossbow.BoltElectrify")
		end)
	end
end

function SWEP:PrimaryAttack()
	local bIronsights = self:GetIronsights()
	if bIronsights and self:GetNextPrimaryFire() > CurTime() and self:Clip1() > 0 then
		timer.Simple(0.1, function()
			self:SetIronsights(false)
		end)

		if SERVER then
			self:SetZoom(false)
		end
		self:EmitSound(sndZoomOut)
		if SERVER then
      		self.Owner:SendLua([[surface.PlaySound("buttons/combine_button7.wav")]])
        end
		//self.Primary.Cone = 0.1
  		
  	end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	if self:Clip1() <= 0 then
		//self:EmitSound("Weapon_SMG1.Empty")
		return
	end
	if SERVER then
		self:SetClip1(0)
		self.Owner:EmitSound(self.Primary.Sound)
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		local ent = ents.Create( "liro_crossbolt")	
		ent:SetSkin(1)
		local Forward = self.Owner:EyeAngles():Forward()
		--ent:SetPos( self.Owner:GetViewModel():GetAttachment(2).Pos + Forward * 0 )
		ent:SetPos( self.Owner:GetShootPos() + Forward * 1 )
		ent:SetOwner( self.Owner );
		ent:SetAngles(self.Owner:EyeAngles())
		ent:SetNWEntity("own",self.Owner)
		ent:Spawn()
		
		local phys = ent:GetPhysicsObject()
		local vel = math.min(800, (90) * 40)
	   	local thr = self.Owner:EyeAngles():Forward() * vel * 1.1
		//phys:ApplyForceCenter( thr )
		local Dir = self.Owner:GetAimVector()
		if ( self.Owner:WaterLevel() == 3 ) then
			ent:SetVelocity( Dir * 1500 );
		else
			ent:SetVelocity( Dir * 3500 );
		end
	end
	local eyeang = self.Owner:EyeAngles()
	eyeang.pitch = eyeang.pitch - 10
	self.Owner:SetEyeAngles( eyeang )
end

local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")
local sndCycleZoom = Sound("Default.Zoom")






function SWEP:SetZoom(state)
   if CLIENT then
      return
   elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
      if state then
         self.Owner:SetFOV(5, 0.3)
      else
         self.Owner:SetFOV(0, 0.2)
      end
   end
end



function SWEP:SetIronsights(state)
	self:SetNWBool("iron",state)
end

function SWEP:GetIronsights()
	return self:GetNWBool("iron",false)
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights(bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

	if bIronsights then
      self:EmitSound(sndZoomIn)
      if SERVER then
      //	self.Owner:SendLua([[surface.PlaySound("buttons/combine_button1.wav")]])
      end
    else
		self:EmitSound(sndZoomOut)
		if SERVER then
      	//	self.Owner:SendLua([[surface.PlaySound("buttons/combine_button7.wav")]])
        end
    end
   self:SetNextSecondaryFire( CurTime() + 0.1)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end



function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end




if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)
         
         -- cover gaps on top and bottom of screen
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor(255, 0, 0, 255)
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)


      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.1) or nil
   end
end

