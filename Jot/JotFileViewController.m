//
//  JotFileViewController.m
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import "Constants.h"
#import "JotFileViewController.h"
#import "JotItemStore.h"
#import "JotItem.h"

@interface TestCell : UITableViewCell
@end
@implementation TestCell

-(void)setFrame:(CGRect)frame {
    frame.origin.x += RIGHT_LEDGE_SIZE;
    frame.size.width -= RIGHT_LEDGE_SIZE;
    return [super setFrame:frame];
}

@end

@implementation JotFileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    menuItems = [[NSArray alloc] initWithObjects:@"Word Count", @"E-mail", @"SMS", @"Copy to Clipboard", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[TestCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = (NSString *)[menuItems objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            NSLog(@"word count");
            [self showCount];
        }
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
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    NSLog(@"Current Item: %@", [[[JotItemStore defaultStore] getCurrentItem] text]);
}

- (void)showCount {
    int count = word_count([[[JotItemStore defaultStore] getCurrentItem] text]);
    NSString *message = [NSString stringWithFormat:@"%i", count];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Count"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

int word_count(NSString* s) {
    CFCharacterSetRef alpha = CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
    CFStringInlineBuffer buf;
    CFIndex len = CFStringGetLength((CFStringRef)s);
    CFStringInitInlineBuffer((CFStringRef)s, &buf, CFRangeMake(0, len));
    UniChar c;
    CFIndex i = 0;
    int word_count = 0;
    Boolean was_alpha = false, is_alpha;
    while (c = CFStringGetCharacterFromInlineBuffer(&buf, i++)) {
        is_alpha = CFCharacterSetIsCharacterMember(alpha, c);
        if (!is_alpha && was_alpha)
            ++ word_count;
        was_alpha = is_alpha;
    }
    if (is_alpha)
        ++ word_count;
    return word_count;
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

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}

@end
