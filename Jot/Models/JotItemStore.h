//
//  JotItemStore.h
//  Jot
//
//  Created by Harry Wolff on 9/26/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JotItem;

@interface JotItemStore : NSObject {
    NSMutableArray *allItems;
    
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (JotItemStore *) sharedStore;

- (NSArray *)allItems;
- (JotItem *)createItem;
- (void)removeItem:(JotItem *)item;

- (BOOL)saveChanges;

- (NSString *)itemArchivePath;

- (void)loadAllItems;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

@end
