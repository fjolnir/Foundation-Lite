#import "NSAutoreleasePool.h"

#ifndef __APPLE__

#import <objc/objc-arc.h>

@interface NSAutoreleasePool () {
    void *_handle;
}
- (BOOL)_ARCCompatibleAutoreleasePool;
@end

@implementation NSAutoreleasePool

- (BOOL)_ARCCompatibleAutoreleasePool
{
    return YES;
}

- (id)init
{
    _handle = objc_autoreleasePoolPush();
    return nil;
}

+ (void)addObject: (id)anObj
{
    objc_autorelease(anObj);
}

- (void)addObject: (id)anObj
{
    objc_autorelease(anObj);
}

- (void)drain
{
  [self dealloc];
}

- (id)retain
{
    abort(); // TODO exception
    return self;
}

- (oneway void)release
{
  [self dealloc];
}
- (id)autorelease
{
    abort(); // TODO exception
    return self;
}

- (void)dealloc
{
    objc_autoreleasePoolPop(_handle);
    [super dealloc];
}

@end

#endif

