local cache = {}

local function outline(sprite, frame, angle)
	local sprite = image.getSpritePatch(sprite, frame, angle)
	if not sprite then return end
	local patch = image.create(sprite.width+4, sprite.height+4)

	for x = 1, sprite.width do
		for y = 1, sprite.height do
			if not sprite:getPixel(x, y) then continue end
			patch:setPixel(x+2, y, 1)
			patch:setPixel(x+2, y+1, 1)

			patch:setPixel(x, y+2, 1)
			patch:setPixel(x+1, y+2, 1)

			patch:setPixel(x+3, y+2, 1)
			patch:setPixel(x+4, y+2, 1)

			patch:setPixel(x+3, y+3, 1)
			patch:setPixel(x+4, y+4, 1)
		end
	end

	for x = 1, sprite.width do
		for y = 1, sprite.height do
			if not sprite:getPixel(x, y) then continue end
			local color = sprite:getPixel(x, y)
			patch:setPixel(x+2, y+2, color)
			patch:setPixel(x+2, y+2, color)
		end
	end


	return patch
end

addHook("MobjThinker", function(mo)
	if not (mo.sprite and mo.frame and mo.type ~= MT_PLAYER) then return end
	local angle = mo.angle/ANGLE_45

	if not cache[mo.sprite] then
		cache[mo.sprite] = {}
		if not cache[mo.sprite][mo.frame] then
			cache[mo.sprite][mo.frame] = {}
			if not cache[mo.sprite][mo.frame][angle] then
				cache[mo.sprite][mo.frame][angle] = outline(mo.sprite, mo.frame, angle)
			end
		end
	end

	if not (cache[mo.sprite] and cache[mo.sprite][mo.frame] and cache[mo.sprite][mo.frame][angle]) then return end
	local patch = cache[mo.sprite][mo.frame][angle]
	mo.tics = $-1
	mo.spriteyoffset = patch.height*FRACUNIT
	mo.image = patch
	mo.frame = $|FF_PAPERSPRITE
end)