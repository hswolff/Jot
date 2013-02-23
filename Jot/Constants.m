//
//  Constants.m
//  Jot
//
//  Created by Harry Wolff on 12/9/12.
//
//

#import "Constants.h"


@implementation Constants

+ (UIFont *)fontSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fontFamily = [userDefaults stringForKey:@"fontFamily"];
    double fontSize = [userDefaults doubleForKey:@"fontSize"];
    return [UIFont fontWithName:fontFamily size:fontSize];
}

+ (UIColor *)backgroundColor {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

+ (UIColor *)fontColor {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontColor"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

@end