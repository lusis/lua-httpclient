package = "httpclient"
version = "0.1.0-2"
source = {
  url = "git://github.com/lusis/lua-httpclient",
  tag = "0.1.0-2"
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
  "luasocket ~> 3.0rc1-1"
}
build = {
  type = "builtin",
  modules = {
    ['httpclient'] = 'src/httpclient/init.lua',
    ['httpclient.luasocket_driver'] = 'src/httpclient/luasocket_driver.lua',
    ['httpclient.inspect'] = 'src/httpclient/inspect.lua',
    ['httpclient.utils'] = 'src/httpclient/utils.lua'
  }
}
