class 'MazeManager'

function MazeManager:__init()

	self.mazes = {}
	self.burners = {}

	Events:Subscribe("PreTick", self, self.Tick)
	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	
	Network:Subscribe("PlayerEnterFire", self, self.PlayerEnterFire)
	Network:Subscribe("PlayerExitFire", self, self.PlayerExitFire)

end

function MazeManager:Tick()

	for _, burner in pairs(self.burners) do
		
		local timer = burner[2]
		if timer:GetSeconds() > 1 then
			timer:Restart()
			local player = burner[1]
			if IsValid(player) then
				player:Damage(0.1)
			end
		end
		
	end

end

function MazeManager:PlayerEnterFire(args)

	self.burners[args.player:GetId()] = {args.player, Timer()}
	args.player:Damage(0.1)

end

function MazeManager:PlayerExitFire(args)

	self.burners[args.player:GetId()] = nil

end

function MazeManager:ModuleLoad()

	-- Seed: Client-side assets are populated according to this number
	-- Position: Where the maze is located in the game world
	-- Size: Side-length of a maze in meters. Must be a power of 2 >= step.
	-- Step: Essentially, the side-length of a cell in meters. Must be a power of 2 <= size.
	-- Height: How tall the walls of the maze are. Must be a power of 2 >= 2.

	Maze({
		seed = 1337,
		position = Vector3(0, 201, 0),
		size = 128,
		step = 16,
		height = 16
	})

end

function MazeManager:ModuleUnload()

	for _, maze in pairs(self.mazes) do
		maze:Remove()
	end

end

MazeManager = MazeManager()
