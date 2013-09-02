#import "Test.h"

static NSURL *file, *dir, *http, *blank;

TestEntity(NSURL,
    SetUp(
        blank     = [NSURL new];
        http      = [NSURL URLWithString:@"http://www.google.com/search"];
        file      = [NSURL fileURLWithPath:@"/bin/bash"];
        dir       = [NSURL fileURLWithPath:@"/bin" isDirectory:YES];
    )
    Case(Creation,
        TAssert(@"+[NSURL new]", !blank);
        TAssert(@"+[NSURL fileURLWithPath:]", file && [file isFileURL]);
        TAssert(@"+[NSURL fileURLWithPath:directory:]", dir && [file isFileURL]);
    )
    Case(Comparison,
        NSURL * const url = [[NSURL alloc] initWithScheme:@"http"
                                                     host:@"www.google.com"
                                                     path:@"search"];;
        TAssert(@"-[isEqual:]",
                 [url isEqual:http] &&
                 ![url isEqual:blank]);
    )
    Case(Deriving,
    )
)

