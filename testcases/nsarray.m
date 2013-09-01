#import "Test.h"

static NSArray *empty, *three, *numeric;
static NSMutableArray *mutable;

TestEntity(NSArray,
    SetUp(
        empty = [NSArray new];
        three = [NSArray arrayWithObjects:@1, @"2", @3.0, nil];
        numeric = @[@3, @4, @1];
        mutable = [@[@"foo", @"bar", @"bath"] mutableCopy];
    )
    Case(Creation,
        TAssert(@"+[NSArray new]",               empty);
        TAssert(@"+[NSArray arrayWithObjects:]", three);
    )
    Case(Accessing,
        TAssert(@"-[NSArray objectAtIndex:]", [three[1] isEqual:@"2"]);
        TAssert(@"-[NSArray lastObject]", [[three lastObject] isEqual:@3.0]);
    )
    Case(Deriving,
        TAssert(@"-[NSArray sortedArrayUsingSelector:]",
            [[numeric sortedArrayUsingSelector:@selector(compare:)] isEqual:@[@1,@3,@4]]);
        TAssert(@"-[NSArray subarrayWithRange:]",
            [[numeric subarrayWithRange:(NSRange){1,1}] isEqual:@[@3]]);
    )
    Case(Mutation,
        TAssert(@"-[NSMutableArray addObject:]",
            [mutable addObject:@"baz"];
            [mutable count] == 4);
        TAssert(@"-[NSMutableArray exchangeObjectAtIndex:withObjectAtIndex:]",
            [mutable exchangeObjectAtIndex:3 withObjectAtIndex:2];
            [mutable[2] isEqual:@"baz"]);
        TAssert(@"-[NSMutableArray removeObject:]",
            [mutable removeObject:@"bath"];
            [mutable count] == 3 && [[mutable lastObject] isEqual:@"baz"]);
        TAssert(@"-[NSMutableArray sortUsingSelector:]",
            [mutable sortUsingSelector:@selector(compare:)];
            [mutable isEqual:@[@"bar", @"baz", @"foo"]]);
    )
)
