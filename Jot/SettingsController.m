//
//  SettingsController.m
//  Jot
//
//  Created by Harry Wolff on 11/10/12.
//
//

#import "SettingsController.h"
#import "SettingsAppearanceController.h"

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
        NSArray *sections = [[NSArray alloc] initWithObjects:@"General", @"Appearance", nil];
        
        NSArray *generalOptions = [[NSArray alloc] initWithObjects:@"Full Screen", @"Logout of Facebook", nil];
        
        NSArray *appearanceOptions = [[NSArray alloc] initWithObjects: @"Font", @"Font Size", @"Font Color", @"Background Color", nil];
        
        NSDictionary *rows = [[NSDictionary alloc] initWithObjectsAndKeys:generalOptions, @"General", appearanceOptions, @"Appearance", nil];

        settingItems = [[NSDictionary alloc] initWithObjectsAndKeys:sections, @"Sections", rows, @"Rows", nil];

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

- (NSArray *)arrayOfRowsInSection:(NSInteger)section {
    NSString *sectionName = [[settingItems objectForKey:@"Sections"] objectAtIndex:section];
    return [[settingItems objectForKey:@"Rows"] objectForKey:sectionName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[settingItems objectForKey:@"Sections"] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [[self arrayOfRowsInSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(indexPath.section == 0 ? UITableViewCellStyleDefault : UITableViewCellStyleValue1) reuseIdentifier:CellIdentifier];
    }
    NSString *text = [[self arrayOfRowsInSection:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UISwitch *fullScreenSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [fullScreenSwitch addTarget:self action:@selector(setFullScreen:) forControlEvents:UIControlEventValueChanged];
        [fullScreenSwitch setOn:[UIApplication sharedApplication].statusBarHidden];
        cell.accessoryView = fullScreenSwitch;
    } else if (indexPath.section == 1) {
        NSString *detailTextLabelText;
        switch (indexPath.row) {
            case 0:
                detailTextLabelText = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontFamily"];
                break;
            case 1:
                detailTextLabelText = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontSize"];
                break;
            default:
                break;
        }
        cell.detailTextLabel.text = detailTextLabelText;
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[settingItems objectForKey:@"Sections"] objectAtIndex:section];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 1:
                [self facebookLogout];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        UIViewController *appearance = [[SettingsAppearanceController alloc] initWithIndexPath:indexPath];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        appearance.navigationItem.title = cell.textLabel.text;
        [self.navigationController pushViewController:appearance animated:YES];
    }
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

    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"fullScreen"];
    
    // update frame of app when removing statusBar
    // solution found here: stackoverflow.com/a/8768610
    //    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController] ;
    //    vc.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.parentViewController.parentViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
}

- (void) facebookLogout {
    [FBSession.activeSession closeAndClearTokenInformation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged Out of Facebook!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

@end
