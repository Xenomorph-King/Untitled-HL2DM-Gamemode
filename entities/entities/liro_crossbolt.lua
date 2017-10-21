AddCSLuaFile()


ENT.Type = "anim"

ENT.PrintName = "Crossbow Bolt"
ENT.exploding = false
ENT.TargetID = {}
ENT.TargetID.text = ""

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )
AccessorFunc( ENT, "dmg", "Dmg", FORCE_NUMBER )


function ENT:Initialize()
	self:SetModel( "models/items/crossbowrounds.mdl" )
	self:PhysicsInit( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetSolid( SOLID_BBOX )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		//phys:Wake()
	end
	self:EmitSound("Weapon_Crossbow.BoltFly")

	if SERVER then
		self:SetGravity(0.1)
		self:SetUseType( SIMPLE_USE )
	end

end

function ENT:Effect(fix)
	local effect = EffectData()
	local normal = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward()*(fix and 75 or 1),
		filter = {self,fix},
		mask = MASK_SHOT_HULL
	})
	effect:SetOrigin(normal.HitPos)
	effect:SetNormal(normal.Normal)
	util.Effect("BoltImpact",effect)
	effect = EffectData()
	effect:SetOrigin(self:GetPos())
	effect:SetRadius(0.2)

	util.Effect("cball_explode", effect)
end

function ENT:Touch(ent)
	//print(ent)
	if self:GetNWBool("inactive",false) then return end
	if ent:IsWorld() then
		local vecDir = self:GetAbsVelocity()
		local tr = self:GetTouchTrace()
		local hitDot = tr.HitNormal:Dot(-tr.Normal)
		//print(hitDot)
		if hitDot < 0.5 and !self.ricochet and false then // DISABLED
			local reflection = 2* tr.HitNormal * hitDot + vecDir
			vecDir = vecDir:GetNormalized()
			local ang = reflection:Angle()
			ang = Angle(-ang.x,ang.y,ang.z)
			self:SetAngles(ang)

			self:SetPos(self:GetPos()+self:GetUp()*10)
			self:SetAbsVelocity(reflection * -5)
			//self.ricochet = true
			return
		end

		self:Effect()
		self:EmitSound("Weapon_Crossbow.BoltHitWorld")
	elseif ent:IsPlayer() or ent:IsNPC() then
		local wepEnt = ents.Create("weapon_liro_crossbow")
		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_PREVENT_PHYSICS_FORCE)
		dmg:SetDamage(400)
		dmg:SetInflictor(wepEnt)
		dmg:SetAttacker(self:GetOwner():IsValid() and self:GetOwner() or self)
		ent:TakeDamageInfo(dmg)
		wepEnt:Remove()

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		effect:SetRadius(0.1)
		effect:SetFlags(3)
		effect:SetColor(0)
		effect:SetScale(6)

		util.Effect("BloodImpact", effect)

		local tr = util.TraceHull({
				startpos = self:GetPos(),
				endpos = self:GetPos() + self:GetForward() * 50,
				filter = ent
		})
		if tr.Entity and tr.Entity:IsWorld() and false then // DISABLED
			if ent:IsPlayer() then
				self:InActive()
				timer.Simple(0, function()
					local hitPos = self:GetTouchTrace().PhysicsBone
					constraint.Weld(ent.server_ragdoll, tr.Entity, 0, 0, 0, false, false )
					self:InActive(ent.server_ragdoll)
				end)
				return
			end
		end
	end
	self:EmitSound("Weapon_Crossbow.BoltSkewer")
	self:Remove()
end

function ENT:InActive(tr)
	self:GetPhysicsObject():EnableMotion(false)
	if tr then
		self:Effect(tr)
	end
	self:SetNWBool("inactive",true)
	self:SetMoveType(MOVETYPE_NONE)
end



function ENT:PhysicsCollide(data, phys)

	print(data.Entity)
	
	//local impulse = -data.Speed * data.HitNormal * 0.3 + (data.OurOldVelocity * -0.5)
	//phys:ApplyForceCenter(impulse)
end

if CLIENT then
	function ENT:Draw()
		if not self.bowEntity then
			self.bowEntity = ClientsideModel("models/crossbow_bolt.mdl",RENDERGROUP_TRANSLUCENT)
			self.bowEntity:SetParent(self)
			self.bowEntity:SetSkin(1)
		else
			self.bowEntity:SetPos(self:GetPos())
			self.bowEntity:SetAngles(self:GetAngles())
		end
		//self:DrawModel()
		render.SetMaterial( Material("cable/redlaser") )
		//render.DrawBeam(self.bowEntity:GetPos(),self.bowEntity:GetPos()+self.bowEntity:GetForward()*50, 5, 1, 1,Color(255,0,0))
	end

	function ENT:OnRemove()
		if self.bowEntity then
			SafeRemoveEntity(self.bowEntity)
		end
	end
end
