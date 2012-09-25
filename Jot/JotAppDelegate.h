//
//  JotAppDelegate.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewDeck/IIViewDeckController.h"

#import "JotViewController.h"
#import "JotFileViewController.h"
#import "JotItemListController.h"


@class JotViewController;

@interface JotAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) JotViewController *centerController;
@property (retain, nonatomic) JotItemListController *leftController;
@property (retain, nonatomic) JotFileViewController *rightController;


@end
