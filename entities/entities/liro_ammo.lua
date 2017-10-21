AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ammo Crate"
ENT.ammotype = "ar2"
local ammotable = {
	[ "smg1" ] = 60,
	[ "ar2" ] = 60, 
	[ "pistol" ] = 60,
	[ "grenade" ] = 1,
	[ "smokegrenade" ] = 1,
}

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/Items/ammocrate_ar2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetPlaybackRate(1)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
	
	function ENT:PackAmmo( activator )
		local num = ammotable[self:GetNWString("ammotype","ar2")]
		local wep = activator:GetWeapon("weapon_liro_".. self.ammotype:Replace("1",""):Replace("smokegrenade","grenade_smoke")) 
		if wep and IsValid(wep) and wep:Ammo1()+num >= wep.Primary.MaxClip-wep.Primary.ClipSize then
			num = (wep.Primary.MaxClip-wep.Primary.ClipSize)-wep:Ammo1()
		end
		if num <= 0 then
			self:EmitSound("buttons/button2.wav")
		end
		activator:GiveAmmo(num, self:GetNWString("ammotype","ar2"))
	end

	function ENT:Think()
		if self:GetNWString("ammotype","ar2"):find("grenade") then
			self:SetModel("models/Items/ammocrate_grenade.mdl")
		else
			self:SetModel("models/Items/ammocrate_"..self:GetNWString("ammotype","ar2")..".mdl")
		end
	end
	
	function ENT:Use(activator)
		if !self.nextUse or self.nextUse < CurTime() then
			self:ResetSequence("close")
			self:EmitSound("items/ammocrate_open.wav")
			
			timer.Simple( .5, function()
				self:PackAmmo( activator )
			end)
			
			timer.Simple( 0.1, function()
				self:ResetSequence("open")
				self:EmitSound("items/ammocrate_close.wav")
			end)
			
			self.nextUse = CurTime() + 1
		end
	end	
end



if CLIENT then

	function LIRO_Ammo_Text()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "liro_ammo" then
				local angles = v:GetAngles();
				local position = v:GetPos();
				local offset = angles:Up()*15 + angles:Forward() * 17 + angles:Right() * 8;
				local offset2 = angles:Up() + angles:Forward() * 1.2 + angles:Right() * - 15.5;

				local txt = (v:GetNWString("ammotype") or "AR2") .. " AMMO"
				txt = txt:upper()
				angles:RotateAroundAxis(angles:Forward(), 90);
				angles:RotateAroundAxis(angles:Right(), 270);
				angles:RotateAroundAxis(angles:Up(), 0);


				cam.Start3D2D(position + offset, angles, 0.1);
					draw.SimpleText(txt, "Borg50", 80.5, 46, Color(255, 255, 255, 255), 1, 1);
					draw.SimpleText(txt, "Borg50", 80.5, 46, Color(255, 255, 255, 255), 1, 1);
				cam.End3D2D();

			end
		end
	end
	hook.Add("PostDrawTranslucentRenderables", "liro_ammo_text", LIRO_Ammo_Text)
end