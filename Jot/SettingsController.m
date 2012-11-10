//
//  SettingsController.m
//  Jot
//
//  Created by Harry Wolff on 11/10/12.
//
//

#import "SettingsController.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id)init {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray *generalOptions = [[NSArray alloc] initWithObjects:@"Full Screen", @"Logout of Facebook", nil];
        
//        NSArray *styleOptions = [[NSArray alloc] initWithObjects:@"Font Size", @"Font Color", nil];
        
        settingItems = [[NSArray alloc] initWithObjects:generalOptions, nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Settings";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [settingItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[settingItems objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *text = [[settingItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UISwitch *fullScreenSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [fullScreenSwitch addTarget:self action:@selector(setFullScreen:) forControlEvents:UIControlEventValueChanged];
        [fullScreenSwitch setOn:[UIApplication sharedApplication].statusBarHidden];
        cell.accessoryView = fullScreenSwitch;
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [[NSString alloc] init];
    switch (section) {
        case 0:
            title = @"General";
            break;
            
        default:
            title = @"Default";
            break;
    }
    return title;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setFullScreen:(UISwitch *)uiswitch {
//    NSLog(@"bounds: %@", NSStringFromCGRect([[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame]));
    
    [[UIApplication sharedApplication] setStatusBarHidden:uiswitch.on withAnimation:UIStatusBarAnimationSlide];
    
    
//    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController] ;
//    [vc updateViewConstraints];
//    [UIViewController attemptRotationToDeviceOrientation];


//    UIWindow *win = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
//    CGRect frame = win.frame;
//    if (uiswitch.on) {
//        win.frame = CGRectMake(frame.origin.x, frame.origin.y-20, frame.size.width, frame.size.height+20);
//    } else {
//        win.frame = CGRectMake(frame.origin.x, frame.origin.y+20, frame.size.width, frame.size.height-20);
//    }
}

@end
