local n,f,t = _G.node, _G.file, _G.tmr
local index = n.flashindex()
local G=_ENV or getfenv()
local lfs_t
if _VERSION == 'Lua 5.1' then
  lfs_t = {
  __index = function(_, name)
    local fn_ut, ba, ma, size, modules = index(name)
    if not ba then return fn_ut
    elseif name == '_time' then return fn_ut
    elseif name == '_config' then
      local fs_ma, fs_size = f.fscfg()
      return {lfs_base = ba, lfs_mapped = ma, lfs_size = size, fs_mapped = fs_ma, fs_size = fs_size}
    elseif name == '_list' then
      return modules
    else
      return nil
    end
  end,
  __newindex = function(_, name, value)
    error("LFS is readonly. Invalid write to LFS. " .. name .. ': '.. value, 2)
  end,
  }
  setmetatable(lfs_t,lfs_t)
else
  lfs_t = n.LFS
end
G.LFS = lfs_t
package.loaders[3] = function(module)
  return lfs_t[module]
end
local lf, df = loadfile, dofile
G.loadfile = function(x)
  local mod, ext = x:match("(.*)%.(l[uc]a?)");
  local fn, ba   = index(mod)
  if ba or (ext ~= 'lc' and ext ~= 'lua') then return lf(x) else return fn end
end
G.dofile = function(x)
  local mod, ext = x:match("(.*)%.(l[uc]a?)");
  local fn, ba   = index(mod)
  if ba or (ext ~= 'lc' and ext ~= 'lua') then return df(x) else return fn() end
end
if n.flashindex() == nil then
  if f.exists("LFS.img") then n.flashreload('LFS.img') else G.LFS = nil end
end
local initTimer = t.create()
initTimer:register(1000, t.ALARM_SINGLE,
  function() local fi=n.flashindex; return pcall(fi and fi'_init') end)
initTimer:start()
