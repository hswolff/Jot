//
//  SettingsColorController.h
//  Jot
//
//  Created by Harry Wolff on 2/23/13.
//
//

#import <UIKit/UIKit.h>
#import "RSColorPickerView.h"
#import "RSBrightnessSlider.h"

@interface SettingsColorController : UIViewController <RSColorPickerViewDelegate> {
    NSString *settingsAppearanceKey;
    
    RSColorPickerView *colorPicker;
	RSBrightnessSlider *brightnessSlider;
    UIView *colorPatch;
}

- (id)initWithIndexPath:(NSIndexPath *)indexPath;

@end
