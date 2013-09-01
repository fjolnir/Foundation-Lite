#import "Test.h"

NSString * const kTestFailedException = @"TestFailedException";

@implementation Test

+ (BOOL)performTests
{
    if(self == [Test class]) {
        int const classCount = objc_getClassList(NULL, 0);
        Class * const classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classCount);
        objc_getClassList(classes, classCount);

        NSUInteger totalTestClasses = 0;
        NSUInteger failedTestClasses= 0;
        for(int i = 0; i < classCount; ++i) {
            Class klass = classes[i];
            while((klass = class_getSuperclass(klass))) {
                if(klass == self) {
                    NSLog(@" * Checking '%@'", [classes[i] entityName]);
                    ++totalTestClasses;
                    if(![classes[i] performTests])
                        ++failedTestClasses;
                    break;
                }
            }
        }
        free(classes);

        if(totalTestClasses == 0)
            return YES;

        if(failedTestClasses == 0) {
            NSLog(@"" ANSI_BOLD_GREEN " * All tests succeeded" ANSI_COLOR_RESET);
        } else {
            NSLog(@"" ANSI_BOLD_RED   " * Tests failed" ANSI_COLOR_RESET);
        }
    } else {
        Method *methods = class_copyMethodList(self, NULL);
        Method *method = methods;

        id instance = [self new];
        NSUInteger totalTests      = 0;
        NSUInteger failedTests = 0;
        while(*method) {
            SEL const selector = method_getName(*method);
            NSString * const selectorAsString = NSStringFromSelector(selector);
            if([selectorAsString hasPrefix:@"test_"]) {
                [instance setUp];

                SuppressPerformSelectorLeakWarning(
                    if(![instance performSelector:selector])
                        ++failedTests;
                )
                ++totalTests;

                [instance tearDown];
            }
            ++method;
        }
        free(methods);
        if(failedTests == 0)
            NSLog(@"" ANSI_COLOR_GREEN "   * %ld/%ld succeeded" ANSI_COLOR_RESET, totalTests - failedTests, totalTests);
        else {
            NSLog(@"" ANSI_COLOR_RED   "   * %ld/%ld succeeded" ANSI_COLOR_RESET, totalTests - failedTests, totalTests);
            return NO;
        }

    }
    return YES;
}

+ (NSString *)entityName
{
    return nil;
}

- (void)setUp    { return; }
- (void)tearDown { return; }

@end

