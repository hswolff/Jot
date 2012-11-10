//
//  JotAppDelegate.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "IIViewDeckController.h"

@class ItemViewController;
@class ItemActionsController;
@class IIViewDeckController;


@interface JotAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) ItemViewController *centerController;
@property (retain, nonatomic) UINavigationController *leftController;
@property (retain, nonatomic) ItemActionsController *rightController;

@property (retain, nonatomic) IIViewDeckController *deckController;

@end
