//
//  SettingsAppearanceController.m
//  Jot
//
//  Created by Harry Wolff on 1/7/13.
//
//

#import "SettingsAppearanceController.h"

@interface SettingsAppearanceController ()

@end

@implementation SettingsAppearanceController

- (id)initWithIndexPath:(NSIndexPath *)indexPath
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        switch (indexPath.row) {
            case 0:
                settingsAppearanceKey = @"fontFamily";
                newOptions = [[NSArray alloc] initWithObjects:@"Arial", @"Baskerville", @"Georgia", @"Helvetica", @"Palatino", @"Verdana", nil];
                break;
            case 1:
                settingsAppearanceKey = @"fontSize";
                newOptions = @[@15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Panda";
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [newOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [newOptions objectAtIndex:indexPath.row]];
    
    if ([settingsAppearanceKey isEqualToString:@"fontFamily"]) {
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.text size:20];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentSetting = [NSString stringWithFormat:@"%@", [userDefaults objectForKey:settingsAppearanceKey]];
    if ([cell.textLabel.text isEqualToString:currentSetting]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *newPreference = [newOptions objectAtIndex:indexPath.row];
    [userDefaults setObject:newPreference forKey:settingsAppearanceKey];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
