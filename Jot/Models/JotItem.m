//
//  JotFile.m
//  Jot
//
//  Created by Harry Wolff on 9/24/12.
//
//

#import "JotItem.h"


@implementation JotItem

@dynamic text;
@dynamic dateCreated;
@dynamic orderingValue;
//@synthesize text = _text;
//@synthesize dateCreated = _dateCreated;
//@synthesize orderingValue = _orderingValue;

- (void) awakeFromFetch {
    [super awakeFromFetch];
}

- (void) awakeFromInsert {
    [super awakeFromInsert];
    NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
    [self setDateCreated:t];
}

- (NSString *) description {
    if (self.text && [self.text length] >= 1) {
        return self.text;
    } else {
        return [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.dateCreated] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    }
    
}


/*
+ (id)randomItem {
    NSString *randomName = [self genRandStringLength: 200];
    
    JotItem *newItem = [[self alloc] initWithText:randomName];
    return newItem;
}

- (id)initWithText:(NSString *)text {
    self = [super init];
    
    if(self) {
        self.text = text;
        self.dateCreated = NSTimeIntervalSince1970;
        self.orderingValue = 0.0;
    }
    
    return self;
}

+ (NSString *) genRandStringLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}
 
*/

@end
