//
//  JotViewController.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JotViewController : UIViewController <UIGestureRecognizerDelegate, UITextViewDelegate> {
    CGRect keyboardFrame; // frame of keyboard when initially displayed
    UIView *keyboardView;  // reference to keyboard view
    int originalKeyboardOriginY;
}

@property (strong, nonatomic) UITextView *textView;


@end
