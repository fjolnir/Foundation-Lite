@class NSObject;

#import <Foundation/NSObjCRuntime.h>
#import <CoreFoundation/CoreFoundation.h>

@class NSString, Protocol;

@protocol NSObject

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (Class)superclass;
- (Class)class;
- (id)self;

- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)respondsToSelector:(SEL)aSelector;

- (id)retain NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (oneway void)release NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (id)autorelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (NSUInteger)retainCount NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

- (NSString *)description;
@optional
- (NSString *)debugDescription;

@end

@protocol NSCopying
- (id)copy;
@end

@protocol NSMutableCopying
- (id)mutableCopy;
@end


NS_ROOT_CLASS
@interface NSObject <NSObject>
+ (void)load;

+ (void)initialize;
- (id)init;

+ (id)new;
+ (id)alloc;
- (void)dealloc;

+ (Class)superclass;
+ (Class)class;
+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
+ (BOOL)conformsToProtocol:(Protocol *)protocol;
- (IMP)methodForSelector:(SEL)aSelector;
- (id)forwardingTargetForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;
- (void)doesNotRecognizeSelector:(SEL)aSelector;

+ (NSString *)description;

+ (BOOL)isSubclassOfClass:(Class)aClass;
@end


#if __has_feature(objc_arc)

// After using a CFBridgingRetain on an NSObject, the caller must take responsibility for calling CFRelease at an appropriate time.
NS_INLINE CF_RETURNS_RETAINED CFTypeRef CFBridgingRetain(id X) {
    return (__bridge_retained CFTypeRef)X;
}

NS_INLINE id CFBridgingRelease(CFTypeRef CF_CONSUMED X) {
    return (__bridge_transfer id)X;
}

#else

// This function is intended for use while converting to ARC mode only.
NS_INLINE CF_RETURNS_RETAINED CFTypeRef CFBridgingRetain(id X) {
    return X ? CFRetain((CFTypeRef)X) : NULL;
}

// This function is intended for use while converting to ARC mode only.
NS_INLINE id CFBridgingRelease(CFTypeRef CF_CONSUMED X) {
    return [(id)CFMakeCollectable(X) autorelease];
}

#endif
