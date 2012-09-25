//
//  JotItemStore.h
//  Jot
//
//  Created by Harry Wolff on 9/26/12.
//
//

#import <Foundation/Foundation.h>

@class JotItem;

@interface JotItemStore : NSObject {
    NSMutableArray *allItems;
}

+ (JotItemStore *) sharedStore;

- (NSArray *)allItems;
- (JotItem *)createItem;

@end
