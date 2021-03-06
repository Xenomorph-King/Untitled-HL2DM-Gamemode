local mat = Material("sprites/animglow01")


function EFFECT:Init( data )

	self.Mag = data:GetMagnitude() or 0
	self.ent = data:GetEntity()
	self.Pos = data:GetOrigin()	
	self.Size = math.Clamp(data:GetScale(),50,1000)

	self.mat = Material("sprites/mechshield")
	self.Normal = (self.Pos - self.ent:GetPos()):GetNormalized()
	self.alfa = 0
	self.InBound = true
	self.Offset = self.Pos - self.ent:GetPos()
end 

function EFFECT:Think()

	if not self.ent or not(self.ent:IsValid()) then 
		return false 
	end
	
	self.Entity:SetPos(self.ent:GetPos() + self.Offset/2)

	if self.InBound then
		self.alfa = self.alfa + 0.2

		if self.alfa > 0.5  then
			self.InBound = false 
		end
	else
		self.alfa = self.alfa -0.2
		self.Size = self.Size * 0.99
	end
	
	
	return true
end 

function EFFECT:Render()

	self.mat:SetVector("$color", Vector(0,50,100) )
	local newAlph = math.Clamp(self.alfa,0,0.5)
	
	self.mat:SetFloat("$alpha",newAlph)
	
	render.SetMaterial(self.mat)
	render.DrawQuadEasy(self.Entity:GetPos(), self.Normal, self.Size, self.Size)
	render.DrawQuadEasy(self.Entity:GetPos(), (self.Normal * -1), self.Size , self.Size)
	
	self.mat:SetVector("$color", Vector(255,255,255) )
end