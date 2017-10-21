AddCSLuaFile()


ENT.Type = "anim"

ENT.PrintName = "Shield"

function ENT:Initialize()
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
//	self:SetNoDraw(true)
	self:SetModelScale( 3 )
	self:PhysicsInitSphere( 180, "canister" )
	self:Activate()
	self:SetNoDraw(true)
end

function ENT:SetPlayer(ply)
	local pos = ply:GetPos() + ply:GetUp()*25
	self:SetAngles(Angle(0,0,0))
	self:SetPos(pos)
	self:SetParent(ply,1)
	self.ply = ply
end


hook.Add("ShouldCollide","liro_Shield", function(ent1, ent2)
	if ent1:GetClass() == "liro_shield" and ent2:IsValid() then
		return false
	end
end)