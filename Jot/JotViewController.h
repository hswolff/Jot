//
//  JotViewController.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JotTextView.h"

@interface JotViewController : UIViewController <DAKeyboardControlDelegate, UITextViewDelegate>

@property (strong, nonatomic) JotTextView *jotTextView;

@end
