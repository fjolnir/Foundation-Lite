#import "NSError.h"
#import "NSString.h"

NSString * const NSCocoaErrorDomain = @"NSCocoaErrorDomain";

NSString * const NSPOSIXErrorDomain = @"NSPOSIXErrorDomain";
NSString * const NSOSStatusErrorDomain = @"NSOSStatusErrorDomain";
NSString * const NSMachErrorDomain = @"NSMachErrorDomain";

NSString * const NSUnderlyingErrorKey = @"NSUnderlyingErrorKey";

NSString * const NSStringEncodingErrorKey = @"NSStringEncodingErrorKey";
NSString * const NSURLErrorKey = @"NSURLErrorKey";
NSString * const NSFilePathErrorKey = @"NSFilePathErrorKey";


@implementation NSError

+ (id)errorWithDomain:(NSString *)aDomain code:(NSInteger)aCode userInfo:(NSDictionary *)aUserInfo
{
    return [[self alloc] initWithDomain:aDomain code:aCode userInfo:aUserInfo];
}

- (id)initWithDomain:(NSString *)aDomain code:(NSInteger)aCode userInfo:(NSDictionary *)aUserInfo
{
    if((self = [super init])) {
        _domain = [aDomain copy];
        _code   = aCode;
//        _userInfo = aUserInfo;
    }
    return self;
}

- (id)copy
{
    return self;
}

@end
