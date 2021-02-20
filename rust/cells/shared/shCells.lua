function GetCell(pos, cell_size)
    return {x = math.floor(pos.x / cell_size), y = math.floor(pos.y / cell_size)}
end

function VerifyCellExists(cell_table, cell)
    if not cell_table[cell.x] then cell_table[cell.x] = {} end
    if not cell_table[cell.x][cell.y] then cell_table[cell.x][cell.y] = {} end
end

-- Returns a table containing objects with x and y of cells that are adjacent to the one given including the one given
function GetAdjacentCells(cell)

    local adjacent = {}

	for x = cell.x - 1, cell.x + 1 do

        for y = cell.y - 1, cell.y + 1 do

            table.insert(adjacent, {x = x, y = y})

        end

    end

    return adjacent
end

CELL_SIZES = {64, 128, 256, 512}

function UpdateCell(old_cell, current_cell)

    -- Get our current cell
    local cell = current_cell
    local current_cell = old_cell

    -- if our cell is different than our previous cell, update it
    if cell.x ~= current_cell.x or cell.y ~= current_cell.y then
    
        local old_adjacent = {}
        local new_adjacent = GetAdjacentCells(cell)

        local updated = GetAdjacentCells(cell)

        if current_cell.x ~= nil and current_cell.y ~= nil then

            old_adjacent = GetAdjacentCells(current_cell)

            -- Filter out old adjacent cells that are still adjacent -- old adjacent only contains old ones that are no longer adjacent
            for i, _ in pairs(old_adjacent) do
                for j, _ in pairs(new_adjacent) do
            
                    -- If new adjacent also contains a cell from old adjacent, remove it from old adjacent
                    if old_adjacent[i] and new_adjacent[j]
                    and old_adjacent[i].x == new_adjacent[j].x 
                    and old_adjacent[i].y == new_adjacent[j].y then
                        old_adjacent[i] = nil
                        updated[j] = nil
                    end
                    
                end
            end
        end

        return {
            old_cell = current_cell,
            old_adjacent = old_adjacent,
            cell = cell,
            adjacent = new_adjacent,
            updated = updated
        }

    end
end