local http = require("socket.http")
local https_ok, https = pcall(_G.require, "ssl.https")
local urlparser = require("socket.url")
local ltn12 = require("ltn12")
local utils = require("httpclient.utils")

local LuaSocketDriver = {}
local luasocketdriver = {}

local default_ssl_params = {
  mode = "client",
  protocol = "tlsv1",
  verify = "peer",
  options = "all",
  cafile = "/etc/ssl/certs/ca-certificates.crt"
}

local default_timeout = 60

local function get_default_opts(t)
  local nt = utils.deep_copy(t)
  if not nt.timeout then nt.timeout = default_timeout end
  if not nt.ssl_opts then nt.ssl_opts = default_ssl_params end
  return nt
end

local function merge_defaults(t1, defaults)
  for k, v in pairs(defaults) do
    if not t1[k] then t1[k] = v end
  end
  return t1
end

function luasocketdriver.new(opts)
  local self = {}
  self.defaults = (get_default_opts(opts or {}))
  setmetatable(self, { __index = LuaSocketDriver })
  return self
end

function LuaSocketDriver:set_default(param, value)
  local t = {}
  t[param] = value
  self.defaults = merge_defaults(t, self.defaults)
end

function LuaSocketDriver:get_defaults()
  return self.defaults
end

function LuaSocketDriver:urlencode(string)
  return urlparser.escape(string)
end

function LuaSocketDriver:urldecode(string)
  return urlparser.unescape(string)
end

function LuaSocketDriver:urlparse(u)
  return urlparser.parse(u)
end

function LuaSocketDriver:get_features()
  support_features = {
    urlencode = true,
    urldecode = true,
    urlparse = true,
    ssl = https_ok
  }
  return support_features
end

function LuaSocketDriver:set_last_request(req_t, driver)
  local t = {}
  t.request = req_t
  t.driver = driver
  self.last_request = t
end

function LuaSocketDriver:get_last_request()
  return self.last_request
end

function LuaSocketDriver:request(url, params, method, args)
  self.last_request = {}
  local resp, r = {}, {}
  local query = params or nil
  local method = method or "GET"
  local uri = url or nil
  local http_client = http
  local ssl_params = args.ssl_opts or self:get_defaults().ssl_opts
  local req_t = {}

  if not uri then
    return {nil, err = "missing url"}
  end

  if query then
    q = nil
    if type(query) == "string" then
      q = query
    else
      local qopts = {}
      for k, v in pairs(query) do
        table.insert(qopts, urlparser.escape(k).."="..urlparser.escape(v))
      end
      q = table.concat(qopts, "&")
    end
    uri = uri.."?"..q
  end
  req_t = {
    url=uri,
    sink=ltn12.sink.table(resp),
    method=method,
    redirect=true
  }

  -- Check if https
  if uri:find("^https") then
    if not https_ok then
      return {nil, "https not supported. Please install luasec"}
    end
    for k, v in pairs(ssl_params) do
      req_t[k] = v
    end 
    -- remove redirect on ssl to prevent failure
    req_t.redirect = nil
    http_client = https
  end
  
  http_client.TIMEOUT = args.timeout or default_timeout
  req_t.headers = args.headers or {["Accept"] = "*/*"}
  if args.body then req_t.source = ltn12.source.string(args.body) end
  local results = {}
  _ = self:set_last_request(req_t, http_client)
  local r = {http_client.request(req_t)}
  if #r == 2 then
    -- the request failed
    return {nil, err = r[2]}
  else
    -- we got a regular result
    results = {
      body = table.concat(resp),
      code = r[2],
      headers = r[3],
      status_line = r[4],
      err = nil
    }
  end
  
  if (results.code >= 400 and results.code <= 599) then
    -- got an error of some kind
    local e = results.body or results.status_line or "no error"
    local r = results
    r.err = e
    return r
  end

  if (results.code == 301 or results.code == 302 or results.code == 307) then
    local loop_control = args.loop_control or {}
    if loop_control[results.headers.location] then
      return {nil, err = "redirect loop on "..results.headers.location}
    end
    loop_control[results.headers.location] = true
    local location = results.headers.location
    return self:request(location, params, method, {loop_control = loop_control})
  end
  return results
end

return luasocketdriver
