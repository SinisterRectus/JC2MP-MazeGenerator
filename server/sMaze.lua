class 'Maze'

function Maze:__init(args)

	self.wno = WorldNetworkObject.Create({
		position = args.position,
		values = {
			__type = "Maze",
			seed = args.seed,
			size = args.size,
			step = args.step,
			height = args.height
		}
	})

	MazeManager.mazes[self:GetId()] = self
	
end

function Maze:GetId()

	return self.wno:GetId()

end

function Maze:Remove()

	MazeManager.mazes[self:GetId()] = nil
	self.wno:Remove()
	
end
