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
    }
    JotItem *p = [[[JotItemStore defaultStore] allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[p description]];
    if (indexPath.row == [[JotItemStore defaultStore] currentIndex]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)selectJot:(JotItem *)jot {
    int lastRow = [[[JotItemStore defaultStore] allItems] indexOfObject:jot];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [self selectRowAtIndexPath:ip andAnimateTableViewScrollPosition:YES];
}


- (void)addNewItem:(id)sender {
    JotItem *newItem = [[JotItemStore defaultStore] createItem];
    int lastRow = [[[JotItemStore defaultStore] allItems] indexOfObject:newItem];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                            withRowAnimation:UITableViewRowAnimationTop];
    [self selectRowAtIndexPath:ip andAnimateTableViewScrollPosition:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.viewDeckController setLeftSize:0];
    } else {
        [self.viewDeckController setLeftSize:LEFT_LEDGE_SIZE completion:^(BOOL finished){
            [self.tableView reloadData];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    [self selectRowAtIndexPath:indexPath andAnimateTableViewScrollPosition:NO];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath andAnimateTableViewScrollPosition:(BOOL)animateTableViewScrollPosition {
    NSArray *items = [[JotItemStore defaultStore] allItems];
    JotItem *selectedItem = [items objectAtIndex:[indexPath row]];
    [[JotItemStore defaultStore] setCurrentItem:indexPath.row];
    [(ItemViewController *)self.viewDeckController.centerController setItem:selectedItem];
    [self.viewDeckController closeLeftViewAnimated:YES];
    
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:YES
                          scrollPosition:(animateTableViewScrollPosition? UITableViewScrollPositionTop : UITableViewScrollPositionNone)];
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
            [self selectJot:[items objectAtIndex:currentIndex]];
        } else {
            [self addNewItem:nil];
        }
        
    
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    [[JotItemStore defaultStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

@end
