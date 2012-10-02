//
//  JotViewController.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JotItem;

@interface JotItemViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate> {
}

@property (strong, nonatomic) UITextView *jotTextView;
@property (nonatomic, assign) BOOL centered;
@property (nonatomic, strong) JotItem *item;

@end
