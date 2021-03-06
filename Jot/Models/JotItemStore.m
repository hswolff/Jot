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

+ (JotItemStore *) defaultStore {
    static JotItemStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self defaultStore];
}

- (id)init {
    self = [super init];
    if (self) {
        // read in Jot.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // where does the sqlite file go?
        NSString *path = [self itemArchivePath];

        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // the managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
        
        [self loadAllItems];
        
        self.currentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentIndex"];
    }
    return self;
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // get one and only one document directory from list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (NSArray *)allItems {
    return allItems;
}

- (JotItem *)createItem {
    double order;
    if ([allItems count] == 0) {
        order = 1.0;
    } else {
        order = [[allItems lastObject] orderingValue] + 1.0;
    }
    
//    NSLog(@"Adding after %d items, order = %.2f", [allItems count], order);


    JotItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"JotItem" inManagedObjectContext:context];
    p.orderingValue = order;
    p.text = @"";
    [allItems addObject:p];
    return p;
}

- (JotItem *)createItemWithText:(NSString *)text {
    JotItem *item = [self createItem];
    item.text = text;
    return item;
}

- (void)removeItem:(JotItem *)jotToDelete {
    [context deleteObject:jotToDelete];
    int indexOfDeletedJot = [allItems indexOfObject:jotToDelete];
    [allItems removeObjectIdenticalTo:jotToDelete];
    
    if (![allItems count]) {
        // if there are no jots left in the store
        self.currentIndex = -1;
    } else if (indexOfDeletedJot == 0) {
        // if you're deleting the jot that is currently selected
        // and it's at the top of the list
        // don't set index to less than 0
        self.currentIndex = 0;
    } else if (indexOfDeletedJot <= self.currentIndex) {
        // if you're deleting the jot that is before the currently selected jot
        self.currentIndex -= 1;
    }

}

- (BOOL)saveChanges {
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
//        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

- (void)loadAllItems {
    if (!allItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"JotItem"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        allItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (void)moveItemAtIndex:(int)from
                toIndex:(int)to
{
    if (from == to) {
        return;
    }
    // Get pointer to object being moved so we can re-insert it
    JotItem *p = [allItems objectAtIndex:from];
    
    // Remove p from array
    [allItems removeObjectAtIndex:from];
    
    // Insert p in array at new location
    [allItems insertObject:p atIndex:to];
    
    // Computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allItems objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[allItems objectAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    
    // Is there an object after it in the array?
    if (to < [allItems count] - 1) {
        upperBound = [[allItems objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allItems objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;

//    NSLog(@"to: %i", to);
//    NSLog(@"newOrderValue: %f", newOrderValue);
    [p setOrderingValue:newOrderValue];
    if (self.currentIndex == from) {
        // if we're moving the currentIndex item then we have to
        // update the currentIndex to the to location
        self.currentIndex = to;
    } else if (self.currentIndex < from && self.currentIndex >= to) {
        // if we're moving an item after the currentIndex
        // to the currentIndex location or before it we have to
        // increase the currentIndex position by 1
        self.currentIndex++;
    } else if (self.currentIndex > from && self.currentIndex <= to) {
        // if we're moving an item before the currentIndex
        // to the currentIndex location or after it we have to
        // decrease the currentIndex position by 1
        self.currentIndex--;
    }
}

- (JotItem *)getCurrentItem {
    if ([allItems count] > 0) {
        return [allItems objectAtIndex:self.currentIndex];
    } else {
        return nil;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:currentIndex forKey:@"currentIndex"];
}

@end
