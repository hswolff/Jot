//
//  JotTextView.m
//  Jot
//
//  Created by Harry Wolff on 7/13/12.
//
//

#import "JotTextView.h"

@implementation JotTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        inputAccessoryView.backgroundColor = [UIColor clearColor];
        self.inputAccessoryView = inputAccessoryView;
//        activeInput = self;
    }
    return self;
}

@end
