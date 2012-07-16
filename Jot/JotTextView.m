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
    }
    return self;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    activeKeyboard  = activeInput.inputAccessoryView.superview;
    originalKeyboardFrame = activeKeyboard.frame;
    activeKeyboard.hidden = NO;
    
    [self scrollRangeToVisible:self.selectedRange];
}

@end
