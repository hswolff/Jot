//
//  QuickNoteViewController.m
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuickNoteViewController.h"

@interface QuickNoteViewController ()

@end

@implementation QuickNoteViewController

@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    
    keyboardSuperView.hidden = NO;
    
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
    keyboardSuperView  = self.textView.inputAccessoryView.superview;
    keyboardSuperFrame = self.textView.inputAccessoryView.superview.frame;
    return;
}

#pragma mark -
#pragma mark Handle Pan Gesture
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
//    NSLog(@"Testing %@", recognizer);
//    CGPoint translation = [recognizer translationInView:self.view];
//    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, 
//                                         recognizer.view.center.y + translation.y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        originalKeyboardY = keyboardSuperView.frame.origin.y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        version 1
//        
//        CGPoint translation = [recognizer translationInView:self.view];
////        NSLog(@"Final Translation in x,y: %f,%f", translation.x, translation.y);
//        if (translation.y >= 50.00) {
//            [self hideKeyboard];
//        }

//        version 2
//        
//        CGRect newFrame;
//        CGRect bounds = [[UIScreen mainScreen] bounds];
//        
//        newFrame = keyboardSuperFrame;
//        newFrame.origin.y = bounds.size.height;  
//        
//        if ((keyboardSuperView.superview))
//            if (keyboardSuperFrame.origin.y != keyboardSuperView.frame.origin.y)
//                [UIView  animateWithDuration:0.2
//                                  animations:^{keyboardSuperView.frame = newFrame;}
//                                  completion:^(BOOL finished){ keyboardSuperView.hidden = YES; keyboardSuperView.frame = keyboardSuperFrame; [self hideKeyboard]; }];
//        
        CGPoint velocity = [recognizer velocityInView:self.view];
        if (velocity.y > 0) {
            [self animateKeyboardOffscreen];
        } else {
            [self animateKeyboardReturnToOriginalPosition];
        }
        return;
        
        
    } else {
        
        CGPoint location = [recognizer locationInView:self.view];  
        
        if ((keyboardSuperView.superview)) {
            CGFloat updateY = keyboardSuperView.frame.origin.y;
            if (location.y < keyboardSuperFrame.origin.y)
                return;
            if ((location.y > updateY) || (location.y < updateY))
                updateY = location.y;
            if (keyboardSuperView.frame.origin.y != updateY)
                keyboardSuperView.frame = CGRectMake(keyboardSuperFrame.origin.x, location.y, keyboardSuperFrame.size.width, keyboardSuperFrame.size.height);
        };
        
        
        
    }
    return;
}

- (void)animateKeyboardOffscreen {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect newFrame = keyboardSuperView.frame;
                         newFrame.origin.y = keyboardSuperView.window.frame.size.height;
                         keyboardSuperView.frame = newFrame;
                     }
     
                     completion:^(BOOL finished){
                         keyboardSuperView.hidden = YES;
                         [self hideKeyboard];
                     }];
}

- (void)animateKeyboardReturnToOriginalPosition {
    [UIView beginAnimations:nil context:NULL];
    CGRect newFrame = keyboardSuperView.frame;
    newFrame.origin.y = originalKeyboardY;
    keyboardSuperView.frame = newFrame;
    [UIView commitAnimations];
}

@end