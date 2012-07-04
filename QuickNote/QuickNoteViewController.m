//
//  QuickNoteViewController.m
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuickNoteViewController.h"

static float FingerGrabHandleSize = 0.0f;

@implementation QuickNoteViewController

@synthesize textView = _textView;

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    
    self.textView = [[UITextView alloc] initWithFrame:frame];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    // Create inputAccessoryView for reference to keyboard
    self.textView.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    

    [self.view addSubview:self.textView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = [defaults objectForKey:@"text"];
    if (text) {
        self.textView.text = text;
        text = nil;
    }
    
    // Immediately show keyboard
    [self.textView becomeFirstResponder];
    
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
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.textView.frame = self.view.bounds;
    
    [UIView commitAnimations];
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
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGPoint velocity = [recognizer velocityInView:self.view];
        if (velocity.y > 0) {
            [self animateKeyboardOffscreen];
        } else if (!keyboardView.hidden) {
            [self animateKeyboardReturnToOriginalPosition];
        }
        return;
        
    }
    
    CGPoint location = [recognizer locationInView:self.view];  

    if (location.y < (keyboardFrame.origin.y - FingerGrabHandleSize)) {
        return;
    }
    
    // update frame of keyboard
    CGRect newFrame = keyboardFrame;
    newFrame.origin.y = location.y + FingerGrabHandleSize;
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
}

@end