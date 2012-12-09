//
//  JotFileViewController.m
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import "Constants.h"
#import "ItemActionsController.h"
#import "JotItemStore.h"
#import "JotItem.h"
#import "IIViewDeckController.h"
#import "SettingsController.h"


static int const FACEBOOK_INDEX = 5;
static int const TWITTER_INDEX = 6;


int word_count(NSString* s) {
    if ([s length] <= 0) {
        return 0;
    }
    CFCharacterSetRef alpha = CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
    CFStringInlineBuffer buf;
    CFIndex len = CFStringGetLength((CFStringRef)s);
    CFStringInitInlineBuffer((CFStringRef)s, &buf, CFRangeMake(0, len));
    UniChar c;
    CFIndex i = 0;
    int word_count = 0;
    Boolean was_alpha = false, is_alpha;
    while ((c = CFStringGetCharacterFromInlineBuffer(&buf, i++))) {
        is_alpha = CFCharacterSetIsCharacterMember(alpha, c);
        if (!is_alpha && was_alpha)
            ++ word_count;
        was_alpha = is_alpha;
    }
    if (is_alpha)
        ++ word_count;
    return word_count;
}


@interface TestCell : UITableViewCell
@end
@implementation TestCell

-(void)setFrame:(CGRect)frame {
    frame.origin.x += RIGHT_LEDGE_SIZE;
    frame.size.width -= RIGHT_LEDGE_SIZE;
    return [super setFrame:frame];
}
@end



@interface ItemActionsController () <FBLoginViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) id<FBGraphUser> loggedInUser;

- (void)completePost:(NSString *)name;
- (void)tweet;

@end



@implementation ItemActionsController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Actions";
    // settings icon from:
    // stackoverflow.com/questions/9755154/ios-uibarbuttonitem-identifier-option-to-create-settings-cogwheel-button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettings)];
    UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24.0];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, UITextAttributeFont, nil];
    [settingsButton setTitleTextAttributes:dict forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    menuItems = [[NSArray alloc] initWithObjects:
                 @"Character Count:",
                 @"Word Count:",
                 @"E-mail",
                 @"SMS",
                 @"Copy to Clipboard",
                 @"Post to Facebook",
                 @"Post to Twitter",
                 nil];
}

#pragma mark -
#pragma mark Delegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[self class]] && self.viewDeckController.rightSize != RIGHT_LEDGE_SIZE) {
        [self.viewDeckController setRightSize:RIGHT_LEDGE_SIZE];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (self.tableView.indexPathForSelectedRow) {
        NSIndexPath *ip = self.tableView.indexPathForSelectedRow;

        // Row is Facebook, do facebook action if clicked OK
        if (ip.row == FACEBOOK_INDEX && buttonIndex == 1) {
            [self postToFacebook];
            return;
        }
        
        // Row is Twitter, do Twitter action if clicked OK
        if (ip.row == TWITTER_INDEX && buttonIndex == 1) {
            [self tweet];
            return;
        }

        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    if (twitterActivityIndicator.isAnimating &&
        [alertView.message rangeOfString:@"Twitter"].location != NSNotFound) {
        [twitterActivityIndicator stopAnimating];
    }
    if (facebookActivityIndicator.isAnimating &&
        [alertView.message rangeOfString:@"Facebook"].location != NSNotFound) {
        [facebookActivityIndicator stopAnimating];
    }
    
    if ([alertView.message rangeOfString:@"create a Jot"].location != NSNotFound) {
        [twitterActivityIndicator stopAnimating];
        [facebookActivityIndicator stopAnimating];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *message;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            message = @"E-mail Sent!";
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
        if (message) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *message;
        if (result == MessageComposeResultSent) {
            message = @"SMS Sent!";
        } else if (result == MessageComposeResultFailed) {
            message = @"Error sending SMS";
        }
        if (message) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCell";
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TestCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSString *actionText = [menuItems objectAtIndex:indexPath.row];
    JotItem *currentItem = [[JotItemStore defaultStore] getCurrentItem];
    
    if (indexPath.row == 0) {
//        actionText = [actionText stringByAppendingFormat:@":  %i", currentItem.text.length];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        lbl.text = [NSString stringWithFormat:@"%i", currentItem.text.length];
        lbl.font = cell.textLabel.font;
        cell.accessoryView = lbl;
    } else if (indexPath.row == 1) {
        int count = word_count(currentItem.text);
//        actionText = [actionText stringByAppendingFormat:@":  %i", count];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        lbl.text = [NSString stringWithFormat:@"%i", count];
        lbl.font = cell.textLabel.font;
        cell.accessoryView = lbl;
    } else if ([currentItem.shared count] > 0) {
        if ([actionText isEqualToString:@"Post to Facebook"]) {
            NSLog(@"currentItem.shared: %@",currentItem.shared);
            for (NSString *share in currentItem.shared) {
                if ([share isEqualToString:@"Facebook"]) {
                     cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                }
            }
        } else if ([actionText isEqualToString:@"Post to Twitter"]) {
            for (NSString *share in currentItem.shared) {
                if ([share isEqualToString:@"Twitter"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                }
            }
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = actionText;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertView *alert = nil;
    
    switch (indexPath.row) {
        case 0:
        case 1:
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 2:
            [self sendEmail];
            break;
        case 3:
            [self sendSMS];
            break;
        case 4: {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            JotItem *item = [[JotItemStore defaultStore] getCurrentItem];
            if (item) {
                [pb setString:[item text]];
            }
            alert = [[UIAlertView alloc] initWithTitle:@"Copied!"
                                                            message:nil
                                                            delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        }
            break;
        case FACEBOOK_INDEX: {
            if ([facebookActivityIndicator isAnimating] ||
                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
            {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
            }
            alert = [[UIAlertView alloc] initWithTitle:@"Post to Facebook?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Post", nil];
        }
            break;
        case TWITTER_INDEX: {
            if ([twitterActivityIndicator isAnimating] ||
                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark)
            {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
            }
            alert = [[UIAlertView alloc] initWithTitle:@"Post to Twitter?"
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     otherButtonTitles:@"Post", nil];
        }
        default:
            break;
    }
    
    if (alert) {
        [alert show];
    }
//    NSLog(@"Current Item: %@", [[[JotItemStore defaultStore] getCurrentItem] text]);
}

- (UITableViewCell *)getCellByName:(NSString *)name {
    NSUInteger inte = [menuItems indexOfObjectIdenticalTo:name];
    NSIndexPath *pp = [NSIndexPath indexPathForRow:inte inSection:0];
    return [self.tableView cellForRowAtIndexPath:pp];
}

#pragma mark -
#pragma mark Action Methods

- (void)handleEmptyJotState {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:@"You need to create a Jot first!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showSettings {
    SettingsController *settingsController = [[SettingsController alloc] init];
    [self.navigationController pushViewController:settingsController animated:YES];
    
    [self.viewDeckController setRightSize:0];
}

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        JotItem *item = [[JotItemStore defaultStore] getCurrentItem];
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"Jot: %@", [item description]]];
//        NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
//        [mailer setToRecipients:toRecipients];
        NSString *emailBody = item.text;
        [mailer setMessageBody:emailBody isHTML:NO];
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:mailer animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                        message:@"You need to set up an e-mail account first!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)sendSMS {
    if ([MFMessageComposeViewController canSendText]) {
        JotItem *item = [[JotItemStore defaultStore] getCurrentItem];
        MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
        sms.messageComposeDelegate = self;
        sms.body = item.text;
//        sms.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:sms animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                        message:@"Something went wrong :("
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) tweet {
    UITableViewCell *cell = [self getCellByName:@"Post to Twitter"];
    [cell setSelected:NO animated:NO];
    
    twitterActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.accessoryView = twitterActivityIndicator;
    [twitterActivityIndicator startAnimating];
    
//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(completePost:) userInfo:nil repeats:NO];
//    return;
    
    
    
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                // Create a request, which in this example, posts a tweet to the user's timeline.
                // This example uses version 1 of the Twitter API.
                // This may need to be changed to whichever version is currently appropriate.
                JotItem *item = [[JotItemStore defaultStore] getCurrentItem];
                if (item) {
                    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:item.text forKey:@"status"] requestMethod:TWRequestMethodPOST];
                    
                    // Set the account used to post the tweet.
                    [postRequest setAccount:twitterAccount];
                    
                    // Perform the request created above and create a handler block to handle the response.
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        //                    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                        //                    [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                        //                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tweet complete"
                        //                                                                        message:output
                        //                                                                       delegate:nil
                        //                                                              cancelButtonTitle:@"OK"
                        //                                                              otherButtonTitles:nil];
                        //                    [alertView show];
                        [self completePost:@"Post to Twitter"];
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self handleEmptyJotState];
                    });
                }
            }
        } else {
            NSLog(@"no success: %@", error);
            NSString *errorMessage = nil;
            if ([error code] == 6) {
                errorMessage = @"Account not found. Please setup your account in Settings.";
            } else if ([error code] == 7) {
                errorMessage = @"Account access denied.";
            } else {
                errorMessage = @"Something went wrong.";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not connect to Twitter"
                                                                message:errorMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alertView show];
            });
        }
    }];
}

#pragma mark -
#pragma mark Facebook Methods

- (void)completePost:(NSString *)name {
//    NSLog(@"Completed Post: %@", name);
//    name = @"Facebook";
    
    UITableViewCell *cell = [self getCellByName:name];
    
    if ([name isEqualToString:@"Post to Facebook"]) {
        [facebookActivityIndicator stopAnimating];
        [[[[JotItemStore defaultStore] getCurrentItem] shared] addObject:@"Facebook"];
    } else if ([name isEqualToString:@"Post to Twitter"]) {
        [twitterActivityIndicator stopAnimating];
        [[[[JotItemStore defaultStore] getCurrentItem] shared] addObject:@"Twitter"];
    }
    
    cell.accessoryView = nil;
    cell.selected = NO;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)postToFacebook {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    [cell setSelected:NO animated:NO];
    
    facebookActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    cell.accessoryView = facebookActivityIndicator;
    [facebookActivityIndicator startAnimating];

//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(completePost:) userInfo:nil repeats:NO];
//    return;
    
    NSLog(@"FBSession isOpen? %@", FBSession.activeSession.isOpen?@"YES":@"NO");
    
    if (FBSession.activeSession.isOpen) {
        [self postFacebookStatus];
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
    }
    
}

- (void)postFacebookStatus {
    NSString *message = [[[JotItemStore defaultStore] getCurrentItem] text];
    [self performPublishAction:^{
        // otherwise fall back on a request for permissions and a direct post
        [FBRequestConnection startForPostStatusUpdate:message
                                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                        //                                                [self showAlert:message result:result error:error];
                                        [self completePost:@"Post to Facebook"];
                                    }];
    }];
}

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                 }];
    } else {
        action();
    }
    
}

- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
//        NSDictionary *resultDict = (NSDictionary *)result;
//        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.\nPost ID: %@",
//                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success!";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    NSString *errorMessage = nil;
    switch (state) {
        case FBSessionStateOpen:
        case FBSessionStateOpenTokenExtended: {
            NSLog(@"FBSessionStateOpen");
            [self postFacebookStatus];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            NSLog(@"FBSessionStateClosedLoginFailed");
            [facebookActivityIndicator stopAnimating];
            errorMessage = @"Failed to login to Facebook";
        }
            break;
        default:
            NSLog(@"Default");
            break;
    }
    
    if (errorMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

@end
