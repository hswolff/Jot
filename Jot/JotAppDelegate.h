//
//  JotAppDelegate.h
//  Jot
//
//  Created by Harry Wolff on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JotViewController;

@interface JotAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) UIViewController *centerController;
@property (retain, nonatomic) UIViewController *leftController;
@property (retain, nonatomic) UIViewController *rightController;


@end
