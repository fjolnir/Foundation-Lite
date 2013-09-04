#import <Foundation/NSObject.h>
#import <Foundation/NSFastEnumeration.h>
#import <CoreFoundation/CFDictionary.h>

@class NSArray, NSString;

@interface NSDictionary : NSObject <NSCopying, NSMutableCopying, NSFastEnumeration>

+ (id)dictionary;
+ (id)dictionaryWithObject:(id)aObject forKey:(id <NSCopying>)aKey;
+ (id)dictionaryWithObjects:(const id [])aObjects forKeys:(const id <NSCopying> [])aKeys count:(NSUInteger)aCnt;
+ (id)dictionaryWithObjectsAndKeys:(id)aFirstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)dictionaryWithDictionary:(NSDictionary *)aDict;
+ (id)dictionaryWithObjects:(NSArray *)aObjects forKeys:(NSArray *)aKeys;
//+ (id)dictionaryWithContentsOfFile:(NSString *)aPath;
//+ (id)dictionaryWithContentsOfURL:(NSURL *)aUrl;

- (id)initWithObjects:(const id [])aObjects forKeys:(const id <NSCopying> [])aKeys count:(NSUInteger)aCnt;
- (id)initWithObjectsAndKeys:(id)aFirstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithDictionary:(NSDictionary *)aOtherDictionary;
- (id)initWithDictionary:(NSDictionary *)aOtherDictionary copyItems:(BOOL)aFlag;
- (id)initWithObjects:(NSArray *)aObjects forKeys:(NSArray *)aKeys;

//- (id)initWithContentsOfFile:(NSString *)aPath;
//- (id)initWithContentsOfURL:(NSURL *)aUrl;

- (NSUInteger)count;
- (id)objectForKey:(id)aAKey;

- (NSArray *)allKeys;
- (NSArray *)allKeysForObject:(id)aAnObject;    
- (NSArray *)allValues;
- (BOOL)isEqualToDictionary:(NSDictionary *)aOtherDictionary;
- (NSArray *)objectsForKeys:(NSArray *)aKeys notFoundMarker:(id)aMarker;
//- (BOOL)writeToFile:(NSString *)aPath atomically:(BOOL)aUseAuxiliaryFile;
//- (BOOL)writeToURL:(NSURL *)aUrl atomically:(BOOL)aAtomically;

- (NSArray *)keysSortedByValueUsingSelector:(SEL)aComparator;
- (void)getObjects:(id __unsafe_unretained [])aObjects andKeys:(id __unsafe_unretained [])aKeys;

- (id)objectForKeyedSubscript:(id)aKey;

@end

@interface NSDictionary (FoundationLiteExtensionMethods)

- (CFDictionaryRef)CFDictionary;

@end

@interface NSMutableDictionary : NSDictionary

+ (id)dictionaryWithCapacity:(NSUInteger)aNumItems;
- (id)initWithCapacity:(NSUInteger)aNumItems;

- (void)removeObjectForKey:(id)aAKey;
- (void)setObject:(id)aAnObject forKey:(id <NSCopying>)aAKey;

- (void)addEntriesFromDictionary:(NSDictionary *)aOtherDictionary;
- (void)removeAllObjects;
- (void)removeObjectsForKeys:(NSArray *)aKeyArray;
- (void)setDictionary:(NSDictionary *)aOtherDictionary;
- (void)setObject:(id)aObj forKeyedSubscript:(id <NSCopying>)aKey;

@end

