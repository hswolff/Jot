//
//  JotViewController.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemViewController.h"
#import "DAKeyboardControl.h"
#import "IIViewDeckController.h"
#import "Models/JotItemStore.h"
#import "JotItem.h"
#import "Constants.h"

@implementation UITextView (AllowMultiTouches)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    if (self.editable) {
        return self.editable;
    } else {
        return YES;
    }
}

@end




@implementation ItemViewController

@synthesize jotTextView = _jotTextView;
@synthesize item = _item;

#pragma mark -
#pragma mark View Lifecycle Management

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [Constants backgroundColor];
    
    self.jotTextView = [[UITextView alloc] initWithFrame:frame];
    self.jotTextView.delegate = self;
    self.jotTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.jotTextView.font = [Constants fontSettings];
    self.jotTextView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    self.jotTextView.backgroundColor = [Constants backgroundColor];
    
    [self.view addSubview:self.jotTextView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.centered = YES;
    [self.jotTextView addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        if (_jotTextView.editable) {
            CGRect newFrame = _jotTextView.frame;
            newFrame.size.height = keyboardFrameInView.origin.y - _jotTextView.contentOffset.y;
            _jotTextView.frame = newFrame;
        }
    }];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changeGesture:)];
    [self.jotTextView addGestureRecognizer:panGesture];
    
    JotItemStore *defaultStore = [JotItemStore defaultStore];
    [self setItem:[defaultStore getCurrentItem]];
    
    [defaultStore addObserver:self forKeyPath:@"currentIndex" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(defaultsChanged:)
                                              name:NSUserDefaultsDidChangeNotification
                                              object:nil];

    // Immediately show keyboard
    [self.jotTextView becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.jotTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    if ([keyPath isEqualToString:@"currentIndex"]) {
        JotItemStore *defaultStore = (JotItemStore *)object;
        [self setItem:[defaultStore getCurrentItem]];
        
    }
}

- (void)defaultsChanged:(NSNotification *)notification {
    self.view.backgroundColor = [Constants backgroundColor];
    self.jotTextView.backgroundColor = [Constants backgroundColor];
    self.jotTextView.font = [Constants fontSettings];
}

#pragma mark -
#pragma mark Modify Item

- (void)setItem:(JotItem *)item {
    _item = item;
    self.jotTextView.text = self.item.text;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (!self.item) {
        JotItem *newItem = [[JotItemStore defaultStore] createItemWithText:textView.text];
        [[JotItemStore defaultStore] setCurrentIndex:0];
        self.item = newItem;
    }
    self.item.text = textView.text;
    
    if (self.item.shared.count > 0) {
        [self.item.shared removeAllObjects];
    }
}

- (void)setCentered:(BOOL)centered {
//    NSLog(@"setCentered: %i", centered);
    _jotTextView.scrollEnabled = centered;
    _jotTextView.editable = centered;
    _centered = centered;
}

#pragma mark -
#pragma mark GestureRecognizer

- (void)changeGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.view];
//    CGPoint velocity = [gesture velocityInView:self.view];
//    if (self.centered) {
//        NSLog(@"Centered: true");
//    } else {
//        NSLog(@"Centered: false");
//    }
//    NSLog(@"point: %@", NSStringFromCGPoint(point));
//    NSLog(@"velocity: %@", NSStringFromCGPoint(velocity));
    
    if (!self.centered) {
//        NSLog(@"AAA");
        [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
        [self.jotTextView hideKeyboard];
    }
    else if (point.y != 0) {
//        NSLog(@"BBB");
    }
    else if (point.x >= 0 || point.x <= 0) {
//        NSLog(@"CCC");
        [self.viewDeckController performSelector:@selector(panned:) withObject:gesture];
        [self.jotTextView hideKeyboard];
    }

}

@end