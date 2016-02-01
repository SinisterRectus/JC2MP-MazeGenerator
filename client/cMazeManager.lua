class 'MazeManager'

function MazeManager:__init()

	self.mazes = {}
	self.triggers = {}
	
	self.ceilings = true -- whether to construct maze ceilings

	Events:Subscribe("ShapeTriggerEnter", self, self.TriggerEnter)
	Events:Subscribe("ShapeTriggerExit", self, self.TriggerExit)
	Events:Subscribe("WorldNetworkObjectCreate", self, self.MazeSpawn)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.MazeDespawn)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)

end

function MazeManager:TriggerEnter(args)

	if args.entity.__type ~= "LocalPlayer" then return end
	local trigger = self.triggers[args.trigger:GetId()]
	if not trigger then return end
	local object = trigger.parent
	if not object then return end
	
	local name = class_info(object).name
	
	if name == "Fire" then

		Network:Send("PlayerEnterFire", {player = LocalPlayer})

	elseif name == "Pickup" then -- not synced

		ClientSound.Play(AssetLocation.Game, {
			position = object.position,
			bank_id = 19,
			sound_id = 3,
			variable_id_focus = 0
		})
		
		object:Remove()

	end

end

function MazeManager:TriggerExit(args)

	if args.entity.__type ~= "LocalPlayer" then return end
	local trigger = self.triggers[args.trigger:GetId()]
	if not trigger then return end
	local object = trigger.parent
	if not object then return end
	
	if class_info(object).name == "Fire" then
		Network:Send("PlayerExitFire", {player = LocalPlayer})
	end

end

function MazeManager:MazeSpawn(args)

	if args.object:GetValue("__type") ~= "Maze" then return end
	
	Maze(args)

end

function MazeManager:MazeDespawn(args)

	if args.object:GetValue("__type") ~= "Maze" then return end
	local maze = self.mazes[args.object:GetId()]
	if not maze then return end

	maze:Remove()

end

function MazeManager:ModuleUnload()

	for _, maze in pairs(self.mazes) do
		maze:Remove()
	end

end

MazeManager = MazeManager()
