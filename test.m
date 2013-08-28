#import <Foundation/Foundation.h>

@interface Test : NSObject
@end
@implementation Test
- (void)dealloc
{
    printf("[Test] Deallocating: 0x%x\n", (int)self);
}
@end

int main()
{
    @autoreleasepool {
        NSString *str = @"foo";
        printf("Const string: 0x%x: %s: %ld\n", (int)str, [str UTF8String], [str length]);

        printf("Copied const string: %s\n", [[@"foo" copy] UTF8String]);

        NSString *formatStr = [NSString stringWithFormat:@"Hey %d %@", 123, @"embedded"];
        NSLog(@"Formatted: %@ %s", formatStr, [formatStr UTF8String]);

        NSLog(@"Number: %@ Number as str: %@", @123, [@123.3 stringValue]);

        Test *test = [Test new];
        NSLog(@"Test class: %@ instance: %@", [Test class], test);
        [test performSelector:@selector(stringValue)];
    }
    return 0;
}
