//
//  QuickNoteViewController.h
//  QuickNote
//
//  Created by Harry Wolff on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickNoteViewController : UIViewController
- (IBAction)hideKeyboard:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
