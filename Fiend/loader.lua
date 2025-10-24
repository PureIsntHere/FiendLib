-- Fiend Remote Loader — drop-in single require for GitHub/raw hosts
-- Usage:
--   local repo = 'https://raw.githubusercontent.com/<user>/<repo>/<branch>/Fiend/'
--   local Fiend = loadstring(game:HttpGet(repo .. 'loader.lua'))()(repo)
--
-- Optional: load an addon in one line
--   local ThemeManager = loadstring(game:HttpGet(repo .. 'loader.lua'))()(repo, 'addons/ThemeManager')
--
-- Advanced: multiple modules
--   local L = loadstring(game:HttpGet(repo .. 'loader.lua'))()
--   local Fiend, ThemeManager, SaveManager = L(repo, {'init', 'addons/ThemeManager', 'addons/SaveManager'})

local HttpGet
do
    -- pick the strongest HTTP primitive available
    if syn and syn.request then
        HttpGet = function(url)
            local r = syn.request({Url = url, Method = 'GET'})
            assert(r and r.Success and r.StatusCode == 200, ('[FiendLoader] HTTP %s: %s'):format(r and r.StatusCode or '?', url))
            return r.Body
        end
    elseif http and http.request then
        HttpGet = function(url)
            local r = http.request({Url = url, Method = 'GET'})
            assert(r and r.Success and r.StatusCode == 200, ('[FiendLoader] HTTP %s: %s'):format(r and r.StatusCode or '?', url))
            return r.Body
        end
    else
        HttpGet = function(url)
            return game:HttpGet(url)
        end
    end
end

return function(baseUrl, what)
    assert(type(baseUrl) == 'string', '[FiendLoader] Pass the base repo URL ending with /Fiend/')
    if baseUrl:sub(-1) ~= '/' then baseUrl = baseUrl .. '/' end

    local cache = {}   -- url -> module return
    local srcCache = {}-- url -> source (optional)
    local loaded = {}  -- path -> module return

    -- Convert "lib/utils" or "lib.utils" to normalized path
    local function norm(path)
        path = path:gsub('%.', '/')
        path = path:gsub('^/*', ''):gsub('/*$', '')
        return path
    end

    -- Virtual "script" node to support script.Parent.Parent.foo.bar resolution
    local function ScriptNode(path)
        return setmetatable({ __path = path }, {
            __index = function(t, k)
                if k == 'Parent' then
                    local up = t.__path:match('(.+)/[^/]+$') or ''
                    return ScriptNode(up)
                else
                    local new = (t.__path == '' and k) or (t.__path == '' and k) or (t.__path == '' and k)
                    new = (t.__path == '' and k) or (t.__path .. '/' .. k)
                    return ScriptNode(new)
                end
            end
        })
    end

    -- Core remote require, aware of our ScriptNode
    local function RemoteRequire(arg)
        if type(arg) == 'table' and arg.__path then
            return RemoteRequire(arg.__path)
        end
        local mpath = norm(arg)
        if loaded[mpath] ~= nil then return loaded[mpath] end

        local url = baseUrl .. mpath .. '.lua'
        local src = srcCache[url]
        if not src then
            src = HttpGet(url)
            assert(type(src) == 'string' and #src > 0, ('[FiendLoader] empty source @ %s'):format(url))
            srcCache[url] = src
        end

        -- Compile with a friendly chunkname
        local chunk, err = loadstring(src, ('=@Fiend/%s'):format(mpath))
        assert(chunk, ('[FiendLoader] loadstring failed for %s: %s'):format(mpath, tostring(err)))

        -- Sandbox that mimics Roblox/Luau globals but injects our require + script
        local env = setmetatable({}, { __index = getfenv(1) })
        env.require = RemoteRequire
        env.script  = ScriptNode(mpath)

        setfenv(chunk, env)
        local ok, ret = pcall(chunk)
        assert(ok, ('[FiendLoader] runtime error in %s: %s'):format(mpath, tostring(ret)))

        loaded[mpath] = ret
        return ret
    end

    -- Helper to resolve modules:
    --   * string -> single module ('init' by default)
    --   * table  -> list of modules
    --   * nil    -> 'init'
    local function grab(target)
        if target == nil then
            return RemoteRequire('init')
        elseif type(target) == 'string' then
            return RemoteRequire(target)
        elseif type(target) == 'table' then
            local out = {}
            for i, p in ipairs(target) do
                out[i] = RemoteRequire(p)
            end
            return table.unpack(out)
        else
            error('[FiendLoader] invalid second argument: ' .. typeof(target))
        end
    end

    return grab(what)
end