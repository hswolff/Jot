//
//  QuickNoteViewController.h
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickNoteViewController : UIViewController <UIGestureRecognizerDelegate, UITextViewDelegate> {
    CGRect keyboardFrame; // frame of keyboard when initially displayed
    UIView *keyboardView;  // reference to keyboard view
    int originalKeyboardOriginY;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
