//
//  JotViewController.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotViewController.h"

@interface JotViewController ()

@end

@implementation JotViewController

@synthesize jotTextView = _jotTextView;

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    
    self.jotTextView = [[JotTextView alloc] initWithFrame:frame];
    self.jotTextView.delegate = self;
    self.jotTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.jotTextView.font = [UIFont systemFontOfSize:18.0];
    self.jotTextView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    
    [self.view addSubview:self.jotTextView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = [defaults objectForKey:@"text"];
    if (text) {
        self.jotTextView.text = text;
        text = nil;
    }
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Immediately show keyboard
    [self.jotTextView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.jotTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)handleEnteredBackground:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.jotTextView.text forKey:@"text"];
    
    [defaults synchronize];
}

- (void)keyboardFrameWillChange:(CGRect)newFrame from:(CGRect)oldFrame over:(CGFloat)seconds;
{
    CGRect viewFrame = self.view.bounds;
    
    CGPoint keyboardPoint = [self.view convertPoint:newFrame.origin fromView:nil];
    
    CGFloat newHeight = keyboardPoint.y - viewFrame.origin.y;
    CGFloat maxHeight = self.view.frame.size.height;
    
    viewFrame.size.height = MIN(maxHeight, newHeight);
    
    BOOL up = (oldFrame.origin.y > newFrame.origin.y);
    
    [UIView animateWithDuration:seconds
                          delay:0
                        options:(up ? 0 : UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         self.jotTextView.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end