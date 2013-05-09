//
//  SettingsAppearanceController.h
//  Jot
//
//  Created by Harry Wolff on 1/7/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsAppearanceController : UITableViewController {
    NSMutableArray *newOptions;
    NSString *settingsAppearanceKey;
}

- (id)initWithIndexPath:(NSIndexPath *)indexPath;

@end
