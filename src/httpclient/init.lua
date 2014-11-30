local utils = require("httpclient.utils")

local HttpClient = {}
local m = {}

local DEFAULT_DRIVER = 'httpclient.luasocket_driver'

function m.new(x)
  local self = {}
  local d = x or DEFAULT_DRIVER
  local driver_ok, driver = pcall(require, d) 
  if not driver_ok then
    error()
  end
  self.client = driver.new()
  self.defaults = self.client.defaults
  setmetatable(self, {__index = HttpClient})
  return self
end

local function merge_defaults(t1, defaults)
  for k, v in pairs(defaults) do
    if not t1[k] then t1[k] = v end
  end
  return t1
end

function HttpClient:set_default(param, value)
  self.client:set_default(param, value)
  self.defaults = self.client.defaults
end

function HttpClient:get_defaults()
  return self.defaults
end

function HttpClient:get(url, options)
  local opts = options or self:get_defaults()
  local params = opts.params or nil
  local method = "GET"

  return self.client:request(url, params, method, opts)
end

function HttpClient:post(url, data, options)
  local opts = options or {}
  opts = merge_defaults(opts, self:get_defaults())
  local params = opts.params or nil
  if opts.content_type then
    opts.headers = opts.headers or {}
    opts.headers["Content-Type"] = opts.content_type
  end
  -- post/put/patch all look similar
  -- allow method passed in via opts to unify "posting" code
  local method = opts.method or "POST"
  if not data then
    return {nil, err = "missing data"}
  else
    opts.body = data
    opts.headers = opts.headers or {}
    opts.headers["Content-Length"] = string.len(data)
  end

  return self.client:request(url, params, method, opts)
end

function HttpClient:put(url, data, options)
    local opts = options or {}
    opts.method = "PUT"
    return self:post(url, data, opts)
end

function HttpClient:patch(url, data, options)
    local opts = options or {}
    opts.method = "PATCH"
    return self:post(url, data, opts)
end

function HttpClient:head(url, options)
  local opts = options or {}
  opts = merge_defaults(opts, self:get_defaults())
  local params = opts.params or nil

  local method = "HEAD"
  return self.client:request(url, params, method, opts)
end

function HttpClient:delete(url, options)
  local opts = options or {}
  opts = merge_defaults(opts, self:get_defaults())
  local params = opts.params or nil

  local method = "DELETE"
  return self.client:request(url, params, method, opts)
end

return m
