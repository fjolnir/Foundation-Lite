#import <Foundation/NSObject.h>

@class NSString;

@interface NSNumber : NSObject
+ (NSNumber *)numberWithChar:(char)value;
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value;
+ (NSNumber *)numberWithShort:(short)value;
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value;
+ (NSNumber *)numberWithInt:(int)value;
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value;
+ (NSNumber *)numberWithLong:(long)value;
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value;
+ (NSNumber *)numberWithLongLong:(long long)value;
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value;
+ (NSNumber *)numberWithFloat:(float)value;
+ (NSNumber *)numberWithDouble:(double)value;
+ (NSNumber *)numberWithBool:(BOOL)value;
+ (NSNumber *)numberWithInteger:(NSInteger)value;
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;

- (id)initWithChar:(char)value;
- (id)initWithUnsignedChar:(unsigned char)value;
- (id)initWithShort:(short)value;
- (id)initWithUnsignedShort:(unsigned short)value;
- (id)initWithInt:(int)value;
- (id)initWithUnsignedInt:(unsigned int)value;
- (id)initWithLong:(long)value;
- (id)initWithUnsignedLong:(unsigned long)value;
- (id)initWithLongLong:(long long)value;
- (id)initWithUnsignedLongLong:(unsigned long long)value;
- (id)initWithFloat:(float)value;
- (id)initWithDouble:(double)value;
- (id)initWithBool:(BOOL)value;
- (id)initWithInteger:(NSInteger)value;
- (id)initWithUnsignedInteger:(NSUInteger)value;

- (char)charValue;
- (unsigned char)unsignedCharValue;
- (short)shortValue;
- (unsigned short)unsignedShortValue;
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;

- (NSString *)stringValue;

- (NSComparisonResult)compare:(NSNumber *)otherNumber;

- (BOOL)isEqualToNumber:(NSNumber *)number;
@end
