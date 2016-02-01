class 'Fire'

function Fire:__init(args)
	
	self.objects = {
		static = ClientStaticObject.Create({
			position = args.position,
			angle = args.angle,
			model = "vegetation_0.blz/jungle_T08_understoryL-Stump.lod"
		}),
		trigger = Trigger({
			position = args.position,
			angle = args.angle,
			type = TriggerType.Sphere,
			size = Vector3(3, 3, 3),
			trigger_player = true,
			parent = self
		}),
		light = ClientLight.Create({
			position = args.position,
			color = Color.Orange,
			radius = 20,
		}),
		effect = ClientEffect.Create(AssetLocation.Game, {
			position = args.position,
			angle = args.angle,
			effect_id = 30
		})
	}

	args.parent.objects.fires[self:GetId()] = self
	self.parent = args.parent

end

function Fire:GetId()
	return self.objects.static:GetId()
end

function Fire:Remove()

	for _, object in pairs(self.objects) do
		object:Remove()
	end
	
	self.parent.objects.fires[self:GetId()] = nil

end
