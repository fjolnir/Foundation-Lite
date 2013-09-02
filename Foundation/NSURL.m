#import "NSURL.h"
#import "NSObject.h"
#import "NSString.h"
#import "NSNumber.h"
#import "NSArray.h"
#include <sys/stat.h>

#define NSURLFromRetainedCFURL(cfURL...) ({ \
    CFURLRef __cfURL = (cfURL); \
    NSURL * const url = [[NSURL alloc] initWithCFURL:__cfURL]; \
    CFRelease(__cfURL); \
    url; \
})
#define NSStringFromRetainedCFString(cfStr...) ({ \
    CFStringRef __cfStr = (cfStr); \
    NSString * const str = [[NSString alloc] initWithCFString:__cfStr]; \
    CFRelease(__cfStr); \
    str; \
})
#define PathIsDir(path...) ({ \
    struct stat statBuf; \
    lstat([(path) UTF8String], &statBuf) == 0 && S_ISDIR(statBuf.st_mode); \
})

NSString *NSURLFileScheme = @"file";

@interface NSURL () {
    CFURLRef _cfURL;
}
@end

@implementation NSURL

+ (id)fileURLWithPath:(NSString *)aPath isDirectory:(BOOL)aIsDir
{
    return [[self alloc] initFileURLWithPath:aPath isDirectory:aIsDir];
}
+ (id)fileURLWithPath:(NSString *)aPath
{
    return [[self alloc] initFileURLWithPath:aPath];
}
- (id)initWithScheme:(NSString *)aScheme host:(NSString *)aHost path:(NSString *)aPath
{
    assert(aScheme && aHost && aPath);
    return [self initWithString:[NSString stringWithFormat:@"%@://%@/%@", aScheme, aHost, aPath]];
}

+ (id)URLWithString:(NSString *)aURLString
{
    return [[self alloc] initWithString:aURLString];
}
+ (id)URLWithString:(NSString *)aURLString relativeToURL:(NSURL *)aBaseURL
{
    return [[self alloc] initWithString:aURLString relativeToURL:aBaseURL];
}

- (id)initFileURLWithPath:(NSString *)aPath isDirectory:(BOOL)aIsDir
{
    if((self = [super init]))
        _cfURL = CFURLCreateWithFileSystemPath(NULL, [aPath CFString],
                                               kCFURLPOSIXPathStyle, aIsDir);
    return self;
}

- (id)initFileURLWithPath:(NSString *)aPath
{
    if((self = [super init])) {
        BOOL const isDir = PathIsDir(aPath);
        if(isDir && ![aPath hasSuffix:@"/"])
            aPath = [aPath stringByAppendingString:@"/"];
        self = [self initFileURLWithPath:aPath isDirectory:isDir];
    }
    return self;
}

- (id)init
{
    return nil;
}
- (id)initWithString:(NSString *)aURLString
{
    return [self initWithString:aURLString relativeToURL:nil];
}
- (id)initWithString:(NSString *)aURLString relativeToURL:(NSURL *)aBaseURL
{
    if((self = [super init]))
        _cfURL = CFURLCreateWithString(NULL, [aURLString CFString], [aBaseURL CFURL]);
    return self;
}
- (id)initWithCFURL:(CFURLRef)aURL
{
    if((self = [super init]))
        _cfURL = CFRetain(aURL);
    return self;
}

- (void)dealloc
{
    if(_cfURL)
        CFRelease(_cfURL), _cfURL = NULL;
}

- (CFURLRef)CFURL
{
    return _cfURL;
}

- (NSString *)absoluteString
{
    return [[NSString alloc] initWithCFString:CFURLGetString(_cfURL)];
}
- (NSString *)relativeString
{
    assert(0);
    return nil;
}
- (NSURL *)baseURL
{
    return [[[self class] alloc] initWithCFURL:CFURLGetBaseURL(_cfURL)];
}
- (NSURL *)absoluteURL
{
    return NSURLFromRetainedCFURL(CFURLCopyAbsoluteURL(_cfURL));
}

- (NSString *)scheme
{
    return NSStringFromRetainedCFString(CFURLCopyScheme(_cfURL));
}
- (NSString *)resourceSpecifier
{
    return NSStringFromRetainedCFString(CFURLCopyScheme(_cfURL));
}

- (NSString *)host
{
    return NSStringFromRetainedCFString(CFURLCopyHostName(_cfURL));
}
- (NSNumber *)port
{
    return @(CFURLGetPortNumber(_cfURL));
}
- (NSString *)user
{
    return NSStringFromRetainedCFString(CFURLCopyUserName(_cfURL));
}
- (NSString *)password
{
    return NSStringFromRetainedCFString(CFURLCopyPassword(_cfURL));
}
- (NSString *)path
{
    return NSStringFromRetainedCFString(CFURLCopyPath(_cfURL));
}
- (NSString *)fragment
{
    return NSStringFromRetainedCFString(CFURLCopyFragment(_cfURL, NULL));
}
- (NSString *)parameterString
{
    return NSStringFromRetainedCFString(CFURLCopyParameterString(_cfURL, NULL));
}
- (NSString *)query
{
    return NSStringFromRetainedCFString(CFURLCopyQueryString(_cfURL, NULL));
}
- (NSString *)relativePath
{
    assert(0); // TODO
    return nil;
}

- (BOOL)isFileURL
{
    assert(0); // TODO
    return NO;
}

- (NSURL *)standardizedURL
{
    assert(0); // TODO
    return nil;
}

- (id)copy
{
    return [[self class] URLWithString:[self absoluteString]];
}

- (BOOL)isEqual:(id)aObj
{
    if([aObj isKindOfClass:[NSURL class]])
        return CFEqual(_cfURL, [aObj CFURL]);
    else
        return NO;
}

- (NSString *)description
{
    return [self absoluteString];
}

@end

@implementation NSURL (NSURLPathUtilities)

+ (NSURL *)fileURLWithPathComponents:(NSArray *)aComponents
{
    return [self fileURLWithPath:[aComponents componentsJoinedByString:@"/"]];
}
- (NSArray *)pathComponents
{
    return [[self path] componentsSeparatedByString:@"/"];
}
- (NSString *)lastPathComponent
{
    return NSStringFromRetainedCFString(CFURLCopyLastPathComponent(_cfURL));
}
- (NSString *)pathExtension
{
    return NSStringFromRetainedCFString(CFURLCopyPathExtension(_cfURL));
}
- (NSURL *)URLByAppendingPathComponent:(NSString *)aPathComponent
{
    return NSURLFromRetainedCFURL(CFURLCreateCopyAppendingPathComponent(
        NULL, _cfURL,
        [aPathComponent CFString],
        PathIsDir([NSString stringWithFormat:@"%@/%@", [self path], aPathComponent])));
}
- (NSURL *)URLByAppendingPathComponent:(NSString *)aPathComponent isDirectory:(BOOL)aIsDirectory
{
    return NSURLFromRetainedCFURL(CFURLCreateCopyAppendingPathComponent(
        NULL, _cfURL,
        [aPathComponent CFString],
        aIsDirectory));
}
- (NSURL *)URLByDeletingLastPathComponent
{
    return NSURLFromRetainedCFURL(CFURLCreateCopyDeletingLastPathComponent(NULL, _cfURL));
}
- (NSURL *)URLByAppendingPathExtension:(NSString *)aPathExtension
{
    return NSURLFromRetainedCFURL(CFURLCreateCopyAppendingPathExtension(NULL, _cfURL, [aPathExtension CFString]));
}
- (NSURL *)URLByDeletingPathExtension
{
    return NSURLFromRetainedCFURL(CFURLCreateCopyDeletingPathExtension(NULL, _cfURL));
}

@end

@implementation NSString (NSURLUtilities)

- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)aEnc
{
    return NSStringFromRetainedCFString(CFURLCreateStringByAddingPercentEscapes(
        NULL, [self CFString], NULL, NULL, aEnc
    ));
}
- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)aEnc
{
    return NSStringFromRetainedCFString(CFURLCreateStringByReplacingPercentEscapes(
        NULL, [self CFString], NULL
    ));
}

@end
