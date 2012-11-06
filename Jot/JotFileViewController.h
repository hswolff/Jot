//
//  JotFileViewController.h
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>

@interface JotFileViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    NSArray *menuItems;
}

@end
