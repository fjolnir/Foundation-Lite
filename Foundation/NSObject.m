#import "NSObject.h"
#import "NSAutoreleasePool.h"
#import "NSString.h"
#import "NSException.h"
#import <objc/runtime.h>

// The Apple runtime already implements NSObject
#ifndef __APPLE__
#import <objc/hooks.h>
#import <objc/objc-arc.h>

// libobjc2 allocates sizeof(void*) space before the object, we store the reference count there
#define RefCountPtr ((intptr_t *)((intptr_t *)self - 1))

@interface NSObject () {
    Class isa;
}
- (id)_unhandledSelector_linux;
@end

static id proxy_lookup(id aReceiver, SEL aSelector)
{
    if(class_respondsToSelector(object_getClass(aReceiver), @selector(forwardingTargetForSelector:)))
        return [aReceiver forwardingTargetForSelector:aSelector];
    return nil;
}

static struct objc_slot *retrieve_doesNotRecognizeSelector(id aReceiver, SEL aSelector)
{
    __thread static struct objc_slot forwardingSlot;
    forwardingSlot.method = class_getMethodImplementation(object_getClass(aReceiver), @selector(_unhandledSelector_linux));
    return &forwardingSlot;
}

@implementation NSObject
- (void)_ARCCompliantRetainRelease {}

+ (void)load
{
    return;
}

+ (void)initialize
{
    objc_proxy_lookup   = &proxy_lookup;
    __objc_msg_forward3 = &retrieve_doesNotRecognizeSelector;
}

+ (id)new
{
    return [[self alloc] init];
}

+ (id)alloc
{
    return class_createInstance(self, 0);
}

- (void)dealloc
{
    object_dispose(self);
}

- (id)init
{
    return self;
}

- (id)retain
{
    __sync_add_and_fetch(RefCountPtr, 1);
    return self;
}
+ (id)retain
{
    return self;
}

- (oneway void)release
{
    if(__sync_sub_and_fetch(RefCountPtr, 1) == -1) {
        objc_delete_weak_refs(self);
        [self dealloc];
    }
}
+ (oneway void)release
{
    return;
}

- (id)autorelease
{
    [NSAutoreleasePool addObject:self];
    return self;
}
+ (id)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return *RefCountPtr + 1;
}
+ (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self];
}
+ (NSString *)description
{
    return NSStringFromClass(self);;
}

- (NSString *)debugDescription
{
    return [self description];
}
+ (NSString *)debugDescription
{
    return [self description];
}

#pragma mark - Introspection

- (Class)superclass
{
    return class_getSuperclass([self class]);
}
- (Class)class
{
    return object_getClass(self);
}
- (id)self
{
    return self;
}

+ (BOOL)isSubclassOfClass:(Class)aClass
{
    for(Class klass = self; klass; klass = class_getSuperclass(klass)) {
        if(klass == aClass)
            return YES;
    }
    return NO;
}

+ (BOOL)isKindOfClass:(Class)aClass
{
    for(Class klass = object_getClass(self); klass; klass = class_getSuperclass(klass)) {
        if(klass == aClass)
            return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    for(Class klass = [self class]; klass; klass = class_getSuperclass(klass)) {
        if(klass == aClass)
            return YES;
    }
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [self class] == aClass;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return class_conformsToProtocol([self class], aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
   return class_respondsToSelector([self class], aSelector);
}


+ (Class)superclass
{
    return class_getSuperclass(self);
}
+ (Class)class
{
    return self;
}
+ (BOOL)instancesRespondToSelector:(SEL)aSelector
{
    return class_respondsToSelector(self, aSelector);
}
+ (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return class_conformsToProtocol(self, aProtocol);
}
- (IMP)methodForSelector:(SEL)aSelector
{
    return class_getMethodImplementation([self class], aSelector);
}
+ (IMP)instanceMethodForSelector:(SEL)aSelector
{
    return class_getMethodImplementation(self, aSelector);
}


#pragma mark - Dispatch

- (id)performSelector:(SEL)aSelector
{
    return objc_msgSend(self, aSelector);
}
- (id)performSelector:(SEL)aSelector withObject:(id)object
{
    return objc_msgSend(self, aSelector, object);
}
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2
{
    return objc_msgSend(self, aSelector, object1, object2);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}

// Necessary because libobjc2 passes the selector in _cmd
- (id)_unhandledSelector_linux
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
+ (id)_unhandledSelector_linux
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
+ (void)doesNotRecognizeSelector:(SEL)aSelector
{
    @throw [NSException exceptionWithName:@"UnrecognizedSelectorException"
                                   format:@"+[%@ %s]: unrecognized selector sent to class %p", self, sel_getName(aSelector), self];
}
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    @throw [NSException exceptionWithName:@"UnrecognizedSelectorException"
                                   format:@"-[%@ %s]: unrecognized selector sent to object %p", [self class], sel_getName(aSelector), self];
}


#pragma mark - Comparison

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}
- (NSUInteger)hash
{
    return (NSUInteger)self;
}

@end

#endif
