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

@synthesize textView = _textView;

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    
    self.textView = [[UITextView alloc] initWithFrame:frame];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    // Create inputAccessoryView for reference to keyboard
    self.textView.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.view addSubview:self.textView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = [defaults objectForKey:@"text"];
    if (text) {
        self.textView.text = text;
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
    self.textView.text = lyrics;
    
    // Copied from 'KeyboardAccessory'
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // Immediately show keyboard
    [self.textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setTextView:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)handleEnteredBackground:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.textView.text forKey:@"text"];
    
    [defaults synchronize];
}


#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    keyboardView.hidden = NO;
    
    /*
     Copied from 'KeyboardAccessory'
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
    
    return;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    keyboardView  = self.textView.inputAccessoryView.superview;
    keyboardFrame = self.textView.inputAccessoryView.superview.frame;
    return;
}

// Copied from 'KeyboardAccessory'
- (void)keyboardWillHide:(NSNotification *)notification {
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
    
    return;
}


#pragma mark -
#pragma mark Gesture Recognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleGesture:(UIPanGestureRecognizer *)recognizer {
    
    // If keyboard is hidden then we don't want to change frame of keyboard and textView
    if (keyboardView.hidden) {
        return;
    }
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        originalKeyboardOriginY = keyboardView.frame.origin.y;
    }
    CGPoint location = [recognizer locationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    NSLog(@"\n");
    NSLog(@"location (x, y): (%f, %f)", location.x, location.y);
    NSLog(@"velocity (x, y): (%f, %f)", velocity.x, velocity.y);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        
        if (velocity.y > 0 && location.y > originalKeyboardOriginY ) {
            [self animateKeyboardOffscreen];
        } else if (!keyboardView.hidden) {
            [self animateKeyboardReturnToOriginalPosition];
        }
        return;
        
    }
    
    
    if (location.y < keyboardFrame.origin.y) {
        return;
    }
    
    // update frame of keyboard
    CGRect newFrame = keyboardFrame;
    newFrame.origin.y = location.y;
    keyboardView.frame = newFrame;
    
    // update frame of UITextView
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = location.y - self.view.bounds.origin.y;
    self.textView.frame = newTextViewFrame;
    
    return;
}

- (void)animateKeyboardOffscreen {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
     
                     animations:^{
                         CGRect newFrame = keyboardView.frame;
                         newFrame.origin.y = keyboardView.window.frame.size.height;
                         keyboardView.frame = newFrame;
                         self.textView.frame = self.view.bounds;
                     }
     
                     completion:^(BOOL finished){
                         keyboardView.hidden = YES;
                         [self.textView resignFirstResponder];
                     }];
    return;
}

- (void)animateKeyboardReturnToOriginalPosition {
    [UIView beginAnimations:nil context:NULL];
    
    CGRect newFrame = keyboardView.frame;
    newFrame.origin.y = originalKeyboardOriginY;
    keyboardView.frame = newFrame;
    
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = self.view.bounds.size.height - keyboardFrame.size.height;
    self.textView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
    return;
}

@end