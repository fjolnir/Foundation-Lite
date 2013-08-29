#include <Foundation/NSObject.h>

@class NSDictionary, NSArray;

// Predefined domain for errors from most AppKit and Foundation APIs.
FOUNDATION_EXPORT NSString * const NSCocoaErrorDomain;

// Other predefined domains; value of "code" will correspond to preexisting values in these domains.
FOUNDATION_EXPORT NSString * const NSPOSIXErrorDomain;
FOUNDATION_EXPORT NSString * const NSOSStatusErrorDomain;
FOUNDATION_EXPORT NSString * const NSMachErrorDomain;

// Key in userInfo. A recommended standard way to embed NSErrors from underlying calls. The value of this key should be an NSError.
FOUNDATION_EXPORT NSString * const NSUnderlyingErrorKey;

// Other standard keys in userInfo, for various error codes
FOUNDATION_EXPORT NSString * const NSStringEncodingErrorKey;  // NSNumber containing NSStringEncoding
FOUNDATION_EXPORT NSString * const NSURLErrorKey;  // NSURL
FOUNDATION_EXPORT NSString * const NSFilePathErrorKey;  // NSString


@interface NSError : NSObject <NSCopying>
@property(readonly) NSInteger code;
@property(readonly) NSString *domain;
@property(readonly) NSDictionary *userInfo;

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
@end
