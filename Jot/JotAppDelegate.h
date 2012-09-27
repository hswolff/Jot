//
//  JotAppDelegate.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewDeck/IIViewDeckController.h"

@class JotViewController;
@class JotFileViewController;
@class JotViewController;
@class IIViewDeckController;


@interface JotAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) JotViewController *centerController;
@property (retain, nonatomic) UINavigationController *leftController;
@property (retain, nonatomic) JotFileViewController *rightController;

@property (retain, nonatomic) IIViewDeckController *deckController;

- (void) openCenterViewControllerWithText:(NSString *)text;

@end
