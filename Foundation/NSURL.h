#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <CoreFoundation/CFURL.h>

@class NSNumber, NSData, NSDictionary;

FOUNDATION_EXPORT NSString *NSURLFileScheme;

@interface NSURL : NSObject <NSCopying>

+ (id)URLWithString:(NSString *)aURLString;
+ (id)URLWithString:(NSString *)URLString relativeToURL:(NSURL *)aBaseURL;
+ (id)fileURLWithPath:(NSString *)aPath isDirectory:(BOOL)aIsDir;
+ (id)fileURLWithPath:(NSString *)aPath;

- (id)initWithScheme:(NSString *)aScheme host:(NSString *)aHost path:(NSString *)aPath;

- (id)initFileURLWithPath:(NSString *)aPath isDirectory:(BOOL)aIsDir;
- (id)initFileURLWithPath:(NSString *)aPath;

- (id)initWithString:(NSString *)aURLString;
- (id)initWithString:(NSString *)aURLString relativeToURL:(NSURL *)aBaseURL;

- (id)initWithCFURL:(CFURLRef)aURL;

- (NSString *)absoluteString;
- (NSString *)relativeString;
- (NSURL *)baseURL;
- (NSURL *)absoluteURL;

- (NSString *)scheme;
- (NSString *)resourceSpecifier;

- (NSString *)host;
- (NSNumber *)port;
- (NSString *)user;
- (NSString *)password;
- (NSString *)path;
- (NSString *)fragment;
- (NSString *)parameterString;
- (NSString *)query;
- (NSString *)relativePath;

- (BOOL)isFileURL;

- (NSURL *)standardizedURL;

@end

@interface NSURL (FoundationLiteExtensionMethods)

- (CFURLRef)CFURL;

@end


@interface NSString (NSURLUtilities)

- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)aEnc;
- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)aEnc;

@end


@interface NSURL (NSURLPathUtilities)

+ (NSURL *)fileURLWithPathComponents:(NSArray *)aComponents;
- (NSArray *)pathComponents;
- (NSString *)lastPathComponent;
- (NSString *)pathExtension;
- (NSURL *)URLByAppendingPathComponent:(NSString *)aPathComponent;
- (NSURL *)URLByAppendingPathComponent:(NSString *)aPathComponent isDirectory:(BOOL)aIsDirectory;
- (NSURL *)URLByDeletingLastPathComponent;
- (NSURL *)URLByAppendingPathExtension:(NSString *)aPathExtension;
- (NSURL *)URLByDeletingPathExtension;

@end

