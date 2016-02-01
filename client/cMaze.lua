class 'Maze'

function Maze:__init(args)

	self.timer = Timer()
	
	local wno = args.object
	local values = wno:GetValues()

	self.graph = {}
	
	self.objects = {
		statics = {},
		effects = {},
		lights = {},
		pickups = {},
		fires = {},
		torches = {},
	}
	
	self.wno = wno
	self.seed = values.seed
	self.size = values.size
	self.step = values.step
	self.height = values.height
	self.position = wno:GetPosition()
	
	self:InitVars()
	self:Generate()
	
	MazeManager.mazes[wno:GetId()] = self

end

function Maze:InitVars()

	local p = self.position

	self.h_size = 0.5 * self.size
	self.h_step = 0.5 * self.step
	
	self.x_start, self.x_stop = p.x - self.h_size, p.x + self.h_size - self.step
	self.z_start, self.z_stop = p.z - self.h_size, p.z + self.h_size - self.step

end

function Maze:Generate() 

	math.randomseed(self.seed)

	local p = self.position
	local step, h_step = self.step, self.h_step
	local x_start, x_stop = self.x_start, self.x_stop
	local z_start, z_stop = self.z_start, self.z_stop

	p.x = math.floor(p.x); p.z = math.floor(p.z)

	for x = x_start, x_stop, step do
		for z = z_start, z_stop, step do
			self:AddNode(x, p.y, z)
		end
	end

	self:CarvePath()
	
	self.graph[x_start][z_start].neighbors[3] = true -- entrance
	self.graph[x_stop][z_stop].neighbors[4] = true -- exit
	
	self:AddObjects()

end

function Maze:AddNode(x, y, z)

	self.graph[x] = self.graph[x] or {}
	self.graph[x][z] = {Vector3(x, y, z), neighbors = {}}

end

function Maze:CarvePath()

	local x = self.x_start
	local z = self.z_start
	local dx = {0, 0, -1, 1}
	local dz = {-1, 1, 0, 0}
	local opposites = {2, 1, 4, 3}

	for i in ipairs(dx) do
		dx[i] = dx[i] * self.step
	end

	for i in ipairs(dz) do
		dz[i] = dz[i] * self.step
	end

	local node = self.graph[x][z]

	local s = {node}
	local visited = {[node] = true}

	while #s > 0 do

		local node = table.remove(s)
		local directions = {1, 2, 3, 4}

		while #directions > 0 do

			local dir = table.remove(directions, math.random(1, #directions))
			local x = node[1].x + dx[dir]
			local z = node[1].z + dz[dir]

			local neighbor = self.graph[x] and self.graph[x][z]
			if neighbor and not visited[neighbor] then
				node.neighbors[dir] = neighbor
				neighbor.neighbors[opposites[dir]] = node
				visited[neighbor] = true
				node = neighbor
				table.insert(s, neighbor)
				directions = {1, 2, 3, 4}
			end

		end

	end

end

function Maze:AddObjects()

	local step = self.step
	local h_step = self.h_step
	local q_step = 0.5 * h_step
	local height = self.height

	local spawn_args = {
		statics = {},
		pickups = {},
		fires = {},
		torches = {},
	}

	local offsets = {
		Vector3.Forward,
		Vector3.Backward,
		Vector3.Left,
		Vector3.Right,
		Vector3.Up
	}

	local angles = {
		Angle(0, 0, 0),
		Angle(math.pi, 0, 0),
		Angle(0.5 * math.pi, 0, 0),
		Angle(-0.5 * math.pi, 0, 0),
		Angle(0, math.pi, 0)
	}

	local opposites = {2, 1, 4, 3}
	local orthogonals = {3, 4, 2, 1}
	local pillars = {"a", "b", "c", "d"}
	
	local models = {
		"areaset01.blz/gb090-o.lod", -- wall
		"areaset01.blz/gb162-m.lod", -- floor/ceiling
		"areaset01.blz/gb080-%s.lod", -- random pillars (note the %s)
	}
	
	local collisions = {}
	for i, model in ipairs(models) do
		collisions[i] = model:gsub("-" , "_lod1-"):gsub("%.lod" , "_col.pfx")
	end

	for x, v in pairs(self.graph) do
		for z, node in pairs(v) do
		
			local neighbors = node.neighbors
			for i = 1, 4 do
				if not neighbors[i] then

					if (i == 1 or (i == 2 and z == self.z_stop)) or (i == 3 or (i == 4 and x == self.x_stop)) then -- prevents multiple walls occupying the same spot
						for j = -h_step + 2, h_step - 2, 4 do
							local position = node[1] + h_step * offsets[i] + j * offsets[orthogonals[i]]
							local angle = angles[i]
							for k = 1, height, 2 do
								table.insert(spawn_args.statics, {
									position = position + (k - 1) * offsets[5],
									angle = angle,
									model = models[1],
									collision = collisions[1]
								}) -- walls
							end
						end
					end

					if not neighbors[orthogonals[i]] then
						table.insert(spawn_args.torches, {
							parent = self,
							position = node[1] + 0.75 * h_step * (offsets[i] + offsets[orthogonals[i]]),
							angle = angles[i]
						}) -- torches in corners
					end

				end

			end
			
			if step < 8 then

				local model = models[2]
				local collision = collisions[2]
				
				local r = math.random() * 0.01 -- prevents Z-fighting
				table.insert(spawn_args.statics, {
					position = node[1] + offsets[5] * r,
					angle = angles[1],
					model = model,
					collision = collision
				}) -- floors
				if MazeManager.ceilings then
					table.insert(spawn_args.statics, {
						position = node[1] + offsets[5] * (self.height + r),
						angle = angles[5],
						model = collision,
						collision = model
					}) -- ceilings
				end

			else -- only populate if step is >= 8

				local model = models[2]
				local collision = collisions[2]
				for i = -h_step + 4, h_step - 4, 8 do
					for j = -h_step + 4, h_step - 4, 8 do			
						local r = math.random() * 0.01 -- prevents Z-fighting
						local position = node[1] + Vector3(i, 0, j)
						table.insert(spawn_args.statics, {
							position = position + offsets[5] * r,
							angle = angles[1],
							model = model,
							collision = collision
						}) -- floors
						if MazeManager.ceilings then
							table.insert(spawn_args.statics, {
								position = position + offsets[5] * (self.height + r),
								angle = angles[5],
								model = model,
								collision = collision
							}) -- ceilings
						end
					end
				end
				
				if table.count(neighbors) > 1 then
					if height >= 8 then
						local r = math.random()
						if r < 0.1 then
							table.insert(spawn_args.fires, {
								parent = self,
								position = node[1] + Vector3(math.random(-q_step, q_step), 0.5, math.random(-q_step, q_step)),
								angle = angles[math.random(1, 4)]
							}) -- random floor fires
						elseif r < 0.5 then
							local pillar = table.randomvalue(pillars)
							table.insert(spawn_args.statics, {
								position = node[1] + Vector3(math.random(-q_step, q_step), 0, math.random(-q_step, q_step)),
								angle = angles[math.random(1, 4)],
								model = string.format(models[3], pillar),
								collision = string.format(collisions[3], pillar)
							}) -- random pillars
						end
					end
				else
					for i, neighbor in pairs(neighbors) do
						table.insert(spawn_args.pickups, {
							parent = self,
							position = node[1] + q_step * offsets[opposites[i]],
							angle = angles[i],
						}) -- pickups in dead-ends
					end
				end

			end

		end
	end
	
	self.loader = Events:Subscribe("PostTick", function()
		if #spawn_args.statics > 0 then
			for i = 1, math.min(1000, #spawn_args.statics) do
				table.insert(self.objects.statics, ClientStaticObject.Create(table.remove(spawn_args.statics)))
			end
		elseif #spawn_args.pickups > 0 then
			Pickup(table.remove(spawn_args.pickups))
		elseif #spawn_args.fires > 0 then
			Fire(table.remove(spawn_args.fires))
		elseif #spawn_args.torches > 0 then
			Torch(table.remove(spawn_args.torches))
		else
			Events:Unsubscribe(self.loader)
			self.loader = nil
			print(string.format("Maze generated in %i ms", self.timer:GetMilliseconds()))
		end
	end)

end

function Maze:GetId()
	return self.wno:GetId()
end

function Maze:Remove()

	for _, v in pairs(self.objects) do
		for _, object in pairs(v) do
			object:Remove()
		end
	end
	
	MazeManager.mazes[self:GetId()] = nil

end
