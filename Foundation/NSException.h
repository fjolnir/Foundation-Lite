#import <Foundation/NSObject.h>

#define NSAssert(cond, desc, ...) do { \
    if(!(cond)) { \
        NSLog(@" *** Assertion failure in %s, %s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__); \
        [NSException exceptionWithName:NSInternalInconsistencyException \
                                format:desc, #__VA_ARGS__]; \
    } \
} while(0)

#define NSCAssert(cond, desc, ...) do { \
    if(!(cond)) { \
        NSLog(@" *** Assertion failure in %s, %s:%d", __PRETTY_FUNCTION__, __FILE__, __LINE__); \
        [NSException exceptionWithName:NSInternalInconsistencyException \
                                format:desc, #__VA_ARGS__]; \
    } \
} while(0)

#define NSParameterAssert(cond) do { \
    if(!(cond)) \
        [NSException exceptionWithName:NSInternalInconsistencyException \
                                format:@"Invalid parameter not satisfying: %s", #cond]; \
} while(0)



@class NSString, NSDictionary;

FOUNDATION_EXPORT NSString *NSGenericException;
FOUNDATION_EXPORT NSString *NSRangeException;
FOUNDATION_EXPORT NSString *NSInvalidArgumentException;
FOUNDATION_EXPORT NSString *NSInternalInconsistencyException;
FOUNDATION_EXPORT NSString *NSMallocException;
FOUNDATION_EXPORT NSString *NSObjectInaccessibleException;
FOUNDATION_EXPORT NSString *NSObjectNotAvailableException;
FOUNDATION_EXPORT NSString *NSDestinationInvalidException;
FOUNDATION_EXPORT NSString *NSPortTimeoutException;
FOUNDATION_EXPORT NSString *NSInvalidSendPortException;
FOUNDATION_EXPORT NSString *NSInvalidReceivePortException;
FOUNDATION_EXPORT NSString *NSPortSendException;
FOUNDATION_EXPORT NSString *NSPortReceiveException;

@interface NSException : NSObject

+ (void)raise:(NSString *)name format:(NSString *)format, ...;
+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)argList;

+ (NSException *)exceptionWithName:(NSString *)aName
                            reason:(NSString *)aReason
                          userInfo:(NSDictionary *)aUserInfo;

+ (NSException *)exceptionWithName:(NSString *)aName
                            format:(NSString *)aFormat, ...;

- (id)initWithName:(NSString *)aName
            reason:(NSString *)aReason
          userInfo:(NSDictionary *)aUserInfo;


- (NSString *)name;
- (NSString *)reason;
- (NSDictionary *)userInfo;

- (void)raise;
@end
