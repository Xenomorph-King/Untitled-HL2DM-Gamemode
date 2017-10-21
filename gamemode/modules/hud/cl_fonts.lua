_loaded = _loaded and false 

if !_loaded then
	_loaded = true
	fontwn = "Borg48"
	fontws = "Borg14"
	fontwnb = "Borg24"
	fontwsb = "Borg30"

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(28),
	weight = 400,
	antialias = true
	} 
	surface.CreateFont( fontwn, fontdata )
	local fontdata = { 
	font = "Aero Matics Display",
	size = ScreenScale(20),
	weight = 400,
	antialias = true
	}  
	surface.CreateFont( "Borg100", fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(35),
	weight = 400,
	antialias = true
	} 
	surface.CreateFont( "Borg101", fontdata )


	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(38),
	weight = 400,
	antialias = true
	} 
	surface.CreateFont( "Borg50", fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(22), 
	weight = 400,
	antialias = true
	} 
	surface.CreateFont( "Borg60", fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = 200, 
	weight = 400,
	antialias = true
	} 
	surface.CreateFont( "Borg70", fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = 14,
	weight = 400,
	antialias = true
	}
	surface.CreateFont( fontws, fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(8),
	weight = 400,
	}
	surface.CreateFont( fontwnb, fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(12),
	weight = 400
	}
	surface.CreateFont( fontwsb, fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(16),
	weight = 400
	}
	surface.CreateFont( "Borg40", fontdata )

	local fontdata = {
	font = "Aero Matics Display",
	size = ScreenScale(10),
	weight = 400
	}
	surface.CreateFont( "Borg41", fontdata )

	local fontdata = {
	font = "Stellar",
	size = 55,
	weight = 400,
	}
	surface.CreateFont( "CV42", fontdata )

	local fontdata = {
			font = "Stellar",
			size = ScreenScale(8),
			weight = 400,
	}
	surface.CreateFont( "targ_id", fontdata )
end