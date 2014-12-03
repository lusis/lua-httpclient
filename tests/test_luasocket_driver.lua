package.path = ';src/?.lua;src/httpclient/?.lua;tests/?.lua;'..package.path
require('luaunit')

local httpclient = require("httpclient")
local cjson = require("cjson")

TestHttpClientLuaSocket = {}

function TestHttpClientLuaSocket:setup()
end

function TestHttpClientLuaSocket:test_failure()
  local hc = httpclient.new()
  local res = hc:get("http://nohost")
  assertEquals(res.body, nil)
  assertEquals(res.err, "host or service not provided, or not known")
end

function TestHttpClientLuaSocket:test_defaults()
  local hc = httpclient.new()
  assertEquals(type(hc:get_defaults()), "table")
  -- existing key
  hc:set_default("timeout", 120)
  assertEquals(hc.defaults.timeout, 120)
  assertEquals(hc:get_defaults().timeout, 120)
  -- ssl opts
  assertEquals(hc.defaults.ssl_opts.verify, "peer")
  hc:set_default("ssl_opts", { verify = "none" })
  assertEquals(hc.defaults.ssl_opts.verify, "none")
  -- new key
  hc:set_default("foo", "bar")
  assertEquals(hc.defaults.foo, "bar")
  assertEquals(hc:get_defaults().foo, "bar")
  -- passed in via request is handled in timeout test
end

function TestHttpClientLuaSocket:test_query_table()
  local params = {foo = "bar"}
  local opts = {params = params}
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/get",opts)
  local b = cjson.decode(res.body)
  assertEquals(b.args.foo, "bar")
end

function TestHttpClientLuaSocket:test_query_string()
  local params = "foo=bar"
  local opts = {params = params}
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/get",opts)
  local b = cjson.decode(res.body)
  assertEquals(b.args.foo, "bar")
end

function TestHttpClientLuaSocket:test_timeout()
  local hc = httpclient.new()
  hc:set_default('timeout', 5)
  assertEquals(hc.defaults.timeout, 5)
  local res = hc:get("http://httpbin.org/delay/10")
  assertEquals(res.body, nil)
  assertEquals("timeout", res.err)
end

function TestHttpClientLuaSocket:test_head()
  local hc = httpclient.new()
  local res = hc:head("http://httpbin.org/get")
  assertEquals(res.code, 200)
  assertEquals(res.body, "")
  assertEquals(res.headers["content-type"], "application/json")
end

function TestHttpClientLuaSocket:test_get()
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/get")
  -- assert we have all the bits
  assertEquals(res.err, nil)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.code, nil)
  assertNotEquals(res.headers, nil)
  assertNotEquals(res.status_line, nil)
  -- now we test the actual data
  local b = cjson.decode(res.body)
  assertEquals(res.code, 200)
  assertEquals(b.url, "http://httpbin.org/get")
  assertEquals(res.headers["content-type"], "application/json")
  assertEquals(res.status_line, "HTTP/1.1 200 OK")
end

function TestHttpClientLuaSocket:test_post()
  local post_data = "foobarbang"
  local hc = httpclient.new()
  local res = hc:post("http://httpbin.org/post",post_data)
  -- assert we have all the bits
  assertEquals(res.err, nil)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.code, nil)
  assertNotEquals(res.headers, nil)
  assertNotEquals(res.status_line, nil)
  -- now we test the actual data
  local b = cjson.decode(res.body)
  assertEquals(res.code, 200)
  assertEquals(b.data, post_data)
  assertEquals(res.headers["content-type"], "application/json")
  assertEquals(res.status_line, "HTTP/1.1 200 OK")
end

function TestHttpClientLuaSocket:test_put()
  local put_data = "foobarbang"
  local hc = httpclient.new()
  local res = hc:put("http://httpbin.org/put",put_data)
  -- assert we have all the bits
  assertEquals(res.err, nil)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.code, nil)
  assertNotEquals(res.headers, nil)
  assertNotEquals(res.status_line, nil)
  -- now we test the actual data
  local b = cjson.decode(res.body)
  assertEquals(res.code, 200)
  assertEquals(b.data, put_data)
  assertEquals(res.headers["content-type"], "application/json")
  assertEquals(res.status_line, "HTTP/1.1 200 OK")
end

function TestHttpClientLuaSocket:test_patch()
  local patch_data = "foobarbang"
  local hc = httpclient.new()
  local res = hc:patch("http://httpbin.org/patch",patch_data)
  -- assert we have all the bits
  assertEquals(res.err, nil)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.code, nil)
  assertNotEquals(res.headers, nil)
  assertNotEquals(res.status_line, nil)
  -- now we test the actual data
  local b = cjson.decode(res.body)
  assertEquals(res.code, 200)
  assertEquals(b.data, patch_data)
  assertEquals(res.headers["content-type"], "application/json")
  assertEquals(res.status_line, "HTTP/1.1 200 OK")
end

function TestHttpClientLuaSocket:test_delete()
  local hc = httpclient.new()
  local res = hc:delete("http://httpbin.org/status/204")
  assertEquals(res.err, nil)
  assertEquals(res.body, "")
  assertNotEquals(res.code, nil)
  assertNotEquals(res.headers, nil)
  assertNotEquals(res.status_line, nil)
  -- now we test the actual data
  assertEquals(res.code, 204)
  assertEquals(res.headers["content-length"], "0")
  assertEquals(res.status_line, "HTTP/1.1 204 NO CONTENT")
end

function TestHttpClientLuaSocket:test_set_content_type()
  local hc = httpclient.new()
  local res = hc:post("http://httpbin.org/post","foobarbang",{content_type = "text/xml"})
  local b = cjson.decode(res.body)
  assertEquals(b.headers["Content-Type"], "text/xml")
end

function TestHttpClientLuaSocket:test_override_header()
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/get",{headers = {accept = "application/json"}})
  local b = cjson.decode(res.body)
  assertEquals(b.headers["Accept"], "application/json")
end

function TestHttpClientLuaSocket:test_override_post_override_all()
  local post_data = ""
  local user_agent = "lua httpclient unit tests"
  local hc = httpclient.new()
  local res = hc:post("http://httpbin.org/post",post_data, {headers = {accept = "application/json", ["user-agent"] = user_agent}, params = {baz = "qux"}})
  local b = cjson.decode(res.body)
  assertEquals(res.code, 200)
  assertEquals(b.data, post_data)
  assertEquals(b.headers["Accept"], "application/json")
  assertEquals(b.headers["User-Agent"], user_agent)
  assertEquals(b.args.baz, "qux")
  assertEquals(res.headers["content-type"], "application/json")
  assertEquals(res.status_line, "HTTP/1.1 200 OK")
end

function TestHttpClientLuaSocket:test_https()
  local hc = httpclient.new()
  local res = hc:get("https://httpbin.org/get")
  assertEquals(res.code, 200)
  assertEquals(hc:get_last_request().driver._NAME, "ssl.https")
end

function TestHttpClientLuaSocket:test_redirect_to_ssl()
  local hc = httpclient.new()
  local res = hc:get("http://gist.githubusercontent.com/lusis/4a4450a3133f086cb5bb/raw/0a2e6673368cc21c21dda0fe05a09f6d43f3246b/e.lua")
  assertEquals(res.code, 200)
  assertEquals(hc:get_last_request().driver._NAME, "ssl.https")
end

-- temporarily disabled
-- no reliable way to test this yet (at least via httpbin)
-- function TestHttpClientLuaSocket:test_ssl_redirect()
--   local redir_to = "https://httpbin.org/get"
--   local hc = httpclient.new()
--   local res = hc:get("http://httpbin.org/redirect-to?url="..redir_to)
--   assertEquals(res.code, 200)
--   local b = cjson.decode(res.body)
--   assertEquals(b.url, redir_to)
-- end

function TestHttpClientLuaSocket:test_4xx()
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/status/418")
  assertEquals(res.code, 418)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.headers, nil)
  assertEquals(res.status_line, "HTTP/1.1 418 I'M A TEAPOT")
  -- We don't care what the error IS just that it sets err
  assertNotEquals(res.err, nil)
end

function TestHttpClientLuaSocket:test_5xx()
  local hc = httpclient.new()
  local res = hc:get("http://httpbin.org/status/500")
  assertEquals(res.code, 500)
  assertNotEquals(res.body, nil)
  assertNotEquals(res.headers, nil)
  assertEquals(res.status_line, "HTTP/1.1 500 INTERNAL SERVER ERROR")
  -- We don't care what the error IS just that it sets err
  assertNotEquals(res.err, nil)
end

function TestHttpClientLuaSocket:test_redir_loop()
  -- no way to test this yet
  -- httpbin /redirect/:n doesn't send you to same location each time
end

function TestHttpClientLuaSocket:test_missing_url()
  local hc = httpclient.new()
  local res = hc:get(nil)
  assertNil(res.body)
  assertEquals(res.err, "missing url")
end

function TestHttpClientLuaSocket:test_body()
  local hc = httpclient.new()
  local res = hc:post("http://httpbin.org/post",nil)
  assertNil(res.body)
  assertEquals(res.err, "missing data")
end

lu = LuaUnit.new()
lu:setOutputType("tap")
os.exit(lu:runSuite())
