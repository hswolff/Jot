//
//  JotListViewController.m
//  Jot
//
//  Created by Harry Wolff on 9/1/12.
//
//

#import "JotItemListController.h"
#import "JotItem.h"
#import "Models/JotItemStore.h"
#import "ViewDeck/IIViewDeckController.h"
#import "JotItemViewController.h"

@interface FileList : UITableView <UIGestureRecognizerDelegate>
@end

@implementation FileList
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}
@end


@implementation JotItemListController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView = [FileList new];
        self.tableView.backgroundColor = [UIColor whiteColor];
        
        self.navigationItem.title = @"Jot Files";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewItem:)];
        
        self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:[self editButtonItem], addButton, nil];
    }
    return self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[JotItemStore sharedStore] allItems] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"UITableViewCell"];
    }
    JotItem *p = [[[JotItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[p description]];
    return cell;
}


- (void) addNewItem:(id)sender {
    JotItem *newItem = [[JotItemStore sharedStore] createItem];
    
    int lastRow = [[[JotItemStore sharedStore] allItems] indexOfObject:newItem];
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                            withRowAnimation:UITableViewRowAnimationTop];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.viewDeckController setLeftLedge:0];
    } else {
        [self.viewDeckController setLeftLedge:92.0];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    NSArray *items = [[JotItemStore sharedStore] allItems];
    JotItem *selectedItem = [items objectAtIndex:[indexPath row]];
    [(JotItemViewController *)self.viewDeckController.centerController setItem:selectedItem];
    [self.viewDeckController closeLeftViewBouncing:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JotItemStore *ps = [JotItemStore sharedStore];
        NSArray *items = [ps allItems];
        JotItem *p = [items objectAtIndex:[indexPath row]];
        [ps removeItem:p];
        
        // We also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    [[JotItemStore sharedStore] moveItemAtIndex:[fromIndexPath row]
                                         toIndex:[toIndexPath row]];
}

@end
