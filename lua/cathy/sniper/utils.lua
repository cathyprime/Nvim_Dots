local M = {}

---@param match string
---@param template string
function M.replace_all(match, template)
    match = vim.F.if_nil(match, "")
    ---@type string
    local match_str = ""
    if type(match) == "table" then
        match_str = table.concat(match, "\n")
    else
        match_str = match
    end

    local ret = template:gsub("%%s", match_str)
    local ret_lines = vim.split(ret, "\n", {
        trimempty = false,
    })

    return ret_lines
end

function M.make_type_matcher(types)
    if type(types) == "string" then
        return { [types] = 1 }
    end

    if type(types) == "table" then
        if vim.islist(types) then
            local new_types = {}
            for _, v in ipairs(types) do
                new_types[v] = 1
            end
            return new_types
        end
    end

    return types
end

---@param node TSNode
---@param types string[]
function M.find_first_parent(node, types)
    local matcher = M.make_type_matcher(types)

    ---@param root TSNode|nil
    ---@return TSNode|nil
    local function find_parent_impl(root)
        if root == nil then
            return nil
        end
        if matcher[root:type()] == 1 then
            return root
        end
        return find_parent_impl(root:parent())
    end

    return find_parent_impl(node)
end

function M.invoke_after_reparse_buffer(ori_bufnr, match, fun)
    local function reparse_buffer()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local lines = vim.api.nvim_buf_get_lines(ori_bufnr, 0, -1, false)
        local current_line = lines[row]
        local current_line_left = current_line:sub(1, col - #match)
        local current_line_right = current_line:sub(col + 1)
        lines[row] = current_line_left .. current_line_right
        local lang = vim.treesitter.language.get_lang(vim.bo[ori_bufnr].filetype) or vim.bo[ori_bufnr].filetype

        local source = table.concat(lines, "\n")
        ---@type vim.treesitter.LanguageTree
        local parser = vim.treesitter.get_string_parser(source, lang)
        parser:parse(true)

        return parser, source
    end

    local parser, source = reparse_buffer()

    local ret = { fun(parser, source) }

    parser:destroy()

    return unpack(ret)
end

function M.inject_name(NAME, find_first_paren_args)
    return function(_, line_to_cursor, match, captures)
        -- check if at the line begin
        if not line_to_cursor:sub(1, -(#match + 1)):match("^%s*$") then
            return nil
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local buf = vim.api.nvim_get_current_buf()

        return M.invoke_after_reparse_buffer(buf, match, function(parser, source)
            local pos = {
                row - 1,
                col - #match, -- match has been removed from source
            }
            local node = parser:named_node_for_range({
                pos[1],
                pos[2],
                pos[1],
                pos[2],
            })
            if node == nil then
                return nil
            end

            local class_node = M.find_first_parent(node, find_first_paren_args)
            if class_node == nil then
                return nil
            end
            local name_nodes = class_node:field("name")
            if name_nodes == nil or #name_nodes == 0 then
                return nil
            end
            local name_node = name_nodes[1]
            local ret = {
                trigger = match,
                captures = captures,
                env_override = {
                    [NAME] = vim.treesitter.get_node_text(name_node, source),
                },
            }
            return ret
        end)
    end
end

---@param replaced string
---@return fun(match: string): string[]
function M.simple_replace_callback(replaced)
    return function(match)
        return M.replace_all(match, replaced)
    end
end

---@param cmp fun(node: TSNode): boolean
---@return boolean contains
---@return TSNode|nil matchedNode
function M.tree_contains_type(cmp)
    local node = vim.treesitter.get_node()
    if not node then return false, nil end
    while(node and node:parent() ~= nil) do
        if cmp(node) then
            return true, node
        end
        node = node:parent()
    end
    return false, nil
end

return M
