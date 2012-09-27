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
#import "JotViewController.h"

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
        
//        UIBarButtonItem *bbiLeft = [[UIBarButtonItem alloc]
//                                initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
//                                target:self
//                                action:@selector(editItems)];
//        self.navigationItem.leftBarButtonItem = bbiLeft;
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewItem:)];
        self.navigationItem.leftBarButtonItem = bbi;
        
        for (int i = 0; i < 5; i++) {
            [[JotItemStore sharedStore] createItem];
        }
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

- (void) editItems {
    NSLog(@"Hwaaaa");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
    NSArray *items = [[JotItemStore sharedStore] allItems];
    JotItem *selectedItem = [items objectAtIndex:[indexPath row]];
    [(JotViewController *)self.viewDeckController.centerController setText:selectedItem.text];
    [self.viewDeckController closeLeftViewBouncing:nil];
}

@end
