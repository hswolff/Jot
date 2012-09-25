//
//  JotAppDelegate.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotAppDelegate.h"


@implementation JotAppDelegate

@synthesize window = _window;
@synthesize centerController = _viewController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.centerController = [[JotViewController alloc] init];
    self.leftController = [[JotItemListController alloc] init];
    self.rightController = [[JotFileViewController alloc] init];
    
    // DONE FOR QUICK DEV, UNDO BEFORE COMMITTING
    IIViewDeckController *deckController = [[IIViewDeckController alloc]
                                                  initWithCenterViewController:self.leftController
                                                            leftViewController:self.centerController
                                                           rightViewController:self.rightController];
    deckController.delegate = self;
    
    self.window.rootViewController = deckController;
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

@end
