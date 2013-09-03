#import "NSException.h"
#import "NSString.h"
#import "NSDictionary.h"
#import <objc/hooks.h>

NSString *NSGenericException = @"NSGenericException";
NSString *NSRangeException = @"NSRangeException";
NSString *NSInvalidArgumentException = @"NSInvalidArgumentException";
NSString *NSInternalInconsistencyException = @"NSInternalInconsistencyException";
NSString *NSMallocException = @"NSMallocException";
NSString *NSObjectInaccessibleException = @"NSObjectInaccessibleException";
NSString *NSObjectNotAvailableException = @"NSObjectNotAvailableException";
NSString *NSDestinationInvalidException = @"NSDestinationInvalidException";
NSString *NSPortTimeoutException = @"NSPortTimeoutException";
NSString *NSInvalidSendPortException = @"NSInvalidSendPortException";
NSString *NSInvalidReceivePortException = @"NSInvalidReceivePortException";
NSString *NSPortSendException = @"NSPortSendException";
NSString *NSPortReceiveException = @"NSPortReceiveException";



@interface NSException () {
    NSString *_name, *_reason;
    NSDictionary *_userInfo;
}
@end

static void _handleUnexpectedException(id aException)
{
    if([aException isKindOfClass:[NSException class]])
        NSLog(@" *** Terminating due to uncaught exception '%@', reason: '%@'",
              [aException name], [aException reason]);
    else
        NSLog(@" *** Terminating due to uncaught exception: %@", aException);
    abort();
}

@implementation NSException

+ (void)initialize
{
    _objc_unexpected_exception = &_handleUnexpectedException;
}

+ (void)raise:(NSString *)aName format:(NSString *)aFormat, ...
{
    va_list argList;
    @try {
        va_start(argList, aFormat);
        [self raise:aName format:aFormat arguments:argList];
    } @catch(id e) {
        @throw e;
    } @finally {
        va_end(argList);
    }
}

+ (void)raise:(NSString *)aName format:(NSString *)aFormat arguments:(va_list)aArgList
{
    [[self exceptionWithName:aName 
                      reason:[[NSString alloc] initWithFormat:aFormat arguments:aArgList]
                    userInfo:nil] raise];
}

+ (NSException *)exceptionWithName:(NSString *)aName
                            reason:(NSString *)aReason
                          userInfo:(NSDictionary *)aUserInfo
{
    return [[self alloc] initWithName:aName reason:aReason userInfo:aUserInfo];
}

+ (NSException *)exceptionWithName:(NSString *)aName
                            format:(NSString *)aFormat, ...
{
    va_list argList;
    va_start(argList, aFormat);
    NSString * const reason = [[NSString alloc] initWithFormat:aFormat arguments:argList];
    va_end(argList);

    return [self exceptionWithName:aName reason:reason userInfo:nil];
}

- (id)initWithName:(NSString *)aName
            reason:(NSString *)aReason
          userInfo:(NSDictionary *)aUserInfo
{
    if((self = [super init])) {
        _name   = [aName copy];
        _reason = [aReason copy];
        _userInfo = [aUserInfo copy];
    }
    return self;
}


- (NSString *)name
{
    return _name;
}
- (NSString *)reason
{
    return _reason;
}
- (NSDictionary *)userInfo
{
    return _userInfo;
}

- (void)raise
{
    @throw self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p - Name: %@ Reason: %@>", NSStringFromClass([self class]), self, _name, _reason];
}

@end
