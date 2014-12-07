# httpclient
`httpclient` is a unified wrapper around a few common http/s libraries and methods.

The use case for this was being able to use an internal Github API client via openresty/`ngx.location.capture` and also outside of openresty using `luasocket` and `luasec`.

The `luasocket.http` API is a bit different than the ngx api. This provides a "familiar" interface to both.

*NOTE*: the wrappers for `ngx.location.capture` and `lua-resty-http` modules are not yet done. "Release early/release often" or something like that...

## Usage
You can look at the tests for various usage examples but most interactions use a common pattern.
The result of any call will be a table with the following structure:

```lua
{
  body = <response body>,
  code = <http status code>,
  headers = <table of headers>,
  status_line = <the http status message>,
  err = <nil or error message>
}
```

### Get
```lua
hc = require('httpclient').new()
res = hc:get('http://httpbin.org/get')
if res.body then
  print(res.body)
else
  print(res.err)
end
-- {
--   "args": {}, 
--   "headers": {
--     "Accept": "*/*", 
--     "Connect-Time": "1", 
--     "Connection": "close", 
--     "Host": "httpbin.org", 
--     "Total-Route-Time": "0", 
--     "User-Agent": "LuaSocket 3.0-rc1", 
--     "Via": "1.1 vegur", 
--     "X-Request-Id": "b64c0bb9-653a-44ec-8bd2-a768ad80d720"
--   }, 
--   "origin": "1.1.1.1", 
--   "url": "http://httpbin.org/get"
-- }
```

### Post
```lua
hc = require('httpclient').new()
res = hc:post('http://httpbin.org/post','somepostdata')
```

The following verbs are supported:
- `GET`
- `PUT`
- `POST`
- `HEAD`
- `PATCH`
- `DELETE`

Note that this library does not do any special handling of the response body other than giving it to you as-is.
This library is intended to be used by a higher-level library that handles parsing

As other drivers are finished out, they'll be passed in to the constructor. Currently the default driver is `httpclient.luasocket_driver`

## openresty/nginx example
- Install to the appropriate path for luajit
- Add an `internal` location to the appropriate place for handling the location capture:

```
        location /capture {
                internal;
                resolver 8.8.8.8;
                set_unescape_uri $clean_url $arg_url;
                proxy_pass $clean__url;
        }

```

The above stanza sets up an internal capture location called `/capture`. When a request is sent to it via `ngx.location.capture`, takes whatever url is sent to that location and strips off the `url` argument from it and then does a standard proxy pass.

You can use either `content_by_lua` or `content_by_lua_file` with something like so in it:

```lua
local hc = require("httpclient").new('httpclient.ngx_driver')

local d,_ = hc:get("https://httpbin.org/get")

ngx.header.content_type = d.headers['content-type'];
ngx.say(d.body)
```

Note the default options for the `ngx_driver` are to use a capture location of `/capture` and for the real url to be passed with an arg name of `url`. This can be overridden like so:

```lua
local hc = require("httpclient").new('httpclient.ngx_driver')
hc:set_default('capture_url', '/somewhere_else')
hc:set_default('capture_variable', 'someother_variable')
```

Those changes would result in your above stanza requiring the following:

```
        location /somewhere_else {
                internal;
                resolver 8.8.8.8;
                set_unescape_uri $clean_url $arg_someother_variable;
                proxy_pass $clean__url;
        }
```

Note that previous versions of this readme required setting some params in the internal redirect to clear headers. This is no longer needed as the ngx driver will now clear ALL headers before requesting.

## Other bits
There are ways to override much of what you pass in to the actual http request specific to the driver.

## Install
Easiest option is probably to install from luarocks:

`luarocks install httpclient`

Alternately, you can install via the included `Makefile`. You'll probably want to override the `LUA_SHAREDIR` environment variable. You'll also need to make sure you install `luasocket` and ideally `luasec` (for https links).

## Requirements
The following versions were tested
- lua 5.2 (the version that shipped with trusty)
- luasec 0.5-2 (only required for https support)
- luasocket 3.0rc1-1
- net-url (included MIT license - https://github.com/golgote/neturl - see LICENSE.net-url)

If you want to run the test suite:
- luacov 0.6-1
luaunit is included in the test dir

## Third-party
Included third-party code

### neturl
httpclient also includes its own url parser provided by [neturl](https://github.com/golgote/neturl). This is because the urlparser shipped with luasocket has quite a few issues the biggest of which is the inability to parse querystrings.

### luaunit
unit testing is done using [luaunit](https://github.com/bluebird75/luaunit)

## TODO
- Add remaining drivers
- make a rockspec/post to luarocks
- Document better
