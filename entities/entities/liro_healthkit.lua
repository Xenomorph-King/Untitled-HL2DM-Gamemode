AddCSLuaFile()


ENT.Type = "anim"

ENT.PrintName = "Healthkit"
ENT.exploding = false
ENT.TargetID = {}
ENT.TargetID.text = "Health Kit"

function ENT:Initialize()
	self:SetModel( "models/items/healthkit.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		//phys:Wake()
	end
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use(ply)
	if ( self:IsPlayerHolding() ) then return end
	if ply:KeyDown(IN_WALK) then
		ply:PickupObject( self )
		return
	end
	local hamo = 25
	local plyH = ply:Health()
	local plyHM = ply:GetMaxHealth()
	local new = math.Clamp(plyH+hamo,0,plyHM)

	if new == plyH then return end

	ply:SetHealth(new)

	self:EmitSound("HealthKit.Touch")
	self:Remove()
end
