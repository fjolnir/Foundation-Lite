#import "NSDictionary.h"
#import "NSObjCRuntime.h"
#import "NSArray.h"
#import "NSString.h"
#import "NSNumber.h"

@interface NSDictionary () {
    @protected
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
- (id)initWithDictionary:(NSDictionary *)aDictionary copyItems:(BOOL)aCopy
{
    if((self = [super init])) {
        id *keys = malloc([aDictionary count] * sizeof(id));
        id *objs = malloc([aDictionary count] * sizeof(id));
        CFDictionaryGetKeysAndValues(_cfDict, (const void **)keys, (const void **)objs);
        if(aCopy) {
            for(NSUInteger i = 0; i < [aDictionary count]; ++i) {
                objs[i] = [objs[i] copy];
            }
        }
        self = [self initWithObjects:objs forKeys:keys count:[aDictionary count]];
        free(keys);
        free(objs);
    }
    return self;
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
    return [[NSDictionary alloc] initWithDictionary:self];
}
- (id)mutableCopy
{
    return [[NSMutableDictionary alloc] initWithDictionary:self];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState * const)aState objects:(id * const)aBuffer count:(NSUInteger const)aLen
{
    if(aState->state == 0)
        // This will go away if some doofus drains the pool in the middle of the loop => maybe come up with a different way?
        aState->extra[1] = (unsigned long)[self allKeys];
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
    return [desc autorelease];
}

@end

@implementation NSMutableDictionary

#define MakeCFDictMutable() do { \
    CFDictionaryRef oldDict = _cfDict; \
    _cfDict = CFDictionaryCreateMutableCopy(NULL, 0, _cfDict); \
    CFRelease(oldDict); \
} while(0)

+ (id)dictionaryWithCapacity:(NSUInteger)aCapacity
{
    return [[[self alloc] initWithCapacity:aCapacity] autorelease];
}

- (id)initWithCapacity:(NSUInteger)aCapacity
{
    if((self = [super init]))
        _cfDict = CFDictionaryCreateMutable(NULL, aCapacity, &_NSDictionaryKeyCallBacks, &_NSDictionaryValueCallBacks);
    return self;
}
- (id)init
{
    return [self initWithCapacity:0];
}
- (id)initWithObjects:(const id [])aObjects forKeys:(const id <NSCopying> [])aKeys count:(NSUInteger)aCnt
{
    if((self = [super initWithObjects:aObjects forKeys:aKeys count:aCnt]))
        MakeCFDictMutable();
    return self;
}
- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    if((self = [super init]))
        _cfDict = CFDictionaryCreateMutableCopy(NULL, 0, [aDictionary CFDictionary]);
    return self;
}
- (id)initWithDictionary:(NSDictionary *)aDictionary copyItems:(BOOL)aCopy
{
    if((self = [super initWithDictionary:aDictionary copyItems:aCopy]))
        MakeCFDictMutable();
    return self;
}
- (id)initWithObjects:(NSArray *)aObjects forKeys:(NSArray *)aKeys
{
    if((self = [super initWithObjects:aObjects forKeys:aKeys]))
        MakeCFDictMutable();
    return self;
}

- (void)removeObjectForKey:(id)aKey
{
    CFDictionaryRemoveValue((CFMutableDictionaryRef)_cfDict, (const void *)aKey);
}
- (void)setObject:(id)aObject forKey:(id <NSCopying>)aKey
{
    CFDictionarySetValue((CFMutableDictionaryRef)_cfDict, (const void *)aKey, (const void *)aObject);
}

- (void)addEntriesFromDictionary:(NSDictionary *)aDictionary
{
    for(id key in aDictionary) {
        self[key] = aDictionary[key];
    }
}

- (void)removeAllObjects
{
    CFDictionaryRemoveAllValues((CFMutableDictionaryRef)_cfDict);
}
- (void)removeObjectsForKeys:(NSArray *)aKeys
{
    for(id key in aKeys)
        [self removeObjectForKey:key];
}
- (void)setDictionary:(NSDictionary *)aDictionary
{
    [self removeAllObjects];
    [self addEntriesFromDictionary:aDictionary];
}

- (void)setObject:(id)aObj forKeyedSubscript:(id <NSCopying>)aKey
{
    CFDictionarySetValue((CFMutableDictionaryRef)_cfDict, (const void *)aKey, (const void *)aObj);
}

@end
