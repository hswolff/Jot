//
//  JotAppDelegate.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "JotAppDelegate.h"

#import "JotItemViewController.h"
#import "JotFileViewController.h"
#import "JotItemListController.h"

#import "JotItemStore.h"

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
    self.deckController.leftLedge = LEFT_LEDGE_SIZE;
    
    self.window.rootViewController = self.deckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPanToOffset:(CGFloat)offset {
//    NSLog(@"viewDeckController Offset: %f", offset);
    if (offset) {
        [self.centerController setCentered:NO];
    } else {
        [self.centerController setCentered:YES];
    }
}

- (void)viewDeckControllerDidShowCenterView:(IIViewDeckController *)viewDeckController animated:(BOOL)animated {
//    NSLog(@"viewDeckControllerDidShowCenterView");
    [self.centerController setCentered:YES];
    [self.centerController.jotTextView becomeFirstResponder];
}

- (void)viewDeckControllerDidOpenLeftView:(IIViewDeckController *)viewDeckController animated:(BOOL)animated {
    BOOL success = [[JotItemStore defaultStore] saveChanges];
    [[[self.leftController.viewControllers objectAtIndex:0] tableView] reloadData];
    if (success) {
//        NSLog(@"Saved all the JotItems");
    } else {
//        NSLog(@"Could not save any of the JotItems");
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    BOOL success = [[JotItemStore defaultStore] saveChanges];
    if (success) {
//        NSLog(@"Saved all the JotItems");
    } else {
//        NSLog(@"Could not save any of the JotItems");
    }
}

@end
