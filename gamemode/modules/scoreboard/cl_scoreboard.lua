

function draw.AAText( text, font, x, y, color, align )

    draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,math.min(color.a,120)), align )
    draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,math.min(color.a,50)), align )
    draw.SimpleText( text, font, x, y, color, align )

end

if SERVER then return end

local scoreboard
local dlist

surface.CreateFont( "Deathrun_Smooth", { font = "Arial", size = 20, weight = 700, antialias = true } )
surface.CreateFont( "Deathrun_SmoothMed", { font = "Arial", size = 20, weight = 700, antialias = true } )
surface.CreateFont( "Deathrun_SmoothBig", { font = "Arial", size = 46, weight = 100, antialias = true } )

local namecolor = {
   default = COLOR_WHITE,
   admin = color_white,
   dev = Color(100, 240, 105, 255)
};

function GM:GetScoreboardColor(ply)
   if not IsValid(ply) then return namecolor.default end

   local pgroup = ply:GetNWInt('PGroup',0)
   if ply:SteamID() == "STEAM_0:0:11123796" then
		return Color(166, 122, 238, 255)
	elseif (pgroup == 3 or ply:IsSuperAdmin()) then
      return namecolor.admin
   elseif (pgroup == 2) then
      return Color(255, 215, 0, 255)
	elseif (pgroup == 22) then
      return Color(100, 149, 200, 255)
	elseif (pgroup == 23) then
      return Color(100, 149, 237, 255)
	elseif (pgroup == 1) then
		return Color(100, 230, 105, 255)
	elseif (pgroup == 12) then
		return Color(255, 128, 0, 255)
	elseif (pgroup == 13) then
		return Color(249, 132, 229, 255)
	elseif (pgroup == 15) then
		return Color(230, 150, 229, 255)
	elseif (pgroup == 14) then
		return Color(255, 191, 0, 255)
	elseif (pgroup == 16) then
		return Color(255, 175, 0, 255)
   end
   return namecolor.default
end

local hostname_w, hostname_h
local rgb = Color
local function ScoreboardPaint( panel, w, h )
	//draw.RoundedBox( 0, 0, 0, w, h, rgb(44, 62, 80, 200) )
end

function GM:GetScoreboardIcon( ply )
	if not IsValid(ply) then return false end
	if ply:IsAdmin() then
		return "icon16/shield.png"
	end
end

local function GetTeamScoreInfo()
	local TeamInfo = {}
	for id, pl in pairs( player.GetAll() ) do
		local _team = pl:getTeam()
		local _deaths = pl:GetDeaths() 
		local _ping = pl:Ping()
		local _cash = pl:GetKills()
		local _class = pl:getClass()
		if (not TeamInfo[_team]) then
			TeamInfo[_team] = {}
			TeamInfo[_team].TeamName = teamNames[_team]:upper()
			TeamInfo[_team].Color = teamColor[_team]
			TeamInfo[_team].Players = {}
		end
		local PlayerInfo = {}
		PlayerInfo.Deaths = _deaths
		PlayerInfo.Ping = _ping
		PlayerInfo.Name = pl:Nick()
		PlayerInfo.PlayerObj = pl
		PlayerInfo.cash = _cash
		PlayerInfo.UseMat = GAMEMODE:GetScoreboardIcon( pl )
		local rank = pl:GetUserGroup()
		if rank == 'user' then rank = ''
		elseif rank == 'superadmin' and pl:SteamID() == "STEAM_0:0:27268648" then rank = 'co-owner'
		elseif rank == 'superadmin' and pl:SteamID() == "STEAM_0:0:11123796" then rank = 'great leader'
		end
		local _rank = rank 
		rank = string.sub(rank,2	,#rank)
		_rank = string.sub(_rank,0,1):upper()
		rank = _rank .. rank
		PlayerInfo.rank = rank
		PlayerInfo.rankc = GAMEMODE:GetScoreboardColor(pl)
		PlayerInfo.class = classNames[_class]:upper()
		local insertPos = #TeamInfo[_team].Players + 1
		PlayerInfo.num = insertPos
		for idx, info in pairs(TeamInfo[_team].Players) do
			if (PlayerInfo.cash > info.cash) then
				insertPos = idx
				break
			elseif (PlayerInfo.cash == info.cash) then
				if (PlayerInfo.Name < info.Name) then
					insertPos = idx
					break
				end
			end
		end
		
		table.insert(TeamInfo[_team].Players, insertPos, PlayerInfo)
	end
	if TeamInfo[TEAM_REBELS] and #TeamInfo[TEAM_REBELS].Players >= 2 then
		table.sort( TeamInfo[TEAM_REBELS].Players, function( a, b ) return a.num < b.num end )
	end
	if TeamInfo[TEAM_COMBINE] and #TeamInfo[TEAM_COMBINE].Players >= 2 then
		table.sort( TeamInfo[TEAM_COMBINE].Players, function( a, b ) return a.num < b.num end )
	end
	return TeamInfo
end

local function CreatePlayer( ply, tm, num)

	local pan = vgui.Create( "DPanel" )
	--pan:SetText("")
	pan:SetSize( 0, 30 )
	pan.UseMat = ply.UseMat or false
	if pan.UseMat then
		pan.UseMat = Material(pan.UseMat)
	end
	pan.Paint = function( self, w, h )
		--if not IsValid(ply) then self:Remove() return end
		if not self.TeamColor then
			self.TeamColor = tm.Color
			self.NickColor = tm.Color
			surface.SetFont( "Deathrun_Smooth" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h 
		local col = rgb(52, 73, 94, 240)
		if ply.num % 2 != 0 then
			col = rgb(44, 62, 80, 240)
		end
		draw.RoundedBox( 4, 0, 0, w, h, col )
		draw.AAText( ply.Name, "Deathrun_Smooth", 2 + 16 + 16, h/2 - self.maxH/2 + 2, color_white )

		if self.UseMat then
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.SetMaterial( self.UseMat )
			surface.DrawTexturedRect( w - 18 - 30, 15-8, 16, 16)
		end

		draw.AAText( ply.Ping, "Deathrun_Smooth", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		
		if ply.rank != "" and ply.rankc then draw.AAText( ply.rank, "Deathrun_Smooth", w/2, h/2 - self.maxH/2 + 2, ply.rankc, TEXT_ALIGN_CENTER ) end
		surface.SetFont("Deathrun_Smooth")
		local w1 = surface.GetTextSize(ply.class)
		if ply.PlayerObj:getTeam() == LocalPlayer():getTeam() or LocalPlayer():IsAdmin() then
			draw.AAText( ply.class, "Deathrun_Smooth", w/2+w1/2, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		end
		//draw.AAText( 'Tier '..ply.tier, "Deathrun_Smooth", w - 300, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		draw.AAText( ply.cash..' kills', "Deathrun_Smooth", w - 200, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
		draw.AAText( ply.Deaths..' deaths', "Deathrun_Smooth", w - 100, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )

	end
	
	pan.voice = vgui.Create("DImageButton", pan)
	pan.voice:SetSize(16,16)
	
	pan.voice:SetVisible(true)
	pan.voice:DockMargin(4, 4, 69, 4)
	pan.voice:Dock(RIGHT)
	
	pan.voice.DoClick = function()
	   if IsValid(ply.PlayerObj) and ply.PlayerObj != LocalPlayer() then
		  ply.PlayerObj:SetMuted(not ply.PlayerObj:IsMuted())
			if ply.PlayerObj != LocalPlayer() then
			  local muted = ply.PlayerObj:IsMuted()
			  pan.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
			else
			  pan.voice:Hide()
			end
	   end
	end
	if IsValid(ply.PlayerObj) and ply.PlayerObj != LocalPlayer() then
	  local muted = ply.PlayerObj:IsMuted()
	  pan.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
	else
	  pan.voice:Hide()
	end

	local ava = vgui.Create( "AvatarImage", pan )
	ava:SetPlayer( ply.PlayerObj, 16 )
	ava:SetSize( 30, 30 )
	ava:SetPos( 0, 0 )

	local btn = vgui.Create( "DButton", pan )
	btn:SetSize( 30, 30 )
	btn:SetPos( 0, 0 )
	btn:SetText("")
	btn.Paint = function() end
	btn.DoClick = function()

		ply.PlayerObj:ShowProfile()
		print("test")

	end

	dlist:AddItem(pan)

end

local connect_mat = Material( "icon16/server_connect.png" )

local function CreateName( name, id )

	local pan = vgui.Create( "DPanel" )
	--pan:SetText("")
	pan:SetSize( 0, 22 )
	pan.Paint = function( self, w, h )
		if not self.TeamColor then
			self.TeamColor = Color( 77, 77, 77, 250 )
			surface.SetFont( "Borg48" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h - 2
		draw.RoundedBox( 4, 0, 2, w, h, self.TeamColor )
		draw.AAText( name, "Borg48", 2 + 16 + 4, h/2 - self.maxH/2 + 2, Color(255, 255, 255, 255) )

		surface.SetDrawColor( Color(255, 255, 255, 255) )
		surface.SetMaterial( connect_mat )
		surface.DrawTexturedRect( 2, 4, 16, 16 )

		draw.AAText( id, "Borg", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
	end

	dlist:AddItem(pan)

end

local function CreateTeamThing( name, color, tm )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, 24 )
	pan.Paint = function( self, w, h )
		if not self.maxH then
			surface.SetFont( "Borg41" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
			self:SetSize( 0, h2 + 2 )
			h = h2 + 2
		end

		draw.RoundedBox( 0, 0, 0, w, h, Color(color.r,color.g,color.b,220) )
		name = tm.TeamName-- .. "  (" .. #tm.Players .. " Players)"
		draw.AAText( name, "Borg41", w/2, h/2 - self.maxH/2, Color(255,255,255,255), TEXT_ALIGN_CENTER )
	end

	dlist:AddItem(pan)

end

local function CreateEmpty( h )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, h )
	pan.Paint = function() end
	dlist:AddItem(pan)

end

local function Refresh()

	if not dlist then return end

	dlist:Clear()
	local pool = {}
	
	local teams = GetTeamScoreInfo()
	
	for k,tm in pairs(teams) do
		if k == 1 then
			CreateTeamThing( tm.TeamName, tm.Color, tm )
			for k, v in ipairs( tm.Players ) do
				--for i=0,10 do CreatePlayer(v,tm) end
				CreatePlayer(v,tm)
			end
			break
		end
	end	
	
	for k,tm in pairs(teams) do
		if k != 1 then
			CreateTeamThing( tm.TeamName, tm.Color, tm )
			for k, v in ipairs( tm.Players ) do
				--for i=0,10 do CreatePlayer(v,tm) end
				CreatePlayer(v,tm)
			end
		end
	end
	//CreateEmpty( 10 )

	if dlist.VBar then
		dlist.VBar:SetUp( dlist.VBar:GetTall(), dlist:GetTall() )
	end

end

local function CreateScoreboard()

	if scoreboard then
		scoreboard:SetVisible(true)
		Refresh()
		return
	end

	scoreboard = vgui.Create( "DFrame" )
	--
	scoreboard:ShowCloseButton(false)
	scoreboard:SetDraggable(false)
	scoreboard:SetTitle("")
	--
	scoreboard:SetSize( 800, ScrH() * 0.7 )
	--scoreboard:SetPos( ScrW()/2 - scoreboard:GetWide()/2, 5 )
	scoreboard:Center()
	scoreboard.Paint = ScoreboardPaint
	scoreboard:MakePopup()
	scoreboard:ParentToHUD()

	surface.SetFont( "Deathrun_SmoothBig" )
	local _, h = surface.GetTextSize( "|" )

	dlist = vgui.Create( "DPanelList", scoreboard )
	dlist:SetSize( scoreboard:GetWide(), scoreboard:GetTall() - (h+4) )
	dlist:SetPos( 0, 0 )
	dlist:EnableVerticalScrollbar(true)
	dlist.Padding = 0
	scoreboard.Think = function()
		local height = #player.GetAll()*30
		height = height + 22*2
		height = height + 48
		height = math.Clamp(ScrH() * 0.7, 0, height)
		scoreboard:SetHeight(height)
		scoreboard:Center()
		local x,y = scoreboard:GetPos()
		scoreboard:SetPos(x,ScrH()/2-height/1.1)
	end
	Refresh()

	/*local hn = vgui.Create( "DLabel", scoreboard )
	hn:SetFont( "Borg48" )
	hn:SetTextColor( Color( 255, 255, 255, 255 ) )
	hn:SetText( GAMEMODE.Name )
	hn:SizeToContents()
	hn:SetPos( 5, scoreboard:GetTall() - 2 - hn:GetTall() )
*/
end

function GM:ScoreboardShow()

	CreateScoreboard()

end

function GM:ScoreboardHide()

	if not scoreboard then return end
	scoreboard:SetVisible(false)

end
