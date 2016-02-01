class 'Trigger'

function Trigger:__init(args)

	self.entity = ShapeTrigger.Create({
		position = args.position,
		angle = args.angle,
		components = {
			{
				type = args.type,
				size = args.size
			}
		},
		trigger_player = args.trigger_player,
		trigger_player_in_vehicle = args.trigger_player_vehicle,
		trigger_vehicle = args.trigger_vehicle,
		trigger_npc = args.trigger_npc,
		vehicle_type = args.vehicle_type
	})
	
	self.type = args.type
	self.size = args.size
	self.component = args.component
	
	self.parent = args.parent
	
	MazeManager.triggers[self:GetId()] = self
	
end

function Trigger:Draw()

	local color = Color.White
	local angle = self:GetAngle()
	local position = self:GetPosition()

	if self.type == TriggerType.Sphere then
	
		local radius = self.size.x
		
		local transform = Transform3()
		transform:Translate(position)

		transform:Rotate(angle)
		Render:SetTransform(transform)
		Render:DrawCircle(Vector3(), radius, color)

		transform:Rotate(Angle(0, 0.5 * math.pi, 0))
		Render:SetTransform(transform)
		Render:DrawCircle(Vector3(), radius, color)
		
		transform:Rotate(Angle(0.5 * math.pi, 0, 0))
		Render:SetTransform(transform)
		Render:DrawCircle(Vector3(), radius, color)
		
		Render:ResetTransform()
		
	else
	
		local x, y, z = self.size.x, self.size.y, self.size.z

		local corners = {
			position + angle * Vector3( x,  y,  z),
			position + angle * Vector3(-x,  y,  z),
			position + angle * Vector3(-x,  y, -z),
			position + angle * Vector3( x,  y, -z),
			position + angle * Vector3( x, -y,  z),
			position + angle * Vector3(-x, -y,  z),
			position + angle * Vector3(-x, -y, -z),
			position + angle * Vector3( x, -y, -z),
		}

		Render:DrawLine(corners[1], corners[2], color)
		Render:DrawLine(corners[2], corners[3], color)
		Render:DrawLine(corners[3], corners[4], color)
		Render:DrawLine(corners[4], corners[1], color)
		
		Render:DrawLine(corners[1], corners[5], color)
		Render:DrawLine(corners[2], corners[6], color)
		Render:DrawLine(corners[3], corners[7], color)
		Render:DrawLine(corners[4], corners[8], color)
		
		Render:DrawLine(corners[5], corners[6], color)
		Render:DrawLine(corners[6], corners[7], color)
		Render:DrawLine(corners[7], corners[8], color)
		Render:DrawLine(corners[8], corners[5], color)
	
	end

end

function Trigger:GetPosition()
	return self.entity:GetPosition()
end

function Trigger:SetPosition(position)
	return self.entity:SetPosition(position)
end

function Trigger:GetAngle()
	return self.entity:GetAngle()
end

function Trigger:GetId()
	return self.entity:GetId()
end

function Trigger:Remove()

	MazeManager.triggers[self:GetId()] = nil
	self.entity:Remove()

end
