LUA_DIR=/usr/local
LUA_LIBDIR=$(LUA_DIR)/lib/lua/5.1
LUA_SHAREDIR=$(LUA_DIR)/share/lua/5.1

install:
	mkdir -p $(LUA_SHAREDIR)/httpclient
	cp src/httpclient.lua $(LUA_SHAREDIR)
	cp src/httpclient/* ${LUA_SHAREDIR)

.PHONY: install
