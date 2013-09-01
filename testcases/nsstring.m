#import "Test.h"

static NSString *empty, *words, *numeric;
static NSMutableString *mutable;

TestEntity(NSString,
    SetUp(
        empty = [NSString new];
        words = @"foo bar baz";
        numeric = @"3.01";
        mutable = [@"testing foundation" mutableCopy];
    )
    Case(Creation,
        TAssert(@"Constant string", words);
        TAssert(@"+[NSString new]", empty);
        TAssert(@"+[NSString stringWithUTF8String:]",
            [[NSString stringWithUTF8String:"test"] isEqual:@"test"]);
        TAssert(@"+[NSString stringWithFormat:]",
            [[NSString stringWithFormat:@"%@ %d %.1f", @"one", 2, 3.0] isEqual:@"one 2 3.0"]);
    )
    Case(Comparison,
        NSString * const s1 = @"フーバー";
        NSString * const s2 = [s1 copy];
        TAssert(@"-[isEqual:]",
                 [s1 isEqual:s2] &&
                ![s1 isEqual:[NSObject new]]);

        TAssert(@"-[compare:]",
                [s1 compare:s2]       == NSOrderedSame &&
                [s1 compare:@""]      != NSOrderedSame &&
                [@"" compare:@"a"]    == NSOrderedAscending &&
                [@"a" compare:@"b"]   == NSOrderedAscending &&
                [@"cd" compare:@"bc"] == NSOrderedDescending &&
                [@"ä" compare:@"ö"]   == NSOrderedAscending &&
                [@"€" compare:@"ß"]   == NSOrderedDescending &&
                [@"aa" compare:@"z"]  == NSOrderedAscending);

        TAssert(@"-[caseInsensitiveCompare:]",
                [@"a" caseInsensitiveCompare:@"A"]  == NSOrderedSame &&
                [@"Ä" caseInsensitiveCompare:@"ä"]  == NSOrderedSame &&
                [@"я" caseInsensitiveCompare:@"Я"]  == NSOrderedSame &&
                [@"€" caseInsensitiveCompare:@"ß"]  == NSOrderedDescending &&
                [@"ß" caseInsensitiveCompare:@"→"]  == NSOrderedAscending &&
                [@"AA" caseInsensitiveCompare:@"z"] == NSOrderedAscending &&
                [[NSString stringWithUTF8String:"ABC"] caseInsensitiveCompare:
                 [NSString stringWithUTF8String:"AbD"]] == [@"abc" compare: @"abd"]);
    )
    Case(Deriving,
    )
    Case(Mutation,
    )
)
