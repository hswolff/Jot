//
//  JotAppDelegate.m
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "JotAppDelegate.h"

#import "ItemViewController.h"
#import "ItemActionsController.h"
#import "ItemListController.h"

#import "JotItemStore.h"

@implementation JotAppDelegate

@synthesize window = _window;
@synthesize centerController = _viewController;
@synthesize leftController = _leftController;
@synthesize rightController = _rightController;
@synthesize deckController = _deckController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarHidden:[[NSUserDefaults standardUserDefaults] boolForKey:@"fullScreen"] withAnimation:UIStatusBarAnimationSlide];    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.centerController = [[ItemViewController alloc] init];
    ItemListController *itemListController = [[ItemListController alloc] init];
    self.leftController = [[UINavigationController alloc] initWithRootViewController:itemListController];
    ItemActionsController *actionsController = [[ItemActionsController alloc] init];
    self.rightController = [[UINavigationController alloc] initWithRootViewController:actionsController];
    self.rightController.delegate = actionsController;
    
    self.deckController = [[IIViewDeckController alloc]
                                                  initWithCenterViewController:self.centerController
                                                            leftViewController:self.leftController
                                                           rightViewController:self.rightController];
    self.deckController.delegate = self;
    self.deckController.leftSize = LEFT_LEDGE_SIZE;
    self.deckController.rightSize = RIGHT_LEDGE_SIZE;
    
    [self showJotWelcomeMessagesIfNeeded];
    
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
//    NSLog(@"panning: %@", panning? @"YES":@"NO");
//    NSLog(@"viewDeckController Offset: %f", offset);
    if (offset && self.centerController.centered == YES) {
//        NSLog(@"Set centered:  NO");
        [self.centerController setCentered:NO];
    } else if (!panning && !offset && self.centerController.centered == NO) {
//        NSLog(@"Set centered:  YES");
        [self.centerController setCentered:YES];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController
 didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide
                  animated:(BOOL)animated
{
//    NSLog(@"didShowCenterViewFromSide");
//    NSLog(@"animated: %@", animated? @"YES":@"NO");
    if (animated) {
        [self.centerController setCentered:YES];
        [self.centerController.jotTextView becomeFirstResponder];
    }
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
            [[[self.rightController.viewControllers objectAtIndex:0] tableView] reloadData];
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [FBSession.activeSession close];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)showJotWelcomeMessagesIfNeeded {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL openUpgradeMessage = YES;
    BOOL showHowToUseInstructions = NO;
    
    static NSString *instructionsMessageKey = @"instructionsMessageShown";
    if (![ud boolForKey:instructionsMessageKey]) {
        showHowToUseInstructions = YES;
        [ud setBool:YES forKey:instructionsMessageKey];
        openUpgradeMessage = NO;
    }
    
    static NSString *applicationVersionMessage = @"applicationVersionMessage";
    NSString *appVersionNumber = [self appVersionNumberDisplayString];
    if (![appVersionNumber isEqualToString:[ud stringForKey:applicationVersionMessage]]) {
        [((ItemListController *)self.leftController.topViewController) showUpgradeMessageAndOpen:openUpgradeMessage];
        [ud setValue:appVersionNumber forKey:applicationVersionMessage];
    }
    
    if (showHowToUseInstructions) {
        [((ItemListController *)self.leftController.topViewController) showHowToUseInstructions];
    }
}

- (NSString *)appVersionNumberDisplayString {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@ (%@)", majorVersion, minorVersion];
}



@end
