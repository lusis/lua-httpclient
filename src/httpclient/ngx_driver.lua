local utils = require("httpclient.utils")

local NgxDriver = {}
local ngxdriver = {}

local default_opts = {
  capture_url = '/capture',
  capture_variable = "url"
}

local function get_default_opts(t)
  local nt = utils.deep_copy(t)
  if not nt.capture_url then nt.capture_url = default_opts.capture_url end
  if not nt.capture_variable then nt.capture_variable = default_opts.capture_variable end
  return nt
end

local function merge_defaults(t1, defaults)
  for k,v in pairs(defaults) do
    if not t1[k] then t1[k] = v end
  end
  return t1
end

function ngxdriver.new(opts)
  local self = {}
  self.defaults = (get_default_opts(opts or {}))
  setmetatable(self, { __index = NgxDriver })
  return self
end

function NgxDriver:set_default(param, value)
  local t = {}
  t[param] = value
  self.defaults = merge_default(t, self.defaults)
end

function NgxDriver:get_defaults()
  return self.defaults
end

function NgxDriver:urlencode(string)
  return ngx.escape_uri(string)
end

function NgxDriver:urldecode(string)
  return ngx.unescape_uri(string)
end

function NgxDriver:urlparse(u)
  return nil
  --return urlparser.parse(u)
end

function NgxDriver:get_features()
  support_features = {
    urlencode = true,
    urldecode = true,
    urlparse = false,
    ssl = true
  }
  return support_features
end

function NgxDriver:set_last_request(req_t, driver)
  local t = {}
  t.request = req_t
  t.driver = driver
  self.last_request = t
end

function NgxDriver:get_last_request()
  return self.last_request
end

function NgxDriver:request(url, params, method, args)
  self.last_request = {}
  local query = params or nil
  local method = method or "GET"
  local uri = url or nil
  --local http_client = ngx.location.capture
  local capture_url = args.capture_url or self:get_defaults().capture_url
  local capture_variable = args.capture_variable or self:get_defaults().capture_variable
  local req_t = {}
  
  if ( method == "GET" ) then new_method = ngx.HTTP_GET end
  if ( method == "PUT" ) then new_method = ngx.HTTP_PUT end
  if ( method == "POST" ) then new_method = ngx.HTTP_POST end
  if ( method == "DELETE" ) then new_method = ngx.HTTP_DELETE end
  if ( method == "PATCH" ) then new_method = ngx.HTTP_PATCH end
  if ( method == "HEAD" ) then new_method = ngx.HTTP_HEAD end

  if not uri then
    return {nil, err = "missing url"}
  end

  if query then
    q = nil
    if type(query) == "string" then
      q = query
    else
      q = ngx.encode_args(query)
    end
    uri = uri.."?"..q
  end
  req_t = {
    args    = {[capture_variable] = uri},
    method  = new_method
  }

  -- clear all browser headers
  local bh = ngx.req.get_headers()
  for k, v in pairs(bh) do
    ngx.req.clear_header(k)
  end
  local h = args.headers or {["Accept"] = "*/*"}
  for k,v in pairs(h) do
    ngx.req.set_header(k, v)
  end
  if args.body then req_t.body = args.body end
  local results = {}
  _ = self:set_last_request(req_t, ngx.req)
  local r = ngx.location.capture(capture_url, req_t)
  results = {
    body = r.body,
    code = r.status,
    headers = r.header,
    status_line = tostring(r.status),
    err = nil
  }
  
  if (results.code >= 400 and results.code <= 599) then
    -- got an error of some kind
    local e = results.body or results.status_line or "no error"
    local r = results
    r.err = e
    return r
  end

  return results
end

return ngxdriver
