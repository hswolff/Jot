//
//  JotAppDelegate.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotAppDelegate.h"

#import "JotItemViewController.h"
#import "JotFileViewController.h"
#import "JotItemListController.h"


@implementation JotAppDelegate

@synthesize window = _window;
@synthesize centerController = _viewController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;
@synthesize deckController = _deckController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.centerController = [[JotItemViewController alloc] init];
    JotItemListController *itemListController = [[JotItemListController alloc] init];
    self.leftController = [[UINavigationController alloc] initWithRootViewController:itemListController];
    self.rightController = [[JotFileViewController alloc] init];
    
    self.deckController = [[IIViewDeckController alloc]
                                                  initWithCenterViewController:self.centerController
                                                            leftViewController:self.leftController
                                                           rightViewController:self.rightController];
    self.deckController.delegate = self;
    self.deckController.leftLedge = 92.0;
    
    self.window.rootViewController = self.deckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPanToOffset:(CGFloat)offset {
    if (offset) {
        [self.centerController setCentered:NO];
    } else {
        [self.centerController setCentered:YES];
    }
}

- (void)openCenterViewControllerWithText:(NSString *)text {
    [self.centerController setText:text];
    [self.deckController closeLeftViewBouncing:nil];
}

@end
