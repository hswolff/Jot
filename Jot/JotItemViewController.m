//
//  JotViewController.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotItemViewController.h"
#import "DAKeyboardControl.h"
#import "Libs/ViewDeck/IIViewDeckController.h"
#import "JotItem.h"

@implementation JotItemViewController

@synthesize jotTextView = _jotTextView;
@synthesize item = _item;

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.jotTextView = [[UITextView alloc] initWithFrame:frame];
    self.jotTextView.delegate = self;
    self.jotTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.jotTextView.font = [UIFont systemFontOfSize:18.0];
    self.jotTextView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    
    [self.view addSubview:self.jotTextView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    [self setDefaultText];
    
    [self.jotTextView addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect newFrame = self.jotTextView.frame;
        newFrame.size.height = keyboardFrameInView.origin.y - self.jotTextView.contentOffset.y;
        self.jotTextView.frame = newFrame;
    }];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeGesture:)];
    [self.jotTextView addGestureRecognizer:panGesture];

    // Immediately show keyboard
    [self.jotTextView becomeFirstResponder];
}

- (void)setItem:(JotItem *)item {
    _item = item;
    self.jotTextView.text = self.item.text;
}


- (void)changeGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.view];

    if (!self.centered) {
        [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            initialPoint = point;
            break;
        default: {
            if (point.y > initialPoint.y || point.y < initialPoint.y) {
            }
            else if (point.x >= initialPoint.x || point.x <= initialPoint.x) {
                [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
            }
        }
            break;

    }
}

- (void)textViewDidChange:(UITextView *)textView {
    self.item.text = textView.text;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.jotTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) setDefaultText {
    NSString *lyrics = @""
    "I threw a wish in the well,\n"
    "Don't ask me, I'll never tell\n"
    "I looked to you as it fell,\n"
    "And now you're in my way\n"
    "\n"
    "I'd trade my soul for a wish,\n"
    "Pennies and dimes for a kiss\n"
    "I wasn't looking for this,\n"
    "But now you're in my way\n"
    "\n"
    "Your stare was holdin',\n"
    "Ripped jeans, skin was showin'\n"
    "Hot night, wind was blowin'\n"
    "Where you think you're going, baby?\n"
    "\n"
    "Hey, I just met you,\n"
    "And this is crazy,\n"
    "But here's my number,\n"
    "So call me, maybe?\n"
    "\n"
    "It's hard to look right,\n"
    "At you baby,\n"
    "But here's my number,\n"
    "So call me, maybe?\n"
    "\n"
    "Hey, I just met you,\n"
    "And this is crazy,\n"
    "But here's my number,\n"
    "So call me, maybe?\n"
    "\n"
    "And all the other boys,\n"
    "Try to chase me,\n"
    "But here's my number,\n"
    "So call me, maybe?\n"
    "\n"
    "You took your time with the call,\n"
    "I took no time with the fall\n"
    "You gave me nothing at all,\n"
    "But still, you're in my way\n"
    "\n"
    "I beg, and borrow and steal\n"
    "Have foresight and it's real\n"
    "I didn't know I would feel it,\n"
    "But it's in my way\n"
    "\n"
    "Your stare was holdin',\n"
    "Ripped jeans, skin was showin'\n"
    "Hot night, wind was blowin'\n"
    "Where you think you're going, baby?\n"
    "\n"
    "Hey, I just met you,\n"
    "And this is crazy,\n"
    "But here's my number,\n"
    "So call me, maybe?";
    self.jotTextView.text = lyrics;
}

@end