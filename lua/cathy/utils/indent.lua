return {
    cpp_indent = function()
        local ts_utils = require("nvim-treesitter.ts_utils")

        local node = ts_utils.get_node_at_cursor()
        if not node then return 0 end

        local node_type = node:type()
        if node_type == "access_specifier" then
            return vim.fn.shiftwidth() / 2
        end

        return require("nvim-treesitter").get_node_indent(node)
    end
}
