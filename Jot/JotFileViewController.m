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
}

@end
