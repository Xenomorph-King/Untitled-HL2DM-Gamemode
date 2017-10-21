local plymeta = FindMetaTable("Player")

TEAM_UNSPEC = 0
TEAM_COMBINE = 1
TEAM_REBELS = 2

CLASS_UNSPEC = 0
CLASS_SOLDIER = 1
CLASS_HEAVY = 2
CLASS_MEDIC = 3
CLASS_SCOUT = 4
CLASS_ENGI = 5
CLASS_RECON = 6

teamNames = {}
teamNames[TEAM_UNSPEC] = "Unspecified"
teamNames[TEAM_COMBINE] = "Combine"
teamNames[TEAM_REBELS] = "Rebels"

classNames = {}
classNames[CLASS_UNSPEC] = "Unspecified"
classNames[CLASS_SOLDIER] = "Soldier"
classNames[CLASS_HEAVY] = "Heavy Soldier"
classNames[CLASS_MEDIC] = "Medic"
classNames[CLASS_SCOUT] = "Scout"
classNames[CLASS_ENGI] = "Engineer"
classNames[CLASS_RECON] = "Recon"

teamColor = {}
teamColor[TEAM_REBELS] = Color(230, 126, 34)
teamColor[TEAM_COMBINE] = Color(52, 152, 219)
teamColor[TEAM_UNSPEC] = Color(255, 255, 0)

local rebelModels = {
	"models/player/Group03/Male_01.mdl",
	"models/player/Group03/Male_02.mdl",
	"models/player/Group03/Male_03.mdl",
	"models/player/Group03/Male_04.mdl",
	"models/player/Group03/Male_05.mdl",
	"models/player/Group03/Male_06.mdl",
	"models/player/Group03/Male_07.mdl",
	"models/player/Group03/Male_08.mdl",
	"models/player/Group03/Male_09.mdl",
	"models/player/Group03/Female_01.mdl",
	"models/player/Group03/Female_02.mdl",
	"models/player/Group03/Female_03.mdl",
	"models/player/Group03/Female_04.mdl",
	"models/player/Group03/Female_06.mdl",
}

local rebelCitizenModels = {
	"models/player/Group01/Male_01.mdl",
	"models/player/Group01/Male_02.mdl",
	"models/player/Group01/Male_03.mdl",
	"models/player/Group01/Male_04.mdl",
	"models/player/Group01/Male_05.mdl",
	"models/player/Group01/Male_06.mdl",
	"models/player/Group01/Male_07.mdl",
	"models/player/Group01/Male_08.mdl",
	"models/player/Group01/Male_09.mdl",
	"models/player/Group01/Female_01.mdl",
	"models/player/Group01/Female_02.mdl",
	"models/player/Group01/Female_03.mdl",
	"models/player/Group01/Female_04.mdl",
	"models/player/Group01/Female_06.mdl",
}

local rebelRefugeeModels = {
//	"models/player/Group02/Male_01.mdl",
	"models/player/Group02/Male_02.mdl", // good
	//"models/player/Group02/Male_03.mdl",
	"models/player/Group02/Male_04.mdl", // good
	//"models/player/Group02/Male_05.mdl",
	"models/player/Group02/Male_06.mdl", // good
	//"models/player/Group02/Male_07.mdl",
	"models/player/Group02/Male_08.mdl", // good
	//"models/player/Group02/Male_09.mdl",
	//"models/player/Group02/Female_01.mdl",
	"models/player/Group02/Female_02.mdl", // good
	//"models/player/Group02/Female_03.mdl",
	"models/player/Group02/Female_04.mdl", // good
	"models/player/Group02/Female_07.mdl", // good
}

local rebelMedicModels = {
	"models/player/Group03m/Male_01.mdl",
	"models/player/Group03m/Male_02.mdl",
	"models/player/Group03m/Male_03.mdl",
	"models/player/Group03m/Male_04.mdl",
	"models/player/Group03m/Male_05.mdl",
	"models/player/Group03m/Male_06.mdl",
	"models/player/Group03m/Male_07.mdl",
	"models/player/Group03m/Male_08.mdl",
	"models/player/Group03m/Male_09.mdl",
	"models/player/Group03m/Female_01.mdl",
	"models/player/Group03m/Female_02.mdl",
	"models/player/Group03m/Female_03.mdl",
	"models/player/Group03m/Female_04.mdl",
	"models/player/Group03m/Female_06.mdl",
}

// format is playerLoadout[team][class] = {armour, weapontable, modeltable, onspawnfunction}

playerLoadout = {}
playerLoadout[TEAM_COMBINE] = {}
playerLoadout[TEAM_COMBINE][CLASS_UNSPEC] = {
	100, 
	{}, 
	rebelModels
}
playerLoadout[TEAM_COMBINE][CLASS_SOLDIER] = {
	100, 
	{"weapon_liro_stunstick", "weapon_liro_ar2", "weapon_liro_cpistol", 
	"weapon_liro_grenade", "weapon_liro_grenade_smoke"}, 
	{"models/player/combine_soldier.mdl"}
}
playerLoadout[TEAM_COMBINE][CLASS_HEAVY] = {
	150, 
	{"weapon_liro_stunstick", "weapon_liro_ar2", "weapon_liro_cpistol", "weapon_liro_grenade"}, 
	{"models/player/combine_super_soldier.mdl"}, 
	function(ply) 
		if CLIENT then return end
		ply:SetAmmo(3,2)
	end  
}
playerLoadout[TEAM_COMBINE][CLASS_MEDIC] = {
	50, 
	{"weapon_liro_stunstick", "weapon_liro_spas12", "weapon_liro_cpistol", "weapon_liro_medkit"}, 
	{"models/player/combine_soldier_prisonguard.mdl"}
}
playerLoadout[TEAM_COMBINE][CLASS_SCOUT] = {
	0, 
	{"weapon_liro_stunstick", "weapon_liro_smg", "weapon_liro_pistol", "weapon_liro_emp"}, 
	{"models/player/police.mdl"}, 
	function(ply) 
		if CLIENT then return end
		ply:SetRun(1.5, true)
	end  
}
playerLoadout[TEAM_COMBINE][CLASS_ENGI] = {
	75, 
	{"weapon_liro_stunstick", "weapon_liro_spas12", "weapon_liro_cpistol"}, 
	{"models/player/combine_soldier_prisonguard.mdl"}, 
	function(ply) 
		if CLIENT then return end
		timer.Simple(0.1, function()
			ply:SetSkin(1)
		end)
	end  
}
playerLoadout[TEAM_COMBINE][CLASS_RECON] = {
	75, 
	{"weapon_liro_stunstick", "weapon_liro_csniper", "weapon_liro_cpistol"}, 
	{"models/player/combine_soldier.mdl"}, 
	function(ply) 
		if CLIENT then return end
		ply:SetRun(0.75)
	end  
}


playerLoadout[TEAM_REBELS] = {}
playerLoadout[TEAM_REBELS][CLASS_UNSPEC] = {
	100, 
	{}, 
	rebelModels
}
playerLoadout[TEAM_REBELS][CLASS_SOLDIER] = {
	85, 
	{"weapon_liro_crowbar", "weapon_liro_smg", "weapon_liro_pistol", 
	"weapon_liro_grenade", "weapon_liro_grenade_smoke"}, 
	rebelModels 
}
playerLoadout[TEAM_REBELS][CLASS_HEAVY] = {
	125, 
	{"weapon_liro_crowbar", "weapon_liro_ar2", "weapon_liro_pistol", "weapon_liro_grenade"}, 
	rebelModels  
}
playerLoadout[TEAM_REBELS][CLASS_MEDIC] = {
	35, 
	{"weapon_liro_crowbar", "weapon_liro_smg", "weapon_liro_pistol", "weapon_liro_medkit"}, 
	rebelMedicModels  
}
playerLoadout[TEAM_REBELS][CLASS_SCOUT] = {
	35, 
	{"weapon_liro_crowbar", "weapon_liro_smg", "weapon_liro_pistol", "weapon_liro_emp", "weapon_liro_grenade_smoke"}, 
	rebelCitizenModels, 
	function(ply) 
		if CLIENT then return end
		ply:SetRun(1.5, true)
	end  
}
playerLoadout[TEAM_REBELS][CLASS_ENGI] = {
	35, 
	{"weapon_liro_crowbar", "weapon_liro_spas12", "weapon_liro_pistol"}, 
	rebelModels 
}
playerLoadout[TEAM_REBELS][CLASS_RECON] = {
	75, 
	{"weapon_liro_crowbar", "weapon_liro_crossbow", "weapon_liro_357"}, 
	rebelModels, 
	function(ply) 
		if CLIENT then return end
		ply:SetRun(0.75, true)
	end   

}


playerLoadout[TEAM_UNSPEC] = {}
function plymeta:getTeam() 
	return self:GetNWInt("team",0)
end

function plymeta:setTeam(num)
	if not num or not teamNames[num] then
		num = 0
	end 
	self:SetNWInt("team",num)
end

function plymeta:getClass() 
	return self:GetNWInt("class",0)
end

function plymeta:setClass(class)
	self:SetNWInt("class",class)
end