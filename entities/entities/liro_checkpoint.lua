AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Command Post"
ENT.exploding = false
ENT.TargetID = {}
ENT.TargetID.format = true
ENT.TargetID.text = "Command Post #%s"
ENT.num = 0
function ENT:Initialize()
	self:SetModel( "models/props_combine/combine_interface001.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNWInt("team",1)
	self:SetNWBool("taking",false)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	
	if SERVER then
		print("NUM1"..table.Count(GAMEMODE.posts)+1)
		self.num = GetGlobalInt("cnum",0)+1
		SetGlobalInt("cnum",self.num)

		self:SetNWInt("cnum",self.num)
		self.alarm = CreateSound(self, "ambient/alarms/combine_bank_alarm_loop1.wav")
		self.start = CreateSound(self, "ambient/machines/thumper_amb.wav")
		self.loop = CreateSound(self, "ambient/machines/combine_terminal_loop1.wav")
		self:SetUseType( SIMPLE_USE )

		self.monitor = ents.Create("prop_physics")
		self.monitor:SetModel("models/props_combine/combine_intmonitor001.mdl")
		self.monitor:SetPos(self:GetPos()+(self:GetForward()*-15)+self:GetUp()*50)
		self.monitor:Spawn()
		self.monitor:SetParent(self)
		self.monitor.monitor = true
		local phys = self.monitor:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(false)
		end

		self:SetNWEntity("monitor",self.monitor)
		updatePost(self)
		self.loop:Play()
	end

	self.num = self:GetNWInt("cnum",0)


	//self:Start()

end

function ENT:Think()
	self.targNum = self:GetNWInt("cnum",0)
end

function ENT:OnRemove()
	if SERVER then
		self.loop:Stop()
		self.alarm:Stop()
		self.start:Stop()
	end
end

function ENT:Use(ply)
	if !IsValid(ply) then return end

	local t = ply:getTeam()
	local t2 = self:GetNWInt("team",1)
	if t2 == t then
		if self:GetNWBool("taking",false) == false then
			self:EmitSound("buttons/combine_button_locked.wav")
		else
			timer.Destroy(self:EntIndex() .. "_CheckpointTimer")
			timer.Destroy(self:EntIndex() .. "_CheckpointFlash")
			self:EmitSound("buttons/combine_button1.wav")
			self:SetNWBool("taking",false)
			self:SetNWBool("flash",false)
			if SERVER then
				self.alarm:Stop()
				self.start:Stop()
			end
			updatePost(self)
		end
	elseif self:GetNWBool("taking",false) == false then
		self:SetNWBool("taking", true)
		timer.Create(self:EntIndex() .. "_CheckpointFlash", 0.5, 0, function() 
			if self:GetNWBool("flash",false) then
				self:SetNWBool("flash",false)
			elseif self:GetNWInt("team",1) == 1 then
				self:SetNWBool("flash",true)
			end
		end)
		self:SetNWInt("time",CurTime()+120)
		timer.Create(self:EntIndex() .. "_CheckpointTimer", 120, 1, function()
			self:Lose(t2)
		end)
		if SERVER then
			if t2 == 1 then
				SendOverlayText("CHECKPOINT #".. self.num .. " COMPROMISED...", Color(255,255,0))
				SendRebelMessage("Checkpoint #".. self.num .. " is starting to come under our control.")
				self.alarm:Play()
			else
				SendOverlayText("CHECKPOINT #".. self.num .. " IS UNDER SIEGE", Color(0,0,255))
				SendRebelMessage("Checkpoint #".. self.num .. " is losing our control.")
				self.start:Play()
			end
			updatePost(self)
		end
	end
end

function ENT:Lose(t2)
	self:SetNWInt("team",(t2%2)+1)
	self:SetNWBool("taking",false)
	self:SetNWInt("time",CurTime())
	updatePost(self)
	timer.Destroy(self:EntIndex() .. "_CheckpointTimer")
	timer.Destroy(self:EntIndex() .. "_CheckpointFlash")
	if SERVER then
		self.alarm:Stop()
		self.start:Stop()
		if t2 == 2 then
			SendOverlayText("CHECKPOINT #".. self.num .. " REGAINED!", Color(0,255,0))
			SendRebelMessage("Checkpoint #".. self.num .. " has fallen.")
			self.monitor:SetSkin(0)
			self:SetSkin(0)
			self.loop:Play()
			self:EmitSound("ambient/machines/thumper_startup1.wav")
		else
			self.monitor:SetSkin(1)
			self:SetSkin(1)
			self.loop:Stop()
			self:EmitSound("ambient/machines/thumper_shutdown1.wav")
			SendOverlayText("CHECKPOINT #".. self.num .. " LOST!", Color(255,100,0))
			SendRebelMessage("Checkpoint #".. self.num .. " is now under control.")
		end
	end
end

if CLIENT then
	hook.Add( "PostDrawTranslucentRenderables", "example", function()
		for k,ent in pairs(ents.FindByClass("liro_checkpoint")) do
			local pos = ent:GetPos() + ent:GetUp()*95 - ent:GetForward() * 18 + ent:GetRight() * 15
			local ang = ent:GetAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), -90 )
			local alpha = 255
			if !ent:GetNWBool("flash",false) then alpha = 0 end
			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.4 )
				surface.SetDrawColor( 255, 255, 255, alpha )
				surface.SetTexture(surface.GetTextureID("effects/combinedisplay001b"))
				surface.DrawTexturedRect(0, 0, 64, 100)
			cam.End3D2D()

			pos = ent:GetPos() + ent:GetUp()*59.4 + ent:GetForward()*-15.9 + ent:GetRight() * 9.8
			local perc = 1
			local time = ent.time or 1
			
			if time and time > 0 then
				perc = math.Clamp((time-CurTime())/120,0,1)
			end
			if time-CurTime() <= 0 then
				perc = 1
			end
			local amo = 90-(90*perc)
			if perc != 1 then
				amo = amo+1
			end
			local col = Color(255,100,0)
			local col2 = Color(52, 73, 94)
			if ent:GetNWInt("team",1) != 2 then
				col = Color(0, 84, 255)
				col2 = Color(52, 73, 94)
			end
			cam.Start3D2D( pos, Angle( 0, ang.y, 40 ), 0.1 )
				draw.RoundedBox(0, 0, 170, 154, 90, col2)	
				draw.RoundedBox(0, 0, 170+amo, 154, 90*perc, col)

				draw.SimpleText("STATUS", "Borg40", 154/2, 210, Color(255, 255, 255, 255), 1, 1);
				draw.SimpleText("STATUS", "Borg40", 154/2, 210, Color(255, 255, 255, 255), 1, 1);
			cam.End3D2D()
		end
	end )
end