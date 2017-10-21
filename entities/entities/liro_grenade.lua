AddCSLuaFile()


ENT.Type = "anim"

ENT.PrintName = "Grenade"
ENT.exploding = false
ENT.TargetID = {}
ENT.TargetID.text = "Frag Grenade"

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )


function ENT:Initialize()
	self:SetModel( "models/weapons/w_grenade.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		//phys:Wake()
	end
	if not self:GetRadius() then self:SetRadius(380) end
	if not self:GetDmg() then self:SetDmg(300) end
	if SERVER then
		util.SpriteTrail( self, 0, Color( 255, 0, 0 ), true, 5, 5, 2, 0.05, "trails/laser.vmt" )
		self:SetUseType( SIMPLE_USE )
	end
	self:Start()

end

function ENT:Tick()
	self:EmitSound("Grenade.Blip")
end

function ENT:Start()
	timer.Simple(1, function()
		self:Tick()
		timer.Simple(1, function() 
			self:Tick()
			timer.Simple(0.4, function() 
				self:Tick()
				timer.Create(self:EntIndex().."_GrenadeTicks", 0.3, 3, function()
					self:Tick()
				end)
			end)
		end)
	end)
	timer.Simple(3.5, function()
		if self and IsValid(self) then
			self:Explode()
		end
	end)
end

function ENT:Explode()
	if self.exploding then return end
	self.exploding = true
	if SERVER then
		self:SetNoDraw(true)
		self:SetSolid(SOLID_NONE)


		local pos = self:GetPos()

		if util.PointContents(pos) == CONTENTS_WATER then
			self:Remove()
			return
		end

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(self:GetRadius() * 0.3)
		effect:SetRadius(self:GetRadius())
		effect:SetMagnitude(self.dmg)

		util.Effect("Explosion", effect, true, true)

		util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, pos, self:GetRadius(), self:GetDmg())


		self:Remove()
	else
		local spos = self:GetPos()
		local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
		util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
	end
end


function ENT:Use(ply)
	if ( self:IsPlayerHolding() ) then return end
	ply:PickupObject( self )
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 50 then
		self.Entity:EmitSound( Format( "physics/metal/metal_grenade_impact_hard%s.wav", math.random( 1, 3 ) ) ) 
	end
	
	//local impulse = -data.Speed * data.HitNormal * 0.3 + (data.OurOldVelocity * -0.5)
	//phys:ApplyForceCenter(impulse)
end

if CLIENT then
	hook.Add("PostDrawOpaqueRenderables","ttt_healthstationviewer",function()
		local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
		local ang = LocalPlayer():EyeAngles()
		ang = Angle(ang.p+90,ang.y,0)
		for k, v in pairs(ents.FindByClass("liro_grenade")) do
			if v:GetOwner() and v:GetOwner():IsValid() and v:GetOwner():IsPlayer() and v:GetOwner():getTeam() == LocalPlayer():getTeam() then
				if v:GetPos():Distance(LocalPlayer():GetPos()) > 1000 then continue end
				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
				
				render.SetStencilReferenceValue(15)
				render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilPassOperation(STENCILOPERATION_KEEP)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				render.SetBlend(0)
					v:DrawModel()
				render.SetBlend(1)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(255,0,0,255)
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
				cam.End3D2D()
				v:DrawModel()
				render.SetStencilEnable(false)
			end
		end
		for k, v in pairs(ents.FindByClass("liro_cball")) do
			if v:GetNWEntity("own",v) and v:GetNWEntity("own",v):IsValid() and v:GetNWEntity("own",v):IsPlayer() and v:GetNWEntity("own",v):getTeam() == LocalPlayer():getTeam() then
				if v:GetPos():Distance(LocalPlayer():GetPos()) > 1000 then continue end
				render.ClearStencil()
				render.SetStencilEnable(true)
				render.SetStencilWriteMask(255)
				render.SetStencilTestMask(255)
				
				render.SetStencilReferenceValue(15)
				render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
				render.SetStencilPassOperation(STENCILOPERATION_KEEP)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				render.SetBlend(0)
					v.Cl:DrawModel()
				render.SetBlend(1)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				cam.Start3D2D(pos,ang,1)
					surface.SetDrawColor(0,0,255,255)
					surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
				cam.End3D2D()
				v.Cl:DrawModel()
				render.SetStencilEnable(false)
			end
		end
	end)

end