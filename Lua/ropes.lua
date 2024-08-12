local bushes = {}
local loaded = false
local rope_cache = {}

local function V_DrawLineLow(v, x_0, y_0, x_1, y_1, color, image)
	local dx = x_1-x_0
	local dy = y_1-y_0
	local yi = 1
	if dy < 0 then
		yi = -1
		dy = -dy
	end
	local D = 2*dy - dx
	local y = y_0

	for x = x_0, x_1 do
		image:setPixel(x, y, color)
		image:setPixel(x, y+1, color)
		image:setPixel(x, y+2, color)
		image:setPixel(x, y+3, color)
		if D > 0 then
			y = y+yi
			D = D + (2*(dy - dx))
		else
			D = D + 2*dy
		end
	end
end

-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
local function V_DrawLineHigh(v, x_0, y_0, x_1, y_1, color, image)
	local dx = x_1-x_0
	local dy = y_1-y_0
	local xi = 1
	if dx < 0 then
		xi = -1
		dx = -dx
	end
	local D = 2*dx - dy
	local x = x_0

	for y = y_0, y_1 do
		image:setPixel(x, y, color)
		image:setPixel(x, y+1, color)
		image:setPixel(x, y+2, color)
		image:setPixel(x, y+3, color)
		if D > 0 then
			x = x+xi
			D = D + (2*(dx - dy))
		else
			D = D + 2*dx
		end
	end
end

local function V_DrawLine(v, x_0, y_0, x_1, y_1, color, image)
	if abs(y_1 - y_0) < abs(x_1 - x_0) then
		if x_0 > x_1 then
			V_DrawLineLow(v, x_1, y_1, x_0, y_0, color, image)
		else
			V_DrawLineLow(v, x_0, y_0, x_1, y_1, color, image)
		end
	else
		if y_0 > y_1 then
			V_DrawLineHigh(v, x_1, y_1, x_0, y_0, color, image)
		else
			V_DrawLineHigh(v, x_0, y_0, x_1, y_1, color, image)
		end
	end
end

addHook("MapThingSpawn", function(mo)
	if loaded then
		bushes = {}
		loaded = false
	end
	table.insert(bushes, mo)
end, MT_BUSH)

addHook("MapLoad", function()
	rope_cache = {}

	if bushes then
		for i = 1, #bushes do
			if i == #bushes then break end
			local bush = bushes[i]
			local next_b = bushes[i+1]
			local dist_hor = R_PointToDist2(bush.x, bush.y, next_b.x, next_b.y)
			local dist_ver = next_b.z - bush.z
			local dist3D = R_PointToDist2(0, bush.z, dist_hor, next_b.z)

			if dist3D > FRACUNIT*4000 then continue end
			local dim_x = abs(dist_hor/FRACUNIT)
			local dim_y = abs(dist_ver/FRACUNIT) or 1

			if dim_x == 0 then continue end

			rope_cache[i] = image.create(9*dim_x/5, 9*dim_y/5)
			V_DrawLine(v, 0, 0, 9*dim_x/5, 9*dim_y/5, 31, rope_cache[i])

			P_SetOrigin(bush, bush.x + (next_b.x - bush.x)/2, bush.y + (next_b.y - bush.y)/2, bush.z + (next_b.z - bush.z)/2)
			bush.frame = $|FF_PAPERSPRITE
			bush.spritexoffset = dim_x * FRACUNIT / 2
			bush.spriteyoffset = (bush.y - next_b.y) / 2
			bush.renderflags = $|RF_ABSOLUTEOFFSETS

			bush.angle = R_PointToAngle2(bush.x, bush.y, next_b.x, next_b.y)
			bush.image = rope_cache[i]
		end
	end

	loaded = true
end)
