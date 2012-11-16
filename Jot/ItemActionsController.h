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
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface ItemActionsController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate> {
    NSArray *menuItems;
    UIActivityIndicatorView *facebookActivityIndicator;
    UIActivityIndicatorView *twitterActivityIndicator;
}

- (UITableViewCell *)getCellByName:(NSString *)name;

@end
