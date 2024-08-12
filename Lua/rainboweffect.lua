local color_list = {
	32, 48, 80, 88, 120, 128, 144, 160, 176, 200, 208
}

local function rainbowoverlayeffect(skin, sprite, super, frame, rotation)
	local sprite = image.getSprite2Patch(skin, sprite, super or false, frame, rotation)
	if not sprite then return end
	local img = image.create(sprite.width, sprite.height)
	img.leftoffset = sprite.leftoffset
	img.topoffset = sprite.topoffset+8*FRACUNIT

	for y = 1, sprite.height do
		local get_start = 0
		local get_end = 0
		local temp_x = 1

		while (not get_start) do
			if temp_x == sprite.width then break end
			local temp_c = sprite:getPixel(temp_x, y)
			if temp_c then
				get_start = temp_x
				break
			end
			temp_x = $+1
		end

		if not get_start then continue end
		temp_x = sprite.width

		while (not get_end) do
			if temp_x == 0 then break end
			local temp_c = sprite:getPixel(temp_x, y)
			if temp_c then
				get_end = temp_x
				break
			end
			temp_x = $-1
		end

		for x = 1, sprite.width do
			local x_offset = max(min(x - get_start, 4), 0) - max(x-get_end+3, 0)

			if not sprite:getPixel(x, y) then continue end
			local color = color_list[(((y + leveltime)/2) % #color_list)+1] + x_offset
			img:setPixel(x, y, color)
			img:setPixel(x, y, color)
		end
	end

	return img
end

addHook("PlayerThink", function(p)
	if not p.mo then return end

	if not p.overlordlay then
		p.overlordlay = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_OVERLAY)
		p.overlordlay.state = S_INVISIBLE
		p.overlordlay.sprite = p.mo.sprite
		p.overlordlay.sprite2 = p.mo.sprite2
		p.overlordlay.frame = p.mo.frame
		p.overlordlay.target = p.mo
		p.overlordlay.tracer = p.mo
	elseif p.overlordlay then
		local patch = rainbowoverlayeffect(p.mo.skin, p.mo.sprite2, false, p.mo.frame, abs((p.mo.angle - R_PointToAngle(p.mo.x, p.mo.y))/ANGLE_45 - 5))
		if patch then
			p.overlordlay.image = patch
			p.overlordlay.spriteyoffset = FRACUNIT*4
			p.overlordlay.frame = $|FF_TRANS30|FF_ADD
			--if ((R_PointToAngle(p.mo.x, p.mo.y) - p.mo.angle)/ANGLE_45 + 1) > 5 then
			--	p.overlordlay.frame = $ &~ FF_HORIZONTALFLIP
			--else
			--	p.overlordlay.frame = $ | FF_HORIZONTALFLIP
			--end
		end
	end
end)