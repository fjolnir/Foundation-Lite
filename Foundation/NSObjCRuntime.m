#import "NSObjCRuntime.h"
#import "NSString.h"
#import <objc/runtime.h>

NSString *NSStringFromSelector(SEL aSelector)
{
    return [NSString stringWithUTF8String:sel_getName(aSelector)];
}
SEL NSSelectorFromString(NSString *aSelectorName)
{
    return sel_registerName([aSelectorName UTF8String]);
}

NSString *NSStringFromClass(Class aClass)
{
    return [NSString stringWithUTF8String:class_getName(aClass)];
}
Class NSClassFromString(NSString *aClassName)
{
    return objc_getClass([aClassName UTF8String]);
}

NSString *NSStringFromProtocol(Protocol * const aProto)
{
    return [NSString stringWithUTF8String:protocol_getName(aProto)];
}
Protocol *NSProtocolFromString(NSString *aName)
{
    return objc_getProtocol([aName UTF8String]);
}

const char *NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp)
{
    assert(0); // TODO
}

void NSLog(NSString * const aFormat, ...)
{
    va_list argList;
    va_start(argList, aFormat);
    NSLogv(aFormat, argList);
    va_end(argList);
}

void NSLogv(NSString * aFormat, va_list aArgs)
{
    fprintf(stderr, "%s\n", [[[NSString alloc] initWithFormat:aFormat arguments:aArgs] UTF8String]);
}

void NSPrintForDebugger(id obj)
{
    fprintf(stderr, "%s\n", [[obj description] UTF8String]);
}
