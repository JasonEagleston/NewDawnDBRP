#include <stdio.h>
#include <time.h>
#include <stdint.h>
#include <unistd.h>
#include <inttypes.h>
#include <luajit/lua.h>
#include <luajit/lualib.h>
#include <luajit/lauxlib.h>

int64_t milliseconds() {
    struct timespec ts;

    if (!timespec_get(&ts, TIME_UTC)) {
        return -1;
    }

    int64_t micros = ts.tv_sec * 1000000;
    micros += ts.tv_nsec / 1000;
    if (ts.tv_nsec % 1000 >= 500) {
        ++micros;
    }

    return micros / 1000;
}

static int get_time(lua_State *L) {
    lua_pushinteger(L, milliseconds());
    return 1;
}
static int lua_sleep(lua_State *L) {
    usleep((int)luaL_checkinteger(L, 1) * 1000);
    return 1;
}

static const struct luaL_Reg timer[] = {
    {"get_time", get_time},
    {"sleep", lua_sleep},
    {NULL, NULL}
};

int luaopen_timer(lua_State* L) {
    luaL_newlib(L, timer);
    printf("Loaded timers.\n");
    return 1;
}
