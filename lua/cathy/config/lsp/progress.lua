local series = {}
local last_message = ""
local timer = vim.loop.new_timer()

local function clear()
    timer:stop()
    timer:start(
        3000,
        0,
        vim.schedule_wrap(function()
            last_message = ""
            vim.api.nvim_echo({{ "" }}, false, {})
        end)
    )
end

local function log(msg)
    local client = msg.client or ""
    local title = msg.title or ""
    local message = msg.message or ""
    local percentage = msg.percentage or 0

    local out = ""
    if client ~= "" then
        out = out .. "[" .. client .. ']'
    end

    if percentage > 0 then
        out = out .. " [" .. percentage .. '%]'
    end

    if title ~= "" then
        out = out .. " " .. title
    end

    if message == "" then
        return
    end

    if title ~= "" and vim.startswith(message, title) then
        message = string.sub(message, string.len(title) + 1)
    end

    message = message:gsub("%s*%d+%%", '')
    message = message:gsub("^%s*-", '')
    message = vim.trim(message)
    if message ~= "" then
        if title ~= "" then
            out = out .. " - " .. message
        else
            out = out .. " " .. message
        end
    end

    last_message = out
    vim.api.nvim_echo({ { out } }, false, {})
end

local function lsp_progress(err, progress, ctx)
    if err then
        return
    end

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local client_name = client and client.name or ""
    local token = progress.token
    local value = progress.value

    local action = {
        ["begin"] = function ()
            series[token] = {
                client = client_name,
                title = value.title or "",
                message = value.message or "",
                percentage = value.percentage or 0,
            }

            local cur = series[token]
            log({
                client = cur.client,
                title = cur.title,
                message = cur.message .. " - Starting",
                percentage = cur.percentage,
            })
        end,
        ["report"] = function ()
            local cur = series[token]
            log({
                client = client_name or (cur and cur.client),
                title = value.title or (cur and cur.title),
                message = value.message or (cur and cur.message),
                percentage = value.percentage or (cur and cur.percentage),
            })
        end,
        ["end"] = function ()
            local cur = series[token]
            local msg = value.message or (cur and cur.message)
            msg = msg and msg .. " - Done" or 'Done'
            log({
                client = client_name or (cur and cur.client),
                title = value.title or (cur and cur.title),
                message = msg,
            })
            series[token] = nil
        end,
    }

    if action[value.kind] then
        action[value.kind]()
    end
end

vim.lsp.handlers['$/progress'] = lsp_progress
