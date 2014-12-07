package = "httpclient"
version = "0.1.0-7"
source = {
  url = "git://github.com/lusis/lua-httpclient",
  tag = "0.1.0-7"
}
description = {
  summary = "Unified http client wrapper",
  detailed = [[
    httpclient is/will be a unified wrapper around a few common lua http client libraries
    ]],
    homepage = "https://github.com/lusis/lua-httpclient",
    license = "Apache"
}
dependencies = {
  "luasocket ~> 3.0rc1-1",
  "inspect ~> 3.0-1"
}
build = {
  type = "builtin",
  modules = {
    ['httpclient'] = 'src/httpclient.lua',
    ['httpclient.luasocket_driver'] = 'src/httpclient/luasocket_driver.lua',
    ['httpclient.ngx_driver'] = 'src/httpclient/ngx_driver.lua',
    ['httpclient.utils'] = 'src/httpclient/utils.lua',
    ['httpclient.neturl'] = 'src/httpclient/neturl.lua'
  }
}
