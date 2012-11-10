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
@class IIViewDeckController;


@interface JotAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) ItemViewController *centerController;
@property (retain, nonatomic) UINavigationController *leftController;
@property (retain, nonatomic) UINavigationController *rightController;

@property (retain, nonatomic) IIViewDeckController *deckController;

@end
