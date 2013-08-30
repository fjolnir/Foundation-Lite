#import <Foundation/NSObject.h>
#import <CoreFoundation/CFDate.h>

@class NSString;

typedef double NSTimeInterval;

#define NSTimeIntervalSince1970  978307200.0

@interface NSDate : NSObject <NSCopying>

+ (id)date;

+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)aSeconds;
+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)aSeconds;
+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)aSeconds;
+ (id)dateWithTimeInterval:(NSTimeInterval)aInterval sinceDate:(NSDate *)aDate;

+ (id)distantFuture;
+ (id)distantPast;

- (id)init;
- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)aSeconds;
- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)aSecondsToAdd;
- (id)initWithTimeIntervalSince1970:(NSTimeInterval)aInterval;
- (id)initWithTimeInterval:(NSTimeInterval)aSsecsToBeAdded sinceDate:(NSDate *)aDate;


- (CFDateRef)CFDate;

- (NSTimeInterval)timeIntervalSinceReferenceDate;

- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)aDate;
- (NSTimeInterval)timeIntervalSinceNow;
- (NSTimeInterval)timeIntervalSince1970;

- (id)dateByAddingTimeInterval:(NSTimeInterval)aInterval;

- (NSDate *)earlierDate:(NSDate *)aDate;
- (NSDate *)laterDate:(NSDate *)aDate;
- (NSComparisonResult)compare:(NSDate *)aDate;
- (BOOL)isEqualToDate:(NSDate *)aDate;

+ (NSTimeInterval)timeIntervalSinceReferenceDate;

@end


