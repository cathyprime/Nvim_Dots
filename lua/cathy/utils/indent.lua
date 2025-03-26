local function getline(lnum)
    return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
end

---@param lnum integer
---@return integer
local function get_indentcols_at_line(lnum)
    local _, indentcols = getline(lnum):find "^%s*"
    return indentcols or 0
end

---@param root TSNode
---@param lnum integer
---@param col? integer
---@return TSNode
local function get_first_node_at_line(root, lnum, col)
    col = col or get_indentcols_at_line(lnum)
    return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

local valid_nodes = {
    access_specifier = 2,
}

return {
    cpp_indent = function(lnum)
        local ts_utils = require("nvim-treesitter.ts_utils")
        local indent = require("nvim-treesitter.indent")

        local node = ts_utils.get_node_at_cursor()
        if not node then
            return -1
        end

        local node = get_first_node_at_line(node, lnum)
        if not node then
            return -1
        end

        local indt = indent.get_indent(lnum)
        local p = node:parent()

        if p then
            local key = valid_nodes[p:type()]
            if key then
                indt = indt + key
            end
        end

        return indt
    end
}
