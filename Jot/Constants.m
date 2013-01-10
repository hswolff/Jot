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
    NSString *color = [[NSUserDefaults standardUserDefaults] stringForKey:@"backgroundColor"];
    UIColor *backgroundColor = nil;
    if ([color isEqualToString:@"gray"]) {
        backgroundColor = [UIColor grayColor];
    } else {
        backgroundColor = [UIColor whiteColor];
    }
    return backgroundColor;
}

@end