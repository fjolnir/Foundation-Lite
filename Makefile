CC=clang

CFLAGS  = -fblocks -fobjc-nonfragile-abi -fno-constant-cfstrings -I. -Wall -g -O0
LDFLAGS=-L/usr/local/lib -lobjc -lpthread -ldispatch -lCoreFoundation

SRC       = test.m \
            Foundation/NSObjCRuntime.m \
            Foundation/NSNumber.m \
            Foundation/NSException.m \
            Foundation/NSData.m \
            Foundation/NSError.m

SRC_NOARC = Foundation/NSObject.m \
            Foundation/NSAutoreleasePool.m \
            Foundation/NSArray.m \
            Foundation/NSDictionary.m \
            Foundation/NSString.m

OBJ       = $(addprefix build/, $(SRC:.m=.o))
OBJ_NOARC = $(addprefix build/, $(SRC_NOARC:.m=.o))

$(OBJ): ARC_FLAGS := -fobjc-arc

build/%.o: %.m
	@echo "\033[32m * Building $< -> $@\033[0m"
	@mkdir -p "build/Foundation"
	@$(CC) $(CFLAGS) $(ARC_FLAGS) -c $< -o $@

all: $(OBJ_NOARC) $(OBJ)
	@$(CC) $(LDFLAGS) $(OBJ) $(OBJ_NOARC) -o test
	@echo ""
	@LD_LIBRARY_PATH=/usr/local/lib ./test

clean:
	@rm -rf build
