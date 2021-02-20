sCells = class()

function sCells:__init()

    self.cells = {}

    self:InitializeCells()

    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)

    Network:Subscribe("Cells/NewCellSyncRequest", self, self.CellSyncRequest)
    Network:Subscribe("Cells/InitialCellSync", self, self.CellSyncRequest)

    --[[
    To subscribe to cell events, use this:

    Cells/PlayerCellUpdate .. CELL_SIZE

        (CELL_SIZE is a valid number from CELL_SIZES in shCell.lua)

        player: the player whose cell just updated
        old_cell: (table of x,y) cell that the player left
        old_adjacent: (table of tables of (x,y)) old adjacent cells that are no longer adjacent to the player (includes old cell)
        cell: (table of x,y) cell that the player is now in
        adjacent: (table of tables of (x,y)) cells that are currently adjacent to the player (includes current cell)

    Cells use a lazy loading strategy and only load the cells that have been accessed by a player.

    ]]
end

function sCells:ClientModulesLoaded(args)
    self:ResetPlayerCellValue(args.player)
end

function sCells:ResetPlayerCellValue(player)

    local cell = {}
    for _, cell_size in pairs(CELL_SIZES) do
        cell[cell_size] = {x = nil, y = nil}
    end

	player:SetValue("Cell", cell)

end

function sCells:InitializeCells()

    for _, cell_size in pairs(CELL_SIZES) do
        self.cells[cell_size] = {}
    end

end

function sCells:CellSyncRequest(args)

    if not args.player:IsValid() then return end
    if not args.position then return end
    
    for _, cell_size in pairs(CELL_SIZES) do
        self:UpdatePlayerCell(args.player, args.position, cell_size)
    end

end

function sCells:UpdatePlayerCell(player, position, cell_size)
    
    if not player:IsValid() then return end

    if not player:GetValue("Cell") then
        player:SetValue("Cell", {[cell_size] = {}})
    elseif not player:GetValue("Cell")[cell_size] then
        local cell_data = player:GetValue("Cell")
        cell_data[cell_size] = {}
        player:SetValue("Cell", cell_data)
    end

    local old_cell = player:GetValue("Cell")[cell_size]
    local new_cell = GetCell(position, cell_size)

    -- Check if they entered a new cell
    if new_cell.x ~= old_cell.x or new_cell.y ~= old_cell.y then

        local cell_data = UpdateCell(old_cell, new_cell)
        cell_data.player = player

        -- print(string.format("%s entered cell %s, %s [%s]", 
        --     player:GetName(), tostring(new_cell.x), tostring(new_cell.y), tostring(cell_size)))
    
        Events:Fire("Cells/PlayerCellUpdate" .. tostring(cell_size), cell_data)

        local player_cell_total = player:GetValue("Cell")
        player_cell_total[cell_size] = new_cell
        player:SetValue("Cell", player_cell_total)
        
    end

end

sCells = sCells()