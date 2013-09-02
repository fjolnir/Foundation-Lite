CC = clang

PREFIX = /usr/local
PRODUCT_NAME = libfoundation_lite.so

CFLAGS  = -fblocks -fobjc-nonfragile-abi -fno-constant-cfstrings -I. -Wall -g -O0
LIB_CFLAGS = -fPIC
LDFLAGS=-L/usr/local/lib -lobjc -lpthread -ldispatch -lCoreFoundation

SRC       = Foundation/NSObjCRuntime.m \
            Foundation/NSNumber.m \
            Foundation/NSException.m \
            Foundation/NSData.m \
            Foundation/NSDate.m \
            Foundation/NSURL.m \
            Foundation/NSError.m

SRC_NOARC = Foundation/NSObject.m \
            Foundation/NSAutoreleasePool.m \
            Foundation/NSArray.m \
            Foundation/NSDictionary.m \
            Foundation/NSString.m

TEST_SRC  = $(wildcard testcases/*.m)

OBJ       = $(addprefix build/, $(SRC:.m=.o))
OBJ_NOARC = $(addprefix build/, $(SRC_NOARC:.m=.o))

$(OBJ): ARC_CFLAGS := -fobjc-arc

build/%.o: %.m
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p "build/Foundation"
	@$(CC) $(CFLAGS) $(LIB_CFLAGS) $(ARC_CFLAGS) -c $< -o $@

all: $(OBJ_NOARC) $(OBJ)
	@$(CC) $(LDFLAGS) $(OBJ) $(OBJ_NOARC) -shared -o build/$(PRODUCT_NAME)
	@echo ""

install: all
	mkdir -p $(PREFIX)/include/Foundation
	cp Foundation/*.h $(PREFIX)/include/Foundation
	cp build/$(PRODUCT_NAME) $(PREFIX)/lib/$(PRODUCT_NAME)

test: all
	@$(CC) $(TEST_SRC) $(ARC_FLAGS) -L./build -lfoundation_lite -fobjc-arc $(CFLAGS) -o build/test
	@LD_LIBRARY_PATH=./build build/test

clean:
	@rm -rf build
