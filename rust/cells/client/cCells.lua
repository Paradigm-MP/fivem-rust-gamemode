cCells = class()

local CellSyncRequestEvent = "Cells/NewCellSyncRequest"
local LocalPlayerCellUpdateEvent = "Cells/LocalPlayerCellUpdate"

function cCells:__init()

    self.current_cell = {}
    self.ready_for_cell = false
    self.CELL_SCAN_INTERVAL = 500

    for _, cell_size in pairs(CELL_SIZES) do
        self.current_cell[cell_size] = {}
    end

    Events:Subscribe("ModulesLoaded", self, self.ModulesLoaded)

    Network:Send(CellSyncRequestEvent, {
        position = self:GetViewpoint()
    })

    Citizen.CreateThread(function()
        while true do
            self:TryCellCheck()
            Wait(self.CELL_SCAN_INTERVAL)
        end
    end)

    --[[
    To subscribe to cell events, use this:

    Cells/LocalPlayerCellUpdate .. CELL_SIZE

        (CELL_SIZE is a valid number from CELL_SIZES in shCell.lua)

        old_cell: (table of x,y) cell that the player left
        old_adjacent: (table of tables of (x,y)) old adjacent cells that are no longer adjacent to the player
        cell: (table of x,y) cell that the player is now in
        adjacent: (table of tables of (x,y)) cells that are currently adjacent to the player

    Cells use a lazy loading strategy and only load the cells that have been accessed by a player.

    ]]

end

function cCells:GetViewpoint()
    return Camera:GetPosition() + Camera:GetRotation() * 2
end

function cCells:CheckIfPlayerInNewCell(cell_size)

    -- Get our current cell
    local cell = GetCell(self:GetViewpoint(), cell_size)
    local current_cell = self.current_cell[cell_size]

    -- if our cell is different than our previous cell, update it
    if cell.x ~= current_cell.x or cell.y ~= current_cell.y then
    
        local cell_data = UpdateCell(current_cell, cell)
        
        -- Fire cell upated event on localplayer
        Events:Fire(LocalPlayerCellUpdateEvent .. tostring(cell_size), cell_data)

        -- Update the current cell we are in
        self.current_cell[cell_size] = cell

        return true
    end

end

function cCells:CheckCells()

    local entered_new_cell = false
    
    -- Check if we entered a new cell, if so tell the server
    for _, cell_size in pairs(CELL_SIZES) do
        local cell_check = self:CheckIfPlayerInNewCell(cell_size)
        entered_new_cell = entered_new_cell or cell_check
        Wait(1)
    end

    -- If we entered at least one new cell, tell the server to update us
    if entered_new_cell then
        Network:Send(CellSyncRequestEvent, {
            position = self:GetViewpoint()
        })
    end

end

function cCells:TryCellCheck()
    
    -- If we are not ready to start checking for cells
    if not self.ready_for_cell then return end

    -- Check all cell sizes
    self:CheckCells()

end

function cCells:ModulesLoaded()
    self.current_cell = {} -- Reset current cell

    for _, cell_size in pairs(CELL_SIZES) do
        self.current_cell[cell_size] = {}
    end

    self.ready_for_cell = true
end

cCells = cCells()



