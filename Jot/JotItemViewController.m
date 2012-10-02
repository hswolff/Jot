//
//  JotViewController.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotItemViewController.h"
#import "DAKeyboardControl.h"
#import "Libs/ViewDeck/IIViewDeckController.h"
#import "JotItem.h"

@implementation JotItemViewController

@synthesize jotTextView = _jotTextView;
@synthesize item = _item;

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.jotTextView = [[UITextView alloc] initWithFrame:frame];
    self.jotTextView.delegate = self;
    self.jotTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.jotTextView.font = [UIFont systemFontOfSize:18.0];
    self.jotTextView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    
    [self.view addSubview:self.jotTextView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.jotTextView addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect newFrame = self.jotTextView.frame;
        newFrame.size.height = keyboardFrameInView.origin.y - self.jotTextView.contentOffset.y;
        self.jotTextView.frame = newFrame;
    }];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeGesture:)];
    [self.jotTextView addGestureRecognizer:panGesture];

    // Immediately show keyboard
    [self.jotTextView becomeFirstResponder];
}

- (void)setItem:(JotItem *)item {
    _item = item;
    self.jotTextView.text = self.item.text;
}


- (void)changeGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.view];

    if (!self.centered) {
        [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            initialPoint = point;
            break;
        default: {
            if (point.y > initialPoint.y || point.y < initialPoint.y) {
            }
            else if (point.x >= initialPoint.x || point.x <= initialPoint.x) {
                [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
            }
        }
            break;

    }
}

- (void)textViewDidChange:(UITextView *)textView {
    self.item.text = textView.text;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.jotTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end