//
//  JotViewController.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JotViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate> {
    CGPoint initialPoint;
}

@property (strong, nonatomic) UITextView *jotTextView;
@property (nonatomic, assign) BOOL centered;

- (void) setText:(NSString *)text;

@end
