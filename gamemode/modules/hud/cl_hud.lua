include("cl_wepswitch.lua")
function GM:HUDShouldDraw(name)
	if(name == "CHudHealth") or (name == "CHudBattery") or (name == "CHudAmmo") or (name == "CHudSecondaryAmmo") or (name == "CHudCrosshair") then
		return false
	end
	return true
end



function surface.OutlinedBox( x, y, w, h, thickness, clr )
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

GM.overlay = nil

function GM:DrawCHealth()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.22
	local x = ScrW()/95.999999999997
	local x2 = ScrW()/76.80000000000
	surface.SetDrawColor(44, 62, 80, 200)
	surface.OutlinedBox(x, y, ScrW()/6.2, 150, 5)
	surface.SetDrawColor(52, 73, 94, 200)
	surface.DrawRect(x2, y+5, (ScrW()/6.2)-10, 140)	

	local hp = math.Round(ply:Health()/ply:GetMaxHealth()*100)
	local armor = math.Round(ply:Armor()/ply:GetMaxArmor()*100)
	local col = Color(255,255,255)
	local col2 = Color(41, 128, 185)
	if hp <= 50 and hp > 20 then
		col = Color(230, 126, 34)
	elseif hp <= 20 then
		col = Color(231, 76, 60)
	end

	if armor <= 50 and armor > 20 then
		col2 = Color(230, 126, 34)
	elseif armor <= 20 then
		col2 = Color(231, 76, 60)
	end

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col )
	surface.SetTextPos( x + 10, y-5 )
	surface.DrawText( "HEALTH: ".. hp .."%" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 10, y+60 )
	surface.DrawText( "ARMOR:" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 170, y+60 )
	surface.DrawText( armor .. "%" )

	if (!self.overlay) then
		self.overlay = Material("effects/combine_binocoverlay")
		self.overlay:SetFloat("$alpha", "0.4")
		self.overlay:Recompute()
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.overlay)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

end

function GM:RenderScreenspaceEffects()
	local brightness = 0.05
	local color2 = 0.25
	local curTime = CurTime()


	local color = {}
	color["$pp_colour_addr"] = 0
	color["$pp_colour_addg"] = 0
	color["$pp_colour_addb"] = 0
	color["$pp_colour_brightness"] = brightness * -1
	color["$pp_colour_contrast"] = 1.25
	color["$pp_colour_colour"] = math.Clamp(0.7 - color2, 0, 1)
	color["$pp_colour_mulr"] = 0
	color["$pp_colour_mulg"] = 0
	color["$pp_colour_mulb"] = 0

	local should_draw = hook.Run("ModifyColorCorrection", color)
	if should_draw then
		DrawColorModify(color)
	end

end

function GM:ModifyColorCorrection(color)

	if (LocalPlayer():getTeam() == TEAM_COMBINE) and LocalPlayer():Alive() then
		color["$pp_colour_addg"] = color["$pp_colour_addg"] + 0.02
		color["$pp_colour_addb"] = color["$pp_colour_addb"] + 0.2
		if LocalPlayer():getClass() == CLASS_HEAVY then
			color["$pp_colour_addr"] = color["$pp_colour_addr"] + 0.3
			color["$pp_colour_addg"] = color["$pp_colour_addg"] - 0.02
			color["$pp_colour_addb"] = color["$pp_colour_addb"] - 0.2
		end 

		color["$pp_colour_brightness"] = color["$pp_colour_brightness"] + 0.01
	elseif LocalPlayer():getTeam() == TEAM_REBELS and LocalPlayer():Alive() and LocalPlayer():getClass() != CLASS_UNSPEC  then
		return false
	elseif LocalPlayer():getClass() == CLASS_UNSPEC then
		color["$pp_color_addr"] = 0
		color["$pp_color_addb"] = 0
		color["$pp_color_addg"] = 0
		color["$pp_colour_brightness"] = -1
	end

	self.color = 0
	self.deltaColor = 0
	self.deltaColor = math.Approach(self.deltaColor, 0.5, FrameTime() * 0.25)
	color["$pp_colour_colour"] = math.max(color["$pp_colour_colour"] + self.deltaColor, 0)
	return true
end

function GetAmmoForCurrentWeapon( ply )
	if ( !IsValid( ply ) ) then return -1 end

	local wep = ply:GetActiveWeapon()
	if ( !IsValid( wep ) ) then return -1 end

	return ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
end


function GM:DrawCAmmo()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.22
	local x = ScrW()/1.21
	local x2 = ScrW()/1.2061992160121
	local wep = ply:GetActiveWeapon()
	if !wep or !IsValid(wep) then return end
	local clip = wep:Clip1()
	local maxclip = wep.Primary.ClipSize
	local clipp = math.Round(clip/maxclip*100)
	local extra = GetAmmoForCurrentWeapon(ply)
	local extramax = wep.Primary.MaxClip-maxclip
	local col = Color(255,255,255)
	local col2 = Color(46, 204, 113)
	local txt = "clip"
	if wep.NoAmmo then return end
	if wep:GetClass():find("grenade") then txt = "num" end
	surface.SetDrawColor(44, 62, 80, 200)
	surface.OutlinedBox(x, y, ScrW()/6.2, 150, 5)
	surface.SetDrawColor(52, 73, 94, 200)
	surface.DrawRect(x2, y+5, (ScrW()/6.2)-10, 140)	


	if clipp <= 60 and clipp > 30 then
		col = Color(230, 126, 34)
	elseif clipp <= 30 then
		col = Color(231, 76, 60)
	end
	if extra < maxclip and extra > 0 then
		col2 = Color(230, 126, 34)
	elseif extra == 0 then
		col2 = Color(231, 76, 60)
	end

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col )
	surface.SetTextPos( x + 10, y-5 )
	surface.DrawText( txt:upper() .. ":  ".. clip .."/"..maxclip )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 10, y+60 )
	surface.DrawText( "EXTRA:" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 140, y+60 )
	surface.DrawText( extra .."/".. extramax )
end

function GM:DrawHealth()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.22
	local x = ScrW()/95.999999999997
	local x2 = ScrW()/76.80000000000
	draw.RoundedBox(12, x, y, ScrW()/6.2, 150, Color(127, 140, 141, 50))
	surface.SetDrawColor(149, 165, 166, 50)
	surface.DrawRect(x2, y+5, (ScrW()/6.2)-10, 140)	

	local hp = math.Round(ply:Health()/ply:GetMaxHealth()*100)
	local armor = math.Round(ply:Armor()/ply:GetMaxArmor()*100)
	local col = Color(255,255,255)
	local col2 = Color(26, 188, 156)
	if hp <= 50 and hp > 20 then
		col = Color(211, 134, 0)
	elseif hp <= 20 then
		col = Color(192, 57, 43)
	end

	if armor <= 50 and armor > 20 then
		col2 = Color(211, 134, 0)
	elseif armor <= 20 then
		col2 = Color(192, 57, 43)
	end

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col )
	surface.SetTextPos( x + 10, y-5 )
	surface.DrawText( "HEALTH: ".. hp .."%" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 10, y+60 )
	surface.DrawText( "ARMOR:" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 170, y+60 )
	surface.DrawText( armor .. "%" )


end

function getTextSize(font,text)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

local newHP = 200
local newArmor = 100
function GM:DrawHealth()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.2
	local w = ScrW()/5
	local h = ScrH()/20

	surface.SetDrawColor(230, 126, 34, 200)
	surface.DrawRect(0, y, w, h)

	surface.SetDrawColor(44, 62, 80, 200)
	surface.DrawRect(0, y+h, w, ScrH()-y-h)	

	//local txt = classNames[ply:getClass() or 0]:upper()
	txt = "VITALS"

	local x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(w/2-x2/2,y+h/2-y2/2)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	w = ScrW()/5.135
	h = ScrH()/20
	
	// thanks darkrp
	local maxHealth = ply:GetMaxHealth()
    local myHealth = ply:Health()
    newHP = math.min(maxHealth, (newHP == myHealth and newHP) or Lerp(0.2, newHP, myHealth))
	local healthRatio = math.Min(newHP / maxHealth, 1)

	surface.SetDrawColor(192, 57, 43, 200)
	surface.DrawRect(5, y+h+5, w, h)

	surface.SetDrawColor(231, 76, 60, 200)
	surface.DrawRect(5, y+h+5, w*healthRatio, h)

	txt = myHealth.."HP"

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(5+w/2-x2/2,y+h)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	local maxArmor = playerLoadout[TEAM_REBELS][ply:getClass()][1]
    local myArmor = ply:Armor()
    newArmor = math.min(maxArmor, (newArmor == myArmor and newArmor) or Lerp(0.2, newArmor, myArmor))
	local armorRatio = math.Min(newArmor / maxArmor, 1)

	surface.SetDrawColor(201, 196, 15, 200)
	surface.DrawRect(5, y+h+h+10, w, h)

	surface.SetDrawColor(241, 196, 15, 200)
	surface.DrawRect(5, y+h+h+10, w*armorRatio, h)

	txt = myArmor.."AP"

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(5+w/2-x2/2,y+h+h+5)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

end



function GM:DrawAmmo()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.22
	local x = ScrW()/1.21
	local x2 = ScrW()/1.2061992160121
	local wep = ply:GetActiveWeapon()

	if !wep or !IsValid(wep) then return end

	local clip = wep:Clip1()
	local maxclip = wep.Primary.ClipSize
	local clipp = math.Round(clip/maxclip*100)
	local extra = GetAmmoForCurrentWeapon(ply)
	local extramax = wep.Primary.MaxClip-maxclip
	local col = Color(255,255,255)
	local col2 = Color(26, 188, 156)
	local txt = "clip"

	if wep:GetClass() == "weapon_liro_crowbar" then return end
	if wep:GetClass():find("grenade") then txt = "num" end

	draw.RoundedBox(12, x, y, ScrW()/6.2, 150, Color(127, 140, 141, 100))
	surface.SetDrawColor(149, 165, 166, 50)
	surface.DrawRect(x2, y+5, (ScrW()/6.2)-10, 140)	

	if clipp <= 60 and clipp > 30 then
		col = Color(211, 134, 0)
	elseif clipp <= 30 then
		col = Color(192, 57, 43)
	end
	if extra < maxclip and extra > 0 then
		col2 = Color(211, 134, 0)
	elseif extra == 0 then
		col2 = Color(192, 57, 43)
	end



	surface.SetFont( "Borg48" )
	surface.SetTextColor( col )
	surface.SetTextPos( x + 10, y-5 )
	surface.DrawText( txt:upper() .. ":  ".. clip .."/"..maxclip )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 10, y+60 )
	surface.DrawText( "EXTRA:" )

	surface.SetFont( "Borg48" )
	surface.SetTextColor( col2 )
	surface.SetTextPos( x + 140, y+60 )
	surface.DrawText( extra .."/".. extramax )
end

local newClip = 30
local newRes = 30
function GM:DrawAmmo()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local wep = ply:GetActiveWeapon()
	if !wep or !IsValid(wep) then return end
	if wep:GetClass():find("crowbar") or wep:GetClass():find("stunstick") then return end

	local y = ScrH()/1.20
	local w = ScrW()/5
	local h = ScrH()/20
	local x = ScrW()-w
	surface.SetDrawColor(230, 126, 34, 200)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(44, 62, 80, 200)
	surface.DrawRect(x, y+h, w, ScrH()-y-h)	

	local txt = classNames[ply:getClass()]:upper()
	txt = "AMMUNITION"

	local x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+w/2-x2/2,y+h/2-y2/2)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	w = ScrW()/5.135
	h = ScrH()/20
	
	// thanks darkrp

	//local extra = GetAmmoForCurrentWeapon(ply)
	//local extramax = wep.Primary.MaxClip-maxclip

	local maxClip = wep.Primary.ClipSize
    local myClip = wep:Clip1()
    newClip = math.min(maxClip, (newClip == myClip and newClip) or Lerp(0.2, newClip, myClip))
	local clipRatio = math.Min(newClip / maxClip, 1)

	surface.SetDrawColor(229, 0, 121, 200)
	surface.DrawRect(x+5, y+h+5, w, h)

	surface.SetDrawColor(255, 0, 135, 200)
	surface.DrawRect(x+5, y+h+5, w*clipRatio, h)

	txt = myClip.."/"..maxClip

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+5+w/2-x2/2,y+h-y2/20)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	local maxRes = wep.Primary.MaxClip-maxClip
    local myRes = GetAmmoForCurrentWeapon(ply)
    newRes = math.min(maxRes, (newRes == myRes and newRes) or Lerp(0.2, newRes, myRes))
	local resRatio = math.Min(newRes / maxRes, 1)

	surface.SetDrawColor(229, 227, 9, 200)
	surface.DrawRect(x+5, y+h+h+10, w, h)

	surface.SetDrawColor(255, 252, 10, 200)
	surface.DrawRect(x+5, y+h+h+10, w*resRatio, h)

	txt = myRes.."/"..maxRes

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+5+w/2-x2/2,y+h+h+5-y2/20)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)
end

local newHP = 200
local newArmor = 100
function GM:DrawCHealth()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local y = ScrH()/1.2
	local w = ScrW()/5
	local h = ScrH()/20

	surface.SetDrawColor(52, 152, 219, 200)
	surface.DrawRect(0, y, w, h)

	surface.SetDrawColor(44, 62, 80, 200)
	surface.DrawRect(0, y+h, w, ScrH()-y-h)	

	//local txt = classNames[ply:getClass() or 0]:upper()
	txt = "VITALS"

	local x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(w/2-x2/2,y+h/2-y2/2)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	w = ScrW()/5.135
	h = ScrH()/20
	
	// thanks darkrp
	local maxHealth = ply:GetMaxHealth()
    local myHealth = ply:Health()
    newHP = math.min(maxHealth, (newHP == myHealth and newHP) or Lerp(0.2, newHP, myHealth))
	local healthRatio = math.Min(newHP / maxHealth, 1)

	surface.SetDrawColor(39, 174, 96, 200)
	surface.DrawRect(5, y+h+5, w, h)

	surface.SetDrawColor(46, 204, 113, 200)
	surface.DrawRect(5, y+h+5, w*healthRatio, h)

	txt = myHealth.."HP"

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(5+w/2-x2/2,y+h)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	local maxArmor = playerLoadout[TEAM_COMBINE][ply:getClass()][1]
    local myArmor = ply:Armor()
    newArmor = math.min(maxArmor, (newArmor == myArmor and newArmor) or Lerp(0.2, newArmor, myArmor))
	local armorRatio = math.Min(newArmor / maxArmor, 1)

	surface.SetDrawColor(61, 30, 229, 200)
	surface.DrawRect(5, y+h+h+10, w, h)

	surface.SetDrawColor(68, 34, 255, 200)
	surface.DrawRect(5, y+h+h+10, w*armorRatio, h)

	txt = myArmor.."AP"

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(5+w/2-x2/2,y+h+h+5)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	if (!self.overlay) then
		self.overlay = Material("effects/combine_binocoverlay")
		self.overlay:SetFloat("$alpha", "0.4")
		self.overlay:Recompute()
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.overlay)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

end



local newClip = 30
local newRes = 30
function GM:DrawCAmmo()
	local ply = LocalPlayer()
	if ply:Alive() == false then return end
	local wep = ply:GetActiveWeapon()
	if !wep or !IsValid(wep) then return end
	if wep:GetClass():find("crowbar") or wep:GetClass():find("stunstick") then return end

	local y = ScrH()/1.20
	local w = ScrW()/5
	local h = ScrH()/20
	local x = ScrW()-w
	surface.SetDrawColor(52, 152, 219, 200)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(44, 62, 80, 200)
	surface.DrawRect(x, y+h, w, ScrH()-y-h)	

	local txt = classNames[ply:getClass()]:upper()
	txt = "AMMUNITION"

	local x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+w/2-x2/2,y+h/2-y2/2)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	w = ScrW()/5.135
	h = ScrH()/20
	
	// thanks darkrp

	//local extra = GetAmmoForCurrentWeapon(ply)
	//local extramax = wep.Primary.MaxClip-maxclip

	local maxClip = wep.Primary.ClipSize
    local myClip = wep:Clip1()
    newClip = math.min(maxClip, (newClip == myClip and newClip) or Lerp(0.2, newClip, myClip))
	local clipRatio = math.Min(newClip / maxClip, 1)

	surface.SetDrawColor(22, 160, 133, 200)
	surface.DrawRect(x+5, y+h+5, w, h)

	surface.SetDrawColor(26, 188, 156, 200)
	surface.DrawRect(x+5, y+h+5, w*clipRatio, h)

	txt = myClip.."/"..maxClip

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+5+w/2-x2/2,y+h-y2/20)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)

	local maxRes = wep.Primary.MaxClip-maxClip
    local myRes = GetAmmoForCurrentWeapon(ply)
    newRes = math.min(maxRes, (newRes == myRes and newRes) or Lerp(0.2, newRes, myRes))
	local resRatio = math.Min(newRes / maxRes, 1)

	surface.SetDrawColor(142, 68, 173, 200)
	surface.DrawRect(x+5, y+h+h+10, w, h)

	surface.SetDrawColor(155, 89, 182, 200)
	surface.DrawRect(x+5, y+h+h+10, w*resRatio, h)

	txt = myRes.."/"..maxRes

	x2,y2 = getTextSize("Borg60",txt)

	surface.SetTextPos(x+5+w/2-x2/2,y+h+h+5-y2/20)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(txt)
end

local OVERLAY_BG = Color(0, 0, 0, 175)

GM.overlayID = GM.overlayID or 0
GM.overlayText = GM.overlayText or {}
GM.overlayID = GM.overlayID or 0



local function findThing(id)
	local thing = nil
	for k,v in pairs(GAMEMODE.overlayText) do
		if v.id == id then thing = k end
	end
	return thing
end

function GM:AddOverlayText(text, bgColor)
	self.overlayID = self.overlayID + 1
	text = "<:: "..string.upper(text)
	local id = self.overlayID
	if (bgColor) then
		bgColor.a = 175
	end

	local data = {
		text = "",
		bgColor = bgColor,
		id = self.overlayID
	}

	table.insert(self.overlayText, data)

	if (#self.overlayText > 8) then
		table.remove(self.overlayText, 1)
	end
	local i = 1
	local uniqueID = "OverlayText"..self.overlayID
	local ID = self.overlayID
	timer.Create(uniqueID, 0.025, #text + 1, function()
		data.text = string.sub(text, 1, i)
		i = i + 1

		if (data.text == #text) then
			LocalPlayer():EmitSound("buttons/button24.wav", 40, 135)
			timer.Remove(uniqueID)
		else
			LocalPlayer():EmitSound("buttons/button24.wav", 40, 135)
		end
	end)

	timer.Simple(15, function()
		table.RemoveByValue(self.overlayText,findThing(id))
		//self.overlayText[findThing(ID)].done = true
	end)


	LocalPlayer():EmitSound("buttons/button24.wav", 40, 160)
end


function GM:HUDPaintOverlayText()
	for i = 1, #self.overlayText do
		local data = self.overlayText[i]
		local x, y = 8, (i - 1) * 30 + 8
		if not data then continue end
 		if data.done then
 			data.x = data.x-8
 		else
 			data.x = x
 		end
 		x = data.x
 		if x < -350 then
 			table.remove(self.overlayText,i)
 		end
		surface.SetFont("Borg24")
		local w, h = surface.GetTextSize(data.text)

		surface.SetDrawColor(data.bgColor or OVERLAY_BG)
		surface.DrawRect(x, y + 6, w + 12, h)

		draw.SimpleText(data.text, "Borg24", x + 6, y + 6, color_white, 0, 0)
	end
end

function GM:DrawRound()
	if (LocalPlayer():getTeam() == TEAM_UNSPEC) or (LocalPlayer():getClass() == CLASS_UNSPEC) or (!LocalPlayer():Alive()) then return end
	local time = GetGlobalInt("round_time",CurTime()+RoundTime and RoundTime or 300)
	time = time-CurTime()
	local timeSeconds = time
	time = string.FormattedTime(time, "%02i:%02i")
	local col = Color(52, 152, 219, 200)
	if LocalPlayer():getTeam() == TEAM_REBELS then
		col = Color(230, 126, 34, 200)
	end

	local txt = "ROUND #".. 7-GetGlobalInt("round_limit",6)
	local roundState = GetGlobalInt("round_state",ROUND_PREP)
	if roundState == ROUND_PREP then
		txt = txt .. " - PREPARING"
	elseif roundState == ROUND_END then
		txt = txt .. " - OVER"
	elseif roundState == ROUND_ACTIVE then
		txt = txt .. " - ACTIVE"
	else 
		txt = txt .. " - WAITING"
		time = "00:00"
	end


	surface.SetFont("Borg30")

	local w2,h2 = surface.GetTextSize(txt)
	local y = 0

	surface.SetDrawColor(col)
	surface.DrawRect(ScrW()/2-w2/2 - 15, y-1, w2 + 30, h2 + 2)

	surface.SetTextPos(ScrW()/2-w2/2, y)
	surface.DrawText(txt)

	local w,h = surface.GetTextSize(time)
	y = y + (h2+2)



	surface.SetDrawColor(44, 62, 80, 200)
	surface.DrawRect(ScrW()/2-w2/2 - 15, y-1, w2 + 30, h + 2)


	surface.SetTextColor(255,255,255,255)
	if math.floor(timeSeconds) % 2 == 0 and (math.floor(timeSeconds) <= 60 and roundState == ROUND_ACTIVE or (math.floor(timeSeconds) <= 5 and (roundState == ROUND_PREP or roundState == ROUND_END))) then
		surface.SetTextColor(255,0,0,255)
	end

	surface.SetTextPos(ScrW()/2-w/2, y)
	surface.DrawText(time)

end

 
function GM:HUDPaint()
	local ply = LocalPlayer()
	if ply:getTeam() == TEAM_UNSPEC and !ply.spawned then
		ply.spawned = true 
		RunConsoleCommand("gm_openspawnmenu")
	end
	if ply:Alive() then
		if ply:getTeam() == TEAM_COMBINE then
			self:DrawCHealth()
			self:DrawCAmmo()
			self:HUDPaintOverlayText()
		elseif ply:getTeam() == TEAM_REBELS then
			self:DrawHealth()
			self:DrawAmmo()
		end
		self:DrawRound()
		WSWITCH:Draw(ply)
		self:HUDDrawPickupHistory()
		self:HUDDrawTargetID()
		self:DrawCPosts()
	end
	self:DrawHitM()
end

local hitMarker = false 
net.Receive("liro_HitMarker", function()
	hitMarker = { Time = math.max(0, CurTime()), Kill = net.ReadBool() }
	//surface.PlaySound("physics/metal/paintcan_impact_soft3.wav")
	surface.PlaySound("liro/hit.wav") // credits to spykr for the code and sounds =)
end)
local hit_length = 0.3
function GM:DrawHitM()
	if hitMarker != false then
		local t = math.max(0, CurTime())
		local diff = t - hitMarker.Time
		local alpham = 1 - (diff / hit_length) 
		
		if not hitMarker.Kill then
			surface.SetDrawColor(255, 255, 255, math.min(255, 280 * alpham))
			hit_length = 0.3
		else
			surface.SetDrawColor(255, 0, 0, math.min(255, 280 * alpham))
			hit_length = 0.4
		end
		
		local length = 20
		local gap = 2
		local x = ScrW() / 2
		local y = ScrH()  / 2
		
		--top lines
		surface.DrawLine( x - gap, y - gap, x - gap - length, y - gap - length)
		surface.DrawLine( x + gap, y - gap, x + gap + length, y - gap - length)
		
		--bottom lines
		surface.DrawLine( x - gap, y + gap, x - gap - length, y + gap + length)
		surface.DrawLine( x + gap, y + gap, x + gap + length, y + gap + length)
		
		if diff >= hit_length then hitMarker = false end
	end
end


GM.posts = {} 

net.Receive("liro_getPost", function()
	local pos = net.ReadVector()
	local num = net.ReadUInt(32)
	local combine = net.ReadBool()
	local taking = net.ReadBool()
	local time = net.ReadBool()
	local ent = net.ReadEntity()
	if time then
		time = CurTime()+120
	end
	ent.time = time or 1
	local t = {}
	t.pos = pos
	t.team = combine and 1 or 2
	t.taking = taking
	t.time = time
	t.ent = ent
	t.num = num
	GAMEMODE.posts[ent:EntIndex() or num] = t
end) 

net.Receive("liro_getPosts", function()
	local t = net.ReadTable()
	GAMEMODE.posts = t
end) 


function IsOffScreen(scrpos)
	return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
end


local function DrawTarget(tgt, id, size, offset, no_shrink, col)
	local scrpos = tgt.pos:ToScreen() -- sweet
	local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size/2 or size

	scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
	   
	if IsOffScreen(scrpos) then return end

	surface.DrawRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	if sz == size then
		local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos)/39.3701).."m"
		local w, h = surface.GetTextSize(text)
		surface.SetTextColor(255, 255, 255, col.a)
		if tgt.taking then
			surface.SetTextColor(0, 0, 0, col.a+20)
		end
		surface.SetTextPos(scrpos.x - w/2, scrpos.y + (offset * sz) - h/2)
		surface.DrawText(text)

		text = "Checkpoint #".. id
		if tgt.time and tgt.time != 0 then
			text = text .. " ("..string.FormattedTime(math.Round(-1*(CurTime()-tgt.time)), "%sm %ss"):Replace("0m ","")..")"
		end
		w, h = surface.GetTextSize(text)
		if col then 
			surface.SetTextColor(col.r, col.g, col.b, col.a)
		end
		surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
		surface.DrawText(text)
	end
end



function GM:DrawCPosts()

	//PrintTable(self.posts)
	for id,post in pairs(self.posts) do
		if post.ent == NULL and false then
			self.posts[0] = nil
			continue
		end
		//surface.SetMaterial(Material())
		//print(post.time-CurTime())
		if post.ent != NULL then
			post.ent.time = post.time
		end
		local dist = math.ceil(LocalPlayer():GetPos():Distance(post.pos)/39.3701)
		if dist > 75 then continue end
		local alpha = 200-(200*(dist/75))
		local col = Color(52, 152, 219, alpha)
		if post.team == TEAM_REBELS then
			col = Color(211, 84, 0,alpha)
		end
		if post.taking then
			col = Color(236, 240, 241,alpha)
		end
		surface.SetTextColor(200, 55, 55, alpha)
		surface.SetDrawColor(col)

		DrawTarget(post, post.num, 16, 0, false, col)
	end
end

timer.Create("checkPosts", 60, 0, function()
	net.Start("requestUpdate_Posts")
		net.WriteEntity(LocalPlayer())
	net.SendToServer()
end)

net.Receive("liro_OverlayText", function()
	local data = net.ReadTable()
	if (LocalPlayer():getTeam() == TEAM_COMBINE) then
		GAMEMODE:AddOverlayText(data[1] .. " ::>", data[2])
	end
end)


GM.PickupHistory = {} 
GM.PickupHistoryLast = 0
GM.PickupHistoryTop = ScrH() / 2
GM.PickupHistoryWide = 300
GM.PickupHistoryCorner  = surface.GetTextureID( "gui/corner8" )

local pickupclr = {
   [2]  = Color(230, 126, 34),
   [1]   = Color(52, 152, 219),
}

function GM:HUDWeaponPickedUp( wep )
   if not (IsValid(wep) and IsValid(LocalPlayer())) or (not LocalPlayer():Alive()) then return end

   local name = wep.GetPrintName and wep:GetPrintName() or wep:GetClass() or "Unknown Weapon Name"

   local pickup = {}
   pickup.time      = CurTime()
   pickup.name      = string.upper(name)
   pickup.holdtime  = 5
   pickup.font      = "Borg24"
   pickup.fadein    = 0.04
   pickup.fadeout   = 0.3

   local role = LocalPlayer().getTeam and LocalPlayer():getTeam() or 0
   pickup.color = pickupclr[role]

   pickup.upper = true

   surface.SetFont( pickup.font )
   local w, h = surface.GetTextSize( pickup.name )
   pickup.height    = h
   pickup.width     = w

   if (self.PickupHistoryLast >= pickup.time) then
      pickup.time = self.PickupHistoryLast + 0.05
   end
   surface.PlaySound("items/ammo_pickup.wav")
   table.insert( self.PickupHistory, pickup )
   self.PickupHistoryLast = pickup.time

end

function GM:HUDItemPickedUp( itemname )

   if not (IsValid(LocalPlayer()) and LocalPlayer():Alive()) then return end

   local pickup = {}
   pickup.time      = CurTime()
   -- as far as I'm aware TTT does not use any "items", so better leave this to
   -- source's localisation
   pickup.name      = "#"..itemname
   pickup.holdtime  = 5
   pickup.font      = "Borg24"
   pickup.fadein    = 0.04
   pickup.fadeout   = 0.3
   pickup.color     = Color( 255, 255, 255, 255 )

   pickup.upper = false

   surface.SetFont( pickup.font )
   local w, h = surface.GetTextSize( pickup.name )
   pickup.height = h
   pickup.width  = w

   if self.PickupHistoryLast >= pickup.time then
      pickup.time = self.PickupHistoryLast + 0.05
   end

   table.insert( self.PickupHistory, pickup )
   self.PickupHistoryLast = pickup.time

end
local ammo = {}
ammo["ammo_ar2"] = "PULSE AMMO"
ammo["ammo_pistol"] = "PISTOL AMMO"
ammo["ammo_smg1"] = "SMG1 AMMO"
ammo["ammo_grenade"] = "GRENADES"
ammo["ammo_smokegrenade"] = "SMOKE GRENADES"
ammo["ammo_ar2altfire"] = "DARK ENERGY BALL"
ammo["ammo_airboatgun"] = "PULSE SNIPER AMMO"
ammo["ammo_buckshot"] = "BUCKSHOT AMMO"
ammo["ammo_xbowbolt"] = "CROSSBOW BOLTS"
ammo["ammo_357"] = ".357 AMMO"
local function TryAmmo(name)
	return ammo[name] or name
end

function GM:HUDAmmoPickedUp( itemname, amount )
   if not (IsValid(LocalPlayer()) and LocalPlayer():Alive()) then return end

   local itemname_trans = TryAmmo(string.lower("ammo_" .. itemname))

   if self.PickupHistory then

      local localized_name = string.upper(itemname_trans)
      for k, v in pairs( self.PickupHistory ) do
         if v.name == localized_name then

            v.amount = tostring( tonumber(v.amount) + amount )
            v.time = CurTime() - v.fadein
            return
         end
      end
   end

   local pickup = {}
   pickup.time      = CurTime()
   pickup.name      = string.upper(itemname_trans)
   pickup.holdtime  = 5
   pickup.font      = "Borg24"
   pickup.fadein    = 0.04
   pickup.fadeout   = 0.3
   pickup.color     = Color(205, 155, 0, 255)
   pickup.amount    = tostring(amount)

   surface.SetFont( pickup.font )
   local w, h = surface.GetTextSize( pickup.name )
   pickup.height = h
   pickup.width  = w

   local w, h = surface.GetTextSize( pickup.amount )
   pickup.xwidth = w
   pickup.width = pickup.width + w + 16

   if (self.PickupHistoryLast >= pickup.time) then
      pickup.time = self.PickupHistoryLast + 0.05
   end

   table.insert( self.PickupHistory, pickup )
   self.PickupHistoryLast = pickup.time

end


function GM:HUDDrawPickupHistory()
   if (not self.PickupHistory) then return end

   local x, y = ScrW() - self.PickupHistoryWide - 20, self.PickupHistoryTop
   local tall = 0
   local wide = 0

   for k, v in pairs( self.PickupHistory ) do
   		if not v.color then v.color = Color(255,0,0) end
      if v.time < CurTime() then

         if (v.y == nil) then v.y = y end

         v.y = (v.y*5 + y) / 6

         local delta = (v.time + v.holdtime) - CurTime()
         delta = delta / v.holdtime

         local alpha = 255
         local colordelta = math.Clamp( delta, 0.6, 0.7 )

         if delta > (1 - v.fadein) then
            alpha = math.Clamp( (1.0 - delta) * (255/v.fadein), 0, 255 )
         elseif delta < v.fadeout then
            alpha = math.Clamp( delta * (255/v.fadeout), 0, 255 )
         end

         v.x = x + self.PickupHistoryWide - (self.PickupHistoryWide * (alpha/255))


         local rx, ry, rw, rh = math.Round(v.x-4), math.Round(v.y-(v.height/2)-4), math.Round(self.PickupHistoryWide+9), math.Round(v.height+8)
         local bordersize = 8

         //surface.SetTexture( self.PickupHistoryCorner )

         surface.SetDrawColor( v.color.r, v.color.g, v.color.b, alpha )
         //surface.DrawTexturedRectRotated( rx + bordersize/2 , ry + bordersize/2, bordersize, bordersize, 0 )
         //surface.DrawTexturedRectRotated( rx + bordersize/2 , ry + rh -bordersize/2, bordersize, bordersize, 90 )
         surface.DrawRect( rx+bordersize, ry,  bordersize+v.height-8, rh)
         //surface.DrawRect( rx+bordersize, ry, v.height - 4, rh )

         --surface.SetDrawColor( 230*colordelta, 230*colordelta, 230*colordelta, alpha )
         surface.SetDrawColor( 20*colordelta, 20*colordelta, 20*colordelta, math.Clamp(alpha, 0, 200) )

         surface.DrawRect( rx+bordersize+v.height-4, ry, rw - (v.height)+12 - bordersize*2, rh )
        // surface.DrawTexturedRectRotated( rx + rw - bordersize/2 , ry + rh - bordersize/2, bordersize, bordersize, 180 )
       //  surface.DrawTexturedRectRotated( rx + rw - bordersize/2 , ry + bordersize/2, bordersize, bordersize, 270 )
         //surface.DrawRect( rx+rw-bordersize, ry+bordersize, bordersize, rh-bordersize*2 )

         draw.SimpleText( v.name, v.font, v.x+8+v.height+8, v.y - (v.height/2)+2, Color( 0, 0, 0, alpha*0.75 ) )

         draw.SimpleText( v.name, v.font, v.x+v.height+14, v.y - (v.height/2), Color( 255, 255, 255, alpha ) )

         if v.amount then
            draw.SimpleText( v.amount, v.font, v.x+self.PickupHistoryWide+2, v.y - (v.height/2)+2, Color( 0, 0, 0, alpha*0.75 ), TEXT_ALIGN_RIGHT )
            draw.SimpleText( v.amount, v.font, v.x+self.PickupHistoryWide, v.y - (v.height/2), Color( 255, 255, 255, alpha ), TEXT_ALIGN_RIGHT )
         end

         y = y + (v.height + 16)
         tall = tall + v.height + 18
         wide = math.Max( wide, v.width + v.height + 24 )

         if alpha == 0 then self.PickupHistory[k] = nil end
      end
   end

   self.PickupHistoryTop = (self.PickupHistoryTop * 5 + ( ScrH() * 0.75 - tall ) / 2 ) / 6
   self.PickupHistoryWide = (self.PickupHistoryWide * 5 + wide) / 6
end

function getHealthCol(num)
	if num < 100 and num > 80 then
		return Color(170, 230, 10, 255)
	elseif num <= 80 and num > 50 then
		return Color(230, 215, 10, 255)
	elseif num <= 50 and num > 20 then
		return Color(255, 140, 0, 255)
	elseif num <= 20 then
		return Color(255, 0, 0)
	end 
	return Color(0, 255, 0)
end

function GM:HUDDrawTargetID()
	local ply = LocalPlayer()

	local trace = ply:GetEyeTrace(MASK_SHOT)
	local ent = trace.Entity

	local x_orig = ScrW() / 2.0
	local x = x_orig
	local y = ScrH() / 2.0

	local col = color_white
	local col2 = color_white 
	local text = ""
	local text2 = ""

	if ent and ent:IsValid() then
		if ent:IsPlayer() then
			text = ent:Nick()
			if ent:getTeam() != ply:getTeam() then
				if ply:getTeam() != TEAM_COMBINE then
					col = Color(52, 152, 219)
				else
					col = Color(230, 126, 34)
				end
				col2 = Color(255,0,0)
				text2 = "ENEMY"
			else
				text2 = (math.Round(ent:Health()/ent:GetMaxHealth()*100))
				if ply:getTeam() == TEAM_COMBINE then
					col = Color(52, 152, 219)
					text = text .. " - " ..classNames[ent:getClass()]
				else
					col = Color(230, 126, 34)
				end
			end
		elseif ent.TargetID then
			local info = ent.TargetID
			text = info.text
			col = info.col or color_white
			if info.format then
				text = info.text:format(ent.targNum)
			end
		end
	end
	
	font = "targ_id"
	if text2 == "" then
		font = "targ_id"
	end
	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = x_orig - w / 2

	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0) )
	draw.SimpleText( text, font, x, y, col )

	font = "targ_id"
	surface.SetFont( font )

   -- Draw second subtitle: karma
	if ent:IsPlayer() then
		//text, clr = util.KarmaToString(ent:GetBaseKarma())
		col2 = text2 != "ENEMY" and getHealthCol(text2) or col2
		text2 = text2 .. (text2 != "ENEMY" and "%" or "")
		w, h = surface.GetTextSize( text2 )
		y = y + h + 5
		x = x_orig - w / 2

		draw.SimpleText( text2, font, x+1, y+1, Color(0,0,0) )
		draw.SimpleText( text2, font, x, y, col2 )
	end
end 