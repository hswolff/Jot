//
//  JotListViewController.h
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import <UIKit/UIKit.h>

@class JotItem;

@interface ItemListController : UITableViewController

- (void)selectJot:(JotItem *)jot;

@end
