#import "NSData.h"

@interface NSData () {
@protected
    CFDataRef _cfData;
}
@end

@implementation NSData

+ (id)data
{
    return [[self alloc] init];
}

+ (id)dataWithData:(NSData *)aData
{
    return [[self alloc] initWithData:aData];
}
+ (id)dataWithBytes:(const void *)aBytes length:(NSUInteger)aLength
{
    return [[self alloc] initWithBytes:aBytes length:aLength];
}
+ (id)dataWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength
{
    return [[self alloc] initWithBytesNoCopy:aBytes length:aLength];
}
+ (id)dataWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength freeWhenDone:(BOOL)aShouldFree
{
    return [[self alloc] initWithBytesNoCopy:aBytes length:aLength freeWhenDone:aShouldFree];
}
//+ (id)dataWithContentsOfFile:(NSString *)aPath options:(NSDataReadingOptions)aReadOptionsMask error:(NSError **)aoErrorPtr
//+ (id)dataWithContentsOfURL:(NSURL *)aUrl options:(NSDataReadingOptions)aReadOptionsMask error:(NSError **)aoErrorPtr
//+ (id)dataWithContentsOfFile:(NSString *)aPath
//+ (id)dataWithContentsOfURL:(NSURL *)aUrl
- (id)initWithBytes:(const void *)aBytes length:(NSUInteger)aLength
{
    if((self = [super init]))
        _cfData = CFDataCreate(NULL, aBytes, aLength);
    return self;
}
- (id)initWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength
{
    return [self initWithBytesNoCopy:aBytes length:aLength freeWhenDone:NO];
}
- (id)initWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength freeWhenDone:(BOOL)aShouldFree
{
    if((self = [super init]))
        _cfData = CFDataCreateWithBytesNoCopy(NULL, aBytes, aLength, aShouldFree ? kCFAllocatorDefault : kCFAllocatorNull);
    return self;
}
//- (id)initWithContentsOfFile:(NSString *)aPath options:(NSDataReadingOptions)aReadOptionsMask error:(NSError **)aoErrorPtr
//- (id)initWithContentsOfURL:(NSURL *)aUrl options:(NSDataReadingOptions)aReadOptionsMask error:(NSError **)aoErrorPtr
//- (id)initWithContentsOfFile:(NSString *)aPath
//- (id)initWithContentsOfURL:(NSURL *)aUrl

- (id)initWithData:(NSData *)aData
{
    if((self = [super init]))
        _cfData = CFDataCreateCopy(NULL, [aData CFData]);
    return self;
}

- (void)dealloc
{
    CFRelease(_cfData);
}

- (CFDataRef)CFData
{
    return _cfData;
}

- (NSUInteger)length
{
    return CFDataGetLength(_cfData);
}
- (const void *)bytes
{
    return CFDataGetBytePtr(_cfData);
}

- (void)getBytes:(void *)aBuffer length:(NSUInteger)aLength
{
    [self getBytes:aBuffer range:(NSRange) {0, aLength}];
}
- (void)getBytes:(void *)aBuffer range:(NSRange)aRange
{
    CFDataGetBytes(_cfData, *(CFRange *)&aRange, aBuffer);
}
- (BOOL)isEqualToData:(NSData *)aOther
{
    return CFEqual(_cfData, [aOther CFData]);
}
- (NSData *)subdataWithRange:(NSRange)aRange
{
    void *bytes = malloc(aRange.length);
    [self getBytes:bytes range:aRange];
    return [[self class] dataWithBytesNoCopy:bytes length:aRange.length freeWhenDone:YES];
}

//- (BOOL)writeToFile:(NSString *)aPath atomically:(BOOL)aUseAuxiliaryFile
//- (BOOL)writeToURL:(NSURL *)aUrl atomically:(BOOL)aAtomically
//- (BOOL)writeToFile:(NSString *)aPath options:(NSDataWritingOptions)aWriteOptionsMask error:(NSError **)aoErrorPtr
//- (BOOL)writeToURL:(NSURL *)aUrl options:(NSDataWritingOptions)aWriteOptionsMask error:(NSError **)aoErrorPtr

- (NSRange)rangeOfData:(NSData *)aDataToFind options:(NSDataSearchOptions)aMask range:(NSRange)aSearchRange
{
    CFRange range = CFDataFind(_cfData, [aDataToFind CFData], *(CFRange *)&aSearchRange, (CFDataSearchFlags)aMask);
    return *(NSRange *)&range;
}

- (NSUInteger)hash
{
    return CFHash(_cfData);
}

- (id)copy
{
    return [[self class] dataWithData:self];
}

- (id)mutableCopy
{
    return [NSMutableData  dataWithData:self];
}

@end


@implementation NSMutableData


+ (id)dataWithCapacity:(NSUInteger)aCapacity
{
    return [[self alloc] initWithCapacity:aCapacity];
}
+ (id)dataWithLength:(NSUInteger)aLength
{
    return [[self alloc] initWithLength:aLength];
}

- (id)initWithCapacity:(NSUInteger)aCapacity
{
    if((self = [super init]))
        _cfData = CFDataCreateMutable(NULL, aCapacity);
    return self;
}
- (id)initWithLength:(NSUInteger)aLength
{
    if((self = [self initWithCapacity:0]))
        [self setLength:aLength];
    return self;
}
- (id)initWithBytes:(const void *)aBytes length:(NSUInteger)aLength
{
    if((self = [super init])) {
        _cfData = CFDataCreateMutable(NULL, 0);
        CFDataAppendBytes((CFMutableDataRef)_cfData, aBytes, aLength);
    }
    return self;
}
- (id)initWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength
{
    return [self initWithBytesNoCopy:aBytes length:aLength freeWhenDone:NO];
}
- (id)initWithBytesNoCopy:(void *)aBytes length:(NSUInteger)aLength freeWhenDone:(BOOL)aShouldFree
{
    if((self = [super init]))
        _cfData = CFDataCreateWithBytesNoCopy(NULL, aBytes, aLength, aShouldFree ? kCFAllocatorDefault : kCFAllocatorNull);
    return self;
}
- (id)initWithData:(NSData *)aData
{
    if((self = [super init]))
        _cfData = CFDataCreateMutableCopy(NULL, 0, [aData CFData]);
    return self;
}

- (void *)mutableBytes
{
    return CFDataGetMutableBytePtr((CFMutableDataRef)_cfData);
}
- (void)setLength:(NSUInteger)aLength;
{
    CFDataSetLength((CFMutableDataRef)_cfData, aLength);
}

- (void)appendBytes:(const void *)aBytes length:(NSUInteger)aLength
{
    CFDataAppendBytes((CFMutableDataRef)_cfData, aBytes, aLength);
}
- (void)appendData:(NSData *)aOther
{
    [self appendBytes:[aOther bytes] length:[aOther length]];
}
- (void)increaseLengthBy:(NSUInteger)aExtraLength
{
    [self setLength:[self length] + aExtraLength];
}
- (void)replaceBytesInRange:(NSRange)aRange withBytes:(const void *)aBytes
{
    CFDataReplaceBytes((CFMutableDataRef)_cfData, *(CFRange *)&aRange, aBytes, aRange.length);
}
- (void)resetBytesInRange:(NSRange)aRange
{
    uint8_t *bytes = calloc(aRange.length, 1);
    [self replaceBytesInRange:aRange withBytes:bytes];
    free(bytes);
}
- (void)setData:(NSData *)aData
{
    CFMutableDataRef newData = CFDataCreateMutableCopy(NULL, 0, [aData CFData]);
    CFDataRef oldData = _cfData;
    _cfData = newData;
    CFRelease(oldData);
}

- (void)replaceBytesInRange:(NSRange)aRange withBytes:(const void *)aReplacementBytes length:(NSUInteger)aReplacementLength
{
    CFDataReplaceBytes((CFMutableDataRef)_cfData, *(CFRange *)&aRange, aReplacementBytes, aReplacementLength);
}

@end

