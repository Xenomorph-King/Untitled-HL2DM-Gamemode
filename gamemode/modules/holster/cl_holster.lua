function CopyAngle(Ang)
	local AngCopy = Angle()
	AngCopy:Set(Ang)
	return AngCopy
end

function CopyVector(Vec)
	local VecCopy = Vector()
	VecCopy:Set(Vec)
	return VecCopy
end

function AddAngles(Ang1, Ang2)
	local Ang1Copy = CopyAngle(Ang1)
	--Ang1Copy.p = Ang1Copy.p + Ang2.p
	Ang1Copy:RotateAroundAxis(Ang1Copy:Forward(), Ang2.p)
	Ang1Copy:RotateAroundAxis(Ang1Copy:Up(), Ang2.y)
	Ang1Copy:RotateAroundAxis(Ang1Copy:Right(), Ang2.r)
	--Ang1Copy.r = Ang1Copy.r + Ang2.r
	return Ang1Copy
end

SWBHolsterData =
{
	["w_crowbar.mdl"] =
	{
		"ValveBiped.Bip01_L_Thigh",
		Vector(4, -3, 4),
		Angle(270, -0, -5),
	},
	["w_pistol.mdl"] =
	{
		"ValveBiped.Bip01_R_Thigh",
		Vector(4, 0, -3.4),
		Angle(265, 5, 180),
		false,
		false,
		false,
		true,
		Angle(270, 183, 256),
		Vector(-1,0,0)
	},
	["w_models/w_cweaponry_pp.mdl"] =
	{
		"ValveBiped.Bip01_L_Thigh",
		Vector(14, 4, 3),
		Angle(265, 5, 185),
		false,
		false,
		false,
		true,
		Angle(270, 183, 256),
		Vector(1,4,9)
	},
	["w_smg1.mdl"] =
	{
		"ValveBiped.Bip01_Pelvis",
		Vector(-4, -7, -7),
		Angle(265, 185, 275),
	},
	["w_irifle.mdl"] =
	{
		"ValveBiped.Bip01_Spine",
		Vector(9,-6,0),
		Angle(-15,30,0),
	},
	["w_grenade.mdl"] =
	{
		"ValveBiped.Bip01_L_Thigh",
		Vector(0,-2,6),
		Angle(130,0,0),
	},
	["w_shotgun.mdl"] =
	{
		"ValveBiped.Bip01_Spine",
		Vector(9,-6,-6),
		Angle(0,35,0),
	},
}

local combine = Vector(0,0,0)
local combine2 = Vector(0,0,0)

local offsets = {}
offsets["models/player/group03/male_01.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3)}
offsets["models/player/group03/male_02.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3)}
offsets["models/player/group03/male_03.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3)}
offsets["models/player/group03/male_04.mdl"] = {Vector(0,0,-1),Vector(-4,4,1)}
offsets["models/player/group03/male_05.mdl"] = {Vector(0,-2,-1), Vector(-5,4,0)}
offsets["models/player/group03/male_06.mdl"] = {Vector(0,-1,-1),Vector(-4,5,0.4)}
offsets["models/player/group03/male_08.mdl"] = {Vector(0,-1,-1), Vector(-4,5,0.4)}
offsets["models/player/group03/male_09.mdl"] = {Vector(0,-1,-1), Vector(-4,5,3)}
offsets["models/player/group03/female_01.mdl"] = {Vector(0,-1,-1), Vector(0,-2,-3)}
offsets["models/player/group03/female_02.mdl"] = {Vector(0,-1,-1), Vector(-4,5,3.5)}
offsets["models/player/group03/female_03.mdl"] = {Vector(0,-1,-1),Vector(-4,4,0.9)}
offsets["models/player/group03/female_04.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3.5)}
offsets["models/player/group03/female_05.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3.5)}
offsets["models/player/group03/female_06.mdl"] = {Vector(0,-1,-1),Vector(-4,4,3.5)}
offsets["models/player/combine_soldier.mdl"] = {Vector(0,-1.5,-1), Vector(-3,4,-3)}
offsets["models/player/combine_soldier_prisonguard.mdl"] = {Vector(0,-1.5,0), Vector(-5,5,-2)}
offsets["models/player/combine_super_soldier.mdl"] = {Vector(1,-1,-1), Vector(-4,5,-1)}
local holsters = {}

function HolsterDraw(Ply, Weapon, HolsterData, Override)
	if IsValid(Ply) and IsValid(Weapon) and HolsterData and (HolsterData[6] or Weapon:GetModel()) then
		local HolsterModel = Weapon.gmp_HolsterModel
		if not HolsterModel then
			HolsterModel = ClientsideModel(HolsterData[6] or Weapon:GetModel(), RENDERGROUP_OPAQUE)
			HolsterModel:SetNoDraw(true)
			HolsterModel:SetMoveType( MOVETYPE_NONE )
			HolsterModel:SetParent(Ply)
			HolsterModel.GetWeaponColor = function()
				return Ply:GetWeaponColor()
			end
			Weapon.gmp_HolsterModel = HolsterModel
		end
		local Source = IsValid(Override) and Override or Ply
		local Bone = Source:LookupBone(HolsterData[1])
		if Bone then
			local BonePos, BoneAng = Source:GetBonePosition(Bone)
			local Pos = CopyVector(HolsterData[2])
			Pos:Rotate(BoneAng)
			HolsterModel:SetPos(BonePos + Pos)
			HolsterModel:SetAngles(AddAngles(BoneAng, HolsterData[3]))
			HolsterModel:SetRenderOrigin(BonePos + Pos)
			HolsterModel:SetRenderAngles(AddAngles(BoneAng, HolsterData[3]))
			HolsterModel:SetupBones()
			HolsterModel:SetSkin(Weapon:GetSkin())
			--HolsterModel:SetMaterial(Weapon:GetMaterial())
			if Weapon.WorldSkin then 
				HolsterModel:SetMaterial(Weapon.Skin)
			end
			for i = 0, HolsterModel:GetNumBodyGroups() - 1 do
				HolsterModel:SetBodygroup(i, Weapon:GetBodygroup(i) or 0)
			end
			HolsterModel:SetColor(Weapon:GetColor())
			if HolsterData[5] then
				HolsterData[5](HolsterModel, Ply, Weapon, HolsterData, Override)
			end
			HolsterModel:DrawModel()
			if HolsterData[4] then
				HolsterData[4](HolsterModel, Ply, Weapon, HolsterData, Override)
			end
			if HolsterData[7] and false then
				local hol = Weapon.holster
				
				if !hol then
					hol = ClientsideModel("models/weapons/w_eq_eholster.mdl")
					hol:SetNoDraw(true)
					hol:SetMoveType( MOVETYPE_NONE )
					hol:SetParent(Ply)
					hol.GetWeaponColor = function()
						return Ply:GetWeaponColor()
					end
					hol.wep = Weapon
					hol.ply = Ply
					Weapon.holster = hol
					table.insert(holsters,hol)
				end
				local BonePos, BoneAng = Source:GetBonePosition(Bone)
				local Pos = CopyVector(HolsterData[2])
				if Ply:getTeam() == TEAM_COMBINE then
					if Weapon:GetClass() == "weapon_liro_cpistol" then
						Pos = Pos + CopyVector(combine)
					else
						Pos = Pos + CopyVector(combine2)
					end
				end
				if offsets[Ply:GetModel()] or offsets[Ply:GetModel():Replace("group03m","group03")] then
					local offset = offsets[Ply:GetModel()]

					if Ply:GetModel():find("group03m") then offset = offsets[Ply:GetModel():Replace("group03m","group03")] end
					if Weapon:GetClass() == "weapon_liro_cpistol" then
						Pos = Pos + CopyVector(offset[2])
					else
						Pos = Pos + CopyVector(offset[1])
					end
				end
				hol:DrawModel()
				Pos:Rotate(BoneAng)
				hol:SetPos(BonePos + Pos + CopyVector(HolsterData[9]))
				hol:SetAngles(AddAngles(BoneAng, HolsterData[8]))
				hol:SetRenderOrigin(BonePos + Pos + CopyVector(HolsterData[9]))
				hol:SetRenderAngles(AddAngles(BoneAng, HolsterData[8]))
				hol:SetupBones()
				hol:SetSkin(Weapon:GetSkin())
			end
		end
	end
end

local function SwbHolsterDraw(Ply)
		if Ply and not IsValid(Ply) then return end
		local Override = false
		if not Ply then
			return
		end

		if IsValid(Ply) and not Ply:InVehicle() then
			local HolsterData = nil
			local ActiveWeapon = Ply:GetActiveWeapon()
			for _, Weapon in pairs(Ply:GetWeapons()) do
				if IsValid(Weapon) and Weapon ~= ActiveWeapon then
					HolsterData = SWBHolsterData[Weapon:GetClass()]
					if not HolsterData then
						local WeaponModel = Weapon:GetModel()
						local SearchPath = "models/weapons/"
						if WeaponModel and WeaponModel:lower():sub(1, SearchPath:len()) == SearchPath then
							HolsterData = SWBHolsterData[WeaponModel:sub(SearchPath:len() + 1):lower()]
						end
					end
				end
				if HolsterData then
					HolsterDraw(Ply, Weapon, HolsterData, Override)
				end
				HolsterData = nil
			end
		end

end
hook.Add("PostPlayerDraw", "SwbHolsterDraw", SwbHolsterDraw)

