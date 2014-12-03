LUA_DIR=/usr/local
LUA_LIBDIR=$(LUA_DIR)/lib/lua/5.1
LUA_SHAREDIR=$(LUA_DIR)/share/lua/5.1
HAS_LUACOV=$(shell lua -e "ok, luacov = pcall(require, 'luacov'); if ok then print('true') end")

install:
	mkdir -p $(LUA_SHAREDIR)/httpclient
	cp src/httpclient.lua $(LUA_SHAREDIR)
	cp src/httpclient/* ${LUA_SHAREDIR)

test: tests/test_*.lua
ifeq ($(HAS_LUACOV), true)
	lua -lluacov $?
else
	lua $?
endif

.PHONY: install test
