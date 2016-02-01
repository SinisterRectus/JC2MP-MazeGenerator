class 'Pickup'

function Pickup:__init(args)
	
	self.position = args.position
	self.angle = args.angle
	
	self.objects = {
		static = ClientStaticObject.Create({
			position = args.position,
			angle = args.angle,
			model = "pickup.boost.cash.eez/pu05-a.lod"
		}),
		trigger = Trigger({
			position = args.position + args.angle * Vector3(0, 0.32, 0),
			angle = args.angle,
			type = TriggerType.Box,
			size = Vector3(0.54, 0.32, 0.36),
			trigger_player = true,
			parent = self
		}),
		light = ClientLight.Create({
			position = args.position + args.angle * Vector3(0, 0.32, 0),
			color = Color.Red,
			radius = 5,
			multiplier = 3
		})
	}
	
	args.parent.objects.pickups[self:GetId()] = self
	self.parent = args.parent

end

function Pickup:GetId()
	return self.objects.static:GetId()
end

function Pickup:Remove()

	for _, object in pairs(self.objects) do
		object:Remove()
	end

	self.parent.objects.pickups[self:GetId()] = nil

end
