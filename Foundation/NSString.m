#import "NSString.h"
#import <CoreFoundation/CFString.h>
#import <dispatch/dispatch.h>

CF_EXPORT void _CFStringAppendFormatAndArgumentsAux(CFMutableStringRef outputString, CFStringRef (*copyDescFunc)(void *, const void *loc), CFDictionaryRef formatOptions, CFStringRef formatString, va_list args);
CF_EXPORT CFStringRef  _CFStringCreateWithFormatAndArgumentsAux(CFAllocatorRef alloc, CFStringRef (*copyDescFunc)(void *, const void *loc), CFDictionaryRef formatOptions, CFStringRef format, va_list arguments);


@interface NSString ()
+ (id)_realAlloc;
- (CFStringRef)CFString;
@end


@interface NSCFString : NSString {
    CFStringRef _cfStr;
    char *_cStringCache;
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


static CFStringRef _copyObjectDescription(void * const aObj, const void *loc)
{
    return CFStringCreateCopy(NULL, [[(id)aObj description] CFString]);
}

@implementation NSCFString

+ (id)alloc
{
    return [super _realAlloc];
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


- (id)initWithCFString:(CFStringRef const)aCFStr
{
    if((self = [super init]))
        _cfStr = CFRetain(aCFStr);
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
- (id)initWithString:(NSString *)aString
{
    return [aString copy];
}
- (id)initWithFormat:(NSString * const)aFormat, ...
{
    va_list argList;
    va_start(argList, aFormat);
    NSCFString * const string = [self initWithFormat:aFormat arguments:argList];
    va_end(argList);
    return string;
}
- (id)initWithFormat:(NSString *)aFormat arguments:(va_list)aArgList
{
    CFStringRef cfStr = _CFStringCreateWithFormatAndArgumentsAux(NULL, &_copyObjectDescription, NULL, [aFormat CFString], aArgList);
    self = [self initWithCFString:cfStr];

    CFRelease(cfStr);
    return self;
}
//- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
//{
//    return [self initWithCFString:CFStringCreateWith];
//}
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
    CFRelease(_cfStr), _cfStr = NULL;
    free(_cStringCache), _cStringCache = NULL;

    [super dealloc];
}

- (id)copy
{
    return [self retain];
}

- (CFStringRef)CFString
{
    return _cfStr;
}

- (NSString *)description
{
    return self;
}

- (const char *)UTF8String
{
    if(_cStringCache)
        return _cStringCache;

    char *utfString = (char *)CFStringGetCStringPtr(_cfStr, kCFStringEncodingUTF8);
    if(!utfString) {
        CFIndex const bufLen = CFStringGetMaximumSizeForEncoding([self length], kCFStringEncodingUTF8);
        _cStringCache = malloc(bufLen);
        CFStringGetCString(_cfStr, _cStringCache, bufLen, kCFStringEncodingUTF8);
        return _cStringCache;
    }
    return utfString;
}

- (NSUInteger)length
{
    return CFStringGetLength(_cfStr);
}

- (unichar)characterAtIndex:(NSUInteger const)aIdx
{
    return CFStringGetCharacterAtIndex(_cfStr, aIdx);
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
    CFStringRef substring = CFStringCreateWithSubstring(NULL, _cfStr, *(CFRange *)&aRange);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:substring] autorelease];
    CFRelease(substring);
    return result;
}


- (NSComparisonResult)compare:(NSString *)aString
{
    return (NSComparisonResult)CFStringCompare(_cfStr, [aString CFString], 0);
}
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)aString
{
    return (NSComparisonResult)CFStringCompare(_cfStr, [aString CFString], kCFCompareCaseInsensitive);
}
- (BOOL)isEqualToString:(NSString *)aString
{
    return [self compare:aString] == NSOrderedSame;
}
- (BOOL)isEqual:(id)aObj
{
    return [aObj isKindOfClass:[NSString class]] && [self isEqualToString:aObj];
}


- (NSRange)rangeOfString:(NSString *)aString
{
    CFRange const range = CFStringFind(_cfStr, [aString CFString], 0);
    return *(NSRange *)&range;
}
- (NSString *)stringByAppendingString:(NSString *)aString
{
    CFArrayRef strings = CFArrayCreate(NULL, (CFTypeRef[]) {
        _cfStr, [aString CFString]
    }, 2, &kCFTypeArrayCallBacks);
    CFStringRef concatenated = CFStringCreateByCombiningStrings(NULL, strings, CFSTR(""));
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:concatenated] autorelease];
    CFRelease(concatenated);
    CFRelease(strings);

    return result;
}

- (double)doubleValue
{
    return CFStringGetDoubleValue(_cfStr);
}
- (float)floatValue
{
    return [self doubleValue];
}
- (int)intValue
{
    return CFStringGetIntValue(_cfStr);
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
    CFMutableStringRef uppercase = CFStringCreateMutableCopy(NULL, 0, _cfStr);
    CFStringUppercase(uppercase, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:uppercase] autorelease];
    CFRelease(uppercase);

    return result;
}
- (NSString *)lowercaseString
{
    CFMutableStringRef lowercase = CFStringCreateMutableCopy(NULL, 0, _cfStr);
    CFStringLowercase(lowercase, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:lowercase] autorelease];
    CFRelease(lowercase);

    return result;
}
- (NSString *)capitalizedString
{
    CFMutableStringRef capitalized = CFStringCreateMutableCopy(NULL, 0, _cfStr);
    CFStringCapitalize(capitalized, NULL);
    NSCFString *result =  [[[NSCFString alloc] initWithCFString:capitalized] autorelease];
    CFRelease(capitalized);

    return result;
}

- (NSUInteger)hash
{
    return CFHash(_cfStr);
}

@end

@implementation NSString

+ (id)_realAlloc
{
    return [super alloc];
}

+ (id)alloc
{
    return [NSCFString alloc];
}

+ (id)stringWithString:(NSString * const)aString;
{
    return [NSCFString stringWithString:aString];
}
+ (id)stringWithCharacters:(const unichar * const)aCharacters length:(NSUInteger const)aLength;
{
    return [NSCFString stringWithCharacters:aCharacters length:aLength];
}
+ (id)stringWithUTF8String:(const char *)aBuf
{
    return [NSCFString stringWithUTF8String:aBuf];
}
+ (id)stringWithFormat:(NSString * const)aFormat, ...;
{
    va_list argList;
    va_start(argList, aFormat);
    NSCFString * const string = [[NSCFString alloc] initWithFormat:aFormat arguments:argList];
    va_end(argList);
    return string;
}
+ (id)stringWithCString:(const char * const)aBuf encoding:(NSStringEncoding const)aEncoding;
{
    return [NSCFString stringWithCString:aBuf encoding:aEncoding];
}

- (CFStringRef)CFString
{
    assert(0); // Abstract
    return NULL;
}

- (NSUInteger)length
{
    assert(0); // Abstract
    return 0;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    assert(0); // Abstract
    return 0;
}

- (id)copy
{
    assert(0); // Abstract
    return nil;
}

- (id)mutableCopy
{
    assert(0); // Abstract
    return nil;
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
    return [[self _heapCopy] description];
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
