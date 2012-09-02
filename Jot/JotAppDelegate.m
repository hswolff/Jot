//
//  JotAppDelegate.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JotAppDelegate.h"

#import "ViewDeck/IIViewDeckController.h"
#import "JotViewController.h"
#import "JotFileViewController.h"
#import "JotListViewController.h"

@implementation JotAppDelegate

@synthesize window = _window;
@synthesize centerController = _viewController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.centerController = [[JotViewController alloc] init];
    self.leftController = [[JotListViewController alloc] init];
    self.rightController = [[JotFileViewController alloc] init];
    
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.centerController leftViewController:self.leftController rightViewController:self.rightController];
    
    
    self.window.rootViewController = deckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
