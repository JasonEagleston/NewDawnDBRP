CC := clang
CFLAGS := -lluajit -shared
OBJS = timer.so
all: $(OBJS)
clean:
	rm *.so	
$(OBJS): %.so: modules/%.c
	$(CC) $(CFLAGS) $< -o $@