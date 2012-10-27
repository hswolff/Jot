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
    self.deckController.leftSize = LEFT_LEDGE_SIZE;
    self.deckController.rightSize = RIGHT_LEDGE_SIZE;
    
    self.window.rootViewController = self.deckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController
          didChangeOffset:(CGFloat)offset
              orientation:(IIViewDeckOffsetOrientation)orientation
                  panning:(BOOL)panning
{
//    NSLog(@"viewDeckController Offset: %f", offset);
    if (offset && self.centerController.centered == YES) {
//        NSLog(@"Set centered:  NO");
        [self.centerController setCentered:NO];
    } else if (!offset && self.centerController.centered == NO) {
//        NSLog(@"Set centered:  YES");
        [self.centerController setCentered:YES];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController
 didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide
                  animated:(BOOL)animated
{
//    NSLog(@"didShowCenterViewFromSide");
    [self.centerController setCentered:YES];
    [self.centerController.jotTextView becomeFirstResponder];
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController
          willOpenViewSide:(IIViewDeckSide)viewDeckSide 
                 animated:(BOOL)animated
{
    //    NSLog(@"viewDeckSide: %@", NSStringFromIIViewDeckSide(viewDeckSide));
    switch (viewDeckSide) {
        case IIViewDeckLeftSide: {
//            NSLog(@"willOpenViewSide:  LEFT");
            [[[self.leftController.viewControllers objectAtIndex:0] tableView] reloadData];
        }
            break;
        case IIViewDeckRightSide:
            //            NSLog(@"RIGHT RIGHT");
        default:
            break;
    }
}

-(void)viewDeckController:(IIViewDeckController *)viewDeckController
          didOpenViewSide:(IIViewDeckSide)viewDeckSide
                 animated:(BOOL)animated
{
//    NSLog(@"viewDeckSide: %@", NSStringFromIIViewDeckSide(viewDeckSide));
    switch (viewDeckSide) {
        case IIViewDeckLeftSide: {
//            NSLog(@"didOpenViewSide:  LEFT");
            BOOL success = [[JotItemStore defaultStore] saveChanges];
            if (success) {
//                NSLog(@"Saved all the JotItems");
            } else {
//                NSLog(@"Could not save any of the JotItems");
            }
        }
            break;
        case IIViewDeckRightSide:
//            NSLog(@"RIGHT RIGHT");
        default:
            break;
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
