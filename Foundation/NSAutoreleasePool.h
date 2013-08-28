#import <Foundation/NSObject.h>

@interface NSAutoreleasePool : NSObject 
+ (void)addObject: (id)anObj;
- (void)addObject: (id)anObj;
- (void) drain;
@end

