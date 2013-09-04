#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSFastEnumeration.h>
#import <CoreFoundation/CFArray.h>

@class NSString, NSURL, NSData;

@interface NSArray : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>

+ (id)array;
+ (id)arrayWithObject:(id)anObject;
+ (id)arrayWithObjects:(const id[])aObjects count:(NSUInteger)aCount;
+ (id)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)arrayWithArray:(NSArray *)array;

- (id)initWithCFArray:(CFArrayRef)aCFArray;
- (id)initWithObjects:(const id[])objects count:(NSUInteger)count;
- (id)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithArray:(NSArray *)array;
- (id)initWithArray:(NSArray *)array copyItems:(BOOL)flag;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (NSArray *)arrayByAddingObject:(id)anObject;
- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray;
- (NSString *)componentsJoinedByString:(NSString *)separator;
- (BOOL)containsObject:(id)anObject;
- (id)firstObjectCommonWithArray:(NSArray *)otherArray;
- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (BOOL)isEqualToArray:(NSArray *)otherArray;
- (id)lastObject;
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray *)subarrayWithRange:(NSRange)range;

- (void)makeObjectsPerformSelector:(SEL)aSelector;
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface NSArray (FoundationLiteExtensionMethods)

- (CFArrayRef)CFArray;

@end

@interface NSMutableArray : NSArray

+ (id)arrayWithCapacity:(NSUInteger)numItems;
- (id)initWithCapacity:(NSUInteger)numItems;

- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(id)anObject inRange:(NSRange)range;
- (void)removeObject:(id)anObject;
- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(id)anObject;
- (void)removeObjectsInArray:(NSArray *)otherArray;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray;
- (void)setArray:(NSArray *)otherArray;
- (void)sortUsingSelector:(SEL)comparator;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end
