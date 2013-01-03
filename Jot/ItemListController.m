//
//  JotListViewController.m
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import "Constants.h"
#import "ItemListController.h"
#import "JotItem.h"
#import "Models/JotItemStore.h"
#import "IIViewDeckController.h"
#import "ItemViewController.h"

@implementation ItemListController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        self.navigationItem.title = @"Jots";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewItem:)];
        
        self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:[self editButtonItem], addButton, nil];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[JotItemStore defaultStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemListCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    JotItemStore *defaultStore = [JotItemStore defaultStore];
    JotItem *p = [[defaultStore allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[p description]];
    if (indexPath.row == [defaultStore currentIndex]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)selectJot:(JotItem *)jot andOpen:(BOOL)open
{
    int lastRow = [[[JotItemStore defaultStore] allItems] indexOfObject:jot];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [[JotItemStore defaultStore] setCurrentIndex:ip.row];
    
    [self.tableView selectRowAtIndexPath:ip animated:YES
                          scrollPosition:(open? UITableViewScrollPositionTop: UITableViewScrollPositionNone)];
    
    if (open) {
        [self.viewDeckController closeLeftViewAnimated:YES];
    }
}


- (void)addNewItem:(id)sender {
    JotItem *newItem = [[JotItemStore defaultStore] createItem];
    int lastRow = [[[JotItemStore defaultStore] allItems] indexOfObject:newItem];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];

    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                          withRowAnimation:UITableViewRowAnimationTop];
    [self selectJot:newItem andOpen:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.viewDeckController setLeftSize:0];
    } else {
        [self.viewDeckController setLeftSize:LEFT_LEDGE_SIZE completion:^(BOOL finished){
            [self.tableView reloadData];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[JotItemStore defaultStore] setCurrentIndex:indexPath.row];
    [self.viewDeckController closeLeftViewAnimated:YES];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JotItemStore *itemStore = [JotItemStore defaultStore];
        NSArray *items = [itemStore allItems];
        JotItem *p = [items objectAtIndex:[indexPath row]];
        [itemStore removeItem:p];
        
        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        int currentIndex = [itemStore currentIndex];
        if (currentIndex >= 0) {
            [self selectJot:[items objectAtIndex:currentIndex] andOpen:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    [[JotItemStore defaultStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

- (void)showHowToUseInstructions {
    NSString *instructionsText = @"Welcome to Jot!\n\
\n\
Let me show you around:\n\
\n\
Here is where you read and write your Jot.\n\
\n\
Swipe down on the keyboard to hide it.\n\
\n\
Swipe to the right to see your list of Jots.\n\
\n\
Swipe to the left to see actions you can perform on your Jot.\n\
\n\
And that's it!\n\
\n\
Thank you for using Jot. :)";
    JotItem *jot = [[JotItemStore defaultStore] createItemWithText:instructionsText];
    [self selectJot:jot andOpen:NO];
}



- (void)showUpgradeMessageAndOpen:(BOOL)open {
    NSString *upgradeText = @"\
1.0.0\n\
------\n\
Initial Release!\n\
Add, remove, re-arrange Jots\n\
Hide keyboard by swiping down\n\
Share Jots to Twitter and Facebook\n\
Make the app go full screen\n\
Killed all the bugs (I found)\n\
Did the happy dance";

    JotItem *jot = [[JotItemStore defaultStore] createItemWithText:upgradeText];
    [self selectJot:jot andOpen:open];
}

@end
