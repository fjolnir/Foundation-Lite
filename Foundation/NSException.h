#import <Foundation/NSObject.h>

@class NSString, NSDictionary;

@interface NSException : NSObject

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
