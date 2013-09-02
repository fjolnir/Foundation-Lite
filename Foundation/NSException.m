#import "NSException.h"
#import "NSString.h"
#import "NSDictionary.h"
#import <objc/hooks.h>

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
