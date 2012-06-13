//
//  QuickNoteViewController.h
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickNoteViewController : UIViewController <UIGestureRecognizerDelegate> {
    CGRect keyboardFrame; // frame of keyboard when initially displayed
    UIView *keyboardView;  // reference to keyboard view
    int originalKeyboardY;
}

- (IBAction)hideKeyboard:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
