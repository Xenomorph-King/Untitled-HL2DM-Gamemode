AddCSLuaFile()


ENT.Type = "anim"

ENT.PrintName = "Combine Ball"
ENT.exploding = false
ENT.TargetID = {}
ENT.TargetID.text = "Dark Energy Ball"

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )


function ENT:Initialize()
	self:SetModel(  "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInitSphere( 16, "metal_bouncy" )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:EnableGravity(false)
	end
	if not self:GetRadius() then self:SetRadius(380) end
	if not self:GetDmg() then self:SetDmg(300) end
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end

	if SERVER then
		util.SpriteTrail( self, 0, Color( 52, 152, 255 ), true, 10, 10, 0.1, 0.025, "trails/plasma.vmt" )
	end
	self:DrawShadow(false)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(255,255,255,15))
	self.loop = CreateSound(self, "weapons/physcannon/energy_sing_loop4.wav")
	self.loop:Play()
	self:Start()
	if CLIENT then
		local cl = ClientsideModel("models/effects/combineball.mdl",RENDERGROUP_BOTH)
		self.Cl = cl
		cl:SetModelScale(0.8)
	end

end

function ENT:Start()
	timer.Simple(3, function()
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

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(self:GetRadius() * 0.3)
		effect:SetRadius(self:GetRadius())
		effect:SetMagnitude(500)

		util.Effect("cball_expl", effect, true, true)

		local effect = EffectData()
		effect:SetStart(pos)
		effect:SetOrigin(pos)
		effect:SetScale(self:GetRadius() * 0.3)
		effect:SetRadius(self:GetRadius())
		effect:SetMagnitude(self.dmg)

		util.Effect("ThumperDust", effect, true, true)
		self.loop:Stop()
		self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
		timer.Simple(0.2, function()
			self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav")
			self:Remove()
		end)
		
	else
		local spos = self:GetPos()
		local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
		util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      
	end
end


function ENT:Use(ply)
	if ( self:IsPlayerHolding() ) then return end
	//ply:PickupObject( self )
end

function ENT:Touch(ent)
	if ent and ent:IsValid() and !ent:IsWorld() and !ent:GetClass():find("liro") and !ent.monitor and ent:GetNWEntity("gun",ent) == ent then
		local dmginfo = DamageInfo()
		dmginfo:SetDamageType(DMG_DISSOLVE)
		dmginfo:SetDamage(1000)
		dmginfo:SetAttacker(self:GetNWEntity("own",self))
		dmginfo:SetInflictor(self)
		ent:TakeDamageInfo(dmginfo)
		if ent:IsPlayer() then
			timer.Simple(0.1, function()
				local bones = ent.server_ragdoll:GetPhysicsObjectCount()
				 
				for i=0,bones-1 do 
					ent.server_ragdoll:GetPhysicsObjectNum(i):EnableGravity(false)
				end
				ent.server_ragdoll:Dissolve()
			end)
		else
			timer.Simple(0.1, function()
				if not ent:IsValid() or not ent:GetPhysicsObject() then return end
				local bones = ent:GetPhysicsObjectCount()
					 
				for i=0,bones-1 do 
						ent:GetPhysicsObjectNum(i):EnableGravity(false)
				end
				ent:Dissolve()
			end)
		end
	end
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 50 then
		self.Entity:EmitSound( Format( "weapons/physcannon/energy_bounce%s.wav", math.random( 1, 2 ) ) ) 
		local effect = EffectData()
		effect:SetOrigin(data.HitPos)
		effect:SetNormal(data.HitNormal)
		effect:SetRadius(10)
		effect:SetMagnitude(100)
		util.Effect("cball_bounce",effect)
	end

	//local impulse = -data.Speed * data.HitNormal * 0.3 + (data.OurOldVelocity * -0.5)
	//phys:ApplyForceCenter(impulse)
end

function ENT:OnRemove()
	self.loop:Stop()
	if CLIENT then
		self.Cl:Remove()
	end
end

if CLIENT then
	function ENT:Think()
		self.Cl:SetPos(self:GetPos())
		local ang = self.Cl:GetAngles()
		self.Cl:SetAngles(Angle(ang.x+math.random(1,5),ang.y+math.random(1,5),ang.z+math.random(1,5)))
	end
	function ENT:Draw()
	end
end