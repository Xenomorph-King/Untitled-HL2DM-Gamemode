AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EMP"
ENT.time = 0
ENT.active = false
function ENT:Initialize()
	self:SetModel( "models/props_lab/reciever01b.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then
		self.loop = CreateSound(self, "ambient/machines/combine_terminal_loop1.wav")
		self:SetUseType(SIMPLE_USE)
	end
	self:SetHealth(100)
	//self:Start()
end

function ENT:Use()
	if self:GetNWInt("timer",-1) == -1 and self:GetNWEntity("cp") != NULL then
		self:Start()
	end
end



function ENT:Start()
	if SERVER then
		self.loop:Play()
	end
	self:SetNWInt("timer",CurTime()+1)
	self.time = CurTime()+1
	self.active = true
	timer.Simple(31, function()
		if self and IsValid(self) then
			self:End()
		end
	end)
end

function ENT:End()
	if SERVER then
		self.loop:Stop()
	end
	self.active = false
	self:DoSound()
end

function ENT:Think()
	//print(self.time-CurTime())
	if math.sqrt((self.time-CurTime())^2) > 1 and self.active then
		self:EmitSound("buttons/blip1.wav")
		self.time = CurTime()
	end
	for k,ent in pairs(ents.FindInSphere(self:GetPos(),400)) do
		if ent:GetClass() == "liro_checkpoint" then 
			if self:GetNWEntity("cp") == NULL or self:GetNWEntity("cp") != NULL and self:GetNWEntity("cp"):GetPos():Distance(self:GetPos()) < ent:GetPos():Distance(self:GetPos()) then
				self:SetNWEntity("cp",ent)
			end
		end
	end
end

function ENT:DoSound()
	self:EmitSound("ambient/machines/thumper_startup1.wav")
	timer.Simple(2.9, function()
		self:EmitSound("ambient/energy/zap"..math.random(1,9)..".wav")
		self:EmitSound("ambient/machines/thumper_hit.wav")
		local ent = self:GetNWEntity("cp")
		ent:Lose(ent:GetNWInt("team",1))
		self:Destruct()
	end)
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() < 0 then
		self:Destruct()
	end
end


function ENT:Destruct()
	self:Remove()

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("cball_explode", effect)
	sound.Play(zapsound, self:GetPos())
end


function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()

	pos = pos + self:GetUp()*3.45 + self:GetRight() * -0 + self:GetForward()*-2

	ang:RotateAroundAxis(ang:Forward(), 180);
	ang:RotateAroundAxis(ang:Right(), 180);
	ang:RotateAroundAxis(ang:Up(), -90);
	cam.Start3D2D(pos,ang,0.05)
		draw.SimpleText("EMP", "Borg70", 0,-50, Color(255, 255, 255, 255), 1, 1);

		local time = self:GetNWInt("timer",-1)
		local perc = 0
		local txt = "E - ENABLE"
		if time != -1 then
			time = CurTime()-time
			if time > 30 then
				perc = 1
				txt = "ACTIVATING..."
			else
				perc = math.Clamp(time/30,0,1)
				txt = "TIME - " ..math.Round(math.Clamp(30-time,0,30)) .. "s"
			end
		end
		if self:GetNWEntity("cp",self) == self then
			txt = "NO CP FOUND"
		end
		

		local x = -135
		local y = 75
		draw.RoundedBox(0, x, y, 270, 60, Color(255,0,0))	
		draw.RoundedBox(0, x, y, 270*perc, 60, Color(248, 148, 6)	)

		surface.SetFont("Borg40")
		local w,h = surface.GetTextSize(txt)

		draw.SimpleText(txt, "Borg40", x+270/2,y+60/2, Color(255, 255, 255, 255), 1, 1);
		y = 5
				self.smoothHealth = self.smoothHealth or 100
		self.smoothHealth = Lerp(0.05, self.smoothHealth, self:Health())
		local perc = math.Clamp(self.smoothHealth/100+0.001,0,1)
		draw.RoundedBox(0, x, y, 270, 60, Color(255,0,0))	
		draw.RoundedBox(0, x, y, 270*perc, 60, Color(0, 255, 6)	)
		

		draw.SimpleText("HEALTH", "Borg40", 0,y+29, Color(255, 255, 255, 255), 1, 1);
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Forward(), 90);
	pos = pos + self:GetForward()*8.9 + self:GetUp()*-3
	cam.Start3D2D(pos,ang,0.05)
		y = -60

	cam.End3D2D()
end