AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Smoke Grenade"
ENT.Lifetime = 300
ENT.DelayedEffect = 7
ENT.Color = Color( 255, 50, 50 )
ENT.emittime = 0
ENT.emitter = nil
ENT.delaytime = 0
ENT.lifetime = 30
ENT.notstart = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.TargetID = {}
ENT.TargetID.text = "Smoke Grenade"

function ENT:Initialize()
	self:SetNWBool("ns",true)
	timer.Simple(3, function()
		self:SetNWBool("ns",false)
		timer.Simple(30, function() 
			if IsValid(self) then
				self:SetNWBool("ns",true)
				self.loopsound:Stop()
				timer.Simple(30, function()
					SafeRemoveEntity(self)
				end)
			end
		end)
	end)
	self:SetModel("models/Items/grenadeAmmo.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetColor(Color(100,100,100))
//	self:SetMaterial("models/debug/debugwhite")
	if SERVER then
		self.lifetime = CurTime() + self.Lifetime
		self.delaytime = CurTime() + self.DelayedEffect
		self:SetUseType(SIMPLE_USE)
		self.loopsound = CreateSound( self, "weapons/flaregun/burn.wav" )
		//self.loopsound:Play()
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			//physicsObject:Wake()
		end
		timer.Simple(3, function()
			self.loopsound:Play()
		end)
		util.SpriteTrail( self, 0, Color( 100, 100, 100 ), true, 5, 5, 2, 0.05, "trails/laser.vmt" )
		self:SetUseType( SIMPLE_USE )
	else
		self.lifetime = CurTime() + self.Lifetime
		self.delaytime = CurTime() + self.DelayedEffect
		self.emitter = ParticleEmitter( self:GetPos() )
		self.emittime = CurTime()+1
	end
end

if (SERVER) then

	function ENT:OnRemove()
		self.loopsound:Stop()
	end
	function ENT:Think()
		if self.lifetime < CurTime() then
			self:Remove()
		end
		if self:WaterLevel() > 0 then
			self:Remove()
		end
		local perc = ( ( self.lifetime - CurTime() )/self.Lifetime )
		if self.delaytime < CurTime() then
			for k, v in pairs( ents.FindInSphere( self:GetPos(), 230*perc ) ) do
				if v:IsPlayer() then
					/*
					local tpos = v:GetPos() + Vector( 0, 0, 5 )
					local curpos = self:GetPos() + self:GetUp() * 50
					local tvec = ( tpos - curpos )
					tvec:Normalize()
					local t = {}
					t.start = curpos
					t.endpos = curpos + tvec * 230*perc
					t.filter = { self } -- By adding player and the vehicle, you can get the seat.
					local tr = util.TraceLine( t ) 
					if tr.Entity == v then
						if !(nut.schema.Call("CanTearGassed", v) == false) then
							v:AddBuff( "teargas", 30 )
						end
					end
					*/
				end
			end
		end
		return CurTime()
	end
	function ENT:Use(activator)
	end
else
	function ENT:Initialize()
		self.lifetime = CurTime() + self.Lifetime
		self.delaytime = CurTime() + self.DelayedEffect
		self.emitter = ParticleEmitter( self:GetPos() )
		self.emittime = CurTime()+self.emittime
	end
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:Think()
		local firepos = self:GetPos() + ( self:GetUp() * 5 )
		local perc = ( ( self.lifetime - CurTime() )/self.Lifetime )
		local startperc = math.Clamp( 1 - ( self.delaytime - CurTime() )/self.DelayedEffect, 0, 1)
		if self:GetNWBool("ns",true) then return end

		if self.emittime < CurTime() then

			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos	)
			smoke:SetVelocity( self:GetUp()*200*math.Rand( .5, 1 )*perc )
			smoke:SetDieTime(math.Rand(1.3,3.3)*perc)
			smoke:SetStartAlpha(math.Rand(75,150))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(66,220)*perc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(150,150,150)
			smoke:SetGravity( Vector( 0, 0, 50 ) )
			smoke:SetAirResistance(150)

			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos )
			smoke:SetVelocity(  Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )*300*startperc )
			smoke:SetDieTime(math.Rand(1.3,3.3)*perc)
			smoke:SetStartAlpha(math.Rand(75,150))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(66,440)*perc*startperc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(150,150,150)
			smoke:SetGravity( Vector( 0, 0, 5 ) )
			smoke:SetAirResistance(130)
			smoke:SetCollide( true )

			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos )
			smoke:SetVelocity(  Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )*300*startperc )
			smoke:SetDieTime(math.Rand(1.3,3.3)*perc)
			smoke:SetStartAlpha(math.Rand(75,150))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(66,440)*perc*startperc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(150,150,150)
			smoke:SetGravity( Vector( 0, 0, 5 ) )
			smoke:SetAirResistance(130)
			smoke:SetCollide( true )

			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos )
			smoke:SetVelocity(  Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )*300*startperc )
			smoke:SetDieTime(math.Rand(1.3,3.3)*perc)
			smoke:SetStartAlpha(math.Rand(75,150))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(66,440)*perc*startperc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(150,150,150)
			smoke:SetGravity( Vector( 0, 0, 5 ) )
			smoke:SetAirResistance(130)
			smoke:SetCollide( true )

			for i = 1, math.random( 1, 20 ) do
				local smoke = self.emitter:Add( "effects/spark", firepos )
				smoke:SetVelocity( ( self:GetUp()*math.Rand(0,1) + self:GetForward()*math.Rand(-.2,.2)  + self:GetRight()*math.Rand(-.2,.2) ) * 150 * perc)
				smoke:SetDieTime(math.Rand(0.05,0.1))
				smoke:SetStartAlpha(math.Rand(150,200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0,1))
				smoke:SetEndSize(math.random(1,3))
				smoke:SetStartLength(math.random(0,3))
				smoke:SetEndLength(math.random(3,12))
				smoke:SetColor(255,186,50)
				smoke:SetGravity( Vector( 0, 0, -50 ) )
				smoke:SetAirResistance(300)
			end

			self.emittime = CurTime() + .05
		end
	end
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 50 then
		self.Entity:EmitSound( Format( "physics/metal/metal_grenade_impact_hard%s.wav", math.random( 1, 3 ) ) ) 
	end
	
	//local impulse = -data.Speed * data.HitNormal * 0.3 + (data.OurOldVelocity * -0.5)
	//phys:ApplyForceCenter(impulse)
end

function ENT:Use(ply)
	if ( self:IsPlayerHolding() ) then return end
	ply:PickupObject( self )
end