typedef unsigned short unichar;

#import <limits.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <CoreFoundation/CFString.h>
#import <stdarg.h>

@class NSData, NSArray, NSDictionary, NSCharacterSet, NSURL, NSError;

#define NSMaximumStringLength (INT_MAX-1)

enum {
    NSASCIIStringEncoding = kCFStringEncodingASCII,
    NSUTF8StringEncoding = kCFStringEncodingUTF8,
    NSISOLatin1StringEncoding = kCFStringEncodingISOLatin1,
    NSShiftJISStringEncoding = kCFStringEncodingDOSJapanese,
    NSUnicodeStringEncoding = kCFStringEncodingUTF16,
    NSWindowsCP1252StringEncoding = kCFStringEncodingWindowsLatin1,
    NSMacOSRomanStringEncoding = kCFStringEncodingMacRoman,

    NSUTF16StringEncoding = kCFStringEncodingUTF16,
    NSUTF16BigEndianStringEncoding = kCFStringEncodingUTF16BE,
    NSUTF16LittleEndianStringEncoding = kCFStringEncodingUTF16LE,

    NSUTF32StringEncoding = kCFStringEncodingUTF32,
    NSUTF32BigEndianStringEncoding = kCFStringEncodingUTF32BE,
    NSUTF32LittleEndianStringEncoding = kCFStringEncodingUTF32LE
};
typedef NSUInteger NSStringEncoding;

typedef NS_OPTIONS(NSUInteger, NSStringEncodingConversionOptions) {
    NSStringEncodingConversionAllowLossy = 1,
    NSStringEncodingConversionExternalRepresentation = 2
};

@interface NSString : NSObject <NSCopying, NSMutableCopying>

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;

@end

@interface NSString (NSStringExtensionMethods)

+ (id)string;
+ (id)stringWithString:(NSString *)string;
+ (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
+ (id)stringWithUTF8String:(const char *)nullTerminatedCString;
+ (id)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;

- (id)init;
- (id)initWithCFString:(CFStringRef const)aCFStr;
- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (id)initWithUTF8String:(const char *)nullTerminatedCString;
- (id)initWithString:(NSString *)aString;
- (id)initWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (id)initWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange;

- (NSString *)substringFromIndex:(NSUInteger)from;
- (NSString *)substringToIndex:(NSUInteger)to;
- (NSString *)substringWithRange:(NSRange)range;

- (NSComparisonResult)compare:(NSString *)string;
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string;

- (BOOL)isEqualToString:(NSString *)aString;

- (BOOL)hasPrefix:(NSString *)aString;
- (BOOL)hasSuffix:(NSString *)aString;

- (NSRange)rangeOfString:(NSString *)aString;
- (NSString *)stringByAppendingString:(NSString *)aString;
//- (NSString *)stringByAppendingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (double)doubleValue;
- (float)floatValue;
- (int)intValue;
- (BOOL)boolValue;

- (NSArray *)componentsSeparatedByString:(NSString *)separator;
- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator;

- (NSString *)uppercaseString;
- (NSString *)lowercaseString;
- (NSString *)capitalizedString;

- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set;

- (NSString *)description;

- (NSUInteger)hash;

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;   // External representation
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding;                                    // External representation


- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement;

- (const char *)UTF8String NS_RETURNS_INNER_POINTER;

@end


@interface NSMutableString : NSString
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString;
- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)appendString:(NSString *)aString;
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)setString:(NSString *)aString;

- (id)initWithCapacity:(NSUInteger)capacity;
+ (id)stringWithCapacity:(NSUInteger)capacity;

//- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

@end

@interface NSConstantString : NSString
@end


