//
//  SettingsColorController.m
//  Jot
//
//  Created by Harry Wolff on 2/23/13.
//
//

#import "SettingsColorController.h"
#import "Constants.h"

@interface SettingsColorController ()

@end

@implementation SettingsColorController

- (id)initWithIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        
        colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(10.0, 40.0, 300.0, 300.0)];
        [colorPicker setDelegate:self];
        [colorPicker setBrightness:1.0];
        [colorPicker setCropToCircle:NO]; // Defaults to YES (and you can set BG color)
        [colorPicker setBackgroundColor:[UIColor clearColor]];
        
        brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectMake(10.0, 360.0, 300.0, 30.0)];
        [brightnessSlider setColorPicker:colorPicker];
        [brightnessSlider setUseCustomSlider:YES]; // Defaults to NO
        
        colorPatch = [[UIView alloc] initWithFrame:CGRectMake(10.0, 400.0, 300.0, 30.0)];
        if (indexPath.row == 2) {
            colorPatch.backgroundColor = [Constants fontColor];
            settingsAppearanceKey = @"fontColor";
        } else {
            colorPatch.backgroundColor = [Constants backgroundColor];
            settingsAppearanceKey = @"backgroundColor";
        }
        
        [self.view addSubview:colorPicker];
        [self.view addSubview:brightnessSlider];
        [self.view addSubview:colorPatch];
    }
    return self;
}

-(void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
	colorPatch.backgroundColor = [cp selectionColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:colorPatch.backgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:settingsAppearanceKey];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
