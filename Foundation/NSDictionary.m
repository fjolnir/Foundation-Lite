#import "NSDictionary.h"
#import "NSObjCRuntime.h"
#import "NSArray.h"
#import "NSString.h"
#import "NSNumber.h"

@interface NSDictionary () {
    CFDictionaryRef _cfDict;
}
@end

CFComparisonResult _NSDictionaryCompareObjects(const void *aA, const void *aB, void *aCtx)
{
    return (CFComparisonResult)[(id)aA compare:(id)aB];
}

const void *_NSDictionaryRetainCallback(CFAllocatorRef aAllocator, const void *aObj)
{
    return [(id)aObj retain];
}
const void *_NSDictionaryCopyCallback(CFAllocatorRef aAllocator, const void *aObj)
{
    return [(id)aObj copy];
}
void _NSDictionaryReleaseCallback(CFAllocatorRef aAllocator, const void *aObj)
{
    [(id)aObj release];
}
static CFStringRef _NSDictionaryCopyDescriptionCallback(const void *aObj)
{
    return CFStringCreateCopy(NULL, [[(id)aObj description] CFString]);
}
static BOOL _NSDictionaryEqualCallback(const void *aA, const void *aB)
{
    return [(__bridge id)aA isEqual:(__bridge id)aB];
}

static CFDictionaryKeyCallBacks _NSDictionaryKeyCallBacks = {
    .version         = 0,
    .retain          = &_NSDictionaryRetainCallback,
    .release         = &_NSDictionaryReleaseCallback,
    .copyDescription = &_NSDictionaryCopyDescriptionCallback,
    .equal           = &_NSDictionaryEqualCallback,
};
static CFDictionaryValueCallBacks _NSDictionaryValueCallBacks = {
    .version         = 0,
    .retain          = &_NSDictionaryCopyCallback,
    .release         = &_NSDictionaryReleaseCallback,
    .copyDescription = &_NSDictionaryCopyDescriptionCallback,
    .equal           = &_NSDictionaryEqualCallback,
};


@implementation NSDictionary

+ (id)dictionary
{
    return [[[self alloc] init] autorelease];
}
+ (id)dictionaryWithObject:(id)aObject forKey:(id <NSCopying>)aKey
{
    return [[[self alloc] initWithObjectsAndKeys:aObject, aKey, nil] autorelease];
}
+ (id)dictionaryWithObjects:(const id [])aObjects forKeys:(const id <NSCopying> [])aKeys count:(NSUInteger)aCnt
{
    return [[[self alloc] initWithObjects:aObjects forKeys:aKeys count:aCnt] autorelease];
}
+ (id)dictionaryWithObjectsAndKeys:(id)aFirstObject, ...
{
    NSWithIDKeyValArgs(aFirstObject,
        return [[self alloc] initWithObjects:__vals forKeys:__keys count:__valCount];
    );
}
+ (id)dictionaryWithDictionary:(NSDictionary *)aDict
{
    return [[[self alloc] initWithDictionary:aDict] autorelease];
}
+ (id)dictionaryWithObjects:(NSArray *)aObjects forKeys:(NSArray *)aKeys
{
    return [[[self alloc] initWithObjects:aObjects forKeys:aKeys] autorelease];
}
//+ (id)dictionaryWithContentsOfFile:(NSString *)aPath
//+ (id)dictionaryWithContentsOfURL:(NSURL *)aUrl

- (id)init
{
    return [self initWithObjects:NULL forKeys:NULL count:0];
}
- (id)initWithObjects:(const id [])aObjects forKeys:(const id <NSCopying> [])aKeys count:(NSUInteger)aCnt
{
    if((self = [super init]))
        _cfDict = CFDictionaryCreate(NULL, (const void **)aKeys, (const void **)aObjects, aCnt,
                                     &_NSDictionaryKeyCallBacks, &_NSDictionaryValueCallBacks);
    return self;
}
- (id)initWithObjectsAndKeys:(id)aFirstObject, ...
{
    NSWithIDKeyValArgs(aFirstObject,
        return [self initWithObjects:__vals forKeys:__keys count:__valCount];
    );
}
- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    if((self = [super init]))
        _cfDict = CFDictionaryCreateCopy(NULL, [aDictionary CFDictionary]);
    return self;
}
- (id)initWithDictionary:(NSDictionary *)aOtherDictionary copyItems:(BOOL)aFlag
{
    
}
- (id)initWithObjects:(NSArray *)aObjects forKeys:(NSArray *)aKeys
{
    assert([aObjects count] == [aKeys count]);
    id *keys = malloc([aKeys count]);
    id *vals = malloc([aObjects count]);

    [aKeys    getObjects:keys range:(NSRange) {0,0}];
    [aObjects getObjects:vals range:(NSRange) {0,0}];

    self = [self initWithObjects:vals forKeys:keys count:[aObjects count]];
    free(keys);
    free(vals);

    return self;
}

//- (id)initWithContentsOfFile:(NSString *)aPath
//- (id)initWithContentsOfURL:(NSURL *)aUrl

- (CFDictionaryRef)CFDictionary
{
    return _cfDict;
}

- (NSUInteger)count
{
    return CFDictionaryGetCount(_cfDict);
}
- (id)objectForKey:(id)aKey
{
    return (id)CFDictionaryGetValue(_cfDict, (const void *)aKey);
}

- (NSArray *)allKeys
{
    id *keys = malloc([self count] * sizeof(id));
    CFDictionaryGetKeysAndValues(_cfDict, (const void **)keys, NULL);
    NSArray *array = [NSArray arrayWithObjects:keys count:[self count]];
    free(keys);
    return array;
}
- (NSArray *)allKeysForObject:(id)aAnObject
{
    assert(0); //TODO
    return nil;
}
- (NSArray *)allValues
{
    id *vals = malloc([self count] * sizeof(id));
    CFDictionaryGetKeysAndValues(_cfDict, NULL, (const void **)vals);
    NSArray *array = [NSArray arrayWithObjects:vals count:[self count]];
    free(vals);
    return array;
}
- (BOOL)isEqualToDictionary:(NSDictionary *)aDictionary
{
    return CFEqual(_cfDict, [aDictionary CFDictionary]);
}
- (NSArray *)objectsForKeys:(NSArray *)aKeys notFoundMarker:(id)aMarker
{
    assert([aKeys count] && aMarker);

    id *objects = malloc([aKeys count] * sizeof(id));
    id *currObj = objects;
    for(id key in aKeys) {
        *(currObj++) = self[key] ?: aMarker;
    }
    NSArray *array = [NSArray arrayWithObjects:objects count:[aKeys count]];
    free(objects);
    return array;
}
//- (BOOL)writeToFile:(NSString *)aPath atomically:(BOOL)aUseAuxiliaryFile
//- (BOOL)writeToURL:(NSURL *)aUrl atomically:(BOOL)aAtomically

- (NSArray *)keysSortedByValueUsingSelector:(SEL)aComparator
{
    assert(0); //
}
- (void)getObjects:(id __unsafe_unretained [])aoObjects andKeys:(id __unsafe_unretained [])aoKeys
{
    CFDictionaryGetKeysAndValues(_cfDict, (const void **)aoKeys, (const void **)aoObjects);
}

- (id)objectForKeyedSubscript:(id)aKey
{
    return (id)CFDictionaryGetValue(_cfDict, (const void *)aKey);
}

- (id)copy
{
    return [[self class] dictionaryWithDictionary:self];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState * const)aState objects:(id * const)aBuffer count:(NSUInteger const)aLen
{
    if(aState->state == 0) {
        aState->extra[1] = (unsigned long)[self allKeys];
    }
    return [(id)aState->extra[1] countByEnumeratingWithState:aState objects:aBuffer count:aLen];
}

- (NSString *)description
{
    NSMutableString *desc = [@"{\n\t" mutableCopy];
    BOOL first = YES;
    for(id key in self) {
        if(!first)
            [desc appendString:@",\n\t"];
        else
            first = NO;

        [desc appendFormat:@"%@ = %@", key, self[key]];
    }
    [desc appendString:@"\n}"];
    return desc;
}
@end


