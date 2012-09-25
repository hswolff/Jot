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
        self.tableView.backgroundColor = [UIColor lightGrayColor];
        
        for (int i = 0; i < 10; i++) {
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

@end
