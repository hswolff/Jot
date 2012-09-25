//
//  JotItemStore.m
//  Jot
//
//  Created by Harry Wolff on 9/26/12.
//
//

#import "JotItemStore.h"
#import "JotItem.h"

@implementation JotItemStore

+ (JotItemStore *) sharedStore {
    static JotItemStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

- (id)init {
    self = [super init];
    if(self) {
        allItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems {
    return allItems;
}

- (JotItem *)createItem {
    JotItem *p = [JotItem randomItem];
    
    [allItems addObject:p];
    
    return p;
}

@end
