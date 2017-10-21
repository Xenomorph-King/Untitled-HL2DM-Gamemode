-------------------------
-- Sassilization SMG
-- Spacetech
-------------------------

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")



function ENT:Initialize()
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionBounds(Vector(-30, -30, -30), Vector(30, 30, 0))
	
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	self.Entity:SetTrigger(true)
	self.Entity:SetNotSolid(true)
	local model = "models/weapons/w_irifle.mdl"
	local wep = weapons.GetStored(self.Gun or "weapon_liro_ar2")
	
	model = wep.WorldModel
	self.Entity:SetModel(model)

	timer.Simple(0.1, function()
		if(IsValid(self)) then
			self.Entity:SetPos(self.Entity:GetPos() + Vector(0, 0, 30))
		end
	end)
end

function ENT:StartTouch(Ent)
	if(!Ent or !Ent:IsValid()) then
		return
	end
	if(Ent:IsPlayer() and Ent:Alive()) and !self:GetNWBool("inactive",false) then
		if true or (gamemode.Call("PlayerCanPickupWeapon", Ent)) then
			if(!Ent:HasWeapon(self.Gun)) then
				Ent:Give(self.Gun)
				self:SetNWBool("inactive",true)
				timer.Simple(10, function()
					if IsValid(self) then
						self:SetNWBool("inactive",false)
					end
				end)
				self.Entity:EmitSound(self.OnTouchSound)
				-- self.Entity:Remove()
			end
		end
	end
end
