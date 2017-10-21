if SERVER then
	AddCSLuaFile()
end
SWEP.HoldType = "AR2"
SWEP.Base = "weapon_liro_base"
SWEP.PrintName			= "Combine Sniper" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.ViewModel				= "models/weapons/v_combinesniper_e2.mdl"
SWEP.WorldModel				= "models/weapons/w_combinesniper_e2.mdl"

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.MaxClip = 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AirboatGun"
SWEP.Tracer = "AR2Tracer"
SWEP.TracerNum = 1
SWEP.HeadKill = true
SWEP.EmptySound = "weapons/combine_sniper/ep2sniper_empty.wav"
SWEP.Combine = true
SWEP.Primary.Recoil         = 5
SWEP.Primary.Damage = 200
SWEP.Primary.Cone = 0.00001
SWEP.Primary.Delay = 2
SWEP.Primary.Sound = Sound("weapons/combine_sniper/ep2sniper_fire.wav")
SWEP.Primary.SoundLevel = 100

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.MaxClip = 2
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "AR2AltFire"
SWEP.Secondary.Delay = 0.1

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 2
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false


SWEP.IronSightsPos 			= Vector(5, -12, 0.5) -- Comment out this line of you don't want ironsights.  This variable must be present if your SWEP is to use a scope.
SWEP.IronSightsAng 			= Vector(2.8, 0, 0)

local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")
local sndCycleZoom = Sound("Default.Zoom")

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
	return self.BaseClass.PrimaryAttack(self)
end



function SWEP:Reload()
	
	if self.Weapon:Clip1() < self.Primary.ClipSize and self:Ammo1() > 0 then
		self:SetIronsights(false,self.Owner)
		self:EmitSound("weapons/combine_sniper/ep2sniper_reload.wav")
		self.Weapon:DefaultReload(ACT_VM_RELOAD);
	end
	
end


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
      	self.Owner:SendLua([[surface.PlaySound("buttons/combine_button1.wav")]])
      end
    else
		self:EmitSound(sndZoomOut)
		if SERVER then
      		self.Owner:SendLua([[surface.PlaySound("buttons/combine_button7.wav")]])
        end
    end
   self:SetNextSecondaryFire( CurTime() + 0.1)
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload( ACT_VM_RELOAD )
   self:SetIronsights( false )
   self:SetZoom( false )
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

if CLIENT then

	local SPRITE = Material('sprites/blueglow2')
	function SWEP:ViewModelDrawn()
		if self:GetIronsights() then
			local lolmat = Material("effects/bluelaser1")
	//		local lolmat2 = Material("sprites/redglow1.vmt")
			local tr = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*999999, self.Owner )
			local posang = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")) 
			render.SetMaterial( lolmat )
			//render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,5,0,0,Color(255,0,0,10))
	//		render.SetMaterial( lolmat2 )
	//		render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
			render.SetMaterial( SPRITE )
			render.DrawSprite( tr.HitPos + tr.Normal*1, 1, 1, Color(255, 255, 255, 255) )
			render.DrawQuadEasy( tr.HitPos + tr.Normal*0.5, tr.Normal, 11, 11, Color(255, 255, 255, 0), CurTime() )
		end
	end
	
	function SWEP:DrawWorldModel()
		self:DrawModel()
		if IsValid(self.Owner) and self:GetIronsights() then
			local lolmat = Material("effects/bluelaser1")
	//		local lolmat2 = Material("sprites/redglow1.vmt")
			local pos = self:GetPos() + self:GetForward() * 40 + self:GetUp() * 13 + self:GetRight() * 8
			local tr = util.QuickTrace( pos, self.Owner:GetAimVector()*999999, self.Owner )
			local posang = self:GetAttachment(self:LookupAttachment("muzzle"))
         if not posang then return end
			render.SetMaterial( lolmat )
			render.DrawBeam(posang.Pos+self.Owner:GetAimVector()*3,tr.HitPos,5,0,0,Color(255,0,0))
	//		render.SetMaterial( lolmat2 )
	//		render.DrawSprite( tr.HitPos, 15, 15, Color(255,255,255,255))
			render.SetMaterial( SPRITE )
			render.DrawSprite( tr.HitPos + tr.Normal*1, 10, 10, Color(255, 255, 255, 255 * 0.7) )
			render.DrawQuadEasy( tr.HitPos + tr.Normal*0.5, tr.Normal, 11, 11, Color(255, 255, 255, self.Alpha), CurTime() )
		else 
			return 
		end
	end
end