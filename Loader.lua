local REPO = "trademarkman/toast-hub"

local RAW = "https://raw.githubusercontent.com/" .. REPO .. "/main/"
local SELF = 'loadstring(game:HttpGet("' .. RAW .. 'ToastHubloader.lua"))()'

local GAMES = {
    [994732206] = {
        name = "Blox Fruits",
        url = "https://vault.pandauth.com/vss/b7d03623a11d0021",
        before = function()
            local cfg = getgenv().ToastHub
            if type(cfg) ~= "table" then
                cfg = {}
                getgenv().ToastHub = cfg
            end
            cfg.Loader = cfg.Loader or SELF
        end,
    },
    [10624691669] = {
        name = "MONOCHROME",
        url = "https://vault.pandauth.com/vss/26419235db6b660b",
        rerun = true,
    },
    [245662005] = {
        name = "Jailbreak",
        url = "https://vault.pandauth.com/vss/afcfd7f04c48e88c",
    },
    [3508322461] = {
        name = "Jujutsu Shenanigans",
        url = "https://vault.pandauth.com/vss/d0a9f76614d6058c",
    },
    [66654135] = {
        name = "Murder Mystery 2",
        url = "https://vault.pandauth.com/vss/6683d5952f12a44b",
    },
}

local function say(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Toast",
            Text = text,
            Duration = 6,
        })
    end)
end

local function fail(text, detail)
    say(text)
    warn("[Toast] " .. text .. (detail ~= nil and (" | " .. tostring(detail)) or ""))
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end
local waited = 0
while game.GameId == 0 and waited < 10 do
    waited = waited + task.wait(0.2)
end

local entry = GAMES[game.GameId]
if not entry then
    local names = {}
    for _, g in pairs(GAMES) do
        names[#names + 1] = g.name
    end
    table.sort(names)
    fail("This game isn't supported. Supported: " .. table.concat(names, ", "))
    return
end

say("Loading " .. entry.name .. "...")

local ok, source = pcall(function()
    return game:HttpGet(entry.url)
end)
if not ok or type(source) ~= "string" or source == "" or source:sub(1, 4) == "404:" then
    fail("Couldn't download the " .. entry.name .. " script. Try again in a minute.", source)
    return
end

local fn, compileErr = loadstring(source, "=" .. entry.name)
if not fn then
    fail("The " .. entry.name .. " script didn't compile.", compileErr)
    return
end

if entry.before then
    pcall(entry.before)
end

if entry.rerun and not getgenv().ToastLoaderQueued then
    local queue = queue_on_teleport
        or queueonteleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
    if queue then
        getgenv().ToastLoaderQueued = true
        pcall(queue, SELF)
    end
end

local ran, runErr = pcall(fn)
if not ran then
    fail("The " .. entry.name .. " script hit an error.", runErr)
end
