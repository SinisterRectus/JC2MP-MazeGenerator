class 'Torch'

function Torch:__init(args)
	
	self.objects = {
		static = ClientStaticObject.Create({
			position = args.position,
			angle = args.angle,
			model = "11x50_reapershqdemo.flz/key041_1-key041_1_torch.lod",
			collision = "11x50_reapershqdemo.flz/key041_1_lod1-key041_1_torch_col.pfx"
		}),
		light = ClientLight.Create({
			position = args.position + args.angle * Vector3(0, 1.2, 0),
			color = Color.Orange,
			radius = 4,
		}),
		effect = ClientEffect.Create(AssetLocation.Game, {
			position = args.position + args.angle * Vector3(0, 1.2, 0),
			angle = args.angle,
			effect_id = 326
		})
	}

	args.parent.objects.torches[self:GetId()] = self
	self.parent = args.parent

end

function Torch:GetId()
	return self.objects.static:GetId()
end

function Torch:Remove()

	for _, object in pairs(self.objects) do
		object:Remove()
	end
	
	self.parent.objects.torches[self:GetId()] = nil

end
