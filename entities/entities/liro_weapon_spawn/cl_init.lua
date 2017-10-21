-------------------------
-- Sassilization SMG
-- Spacetech
-------------------------

include("shared.lua")

ENT.AddPos = false
ENT.SpriteColor = Color(0, 0, 255, 255)
ENT.ShineMat = Material("effects/blueflare1")
ENT.PickupMat = Material("effects/select_ring")
ENT.InactiveColor = Color(255, 00, 0, 255)
local Size = false

local QuadSize = 50
local CircleSize = 75

-- Based on Rambos powerup
-- ^ <3
function ENT:Draw()
	self.Entity:SetAngles(Angle(0, RealTime() * 180, 0))
	
	self.Entity:DrawModel()
	local col = self.SpriteColor
	if self:GetNWBool("inactive",false) then
		col = self.InactiveColor
	end
	Size = (math.sin(2 * CurTime()) * 20) + CircleSize
	render.SetMaterial(self.ShineMat)
	render.DrawSprite(self.Entity:GetPos()+self:GetUp()*5, Size, Size, col)
	
	render.SetMaterial(self.PickupMat)
	render.DrawQuadEasy(self.Entity:GetPos(), vector_up, QuadSize, QuadSize, col)
end

function ENT:DrawTranslucent()
	self:Draw()
end



function LIRO_SPAWN_Text()
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == "liro_weapon_spawn" then
			local pos = v:GetPos() + v:GetUp()*35
			local eyeang = LocalPlayer():EyeAngles().y - 90 -- Face upwards
			local ang = Angle( 0, v:GetAngles().y, 90 )
			local txt = "COMBINE SNIPER"
			local wep = weapons.GetStored(v.Gun)
			if wep.PrintName then
				txt = wep.PrintName:upper()
			end
			//txt="size doesnt matter in this"
			-- Start drawing 
			local x = #txt*50
			local col = v.SpriteColor
			if v:GetNWBool("inactive",false) then
				col = v.InactiveColor
			end
			cam.Start3D2D(pos, ang, 0.1)
				surface.SetDrawColor(col)
				surface.DrawRect(-x/2,400,x,135)
				draw.DrawText( txt, "Borg50", 0, 400, Color(255,255,255), TEXT_ALIGN_CENTER )
			cam.End3D2D()

			ang:RotateAroundAxis(v:GetUp(),180)

			cam.Start3D2D(pos, ang, 0.1)
				draw.DrawText( txt, "Borg50", 0, 400, Color(255,255,255), TEXT_ALIGN_CENTER )
			cam.End3D2D()

		end
	end
end
hook.Add("PostDrawTranslucentRenderables", "liro_spawn_text", LIRO_SPAWN_Text)