#import "NSString.h"
#import "NSData.h"
#import <CoreFoundation/CFString.h>
#import <dispatch/dispatch.h>

CF_EXPORT void _CFStringAppendFormatAndArgumentsAux(CFMutableStringRef outputString, CFStringRef (*copyDescFunc)(void *, const void *loc), CFDictionaryRef formatOptions, CFStringRef formatString, va_list args);
CF_EXPORT CFStringRef  _CFStringCreateWithFormatAndArgumentsAux(CFAllocatorRef alloc, CFStringRef (*copyDescFunc)(void *, const void *loc), CFDictionaryRef formatOptions, CFStringRef format, va_list arguments);


@interface NSString ()
+ (id)_alloc;
@end


@interface NSCFString : NSString {
@protected
    CFStringRef _cfString;
}
@end

@interface NSMutableString () {
@protected
    CFMutableStringRef _cfString;
}
@end

@interface NSConstantString () {
@package
    char *_bytes;
    int32_t _byteLen;
//    dispatch_once_t _realStrCreationToken;
//    NSCFString *_realStr;
#if __LP64__
    int _unused;
#endif
}
@end


static CFStringRef _NSStringCopyObjectDescription(void * const aObj, const void *loc)
{
    return CFStringCreateCopy(NULL, [[(id)aObj description] CFString]);
}

@implementation NSCFString

+ (id)alloc
{
    return [super _alloc];
}

- (id)initWithCFString:(CFStringRef const)aCFStr
{
    if((self = [super init]))
        _cfString = CFRetain(aCFStr);
    return self;
}

- (id)init
{
    return [self initWithCFString:CFSTR("")];
}

- (id)initWithCharacters:(const unichar *)aChars length:(NSUInteger)aLen
{
    CFStringRef cfStr = CFStringCreateWithCharacters(NULL, aChars, aLen);
    self = [self initWithCFString:cfStr];
    CFRelease(cfStr);
    return self;
}
- (id)initWithUTF8String:(const char *)aBuf
{
    CFStringRef cfStr = CFStringCreateWithCString(NULL, aBuf, kCFStringEncodingUTF8);
    self = [self initWithCFString:cfStr];
    CFRelease(cfStr);

    return self;
}

//- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
//{
//    return [self initWithCFString:CFStringCreateWith];
//}


- (id)initWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLen encoding:(NSStringEncoding)aEncoding freeWhenDone:(BOOL)aFree
{
    CFStringRef cfStr = CFStringCreateWithBytesNoCopy(NULL, aBytes, aLen, aEncoding, YES, aFree ? kCFAllocatorDefault : kCFAllocatorNull);
    self = [self initWithCFString:cfStr];
    CFRelease(cfStr);
    return self;
}

- (id)initWithBytes:(const void * const)aBytes length:(NSUInteger const)aLen encoding:(NSStringEncoding const)aEncoding
{
    CFStringRef cfStr = CFStringCreateWithBytes(NULL, aBytes, aLen, aEncoding, YES);
    self = [self initWithCFString:cfStr];
    CFRelease(cfStr);
    return self;
}
- (id)initWithCString:(const char * const)aBuf encoding:(NSStringEncoding const)aEncoding
{
    CFStringRef cfStr = CFStringCreateWithCString(NULL, aBuf, aEncoding);
    self = [self initWithCFString:cfStr];
    CFRelease(cfStr);
    return self;
}

- (void)dealloc
{
    CFRelease(_cfString), _cfString = NULL;

    [super dealloc];
}

- (id)copy
{
    return [self retain];
}

- (CFStringRef)CFString
{
    return _cfString;
}

@end

@implementation NSString

+ (id)_alloc
{
    return [super alloc];
}

+ (id)alloc
{
    return [NSCFString alloc];
}

+ (id)string
{
    return [[[self alloc] init] autorelease];
}

+ (id)stringWithString:(NSString * const)aString;
{
    return [[[self alloc] initWithString:aString] autorelease];
}
+ (id)stringWithCharacters:(const unichar * const)aCharacters length:(NSUInteger const)aLength;
{
    return [[[self alloc] initWithCharacters:aCharacters length:aLength] autorelease];
}
+ (id)stringWithUTF8String:(const char *)aBuf
{
    return [[[self alloc] initWithUTF8String:aBuf] autorelease];
}
+ (id)stringWithFormat:(NSString * const)aFormat, ...;
{
    va_list argList;
    va_start(argList, aFormat);
    NSCFString * const string = [[[self alloc] initWithFormat:aFormat arguments:argList] autorelease];
    va_end(argList);
    return string;
}

+ (id)stringWithCString:(const char * const)aBuf encoding:(NSStringEncoding const)aEncoding;
{
    return [[[self alloc] initWithCString:aBuf encoding:aEncoding] autorelease];
}

- (id)initWithString:(NSString *)aString
{
    return [self initWithCFString:[aString CFString]];
}
- (id)initWithFormat:(NSString * const)aFormat, ...
{
    va_list argList;
    va_start(argList, aFormat);
    self = [self initWithFormat:aFormat arguments:argList];
    va_end(argList);
    return self;
}
- (id)initWithFormat:(NSString *)aFormat arguments:(va_list)aArgList
{
    CFStringRef cfStr = _CFStringCreateWithFormatAndArgumentsAux(NULL, &_NSStringCopyObjectDescription, NULL, [aFormat CFString], aArgList);
    self = [self initWithCFString:cfStr];

    CFRelease(cfStr);
    return self;
}
- (id)initWithData:(NSData *)aData encoding:(NSStringEncoding)aEncoding
{
    return [self initWithBytes:[aData bytes] length:[aData length] encoding:aEncoding];
}


- (NSString *)description
{
    return self;
}

- (const char *)UTF8String
{
    char *utfString = (char *)CFStringGetCStringPtr([self CFString], kCFStringEncodingUTF8);
    if(!utfString) {
        CFIndex const bufLen = CFStringGetMaximumSizeForEncoding([self length], kCFStringEncodingUTF8);
        char *buf = malloc(bufLen);
        CFStringGetCString([self CFString], buf, bufLen, kCFStringEncodingUTF8);
        return [[NSData dataWithBytesNoCopy:buf length:bufLen freeWhenDone:YES] bytes];
    }
    return utfString;
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)aEncoding
{
    if(aEncoding == NSUTF8StringEncoding)
        return [self UTF8String];
    else {
        CFIndex bufLen = CFStringGetMaximumSizeForEncoding([self length], aEncoding);
        uint8_t *buf = malloc(bufLen+1);
        CFStringGetBytes([self CFString], (CFRange){0, [self length]}, aEncoding, '?', false, buf, bufLen, &bufLen);
        buf[bufLen] = '\0';
        return [[NSData dataWithBytesNoCopy:buf length:bufLen+1 freeWhenDone:YES] bytes];
    }
}


- (NSData *)dataUsingEncoding:(NSStringEncoding)aEncoding allowLossyConversion:(BOOL)aLossy
{
    CFIndex bufLen = CFStringGetMaximumSizeForEncoding([self length], aEncoding);
    uint8_t *buf = malloc(bufLen);
    CFStringGetBytes([self CFString], (CFRange){0, [self length]}, aEncoding,
                     aLossy ? '?' : 0, false, buf, bufLen, &bufLen);
    return [NSData dataWithBytesNoCopy:buf length:bufLen freeWhenDone:YES];
}
- (NSData *)dataUsingEncoding:(NSStringEncoding)aEncoding
{
    return [self dataUsingEncoding:aEncoding allowLossyConversion:NO];
}

- (NSUInteger)length
{
    return CFStringGetLength([self CFString]);
}

- (unichar)characterAtIndex:(NSUInteger const)aIdx
{
    return CFStringGetCharacterAtIndex([self CFString], aIdx);
}

- (NSString *)substringFromIndex:(NSUInteger const)aFrom
{
    return [self substringWithRange:(NSRange) { aFrom, [self length] - aFrom }];
}
- (NSString *)substringToIndex:(NSUInteger const)aTo;
{
    return [self substringWithRange:(NSRange) { 0, aTo }];
}
- (NSString *)substringWithRange:(NSRange const)aRange;
{
    CFStringRef substring = CFStringCreateWithSubstring(NULL, [self CFString], *(CFRange *)&aRange);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:substring] autorelease];
    CFRelease(substring);
    return result;
}


- (NSComparisonResult)compare:(NSString *)aString
{
    return (NSComparisonResult)CFStringCompare([self CFString], [aString CFString], 0);
}
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)aString
{
    return (NSComparisonResult)CFStringCompare([self CFString], [aString CFString], kCFCompareCaseInsensitive);
}
- (BOOL)isEqualToString:(NSString *)aString
{
    return CFEqual([self CFString], [aString CFString]);
}
- (BOOL)isEqual:(id)aObj
{
    return [aObj isKindOfClass:[NSString class]] && [self isEqualToString:aObj];
}


- (NSRange)rangeOfString:(NSString *)aString
{
    CFRange const range = CFStringFind([self CFString], [aString CFString], 0);
    return *(NSRange *)&range;
}
- (BOOL)hasPrefix:(NSString *)aPrefix
{
    return CFStringHasPrefix([self CFString], [aPrefix CFString]);
}
- (BOOL)hasSuffix:(NSString *)aSuffix
{
    return CFStringHasSuffix([self CFString], [aSuffix CFString]);
}
- (NSString *)stringByAppendingString:(NSString *)aString
{
    CFArrayRef strings = CFArrayCreate(NULL, (CFTypeRef[]) {
        [self CFString], [aString CFString]
    }, 2, &kCFTypeArrayCallBacks);
    CFStringRef concatenated = CFStringCreateByCombiningStrings(NULL, strings, CFSTR(""));
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:concatenated] autorelease];
    CFRelease(concatenated);
    CFRelease(strings);

    return result;
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)aNeedle withString:(NSString *)aReplacement
{
    CFMutableStringRef temp = CFStringCreateMutableCopy(NULL, 0, [self CFString]);
    CFStringFindAndReplace(temp, [aNeedle CFString], [aReplacement CFString], (CFRange){0,[self length]}, 0);
    NSString *result = [[[self class] alloc] initWithCFString:temp];

    CFRelease(temp);
    return [result autorelease];
}

- (double)doubleValue
{
    return CFStringGetDoubleValue([self CFString]);
}
- (float)floatValue
{
    return [self doubleValue];
}
- (int)intValue
{
    return CFStringGetIntValue([self CFString]);
}
- (BOOL)boolValue
{
    if([self isEqualToString:@"YES"] || [self isEqualToString:@"true"])
        return YES;
    else
        return [self intValue] != 0;
}


- (NSString *)uppercaseString
{
    CFMutableStringRef uppercase = CFStringCreateMutableCopy(NULL, 0, [self CFString]);
    CFStringUppercase(uppercase, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:uppercase] autorelease];
    CFRelease(uppercase);

    return result;
}
- (NSString *)lowercaseString
{
    CFMutableStringRef lowercase = CFStringCreateMutableCopy(NULL, 0, [self CFString]);
    CFStringLowercase(lowercase, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:lowercase] autorelease];
    CFRelease(lowercase);

    return result;
}
- (NSString *)capitalizedString
{
    CFMutableStringRef capitalized = CFStringCreateMutableCopy(NULL, 0, [self CFString]);
    CFStringCapitalize(capitalized, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:capitalized] autorelease];
    CFRelease(capitalized);

    return result;
}

- (NSUInteger)hash
{
    return CFHash([self CFString]);
}

- (CFStringRef)CFString
{
    return NULL;
}

- (id)copy
{
    return [[NSCFString alloc] initWithString:self];
}
- (id)mutableCopy
{
    return [[NSMutableString alloc] initWithString:self];
}
@end

@implementation NSMutableString

#define MakeCFStringMutable() do { \
    CFStringRef oldStr = _cfString; \
    _cfString = CFStringCreateMutableCopy(NULL, [self length], _cfString); \
    CFRelease(oldStr); \
} while(0)

+ (id)alloc
{
    return [self _alloc];
}

+ (id)stringWithCapacity:(NSUInteger)aCapacity
{
    return [[[self alloc] initWithCapacity:aCapacity] autorelease];
}

- (id)init
{
    return [self initWithCapacity:0];
}
- (id)initWithCFString:(CFStringRef const)aCFStr
{
    if((self = [super init]))
        _cfString = CFStringCreateMutableCopy(NULL, 0, aCFStr);
    return self;
}
- (id)initWithCapacity:(NSUInteger)aCapacity
{
    if((self = [super init]))
        _cfString = CFStringCreateMutable(NULL, aCapacity);
    return self;
}
- (id)initWithCharacters:(const unichar *)aChars length:(NSUInteger)aLen
{
    if((self = [super initWithCharacters:aChars length:aLen]))
        MakeCFStringMutable();
    return self;
}
- (id)initWithUTF8String:(const char *)aBuf
{
    if((self = [super initWithUTF8String:aBuf]))
        MakeCFStringMutable();
    return self;
}
- (id)initWithString:(NSString *)aString
{
    if((self = [super init])) {
        _cfString = (CFMutableStringRef)CFRetain([aString CFString]);
        MakeCFStringMutable();
    }
    return self;
}
- (id)initWithFormat:(NSString * const)aFormat, ...
{
    va_list argList;
    va_start(argList, aFormat);
    self = [self initWithFormat:aFormat arguments:argList];
    va_end(argList);
    return self;
}
- (id)initWithFormat:(NSString *)aFormat arguments:(va_list)aArgList
{
    if((self = [super initWithFormat:aFormat arguments:aArgList]))
        MakeCFStringMutable();
    return self;
}
//- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
//{
//    return [self initWithCFString:CFStringCreateWith];
//}
- (id)initWithBytes:(const void * const)aBytes length:(NSUInteger const)aLen encoding:(NSStringEncoding const)aEncoding
{
    if((self = [super initWithBytes:aBytes length:aLen encoding:aEncoding]))
        MakeCFStringMutable();
    return self;
}
- (id)initWithCString:(const char * const)aBuf encoding:(NSStringEncoding const)aEncoding
{
    if((self = [super initWithCString:aBuf encoding:aEncoding]))
        MakeCFStringMutable();
    return self;
}

- (CFStringRef)CFString
{
    return _cfString;
}


- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
{
    CFStringReplace(_cfString, *(CFRange *)&range, [aString CFString]);
}
- (void)insertString:(NSString *)aString atIndex:(NSUInteger)aLoc
{
    CFStringInsert(_cfString, aLoc, [aString CFString]);
}
- (void)deleteCharactersInRange:(NSRange)aRange
{
    CFStringDelete(_cfString, *(CFRange *)&aRange);
}
- (void)appendString:(NSString *)aString
{
    CFStringAppend(_cfString, [aString CFString]);
}
- (void)appendFormat:(NSString *)aFormat, ...
{
    va_list argList;
    va_start(argList, aFormat);
    _CFStringAppendFormatAndArgumentsAux(_cfString, &_NSStringCopyObjectDescription, NULL, [aFormat CFString], argList);
    va_end(argList);
}
- (void)setString:(NSString *)aString
{
    [self replaceCharactersInRange:(NSRange) {0, [self length]} withString:aString];
}

@end

@implementation NSConstantString


- (NSCFString *)_heapCopy
{
    return [[[NSCFString alloc] initWithBytes:_bytes
                                       length:_byteLen
                                     encoding:NSUTF8StringEncoding] autorelease];

// TODO: Create a caching mechanism so we only have to do this once
//    dispatch_once(&_realStrCreationToken, ^{
//        _realStr = [NSCFString stringWithUTF8String:_bytes];
//    });
//    return _realStr;
}

- (CFStringRef)CFString
{
    return [[self _heapCopy] CFString];
}

- (id)forwardingTargetForSelector:(SEL const)aSelector
{
    return [self _heapCopy];
}

- (NSUInteger)length
{
    return [[self _heapCopy] length];
}

- (unichar)characterAtIndex:(NSUInteger const)aIdx
{
    return [[self _heapCopy] characterAtIndex:aIdx];
}

- (const char *)UTF8String
{
    return _bytes;
}

- (NSString *)description
{
    return [self _heapCopy];
}

- (id)retain
{
    return self;
}
- (id)autorelease
{
    return self;
}
- (oneway void)release
{
    return;
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)copy
{
    return [[self _heapCopy] copy];
}

@end
