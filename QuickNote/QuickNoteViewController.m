//
//  QuickNoteViewController.m
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuickNoteViewController.h"

static float FingerGrabHandleSize = 20.0f;

@implementation QuickNoteViewController

@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Create inputAccessoryView for reference to keyboard
    self.textView.inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    // Immediately show keyboard
    [self.textView becomeFirstResponder];
    
    // Copied from 'KeyboardAccessory'
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)hideKeyboard:(id)sender {
    [self hideKeyboard];
}



#pragma mark -
#pragma mark Handle Keyboard

- (void)hideKeyboard {
    [self.textView resignFirstResponder];
}


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

- (void)keyboardDidShow:(NSNotification *)notification {
    keyboardView  = self.textView.inputAccessoryView.superview;
    keyboardFrame = self.textView.inputAccessoryView.superview.frame;
    return;
}

#pragma mark -
#pragma mark Handle Pan Gesture
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {

    if(recognizer.state == UIGestureRecognizerStateBegan){
        originalKeyboardY = keyboardView.frame.origin.y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGPoint velocity = [recognizer velocityInView:self.view];
        if (velocity.y > 0) {
            [self animateKeyboardOffscreen];
        } else {
            [self animateKeyboardReturnToOriginalPosition];
        }
        return;
        
    }
    
    CGPoint location = [recognizer locationInView:self.view];  

    if (location.y < (keyboardFrame.origin.y - FingerGrabHandleSize)) {
        return;
    }
        
    CGRect newFrame = keyboardFrame;
    newFrame.origin.y = location.y + FingerGrabHandleSize;
    keyboardView.frame = newFrame;
    
    return;
}

- (void)animateKeyboardOffscreen {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
     
                     animations:^{
                         CGRect newFrame = keyboardView.frame;
                         newFrame.origin.y = keyboardView.window.frame.size.height;
                         keyboardView.frame = newFrame;
                     }
     
                     completion:^(BOOL finished){
                         keyboardView.hidden = YES;
                         [self hideKeyboard];
                     }];
}

- (void)animateKeyboardReturnToOriginalPosition {
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboardView.frame;
    newFrame.origin.y = originalKeyboardY;
    keyboardView.frame = newFrame;
    [UIView commitAnimations];
}

@end