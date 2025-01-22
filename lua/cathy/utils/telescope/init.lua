local M = {}

local prefix = function (str)
    return string.format(" %s :: ", str)
end

M.project_files = function ()
    local p = require("project_nvim.project")
    local root = p.get_project_root()

    if root then
        M.find_files()
    else
        M.project()
    end
end

M.project = function ()
    require("telescope").extensions.projects.projects({
        prompt_prefix = prefix("Projects")
    })
end

M.find_files = function ()
    require("telescope.builtin").find_files({
        file_ignore_patterns = require("cathy.utils.telescope.config").ignores,
        hidden = true,
        previewer = false,
        prompt_prefix = prefix("Find Files"),
    })
end

M.buffers = function ()
    require("telescope.builtin").buffers({
        previewer = false,
        ignore_current_buffer = true,
        prompt_prefix = prefix("Buffers")
    })
end

M.get_nvim = function ()
    require("telescope.builtin").find_files({
        cwd = "~/.config/nvim",
        previewer = false,
        prompt_prefix = prefix("Neovim Files"),
    })
end

M.grep_current_file = function ()
    require("telescope.builtin").live_grep({
        search_dirs = { vim.fn.expand("%:p") },
        prompt_prefix = prefix("Grep Current File"),
    })
end

M.multi_grep = function (opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()
    local finder = require("telescope.finders").new_async_job {
        command_generator = function (prompt)

            if not prompt or prompt == "" then
                return
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return args
        end,
        entry_maker = require("telescope.make_entry").gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    require("telescope.pickers").new(opts, {
        debounce = 100,
        prompt_title = "Grep (multi)",
        prompt_prefix = prefix("Multi Grep"),
        finder = finder,
        previewer = require("telescope.config").values.grep_previewer(opts),
        sorter = require("telescope.sorters").empty(),
    }):find()
end

M.find_file = function (opts)
    local cache = {}
    local function get_files(path)
        if cache[path] then
            return cache[path]
        end
        local obj = vim.system({ "fd", "-L", "--exact-depth=1", "-HI", '.', path }, { text = true }):wait()
        local stdout = vim.split(obj.stdout, "\n", { trimempty = true, plain = true })
        table.insert(stdout, 1, path .. ".")
        table.insert(stdout, 2, path .. "..")
        cache[path] = stdout
        return stdout
    end
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()
    local displayer = require("telescope.pickers.entry_display").create({
        separator = " ",
        items = {
            { width = 1 },
            { remaining = true }
        }
    })
    local finder = require("telescope.finders").new_dynamic {
        fn = function (prompt)
            local path
            if prompt == "" then
                prompt = "/"
            end
            return get_files(vim.fn.fnamemodify(prompt, ":h") .. "/")
        end,
        entry_maker = function (entry)
            local function make_display (entry_tbl)
                local is_dir = string.sub(
                    require("telescope.actions.state").get_current_line(), -1) == "/"

                if entry_tbl.value:match("%.%.$") and is_dir then
                    local icon, highlight = require("mini.icons").get("directory", vim.fs.normalize(entry_tbl.value))
                    return displayer {
                        { icon, highlight },
                        "../"
                    }
                end
                if entry_tbl.value:match("%.$") and is_dir then
                    local icon, highlight = require("mini.icons").get("directory", vim.fs.normalize(entry_tbl.value))
                    return displayer {
                        { icon, highlight },
                        "./"
                    }
                end
                local t
                local name
                if string.sub(entry_tbl.value, -1) == "/" then
                    t = "directory"
                    name = vim.fn.fnamemodify(entry_tbl.value, ":h:t") .. "/"
                else
                    t = "file"
                    name = vim.fn.fnamemodify(entry_tbl.value, ":t")
                end
                local icon, hl = require("mini.icons").get(t, entry_tbl.value)
                return displayer {
                    { icon, hl },
                    name
                }
            end
            if entry == "" then
                return nil
            end

            local ordinal
            if string.sub(entry, -1) == "/" then
                ordinal = vim.fn.fnamemodify(entry, ":h:t") .. "/"
            else
                ordinal = vim.fn.fnamemodify(entry, ":t")
            end

            return require("telescope.make_entry").set_default_entry_mt({
                value = entry,
                ordinal = ordinal,
                display = make_display
            }, opts)
        end,
        cwd = opts.cwd,
    }
    local sorter = require("telescope.config").values.file_sorter(opts)
    local og_scoring = sorter.scoring_function
    sorter.scoring_function = function (arg1, prompt, arg3, arg4)
        if not prompt then return og_scoring(arg1, path_tail(prompt), arg3, arg4) end

        if string.sub(prompt, -1) == "/" then
            return og_scoring(arg1, "", arg3, arg4)
        end
        return og_scoring(arg1, vim.fn.fnamemodify(prompt, ":t"), arg3, arg4)
    end
    require("telescope.pickers").new(opts, {
        debounce = 100,
        prompt_title = "Find File",
        prompt_prefix = prefix("Find File"),
        layout_config = { bottom_pane = { height = 10 } },
        default_text = vim.uv.cwd() .. "/",
        sorting_order = "ascending",
        finder = finder,
        previewer = false,
        sorter = sorter,
        attach_mappings = function (prompt_bufnr, map)
            local actions       = require "telescope.actions"
            local actions_state = require "telescope.actions.state"

            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
                local selection = actions_state.get_selected_entry()
                if not selection then
                    selection = { value = actions_state.get_current_line() }
                end
                vim.cmd.edit(selection.value)
                local cd_chars = {
                    ["/"] = true,
                    ["."] = true,
                }
                if cd_chars[string.sub(selection.value, -1)] then
                    vim.cmd.cd(selection.value)
                end
            end)

            map({ "i", "n" }, "<tab>", function (prompt_bufnr)
                local selection = actions_state.get_selected_entry()
                local display   = selection.display(selection)
                local picker    = actions_state.get_current_picker(prompt_bufnr)
                local value     = selection.value

                if display:match "%.%.%/$" then
                    local new_path = vim.fs.normalize(selection.value)
                    if #new_path ~= 1 then
                        new_path = new_path .. "/"
                    end
                    picker:set_prompt(new_path)
                    return
                end
                if display:match "%.%/$" then
                    return
                end

                picker:set_prompt(value)
            end)

            map("i", "<c-w>", function (prompt_bufnr)
                local picker = actions_state.get_current_picker(prompt_bufnr)
                local prompt = actions_state.get_current_line()
                if string.sub(prompt, -1) == "/" then
                    if #prompt > 1 then
                        local pos = string.match(string.sub(prompt, 1, -2), ".*()/")
                        picker:set_prompt(string.sub(prompt, 1, pos))
                    end
                else
                    local last_slash = string.match(prompt, ".*()/")
                    picker:set_prompt(string.sub(prompt, 1, last_slash))
                end
            end)

            map("i", "<bs>", function (prompt_bufnr)
                local picker = actions_state.get_current_picker(prompt_bufnr)
                local prompt = actions_state.get_current_line()
                if string.sub(prompt, -1) == "/" then
                    if #prompt > 1 then
                        local pos = string.match(string.sub(prompt, 1, -2), ".*()/")
                        picker:set_prompt(string.sub(prompt, 1, pos))
                    end
                else
                    picker:set_prompt(string.sub(prompt, 1, -2))
                end
            end)

            map({ "i", "n" }, "<c-h>", function (prompt_bufnr)
                local picker = actions_state.get_current_picker(prompt_bufnr)
                picker:set_prompt(os.getenv("HOME") .. "/")
            end)

            return true
        end
    }):find()
end

M.get_word = function ()
    require("telescope.builtin").grep_string({
        search = vim.fn.expand("<cword>"),
        prompt_prefix = prefix("Get Word"),
    })
end

M.oldfiles = function ()
    require("telescope.builtin").oldfiles({
        previewer = false,
        prompt_prefix = prefix("Oldfiles"),
    })
end

M.help_tags = function ()
    require("telescope.builtin").help_tags({
        previewer = false,
        prompt_prefix = prefix("Help Tags"),
    })
end

M.treesitter = function ()
    require("telescope.builtin").treesitter({
        prompt_prefix = prefix("Treesitter"),
    })
end

M.spell_suggest = function ()
    require("telescope.builtin").spell_suggest({
        prompt_prefix = prefix("Spell Suggest"),
    })
end

M.diagnostics = function ()
    require("telescope.builtin").diagnostics({
        prompt_prefix = prefix("Diagnostics"),
    })
end

M.resume = function ()
    require("telescope.builtin").resume()
end

M.references = function ()
    require("telescope.builtin").lsp_references({
        include_declaration = true,
        show_line = true,
        prompt_prefix = prefix("References"),
        layout_config = {
            preview_width = 0.45,
        }
    })
end

M.lsp_document_symbols = function ()
    require("telescope.builtin").lsp_document_symbols({
        prompt_prefix = prefix("Document Symbols")
    })
end

M.lsp_workspace_symbols = function ()
    require("telescope.builtin").lsp_workspace_symbols({
        prompt_prefix = prefix("Workspace Symbols")
    })
end

return M
