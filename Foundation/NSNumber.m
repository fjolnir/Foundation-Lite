#import "NSNumber.h"
#import "NSString.h"

typedef enum {
    kNSIntegerNumberType,
    kNSUIntegerNumberType,
    kNSDoubleNumberType
} NSNumberType;

@interface NSNumber () {
    NSNumberType _type;
    union {
        long long integer;
        unsigned long long unsignedInteger;
        double dbl;
    } _value;
}
@end

@implementation NSNumber

+ (NSNumber *)numberWithChar:(char)value
{
    return [[self alloc] initWithChar:value];
}
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value
{
    return [[self alloc] initWithUnsignedChar:value];
}
+ (NSNumber *)numberWithShort:(short)value
{
    return [[self alloc] initWithShort:value];
}
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value
{
    return [[self alloc] initWithUnsignedShort:value];
}
+ (NSNumber *)numberWithInt:(int)value
{
    return [[self alloc] initWithInt:value];
}
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value
{
    return [[self alloc] initWithUnsignedInt:value];
}
+ (NSNumber *)numberWithLong:(long)value
{
    return [[self alloc] initWithLong:value];
}
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value
{
    return [[self alloc] initWithUnsignedLong:value];
}
+ (NSNumber *)numberWithLongLong:(long long)value
{
    return [[self alloc] initWithLongLong:value];
}
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value
{
    return [[self alloc] initWithUnsignedLongLong:value];
}
+ (NSNumber *)numberWithFloat:(float)value
{
    return [[self alloc] initWithFloat:value];
}
+ (NSNumber *)numberWithDouble:(double)value
{
    return [[self alloc] initWithDouble:value];
}
+ (NSNumber *)numberWithBool:(BOOL)value
{
    return [[self alloc] initWithBool:value];
}
+ (NSNumber *)numberWithInteger:(NSInteger)value
{
    return [[self alloc] initWithInteger:value];
}
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{
    return [[self alloc] initWithUnsignedInteger:value];
}

- (id)initWithChar:(char)value
{
    return [self initWithLongLong:value];
}
- (id)initWithUnsignedChar:(unsigned char)value
{
    return [self initWithUnsignedLongLong:value];
}
- (id)initWithShort:(short)value
{
    return [self initWithLongLong:value];
}
- (id)initWithUnsignedShort:(unsigned short)value
{
    return [self initWithUnsignedLongLong:value];
}
- (id)initWithInt:(int)value
{
    return [self initWithLongLong:value];
}
- (id)initWithUnsignedInt:(unsigned int)value
{
    return [self initWithUnsignedLongLong:value];
}
- (id)initWithLong:(long)value
{
    return [self initWithLongLong:value];
}
- (id)initWithUnsignedLong:(unsigned long)value
{
    return [self initWithUnsignedLongLong:value];
}
- (id)initWithLongLong:(long long)value
{
    if((self = [super init])) {
        _type = kNSIntegerNumberType;
        _value.integer = value;
    }
    return self;
}
- (id)initWithUnsignedLongLong:(unsigned long long)value
{
    if((self = [super init])) {
        _type = kNSUIntegerNumberType;
        _value.unsignedInteger = value;
    }
    return self;
}
- (id)initWithFloat:(float)value
{
    return [self initWithDouble:value];
}
- (id)initWithDouble:(double)value
{
    if((self = [super init])) {
        _type = kNSDoubleNumberType;
        _value.dbl = value;
    }
    return self;
}
- (id)initWithBool:(BOOL)value
{
    return [self initWithLongLong:value];
}
- (id)initWithInteger:(NSInteger)value
{
    return [self initWithLongLong:value];
}
- (id)initWithUnsignedInteger:(NSUInteger)value
{
    return [self initWithUnsignedLongLong:value];
}

#define Accessor(type, name)               \
    - (type) name##Value                   \
    {                                      \
        switch(_type) {                    \
        case kNSIntegerNumberType:         \
            return _value.integer;         \
        case kNSUIntegerNumberType:        \
            return _value.unsignedInteger; \
        case kNSDoubleNumberType:          \
            return _value.dbl;             \
        }                                  \
    }

Accessor(char, char)
Accessor(unsigned char, unsignedChar)
Accessor(short, short)
Accessor(unsigned short, unsignedShort)
Accessor(int, int)
Accessor(unsigned int, unsignedInt)
Accessor(long, long)
Accessor(unsigned long, unsignedLong)
Accessor(long long, longLong)
Accessor(unsigned long long, unsignedLongLong)
Accessor(float, float)
Accessor(double, double)
Accessor(NSInteger, integer)
Accessor(NSUInteger, unsignedInteger)

- (BOOL)boolValue
{
    switch(_type) {
    case kNSIntegerNumberType:
        return _value.integer != 0;
    case kNSUIntegerNumberType:
        return _value.unsignedInteger != 0;
    case kNSDoubleNumberType:
        return  _value.dbl != 0.0;
    }
}

- (NSString *)stringValue
{
    switch(_type) {
    case kNSIntegerNumberType:
        return [NSString stringWithFormat:@"%lld", _value.integer];
    case kNSUIntegerNumberType:
        return [NSString stringWithFormat:@"%llu", _value.unsignedInteger];
    case kNSDoubleNumberType:
        return [NSString stringWithFormat:@"%lf", _value.dbl];
    }
}

- (NSString *)description
{
    return [self stringValue];
}

#define Compare(a, b) do {          \
    __typeof(a) __a = a;            \
    __typeof(b) __b = b;            \
    BOOL __a_isNAN = isnan(__a);    \
    BOOL __b_isNAN = isnan(__b);    \
    if(__a_isNAN && __b_isNAN)      \
        return NSOrderedSame;       \
    else if(__a_isNAN)              \
        return NSOrderedAscending;  \
    else if(__b_isNAN)              \
        return NSOrderedDescending; \
    else if(__a > __b)              \
        return NSOrderedDescending; \
    else if(__a < __b)              \
        return NSOrderedAscending;  \
    else                            \
        return NSOrderedSame;       \
} while(0)

- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
    NSNumberType const otherType = otherNumber->_type;
    double const dblAccuracyLimit = 1LL << DBL_MANT_DIG;

    if(_type == kNSIntegerNumberType) {
        if(otherType == kNSIntegerNumberType)
            Compare([self longLongValue], [otherNumber longLongValue]);
        else if(otherType == kNSUIntegerNumberType) {
            if([self longLongValue] < 0)
                return NSOrderedAscending;
            else
                Compare([self unsignedLongLongValue], [otherNumber unsignedLongLongValue]);
        } else {
            double const other = [otherNumber doubleValue];
            if(other >= (double)(LLONG_MAX + 1ULL))
                return NSOrderedAscending;
            else if(other < LLONG_MIN)
                return NSOrderedDescending;
            else if(other >= dblAccuracyLimit || other <= -dblAccuracyLimit)
                Compare([self longLongValue], (long long)other);
            else
                Compare([self doubleValue], other);
        }
    } else if(_type == kNSUIntegerNumberType) {
        if(otherType == kNSUIntegerNumberType)
            Compare([self unsignedLongLongValue], [otherNumber unsignedLongLongValue]);
        else {
            double const other = [otherNumber doubleValue];
            if(other < 0)
                return NSOrderedDescending;
            else if(other >= (double)(LLONG_MAX + 1ULL))
                return NSOrderedAscending;
            else if(other >= dblAccuracyLimit)
                Compare([self unsignedLongLongValue], (unsigned long)other);
            else
                Compare([self doubleValue], other);
        }

    } else
        Compare([self doubleValue], [otherNumber doubleValue]);
}

- (BOOL)isEqualToNumber:(NSNumber * const)aNumber
{
    return [self compare:aNumber] == NSOrderedSame;
}

- (BOOL)isEqual:(id const)aObj
{
    if([aObj isKindOfClass:[NSNumber class]])
        return [self isEqualToNumber:aObj];
    else
        return NO;
}

- (NSUInteger)hash
{
    switch(_type) {
    case kNSIntegerNumberType:
    case kNSUIntegerNumberType:
        return [self unsignedIntegerValue];
    case kNSDoubleNumberType:
        if(_value.dbl == floor(_value.dbl))
            return [self unsignedIntegerValue];
        else if(isnan(_value.dbl) || _value.dbl == 0.0)
            return 0;
        else
            return _value.unsignedInteger;
    }
}

- (id)copy
{
    switch(_type) {
    case kNSIntegerNumberType:
        return [[self class] numberWithLongLong:_value.integer];
    case kNSUIntegerNumberType:
        return [[self class] numberWithUnsignedLongLong:_value.unsignedInteger];
    case kNSDoubleNumberType:
        return [[self class] numberWithDouble:_value.dbl];
    }
}

@end
