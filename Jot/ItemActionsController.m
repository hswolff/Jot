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


int word_count(NSString* s) {
    CFCharacterSetRef alpha = CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
    CFStringInlineBuffer buf;
    CFIndex len = CFStringGetLength((CFStringRef)s);
    CFStringInitInlineBuffer((CFStringRef)s, &buf, CFRangeMake(0, len));
    UniChar c;
    CFIndex i = 0;
    int word_count = 0;
    Boolean was_alpha = false, is_alpha;
    while (c) {
        c = CFStringGetCharacterFromInlineBuffer(&buf, i++);;
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



@interface ItemActionsController () <FBLoginViewDelegate, UIAlertViewDelegate> {
    NSIndexPath *currentPath;
}

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
    menuItems = [[NSArray alloc] initWithObjects:@"Word Count", @"E-mail", @"SMS", @"Copy to Clipboard", @"Facebook", @"Facebook Logout", @"Twitter", nil];
}

#pragma mark -
#pragma mark Delegate Methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[self class]] && self.viewDeckController.rightSize != RIGHT_LEDGE_SIZE) {
        [self.viewDeckController setRightSize:RIGHT_LEDGE_SIZE];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (currentPath) {
        [self.tableView deselectRowAtIndexPath:currentPath animated:YES];
        currentPath = nil;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
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
    NSString *text = [menuItems objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        int count = word_count([[[JotItemStore defaultStore] getCurrentItem] text]);
        text = [text stringByAppendingFormat:@":  %i", count];
    }
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 1:
            NSLog(@"email");
            [self sendEmail];
            break;
        case 2:
            [self sendSMS];
            break;
        case 3: {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:[[[JotItemStore defaultStore] getCurrentItem] text]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copied!"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            currentPath = indexPath;
            [alert show];
        }
            break;
        case 4: {
            [self postToFacebook:indexPath];
        }
            break;
        case 5:
            [self facebookLogout];
            break;
        case 6:
            [self tweet];
        default:
            break;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
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
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support text messages"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) tweet {
    UITableViewCell *cell = [self getCellByName:@"Twitter"];
    [cell setSelected:NO animated:NO];
    
    if ([twitterActivityIndicator isAnimating]) {
        return;
    }
    
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
                    [self completePost:@"Twitter"];
                }];
            }
        }
    }];
}

#pragma mark -
#pragma mark Facebook Methods

- (void)completePost:(NSString *)name {
//    NSLog(@"Completed Post: %@", name);
//    name = @"Facebook";
    
    UITableViewCell *cell = [self getCellByName:name];
    
    if ([name isEqualToString:@"Facebook"]) {
        [facebookActivityIndicator stopAnimating];
    } else if ([name isEqualToString:@"Twitter"]) {
        [twitterActivityIndicator stopAnimating];
    }
    
    cell.accessoryView = nil;
    cell.selected = NO;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)postToFacebook:(NSIndexPath *)indexPath {
    currentPath = indexPath;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
 
    if ([facebookActivityIndicator isAnimating]) {
        return;
    }
    
    facebookActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    cell.accessoryView = facebookActivityIndicator;
    [facebookActivityIndicator startAnimating];

//    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(completePost:) userInfo:nil repeats:NO];
//    return;
    if (FBSession.activeSession.isOpen) {
        
        // Post a status update to the user's feed via the Graph API, and display an alert view
        // with the results or an error.
        NSString *message = [[[JotItemStore defaultStore] getCurrentItem] text];
        // if it is available to us, we will post using the native dialog
        //    BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
        //                                                                    initialText:message
        //                                                                          image:nil
        //                                                                            url:nil
        //                                                                        handler:nil];
        BOOL displayedNativeDialog = NO;
        if (!displayedNativeDialog) {
            
            [self performPublishAction:^{
                // otherwise fall back on a request for permissions and a direct post
                [FBRequestConnection startForPostStatusUpdate:message
                                            completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                [self showAlert:message result:result error:error];
                                                [self completePost:@"Facebook"];
                                            }];
            }];
        }
        
    } else {
        
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          //                                             [self sessionStateChanged:session
                                          //                                                                 state:state
                                          //                                                                 error:error];
                                      }];
        
    }
    
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

- (void) facebookLogout {
    [FBSession.activeSession closeAndClearTokenInformation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged Out"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
