include("object.lua");

CObjectList = class(
	function (self)
		self.Objects = {};
	end
);

function CObjectList:update()
	self.Objects = {}; -- Flush all objects.
	local size = memoryReadInt(getProc(), addresses.staticTableSize);

	for i = 0,size do
		local addr = memoryReadUIntPtr(getProc(), addresses.staticTablePtr, i*4);
		if( addr and addr > 0) then
			self.Objects[i] = CObject(addr);
		end
	end
end

function CObjectList:getObject(index)
	if( index < 0 or index > #self.Objects ) then
		error("Call to CObjectList:getObject failed: index out of bounds", 2);
	end

	return self.Objects[index];
end

function CObjectList:size()
	return #self.Objects;
end
