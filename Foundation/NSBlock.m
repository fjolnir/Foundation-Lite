#import "NSObject.h"
#import "NSString.h"
#import "NSException.h"

@interface NSBlock : NSObject
@end

extern BOOL objc_create_block_classes_as_subclasses_of(Class aClass);

@implementation NSBlock

+ (void)load
{
    assert(objc_create_block_classes_as_subclasses_of(self));
}

- (id)copy
{
    return _Block_copy(self);
}

- (id)retain
{
    return _Block_copy(self);
}

- (oneway void)release
{
    _Block_release(self);
}

@end
