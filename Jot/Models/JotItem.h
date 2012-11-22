//
//  JotFile.h
//  Jot
//
//  Created by Harry Wolff on 9/24/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JotItem : NSManagedObject
//@interface JotItem : NSObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic) double orderingValue;

@property (nonatomic, retain) NSMutableArray *shared;
//+ (id)randomItem;
//- (id)initWithText:(NSString *)text;
- (NSString *)description;

@end
