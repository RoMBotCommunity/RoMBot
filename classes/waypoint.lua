WPT_NORMAL = 3;
WPT_TRAVEL = 4;		-- don't target, don't fight back
WPT_RUN = 5;		-- don't target

CWaypoint = class(
	function (self, _X, _Z, _Y)
		-- If we're copying from a waypoint
		if( type(_X) == "table" ) then
			local copyfrom = _X;
			self.X = copyfrom.X;
			self.Z = copyfrom.Z;
			self.Y = copyfrom.Y;
			self.Action = copyfrom.Action;
			self.Type = copyfrom.Type;
			self.Tag = copyfrom.Tag;
		else
			self.X = _X;
			self.Z = _Z;
			self.Y = _Y;
			self.Action = nil; -- String containing Lua code to execute when reacing the point.
			self.Type = WTP_NORMAL;
			self.Tag = "";
		end

		if( not self.X ) then self.X = player and player.X or 0.0; end;
		if( not self.Z ) then self.Z = player and player.Z or 0.0; end;
	end
);

function CWaypoint:update()
	-- Does nothing. Just for compatability with
	-- pawn class (so we can interchange if moving
	-- to a target, instead)
end
