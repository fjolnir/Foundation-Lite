#import "NSDate.h"
#import "NSString.h"

@interface NSDate () {
    CFDateRef _cfDate;
}
@end

@implementation NSDate

+ (id)date
{
    return [[self alloc] init];
}

+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)aSeconds
{
    return [[self alloc] initWithTimeIntervalSinceNow:aSeconds];
}
+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)aSeconds
{
    return [[self alloc] initWithTimeIntervalSinceReferenceDate:aSeconds];
}
+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)aSeconds
{
    return [[self alloc] initWithTimeIntervalSince1970:aSeconds];
}
+ (id)dateWithTimeInterval:(NSTimeInterval)aInterval sinceDate:(NSDate *)aDate
{
    return [[self alloc] initWithTimeInterval:aInterval sinceDate:aDate];
}

+ (id)distantFuture
{
    return [self dateWithTimeIntervalSinceReferenceDate:DBL_MAX];
}
+ (id)distantPast
{
    return [self dateWithTimeIntervalSinceReferenceDate:-DBL_MAX];
}

- (id)init
{
    return [self initWithTimeIntervalSinceReferenceDate:[[self class] timeIntervalSinceReferenceDate]];
}
- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)aSeconds
{
    return [self initWithTimeIntervalSinceReferenceDate:[[self class] timeIntervalSinceReferenceDate] + aSeconds];
}
- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)aInterval
{
    if((self = [super init]))
        _cfDate = CFDateCreate(NULL, aInterval);
    return self;
}
- (id)initWithTimeIntervalSince1970:(NSTimeInterval)aInterval
{
    return [self initWithTimeIntervalSinceReferenceDate:aInterval - NSTimeIntervalSince1970];
}
- (id)initWithTimeInterval:(NSTimeInterval)aInterval sinceDate:(NSDate *)aDate
{
    return [self initWithTimeIntervalSinceReferenceDate:[aDate timeIntervalSinceReferenceDate] + aInterval];
}

+ (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return (double)time(NULL) - NSTimeIntervalSince1970;
}
- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return CFDateGetAbsoluteTime(_cfDate);
}

- (CFDateRef)CFDate
{
    return _cfDate;
}

- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)aDate
{
    return CFDateGetTimeIntervalSinceDate(_cfDate, [aDate CFDate]);
}
- (NSTimeInterval)timeIntervalSinceNow
{
    return CFDateGetAbsoluteTime(_cfDate) - [[self class] timeIntervalSinceReferenceDate];
}
- (NSTimeInterval)timeIntervalSince1970
{
    return CFDateGetAbsoluteTime(_cfDate) + NSTimeIntervalSince1970;
}

- (id)dateByAddingTimeInterval:(NSTimeInterval)aInterval
{
    return [[self class] dateWithTimeInterval:aInterval sinceDate:self];
}

- (NSDate *)earlierDate:(NSDate *)aDate
{
    return [self compare:aDate] == NSOrderedDescending ? aDate : self;
}
- (NSDate *)laterDate:(NSDate *)aDate
{
    return [self compare:aDate] == NSOrderedAscending ? aDate : self;
}
- (NSComparisonResult)compare:(NSDate *)aDate
{
    return (NSComparisonResult)CFDateCompare(_cfDate, [aDate CFDate], NULL);
}
- (BOOL)isEqualToDate:(NSDate *)aDate
{
    return CFEqual(_cfDate, [aDate CFDate]);
}

- (id)copy
{
    return self;
}

- (NSString *)description
{
    // TODO: Write NSFormatter/NSDateFormatter
    CFDateFormatterRef formatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterFullStyle, kCFDateFormatterFullStyle);
    CFStringRef formatted = CFDateFormatterCreateStringWithDate(NULL, formatter, _cfDate);
    NSString *description = [[NSString alloc] initWithCFString:formatted];
    CFRelease(formatted);
    CFRelease(formatter);
    return description;
}

@end
