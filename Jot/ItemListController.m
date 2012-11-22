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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ItemListCell";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
//        cell.textLabel.font = [UIFont fontWithName:@"Palatino" size:20.0];
    }
    JotItem *p = [[[JotItemStore defaultStore] allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[p description]];
    return cell;
}


- (void)addNewItem:(id)sender {
    JotItem *newItem = [[JotItemStore defaultStore] createItem];
    
    int lastRow = [[[JotItemStore defaultStore] allItems] indexOfObject:newItem];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                            withRowAnimation:UITableViewRowAnimationTop];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.viewDeckController setLeftSize:0];
    } else {
        [self.viewDeckController setLeftSize:LEFT_LEDGE_SIZE];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    NSArray *items = [[JotItemStore defaultStore] allItems];
    JotItem *selectedItem = [items objectAtIndex:[indexPath row]];
    [[JotItemStore defaultStore] setCurrentItem:indexPath.row];
    [(ItemViewController *)self.viewDeckController.centerController setItem:selectedItem];
    [self.viewDeckController closeLeftViewAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JotItemStore *ps = [JotItemStore defaultStore];
        NSArray *items = [ps allItems];
        JotItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        
        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
//        [[JotItemStore defaultStore] setCurrentItem:nil];
        [(ItemViewController *)self.viewDeckController.centerController setItem:nil];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    [[JotItemStore defaultStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

@end
