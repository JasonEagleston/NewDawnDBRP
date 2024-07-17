CC := clang
CFLAGS := -L $(LUA_INCLUDE_DIR) -lluajit -shared
OBJS = timer.so
all: $(OBJS)
clean:
	rm *.so
$(OBJS): %.so: src/%.c
	$(CC) $(CFLAGS) $< -o $@
