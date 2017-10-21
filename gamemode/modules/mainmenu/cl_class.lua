local fontdata = {
	font = "HALFLIFE2",
	size = 120,
	weight = 550,
	antialias = true
}
surface.CreateFont( "Weapons", fontdata )

local entstorem = {}

function createModel(panel,weap)
	local v = ClientsideModel("weapons/w_rif_m4a1.mdl",RENDERGROUP_BOTH)
	v:Spawn()
	v:SetParent(panel.Entity, panel.Entity:LookupAttachment("anim_attachment_RH"))
	v:AddEffects(EF_BONEMERGE)
	v:SetNoDraw(true)
	panel.WeaponModel = v
	table.insert(entstorem,v)
	function panel:UpdateWeapon(wepclass)
		local wep = weapons.Get(wepclass)
		if !wep then return end
			//print(wep.WorldModel)
		v:SetModel(Model(wep.WorldModel))
		self.weapon = wepClass
		v:SetParent(self.Entity, self.Entity:LookupAttachment("anim_attachment_RH"))
			
		//local anim = ActIndex[wep.HoldType:lower()]
		self.Entity:SetSequence(97)
		if wepclass:find("pistol") or wepclass:find("357") then
			self.Entity:SetSequence(109)
		elseif wepclass:find("grenade") then
			self.Entity:SetSequence(102)
		elseif wepclass:find("med") then
			self.Entity:SetSequence(112)
		elseif wepclass:find("spas") then
			self.Entity:SetSequence(111)
		elseif wepclass:find("smg") then
			self.Entity:SetSequence(113)
		elseif wepclass:find("crossbow") then
			self.Entity:SetSequence(99)
		end

	end

	function panel:LayoutEntity( ent )
			//ent:SetSequence(ACT_HL2MP__AR2)
			// self:RunAnimation()
			local mn, mx = panel.Entity:GetRenderBounds()
			local size = 0
			size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
			size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
			size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

			panel:SetFOV( 30 )
			panel:SetCamPos( Vector( size, size, size ) - Vector(0,80,20) )
			panel:SetLookAt( ( mn + mx ) * 0.5 )
	end
	
	function panel:DrawModel() --copied from DModelPanel
		local curparent = self
		local rightx = self:GetWide()
		local leftx = 0
		local topy = 0
		local bottomy = self:GetTall()
		local previous = curparent
		while( curparent:GetParent() != nil ) do
			curparent = curparent:GetParent()
			local x, y = previous:GetPos()
			topy = math.Max( y, topy + y )
			leftx = math.Max( x, leftx + x )
			bottomy = math.Min( y + previous:GetTall(), bottomy + y )
			rightx = math.Min( x + previous:GetWide(), rightx + x )
			previous = curparent
		end
		render.SetScissorRect( leftx, topy, rightx, bottomy, true )
		self.Entity:DrawModel()
		if IsValid(self.WeaponModel) then
			self.WeaponModel:DrawModel()
		end
		render.SetScissorRect( 0, 0, 0, 0, false )
	end

	panel:UpdateWeapon(weap or "weapon_liro_ar2")

end

/*
	local col = Color(44,61,79,255)
	local col2 = Color(25,25,25,255)
	local col3 = Color(29,42,54)
*/



GM.spawnMenu = nil
function GM:OpenSpawnMenu(force)
	force = force or false
	local ply = LocalPlayer()
	self:CloseSpawnMenu()
	local class = ply:getClass()

	local headerheight = 0
	local w = ScrW()
	local h = ScrH()
	local col = Color(30, 139, 195)
	local col2 = Color(107, 185, 240,255)
	local col3 = Color(37, 116, 169)
	local col4 = col3
	self.spawnMenu = vgui.Create("DFrame")
	self.spawnMenu:SetTitle("")
	self.spawnMenu:SetSize(w, h)
	self.spawnMenu:SetPos(0,0)
	self.spawnMenu:MakePopup()
	surface.SetFont("Borg41")
	local width,height = surface.GetTextSize("CLASS MENU")
	headerheight = height+6
	self.spawnMenu.Paint = function(self,w,h) 
		surface.SetDrawColor(col2.r,col2.g,col2.b,255)
		surface.DrawRect(0,0,w,h)
		surface.SetFont("Borg41")
		surface.SetTextColor(255,255,255,255)
		surface.SetDrawColor(col3)
		surface.DrawRect(0,0,w,headerheight)
		surface.SetTextPos(w/2-width/2, 3)
		surface.DrawText("CLASS MENU")
	end
	self.spawnMenu.OnRemove = function(s)
		for k,v in pairs(entstorem) do
			if v and v:IsValid() then
				v:Remove()
			end
		end
	end
	self.spawnMenu.btnMaxim:Hide()
	self.spawnMenu.btnMinim:Hide()
	self.spawnMenu:ShowCloseButton(false)
	self.spawnMenu:SetDraggable(false)

	self.spawnMenu.closeButton = vgui.Create("DButton", self.spawnMenu)
	self.spawnMenu.closeButton:SetSize(headerheight,headerheight)
	self.spawnMenu.closeButton:SetPos(ScrW()-headerheight,0)
	self.spawnMenu.closeButton:SetText("")
	self.spawnMenu.closeButton.Paint = function(s,w,h)
		surface.SetDrawColor(192, 57, 43,255)
		if s:IsHovered() or class == 0 then
			surface.SetDrawColor(127, 38, 29,255)
		end
		surface.DrawRect(0,0,w,h)
		surface.SetFont("Borg30")
		surface.SetTextColor(255,255,255,255)
		if class == 0 then
			surface.SetTextColor(200,200,200,255)
		end
		local w2,h2 = surface.GetTextSize("X")
		surface.SetTextPos(w/2-w2/2,h/2-h2/2)
		surface.DrawText("X")
	end
	self.spawnMenu.closeButton.DoClick = function()
		if class == 0 and false then
			surface.PlaySound("buttons/button2.wav")
		else
			self:CloseSpawnMenu()
		end
	end





	if ply:getTeam() == 0 or force then // if unassigned then do this stuff
		col3 = Color(29,42,54)
		self.spawnMenu.combineButton = vgui.Create("DButton", self.spawnMenu)
		self.spawnMenu.combineButton.Think = function(s)
			s:SetSize(w/2,h-headerheight)
			s:SetPos(0,headerheight)

		end
		local cCol1 = Color(52, 152, 219)
		local cCol2 = Color(41, 128, 185)
		local rCol1 = Color(230, 126, 34)
		local rCol2 = Color(211, 84, 0)
		self.spawnMenu.combineButton:SetText("")
		self.spawnMenu.combineButton.Paint = function(self,w,h)
			surface.SetDrawColor(cCol2)
			if self:IsHovered() then
				surface.SetDrawColor(cCol1)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255)
			local w2,h2 = surface.GetTextSize("COMBINE FORCES")
			surface.SetTextPos(w/2-w2/2-2,0)
			surface.DrawText("COMBINE FORCES")
		end
		self.spawnMenu.combineButton.DoClick = function()
			net.Start("liro_changeTeam")
				net.WriteEntity(LocalPlayer())
				net.WriteBool(true)
			net.SendToServer()
			self:CloseSpawnMenu()
			surface.PlaySound("ui/buttonclick.wav")
			timer.Simple(0.1, function() self:OpenSpawnMenu() end)
		end

		self.spawnMenu.rebelButton = vgui.Create("DButton", self.spawnMenu)
		self.spawnMenu.rebelButton.Think = function(s)
			s:SetSize(w/2,h-headerheight)
			s:SetPos(w/2,headerheight)
		end
		self.spawnMenu.rebelButton:SetText("")
		self.spawnMenu.rebelButton.Paint = function(self,w,h)
			surface.SetDrawColor(rCol2)
			if self:IsHovered() then
				surface.SetDrawColor(rCol1)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local w2,h2 = surface.GetTextSize("REBEL FORCES")
			surface.SetTextPos(w/2-w2/2-2,0)
			surface.DrawText("REBEL FORCES")
		end 
		self.spawnMenu.rebelButton.DoClick = function()
			net.Start("liro_changeTeam")
				net.WriteEntity(LocalPlayer())
				net.WriteBool(false)
			net.SendToServer()
			self:CloseSpawnMenu()
			surface.PlaySound("ui/buttonclick.wav")
			timer.Simple(0.1, function() self:OpenSpawnMenu() end)
		end


		self.spawnMenu.combineImage = vgui.Create("DImage", self.spawnMenu)
		self.spawnMenu.combineImage:SetImage("liro/back_combine.png")
		self.spawnMenu.combineImage:SizeToContents()
		self.spawnMenu.combineImage:SetPos(0,h-self.spawnMenu.combineImage:GetTall())


		self.spawnMenu.rebelImage = vgui.Create("DImage", self.spawnMenu)
		self.spawnMenu.rebelImage:SetImage("liro/back_rebels.png")
		self.spawnMenu.rebelImage:SizeToContents()
		self.spawnMenu.rebelImage:SetPos(w-self.spawnMenu.rebelImage:GetWide(),h-self.spawnMenu.rebelImage:GetTall())

	else

		/*
		self.spawnMenu.medButton.DoClick = function()
			net.Start("liro_changeClass")
				net.WriteEntity(LocalPlayer())
				net.WriteUInt(CLASS_MEDIC,16)
			net.SendToServer()
			self:CloseSpawnMenu()
			surface.PlaySound("ui/buttonclick.wav")
		end

		self.spawnMenu.medImage = vgui.Create("DImage", self.spawnMenu)
		self.spawnMenu.medImage:SetImage("liro/medic.png")
		self.spawnMenu.medImage:SetSize(256,256)
		self.spawnMenu.medImage:SetPos((5*w)/6-self.spawnMenu.medImage:GetWide()/2,h-self.spawnMenu.medImage:GetTall())
		*/
		if LocalPlayer():getTeam() == TEAM_REBELS then
			col = Color(243, 156, 18)
			col2 = Color(245, 171, 53,255)
			col3 = Color(230, 126, 34)
			col4 = Color(232, 126, 4)
		end



		local classSize = 80
		local panelHeight = (h-headerheight)/9

		self.spawnMenu.soldierModel = vgui.Create("DModelPanel", self.spawnMenu)
		self.spawnMenu.soldierModel:SetSize(h/3-4,ScrH()-panelHeight+2+headerheight-2)
		self.spawnMenu.soldierModel:SetPos(2,panelHeight+2+headerheight)
		self.spawnMenu.soldierModel:SetModel(table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_SOLDIER][3]):Replace("Female","Male"))
		self.spawnMenu.soldierModel:SetAnimated(true)
		local old_paint = self.spawnMenu.soldierModel.Paint
		self.spawnMenu.soldierModel.Paint = function(s,w,h)
		 	surface.SetDrawColor( col )
 			surface.DrawRect( 0, 0, s:GetWide(), s:GetTall() )
			old_paint(s,w,h)
			if s.Gun then
				s.Gun:DrawModel()
			end
		end
		local prim = "weapon_liro_smg"
		if LocalPlayer():getTeam() == TEAM_COMBINE then
			prim = "weapon_liro_ar2"
		end
		createModel(self.spawnMenu.soldierModel,prim)


		local primWep = "AR-2 PULSE RIFLE"
		local secWep = "9MM USP PISTOL"
		local utilWep = "FRAG NADE"
		local specWep = "N/A"
		local className = "SOLDIER"
		local classArmor = 200
		self.spawnMenu.selectPanel = vgui.Create("DPanel", self.spawnMenu)
		self.spawnMenu.selectPanel:SetSize(w, panelHeight)
		self.spawnMenu.selectPanel:SetPos(0,headerheight+2)
		self.spawnMenu.selectPanel:SetText("")
		self.spawnMenu.selectPanel.Paint = function(self,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,0)
			if self:IsHovered() then
				//surface.SetDrawColor(Color(243, 156, 18))
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SOLDIER"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,0)
			//surface.DrawText(txt)
		end 

		self.spawnMenu.soldierButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.soldierButton:SetPos(2,2)
		self.spawnMenu.soldierButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.soldierButton:SetText("")
		local soldMat = Material("materials/vgui/soldier2.png")
		self.spawnMenu.soldierButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SOLDIER"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)

		//	surface.SetMaterial(soldMat)
		//	surface.SetDrawColor(255,255,255)
		//	surface.DrawTexturedRect(0,0,w,h)
		end
		self.spawnMenu.soldierButton.DoClick = function(s)
			local heavModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_SOLDIER][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(heavModel)
			self.spawnMenu.soldierModel:UpdateWeapon(ply:getTeam() == TEAM_COMBINE and "weapon_liro_ar2" or "weapon_liro_smg")
			surface.PlaySound("buttons/blip1.wav")

			if LocalPlayer():getTeam() == TEAM_COMBINE then
				primWep = "AR-2 PULSE RIFLE"
				secWep = "P-2 PISTOL"
				utilWep = "FRAG/SMOKE NADE"
				specWep = "NOTHING"
				className = "SOLDIER"
				classArmor = 100
			else
				primWep = "MP7 SMG"
				secWep = "9MM USP PISTOL"
				utilWep = "FRAG/SMOKE NADE"
				specWep = "NOTHING"
				className = "SOLDIER"
				classArmor = 85
			end

		end


		self.spawnMenu.heavButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.heavButton:SetPos(ScrW()/6+2,2)
		self.spawnMenu.heavButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.heavButton:SetText("")
		local heavMat = Material("materials/vgui/heavy.png")
		self.spawnMenu.heavButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "HEAVY"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)
		end
		self.spawnMenu.heavButton.DoClick = function(s)
			local heavModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_HEAVY][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(heavModel)
			self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_ar2")
			surface.PlaySound("buttons/blip1.wav")

			if LocalPlayer():getTeam() == TEAM_COMBINE then
				primWep = "AR-2 PULSE RIFLE"
				secWep = "P-2 PISTOL"
				utilWep = "FRAG GRENADE"
				specWep = "COMBINE BALLS"
				className = "HEAVY"
				classArmor = 150
			else
				primWep = "AR-2 PULSE RIFLE"
				secWep = "9MM USP PISTOL"
				utilWep = "FRAG GRENADE"
				specWep = "NOTHING"
				className = "HEAVY"
				classArmor = 125
			end
		end

		self.spawnMenu.medButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.medButton:SetPos(2*(ScrW()/6)+2,2)
		self.spawnMenu.medButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.medButton:SetText("")
		local medMat = Material("materials/vgui/medic.png")
		self.spawnMenu.medButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "MEDIC"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)

		end
		self.spawnMenu.medButton.DoClick = function(s)
			local medModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_MEDIC][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(medModel)
			self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_spas12")
			surface.PlaySound("buttons/blip1.wav")
			if LocalPlayer():getTeam() == TEAM_COMBINE then
				primWep = "SPAS-12"
				secWep = "P-2 PISTOL"
				utilWep = "NOTHING"
				specWep = "MEDKIT"
				className = "MEDIC"
				classArmor = 50
			else
				primWep = "SPAS-12"
				secWep = "9MM USP PISTOL"
				utilWep = "NOTHING"
				specWep = "MEDKIT"
				className = "MEDIC"
				classArmor = 35
			end
		end

		self.spawnMenu.scoutButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.scoutButton:SetPos(3*(ScrW()/6)+2,2)
		self.spawnMenu.scoutButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.scoutButton:SetText("")
		self.spawnMenu.scoutButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SCOUT"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)
		end
		self.spawnMenu.scoutButton.DoClick = function(s)
			local medModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_SCOUT][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(medModel)
			self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_smg")
			surface.PlaySound("buttons/blip1.wav")
			if LocalPlayer():getTeam() == TEAM_COMBINE then
				primWep = "MP7 SMG"
				secWep = "9MM USP PISTOL"
				utilWep = "SMOKE/MANHACK"
				specWep = "INCR. SPEED"
				className = "SCOUT"
				classArmor = 0
			else
				primWep = "MP7 SMG"
				secWep = "9MM USP PISTOL"
				utilWep = "EMP/SMOKE"
				specWep = "INCR.SPEED"
				className = "SCOUT"
				classArmor = 0
			end
		end

		self.spawnMenu.engButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.engButton:SetPos(4*(ScrW()/6)+2,2)
		self.spawnMenu.engButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.engButton:SetText("")
		self.spawnMenu.engButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "ENGI."
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)
		end
		self.spawnMenu.engButton.DoClick = function(s)
			local medModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_ENGI][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(medModel)
			self.spawnMenu.soldierModel.Entity:SetSkin(1)
			self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_spas12")
			surface.PlaySound("buttons/blip1.wav")
			if LocalPlayer():getTeam() == TEAM_COMBINE then
				primWep = "SPAS-12"
				secWep = "P-2 PISTOL"
				utilWep = "EMP GRENADE"
				specWep = "BUILDABLES"
				className = "ENGINEER"
				classArmor = 75
			else
				primWep = "SPAS-12"
				secWep = "9MM USP PISTOL"
				utilWep = "EMP GRENADE"
				specWep = "BUILDABLES"
				className = "ENGINEER"
				classArmor = 0
			end
		end

		self.spawnMenu.reconButton = vgui.Create("DButton",self.spawnMenu.selectPanel)
		self.spawnMenu.reconButton:SetPos(5*(ScrW()/6)+2,2)
		self.spawnMenu.reconButton:SetSize(ScrW()/6-4,panelHeight-4)
		self.spawnMenu.reconButton:SetText("")
		self.spawnMenu.reconButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "RECON"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)
		end
		self.spawnMenu.reconButton.DoClick = function(s)
			local medModel = table.Random(playerLoadout[LocalPlayer():getTeam()][CLASS_RECON][3]):Replace("Female","Male")
			self.spawnMenu.soldierModel:SetModel(medModel)
			self.spawnMenu.soldierModel.Entity:SetSkin(1)
			surface.PlaySound("buttons/blip1.wav")
			if LocalPlayer():getTeam() == TEAM_COMBINE then
				self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_csniper")
				primWep = "COMBINE SNIPER"
				secWep = "P-2 PISTOL"
				utilWep = "NOTHING"
				specWep = "DECR. SPEED"
				className = "RECON"
				classArmor = 75
			else
				self.spawnMenu.soldierModel:UpdateWeapon("weapon_liro_crossbow")
				primWep = "CROSSBOW"
				secWep = ".357 MAGNUM REVOLVER"
				utilWep = "NOTHING"
				specWep = "DECR. SPEED"
				className = "RECON"
				classArmor = 0
			end
		end
		local panelSize = ScrH()-panelHeight+2-headerheight
		panelSize = panelSize/7
		x = h/3

		self.spawnMenu.classPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.classPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.classPanel:SetPos(x+2,panelHeight+2+headerheight)
		self.spawnMenu.classPanel:SetText("")
		self.spawnMenu.classPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() then
				//surface.SetDrawColor(Color(243, 156, 18))
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "CLASS"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = className
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end 

		self.spawnMenu.primaryPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.primaryPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.primaryPanel:SetPos(x+2,panelHeight+2+headerheight+panelSize+2)
		self.spawnMenu.primaryPanel:SetText("")
		self.spawnMenu.primaryPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
				surface.SetDrawColor(col4)
				if primWep:find("AR") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_ar2")
				elseif primWep:find("MP7") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_smg")
				elseif primWep:find("SPAS") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_spas12")
				elseif primWep:find("CROS") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_crossbow")
				end
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "PRIMARY"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = primWep
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end 

		self.spawnMenu.secondaryPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.secondaryPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.secondaryPanel:SetPos(x+2,panelHeight+2+headerheight+2+panelSize+panelSize+2)
		self.spawnMenu.secondaryPanel:SetText("")
		self.spawnMenu.secondaryPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT)then
				surface.SetDrawColor(col4)
				if secWep:find("P-2") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_cpistol")
				elseif secWep:find("357") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_357")
				else
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_pistol")
				end
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SECONDARY"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = secWep
			local w2,h2 = surface.GetTextSize(secWep)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end 

		self.spawnMenu.utilityPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.utilityPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.utilityPanel:SetPos(x+2,panelHeight+2+headerheight+2+panelSize+2+panelSize+panelSize+2)
		self.spawnMenu.utilityPanel:SetText("")
		self.spawnMenu.utilityPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
				surface.SetDrawColor(col4)
				if utilWep:find("NADE") or utilWep:find("SMOKE") then
					self:GetParent().soldierModel:UpdateWeapon("weapon_liro_grenade")
				end
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "UTILITY"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = utilWep
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end 

		self.spawnMenu.specialPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.specialPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.specialPanel:SetPos(x+2,panelHeight+2+headerheight+2+panelSize+2+panelSize+2+panelSize+panelSize+2)
		self.spawnMenu.specialPanel:SetText("")
		self.spawnMenu.specialPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() then
				//surface.SetDrawColor(Color(243, 156, 18))
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SPECIAL"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = specWep
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end


		self.spawnMenu.armPanel = vgui.Create("DPanel",self.spawnMenu)
		self.spawnMenu.armPanel:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.armPanel:SetPos(x+2,panelHeight+2+headerheight+2+panelSize+2+panelSize+2+panelSize+panelSize+2+panelSize+2)
		self.spawnMenu.armPanel:SetText("")
		self.spawnMenu.armPanel.Paint = function(self,w,h)
			local s = w/2.5
			surface.SetDrawColor(col)
			if self:IsHovered() then
				//surface.SetDrawColor(Color(243, 156, 18))
			end
			surface.DrawRect(0,0,s,h)

			surface.DrawRect(s+2,0,w-s-2,h)

			surface.SetFont("Borg101")
			surface.SetTextColor(255,255,255,255) 
			local txt = "ARMOR"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
			surface.SetFont("Borg100")
			txt = classArmor .. "AP"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(s+2+(w-s-2)/2-w2/2,h/2-h2/2)
			surface.DrawText(txt)
		end 
		
		self.spawnMenu.spawnButton = vgui.Create("DButton",self.spawnMenu)
		self.spawnMenu.spawnButton:SetSize(ScrW()-x-4, panelSize)
		self.spawnMenu.spawnButton:SetPos(x+2,panelHeight+2+headerheight+2+panelSize+2+panelSize+2+panelSize+panelSize+2+panelSize+2+panelSize+2)
		self.spawnMenu.spawnButton:SetText("")
		self.spawnMenu.spawnButton.Paint = function(s,w,h)
			surface.SetDrawColor(col)
			if s:IsHovered() then
				surface.SetDrawColor(col4)
			end
			surface.DrawRect(0,0,w,h)

			surface.SetFont("Borg48")
			surface.SetTextColor(255,255,255,255) 
			local txt = "SPAWN ("..className..")"
			local w2,h2 = surface.GetTextSize(txt)
			surface.SetTextPos(w/2-w2/2-2,h/2-h2/2)
			surface.DrawText(txt)
		end
		local classes = {}
		classes["SOLDIER"] = CLASS_SOLDIER
		classes["HEAVY"] = CLASS_HEAVY
		classes["MEDIC"] = CLASS_MEDIC
		classes["SCOUT"] = CLASS_SCOUT
		classes["ENGINEER"] = CLASS_ENGI
		classes["RECON"] = CLASS_RECON
		self.spawnMenu.spawnButton.DoClick = function(s)
			local class = classes[className]
			net.Start("liro_changeClass")
				net.WriteEntity(LocalPlayer())
				net.WriteUInt(class,16)
			net.SendToServer()
			self:CloseSpawnMenu()
			surface.PlaySound("ui/buttonclick.wav")
		end

		self.spawnMenu.soldierButton:DoClick()

	end
end

function GM:CloseSpawnMenu()
	if self.spawnMenu then 
		self.spawnMenu:Remove() 
		self.spawnMenu = nil 
	end
end

concommand.Add("gm_openspawnmenu", function(ply,cmd,args) GAMEMODE:OpenSpawnMenu(args[1] and true or false) end)