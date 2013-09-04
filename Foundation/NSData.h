#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

typedef NS_OPTIONS(NSUInteger, NSDataReadingOptions) {
    NSDataReadingMappedIfSafe =   1UL << 0,	// Hint to map the file in if possible and safe
    NSDataReadingUncached = 1UL << 1,	// Hint to get the file not to be cached in the kernel
    NSDataReadingMappedAlways = 1UL << 3,	// Hint to map the file in if possible. This takes precedence over NSDataReadingMappedIfSafe if both are given.
};

typedef NS_OPTIONS(NSUInteger, NSDataWritingOptions) {
    NSDataWritingAtomic = 1UL << 0,	// Hint to use auxiliary file when saving; equivalent to atomically:YES
    NSDataWritingWithoutOverwriting = 1UL << 1, // Hint to return prevent overwriting an existing file. Cannot be combined with NSDataWritingAtomic.

    NSDataWritingFileProtectionNone                                   = 0x10000000,
    NSDataWritingFileProtectionComplete                               = 0x20000000,
    NSDataWritingFileProtectionCompleteUnlessOpen                     = 0x30000000,
    NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication   = 0x40000000,
    NSDataWritingFileProtectionMask                                   = 0xf0000000,
};

typedef NS_OPTIONS(NSUInteger, NSDataSearchOptions) {
    NSDataSearchBackwards = 1UL << 0,
    NSDataSearchAnchored = 1UL << 1
};


@interface NSData : NSObject <NSCopying, NSMutableCopying>

+ (id)data;
+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
//+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
//+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
//+ (id)dataWithContentsOfFile:(NSString *)path;
//+ (id)dataWithContentsOfURL:(NSURL *)url;
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
//- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
//- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
//- (id)initWithContentsOfFile:(NSString *)path;
//- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
+ (id)dataWithData:(NSData *)data;

- (NSUInteger)length;
- (const void *)bytes NS_RETURNS_INNER_POINTER;

- (void)getBytes:(void *)buffer length:(NSUInteger)length;
- (void)getBytes:(void *)buffer range:(NSRange)range;
- (BOOL)isEqualToData:(NSData *)other;
- (NSData *)subdataWithRange:(NSRange)range;
//- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
//- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically; // the atomically flag is ignored if the url is not of a type the supports atomic writes
//- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
//- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
- (NSRange)rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange;

@end

@interface NSData (FoundationLiteExtensionMethods)

- (CFDataRef)CFData;

@end

@interface NSMutableData : NSData

+ (id)dataWithCapacity:(NSUInteger)aNumItems;
+ (id)dataWithLength:(NSUInteger)length;
- (id)initWithCapacity:(NSUInteger)capacity;
- (id)initWithLength:(NSUInteger)length;

- (void *)mutableBytes NS_RETURNS_INNER_POINTER;
- (void)setLength:(NSUInteger)length;

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length;
- (void)appendData:(NSData *)other;
- (void)increaseLengthBy:(NSUInteger)extraLength;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes;
- (void)resetBytesInRange:(NSRange)range;
- (void)setData:(NSData *)data;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength;

@end


