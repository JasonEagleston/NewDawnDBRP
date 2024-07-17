CC := clang
CFLAGS := -lluajit -shared
OBJS = timer.so
all: $(OBJS)
clean:
	rm *.so
$(OBJS): %.so: src/%.c
	$(CC) $(CFLAGS) $< -o $@
