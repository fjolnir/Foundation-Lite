#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <stdlib.h>

NSString * const kTestFailedException;

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"

#define ANSI_BOLD_BLACK   "\033[1m\033[30m"
#define ANSI_BOLD_RED     "\033[1m\033[31m"
#define ANSI_BOLD_GREEN   "\033[1m\033[32m"
#define ANSI_BOLD_YELLOW  "\033[1m\033[33m"
#define ANSI_BOLD_BLUE    "\033[1m\033[34m"
#define ANSI_BOLD_MAGENTA "\033[1m\033[35m"
#define ANSI_BOLD_CYAN    "\033[1m\033[36m"
#define ANSI_BOLD_WHITE   "\033[1m\033[37m"

#define SuppressPerformSelectorLeakWarning(code...) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    code \
    _Pragma("clang diagnostic pop")

#define TLog(format, args...) NSLog(@"     * " format,  ##args)

#define TAssert(msg, cond...) do { \
    if(({ cond; })) \
        TLog(@"%-70s" ANSI_COLOR_GREEN " Successful"ANSI_COLOR_RESET, [msg UTF8String]); \
    else { \
        TLog(@"%-70s" ANSI_BOLD_RED    " FAILED" ANSI_COLOR_RESET, [msg UTF8String]); \
        @throw [NSException exceptionWithName:kTestFailedException \
                                       reason:[NSString stringWithFormat:@"%s failed", #cond] \
                                     userInfo:nil]; \
    } \
} while(0)

#define TestEntity(entity, testCases...) \
@interface Test##entity : Test \
@end \
@implementation Test##entity \
    + (NSString *)entityName { \
        return [@#entity stringByReplacingOccurrencesOfString:@"_" withString:@" "]; \
    } \
    testCases \
@end

#define Case(description, code...) \
- (BOOL)test_##description { \
    NSLog(@"   * %@:", [@#description stringByReplacingOccurrencesOfString:@"_" withString:@" "]); \
    @try { \
        code \
    } \
    @catch(NSException *e) { \
        return NO; \
    } \
    return YES; \
}

#define SetUp(code...)    - (void)setUp    { code; }
#define TearDown(code...) - (void)tearDown { code; }

@interface Test : NSObject
+ (BOOL)performTests;
+ (NSString *)entityName;
- (void)setUp;
- (void)tearDown;
@end
