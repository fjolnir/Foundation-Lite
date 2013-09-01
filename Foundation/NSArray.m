#import "NSArray.h"
#import "NSObjCRuntime.h"
#import "NSString.h"
#import "NSException.h"
#import <CoreFoundation/CFString.h>

@interface NSArray () {
@protected
    CFArrayRef _cfArray;
}
@end

CFComparisonResult _NSArrayCompareObjects(const void *aA, const void *aB, void *aCtx)
{
    return (CFComparisonResult)[(id)aA performSelector:(SEL)aCtx withObject:(id)aB];
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
+ (id)arrayWithObject:(id)aObj
{
    return [[[self alloc] initWithObjects:aObj, nil] autorelease];
}
+ (id)arrayWithObjects:(const id[])aObjs count:(NSUInteger)aCount
{
    return [[[self alloc] initWithObjects:aObjs count:aCount] autorelease];
}
+ (id)arrayWithObjects:(id)aFirstObj, ...
{
    NSWithIDArgs(aFirstObj,
        return [[self alloc] initWithObjects:__objects count:__count];
    );
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
- (id)initWithObjects:(const id[])aObjs count:(NSUInteger)aCount
{
    if((self = [super init]))
        _cfArray = CFArrayCreate(NULL, (const void **)aObjs, aCount, &_NSArrayCallBacks);
    return self;
}
- (id)initWithObjects:(id)aFirstObj, ...
{
    NSWithIDArgs(aFirstObj,
        return [self initWithObjects:__objects count:__count];
    );
}
- (id)initWithArray:(NSArray *)aArray
{
    if((self = [super init]))
        _cfArray = CFArrayCreateCopy(NULL, [aArray CFArray]);
    return self;
}
- (id)initWithArray:(NSArray *)aArray copyItems:(BOOL)aCopy
{
    int const count = [aArray count];
    id copies[count];
    id *head = copies;
    for(id obj in aArray) {
        *(head++) = [[obj copy] autorelease];
    }
    return [self initWithObjects:copies count:count];
}

- (NSString *)description
{
    NSMutableString *desc = [@"(\n\t" mutableCopy];
    [desc appendString:[self componentsJoinedByString:@",\n\t"]];
    [desc appendString:@"\n)"];
    return [desc autorelease];
}
- (CFArrayRef)CFArray
{
    return _cfArray;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState * const)aState
                                  objects:(__unsafe_unretained id * const)aBuffer
                                    count:(NSUInteger const)aLen
{
    NSUInteger count = [self count];
    NSInteger length = MIN(aLen, count - aState->state);

    if(aState->state > 0 && count != *aState->mutationsPtr)
        @throw [NSException exceptionWithName:@"Mutation Exception"
                                       format:@"Array was mutated while enumerating!"];

    aState->extra[0] = count;
    aState->mutationsPtr = &aState->extra[0];
    aState->itemsPtr = aBuffer;

    if(length > 0) {
        CFRange const range = { aState->state, length };
        CFArrayGetValues(_cfArray, range, (const void **)aState->itemsPtr);
        aState->state += length;
    } else {
        length = 0;
    }
    return length;
}

- (NSUInteger)count
{
    return CFArrayGetCount(_cfArray);
}
- (id)objectAtIndex:(NSUInteger)aIdx
{
    return (id)CFArrayGetValueAtIndex(_cfArray, aIdx);
}

- (NSArray *)arrayByAddingObject:(id)aObj
{
    NSUInteger const count = [self count] + 1;
    id *objects;
    if(count < NSMaxStackArguments)
        objects = alloca(count * sizeof(id));
    else
        objects = malloc(count * sizeof(id));

    [self getObjects:objects range:(NSRange) {0, [self count]}];
    objects[count-1] = aObj;

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
        else if(first)
            first = NO;
        [joined appendString:[obj description]];
    }
    return joined;
}
- (BOOL)containsObject:(id const)aObj
{
    return CFArrayContainsValue(_cfArray, (CFRange){0,0}, aObj);
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
- (NSUInteger)indexOfObject:(id const)aObj
{
    return [self indexOfObject:aObj inRange:(NSRange){0,0}];
}
- (NSUInteger)indexOfObject:(id const)aObj inRange:(NSRange const)aRange
{
    return CFArrayGetFirstIndexOfValue(_cfArray, *(CFRange *)&aRange, aObj);
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)aObj
{
    return [self indexOfObjectIdenticalTo:aObj inRange:(NSRange){0,0}];
}
- (NSUInteger)indexOfObjectIdenticalTo:(id)aObj inRange:(NSRange)range
{
    NSUInteger       idx = (range.length == 0) ? 0 : range.location;
    NSUInteger const max = (range.length == 0) ? [self count] : range.location + range.length;
    for(id obj in self) {
        if(idx >= max)
            break;
        else if(obj == aObj)
            return idx;
        ++idx;
    }
    return NSNotFound;
}
- (BOOL)isEqualToArray:(NSArray *)aArray
{
    return CFEqual(_cfArray, [aArray CFArray]);
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
    return [result autorelease];
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

- (NSUInteger)hash
{
    return CFHash(_cfArray);
}

- (id)copy
{
    return [[NSArray alloc] initWithArray:self];
}
- (id)mutableCopy
{
    return [[NSMutableArray alloc] initWithArray:self];
}

@end


@implementation NSMutableArray

#define MakeCFArrayMutable() do { \
    CFArrayRef oldArr = _cfArray; \
    _cfArray = CFArrayCreateMutableCopy(NULL, 0, _cfArray); \
    CFRelease(oldArr); \
} while(0)

+ (id)arrayWithCapacity:(NSUInteger)aCapacity
{
    return [[[self alloc] initWithCapacity:aCapacity] autorelease];
}

- (id)initWithCapacity:(NSUInteger)aCapacity
{
    if((self = [super init]))
        _cfArray = CFArrayCreateMutable(NULL, aCapacity, &_NSArrayCallBacks);
    return self;
}
- (id)init
{
    return [self initWithCapacity:0];
}
- (id)initWithCFArray:(CFArrayRef)aCFArray
{
    if((self = [super init]))
        _cfArray = CFArrayCreateMutableCopy(NULL, 0, aCFArray);
    return self;
}
- (id)initWithObjects:(const id[])aObjs count:(NSUInteger)aCount
{
    if((self = [super initWithObjects:aObjs count:aCount]))
        MakeCFArrayMutable();
    return self;
}
- (id)initWithArray:(NSArray *)aArray
{
    if((self = [super init]))
        _cfArray = CFArrayCreateMutableCopy(NULL, 0, [aArray CFArray]);
    return self;
}
- (id)initWithArray:(NSArray *)aArray copyItems:(BOOL)aCopy
{
    if((self = [super initWithArray:aArray copyItems:aCopy]))
        MakeCFArrayMutable();
    return self;
}

- (void)addObject:(id)aObj
{
    CFArrayAppendValue((CFMutableArrayRef)_cfArray, (const void *)aObj);
}
- (void)insertObject:(id)aObj atIndex:(NSUInteger)aIdx
{
    CFArrayInsertValueAtIndex((CFMutableArrayRef)_cfArray, aIdx, (const void *)aObj);
}
- (void)removeLastObject
{
    [self removeObjectAtIndex:[self count] - 1];
}
- (void)removeObjectAtIndex:(NSUInteger)aIdx
{
    CFArrayRemoveValueAtIndex((CFMutableArrayRef)_cfArray, aIdx);
}
- (void)replaceObjectAtIndex:(NSUInteger)aIdx withObject:(id)aObj
{
    CFArraySetValueAtIndex((CFMutableArrayRef)_cfArray, aIdx, (const void *)aObj);
}

- (void)addObjectsFromArray:(NSArray *)aArray
{
    for(id obj in aArray) {
        [self addObject:obj];
    }
}
- (void)exchangeObjectAtIndex:(NSUInteger)aIdx1 withObjectAtIndex:(NSUInteger)aIdx2
{
    CFArrayExchangeValuesAtIndices((CFMutableArrayRef)_cfArray, aIdx1, aIdx2);
}
- (void)removeAllObjects
{
    CFArrayRemoveAllValues((CFMutableArrayRef)_cfArray);
}
- (void)removeObject:(id)aObj inRange:(NSRange)aRange
{
    for(NSInteger i = aRange.location+aRange.length-1; i >= (NSInteger)aRange.location; --i) {
        if([self[i] isEqual:aObj])
            [self removeObjectAtIndex:i];
    }
}
- (void)removeObject:(id)aObj
{
    [self removeObject:aObj inRange:(NSRange){0, [self count]}];
}
- (void)removeObjectIdenticalTo:(id)aObj inRange:(NSRange)aRange
{
    for(NSInteger i = aRange.location+aRange.length-1; i >= (NSInteger)aRange.location; --i) {
        if(self[i] == aObj)
            [self removeObjectAtIndex:i];
    }
}
- (void)removeObjectIdenticalTo:(id)aObj
{
    [self removeObjectIdenticalTo:aObj inRange:(NSRange) {0, [self count]}];
}
- (void)removeObjectsInArray:(NSArray *)aArray
{
    for(id obj in aArray) {
        [self removeObject:obj];
    }
}
- (void)removeObjectsInRange:(NSRange)aRange
{
    for(NSUInteger i = aRange.location+aRange.length-1; i >= aRange.location; --i) {
        [self removeObjectAtIndex:i];
    }
}
- (void)replaceObjectsInRange:(NSRange)aRange withObjectsFromArray:(NSArray *)aOtherArray range:(NSRange)aOtherRange
{
}
- (void)replaceObjectsInRange:(NSRange)aRange withObjectsFromArray:(NSArray *)aArray
{
    [self replaceObjectsInRange:aRange withObjectsFromArray:aArray range:(NSRange) {0, [aArray count] }];
}
- (void)setArray:(NSArray *)aArray
{
    id *values = malloc([aArray count] * sizeof(id));
    [aArray getObjects:values range:(NSRange){ 0, 0 }];
    CFArrayReplaceValues((CFMutableArrayRef)_cfArray, (CFRange){ 0, [self count] }, (const void **)values, [aArray count]);
    free(values);
}
- (void)sortUsingSelector:(SEL)aComparator
{
    CFArraySortValues((CFMutableArrayRef)_cfArray, (CFRange){0,[self count]}, &_NSArrayCompareObjects, aComparator);
}

- (void)setObject:(id)aObj atIndexedSubscript:(NSUInteger)aIdx
{
    CFArraySetValueAtIndex((CFMutableArrayRef)_cfArray, aIdx, (const void *)aObj);
}

@end
