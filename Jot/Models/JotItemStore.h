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
    
    NSInteger currentIndex;
}

+ (JotItemStore *) defaultStore;

- (NSArray *)allItems;
- (JotItem *)createItem;
- (JotItem *)createItemWithText:(NSString *)text;
- (void)removeItem:(JotItem *)item;

- (BOOL)saveChanges;

- (NSString *)itemArchivePath;

- (void)loadAllItems;

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to;

- (void)setCurrentItem:(NSInteger)i;

- (JotItem *)getCurrentItem;

- (NSInteger)currentIndex;
@end
