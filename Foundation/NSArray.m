#import "NSArray.h"
#import "NSObjCRuntime.h"
#import "NSString.h"
#import "NSException.h"
#import <CoreFoundation/CFString.h>

@interface NSArray () {
    CFTypeRef _cfArray;
}
@end

CFComparisonResult _NSArrayCompareObjects(const void *aA, const void *aB, void *aCtx)
{
    return (CFComparisonResult)[(id)aA compare:(id)aB];
}

const void *_NSArrayRetainCallback(CFAllocatorRef aAllocator, const void *aObj)
{
    return [(id)aObj retain];
}
void _NSArrayReleaseCallback(CFAllocatorRef aAllocator, const void *aObj)
{
    [(id)aObj release];
}
static CFStringRef _NSArrayCopyDescriptionCallback(const void *aObj)
{
    return CFStringCreateCopy(NULL, [[(id)aObj description] CFString]);
}
static BOOL _NSArrayEqualCallback(const void *aA, const void *aB)
{
    return [(__bridge id)aA isEqual:(__bridge id)aB];
}

static CFArrayCallBacks _NSArrayCallBacks = {
    .version         = 0,
    .retain          = &_NSArrayRetainCallback,
    .release         = &_NSArrayReleaseCallback,
    .copyDescription = &_NSArrayCopyDescriptionCallback,
    .equal           = &_NSArrayEqualCallback,
};

@implementation NSArray

+ (id)array
{
    return [[[self alloc] init] autorelease];
}
+ (id)arrayWithObject:(id)aObject
{
    return [[[self alloc] initWithObjects:aObject, nil] autorelease];
}
+ (id)arrayWithObjects:(const id[])aObjects count:(NSUInteger)aCount
{
    return [[[self alloc] initWithObjects:aObjects count:aCount] autorelease];
}
+ (id)arrayWithObjects:(id)aFirstObj, ...
{
    NSArray *array;
    NSWithIDArgs(aFirstObj,
        array = [[self alloc] initWithObjects:__objects count:__count];
    );
    return [array autorelease];
}
+ (id)arrayWithArray:(NSArray *)aArray
{
    return [[[self alloc] initWithArray:aArray] autorelease];
}

- (id)init
{
    return [self initWithObjects:NULL count:0];
}
- (id)initWithCFArray:(CFArrayRef)aCFArray
{
    if((self = [super init]))
        _cfArray = CFArrayCreateCopy(NULL, aCFArray);
    return self;
}
- (id)initWithObjects:(const id[])aObjects count:(NSUInteger)aCount
{
    if((self = [super init]))
        _cfArray = CFArrayCreate(NULL, (const void **)aObjects, aCount, &_NSArrayCallBacks);
    return self;
}
- (id)initWithObjects:(id)aFirstObj, ...
{
    NSWithIDArgs(aFirstObj,
        self = [self initWithObjects:__objects count:__count];
    );
    return self;
}
- (id)initWithArray:(NSArray *)aArray
{
    if([super init])
        _cfArray = CFArrayCreateCopy(NULL, [aArray CFArray]);
    return self;
}
- (id)initWithArray:(NSArray *)aArray copyItems:(BOOL)aCopy
{
    int const count = [aArray count];
    id copies[count];
    id *head = copies;
    for(id obj in aArray) {
        *(head++) = [obj copy];
    }
    return [self initWithObjects:copies count:count];
}

- (NSString *)description
{
    NSMutableString *desc = [@"(\n\t" mutableCopy];
    [desc appendString:[self componentsJoinedByString:@",\n\t"]];
    [desc appendString:@"\n)"];
    return desc;
}
- (CFArrayRef)CFArray
{
    return _cfArray;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState * const)aState objects:(id * const)aBuffer count:(NSUInteger const)aLen
{
    if(aState->state == 0) {
        aState->mutationsPtr = (unsigned long *)[self hash];
        aState->state = 1;
        aState->extra[0] = 0;
    } else {
        unsigned long * const mutPtr = (unsigned long *)[self hash];
        if(mutPtr != aState->mutationsPtr)
            @throw [NSException exceptionWithName:@"Mutation Exception"
                                           format:@"Array was mutated while enumerating!"];
        else
            aState->mutationsPtr = mutPtr;
    }
    aState->itemsPtr = aBuffer;

    NSUInteger const count = MIN([self count] - aState->extra[0], aLen);
    CFRange    const range = { aState->extra[0], count };
    CFArrayGetValues(_cfArray, range, (const void **)aBuffer);
    aState->extra[0] = range.location + range.length;

    return count;
}

- (NSUInteger)count
{
    return CFArrayGetCount(_cfArray);
}
- (id)objectAtIndex:(NSUInteger)aIdx
{
    return (id)CFArrayGetValueAtIndex(_cfArray, aIdx);
}

- (NSArray *)arrayByAddingObject:(id)aObject
{
    NSUInteger const count = [self count] + 1;
    id *objects;
    if(count < NSMaxStackArguments)
        objects = alloca(count * sizeof(id));
    else
        objects = malloc(count * sizeof(id));

    [self getObjects:objects range:(NSRange) {0, [self count]}];
    objects[count-1] = aObject;

    return [[self class] arrayWithObjects:objects count:count];
}
- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)aArray
{
    NSUInteger const count = [self count] + [aArray count];
    id *objects;
    if(count < NSMaxStackArguments)
        objects = alloca(count * sizeof(id));
    else
        objects = malloc(count * sizeof(id));

    [self       getObjects:objects range:(NSRange) {0, [self count]}];
    [aArray getObjects:objects range:(NSRange) {[self count], [aArray count]}];

    return [[self class] arrayWithObjects:objects count:count];
}
- (NSString *)componentsJoinedByString:(NSString *)aSeparator
{
    NSMutableString *joined = [NSMutableString string];
    BOOL first = YES;
    for(id obj in self) {
        if(!first && aSeparator)
            [joined appendString:aSeparator];
        else
            first = NO;
        [joined appendString:[obj description]];
    }
    return joined;
}
- (BOOL)containsObject:(id const)aObject
{
    return CFArrayContainsValue(_cfArray, (CFRange){0,0}, aObject);
}
- (id)firstObjectCommonWithArray:(NSArray *)aArray
{
    for(id obj in self) {
        if([aArray containsObject:obj])
            return obj;
    }
    return nil;
}
- (void)getObjects:(id *)aoObjects range:(NSRange const)aRange
{
    CFArrayGetValues(_cfArray, *(CFRange *)&aRange, (const void **)aoObjects);
}
- (NSUInteger)indexOfObject:(id const)aObject
{
    return [self indexOfObject:aObject inRange:(NSRange){0,0}];
}
- (NSUInteger)indexOfObject:(id const)aObject inRange:(NSRange const)aRange
{
    return CFArrayGetFirstIndexOfValue(_cfArray, *(CFRange *)&aRange, aObject);
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)aObject
{
    return [self indexOfObjectIdenticalTo:aObject inRange:(NSRange){0,0}];
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)aObject inRange:(NSRange)range
{
    NSUInteger       idx = (range.length == 0) ? 0 : range.location;
    NSUInteger const max = (range.length == 0) ? [self count] : range.location + range.length;
    for(id obj in self) {
        if(idx >= max)
            break;
        else if(obj == aObject)
            return idx;
        ++idx;
    }
    return NSNotFound;
}
- (BOOL)isEqualToArray:(NSArray *)aArray
{
    return [self hash] == [aArray hash];
}
- (id)lastObject
{
    if([self count] == 0)
        return nil;
    else
        return self[[self count] - 1];
}
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator
{
    CFMutableArrayRef sorted = CFArrayCreateMutableCopy(NULL, [self count], _cfArray);
    CFArraySortValues(sorted, (CFRange){0,0}, &_NSArrayCompareObjects, NULL);
    NSArray *result = [[NSArray alloc] initWithCFArray:sorted];
    CFRelease(sorted);
    return result;
}
- (NSArray *)subarrayWithRange:(NSRange)aRange
{
    id *objects;
    if(aRange.length < NSMaxStackArguments)
        objects = alloca(aRange.length * sizeof(id));
    else
        objects = malloc(aRange.length * sizeof(id));
    CFArrayGetValues(_cfArray, *(CFRange *)&aRange, (const void **)objects);

    NSArray *result = [[NSArray alloc] initWithObjects:objects count:aRange.length];
    if(aRange.length >= NSMaxStackArguments)
        free(objects);
    return [result autorelease];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
    for(id obj in self) {
        [obj performSelector:aSelector];
    }
}
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)aArg
{
    for(id obj in self) {
        [obj performSelector:aSelector withObject:aArg];
    }
}

- (id)objectAtIndexedSubscript:(NSUInteger)aIdx
{
    return (id)CFArrayGetValueAtIndex(_cfArray, aIdx);
}

@end
