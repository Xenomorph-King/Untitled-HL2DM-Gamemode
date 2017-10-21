local view = {origin = vector_origin, angles = angle_zero, fov=0}
function GM:CalcView( ply, origin, angles, fov )
   view.origin = origin
   view.angles = angles
   view.fov    = fov

   -- first person ragdolling
   if !ply:Alive() and ply:GetObserverMode() == OBS_MODE_IN_EYE then
      local tgt = ply:GetObserverTarget()
      if IsValid(tgt) and (not tgt:IsPlayer()) then
         -- assume if we are in_eye and not speccing a player, we spec a ragdoll
         local eyes = tgt:LookupAttachment("eyes") or 0
         eyes = tgt:GetAttachment(eyes)
         if eyes then
            view.origin = eyes.Pos
            view.angles = eyes.Ang
         end
      end
   end


   local wep = ply:GetActiveWeapon()
   if IsValid(wep) then
      local func = wep.CalcView
      if func then
         view.origin, view.angles, view.fov = func( wep, ply, origin*1, angles*1, fov )
      end
   end

   return view
end

function GM:PlayerBindPress(ply, bind, pressed)
   if not IsValid(ply) then return end

   if bind == "invnext" and pressed then
      if !ply:Alive() then

      else
         WSWITCH:SelectNext()
         surface.PlaySound("common/wpn_moveselect.wav") 
      end
      return true
   elseif bind == "invprev" and pressed then
      if !ply:Alive() then
      else
         WSWITCH:SelectPrev()
         surface.PlaySound("common/wpn_moveselect.wav")
      end 
      return true
   elseif bind == "+attack" then
      if WSWITCH:PreventAttack() then
         if not pressed then
            WSWITCH:ConfirmSelection()
            surface.PlaySound("common/wpn_hudoff.wav")
         end
         return true
      end
   elseif string.sub(bind, 1, 4) == "slot" and pressed then
      local idx = tonumber(string.sub(bind, 5, -1)) or 1
      WSWITCH:SelectSlot(idx)
      surface.PlaySound("common/wpn_moveselect.wav")
      return true
   end
end

