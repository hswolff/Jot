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
        self.view.autoresizesSubviews = YES;
        
        CGRect viewFrame = self.view.frame;
        float staticPatchWidth = 140.0;
        float staticPatchHeight = 44.0;
        float staticPatchY = viewFrame.size.height-staticPatchHeight-10;
        
        float brightnessSliderHeight = 30.0;
        float brightnessSliderY = 360.0; //staticPatchY - brightnessSliderHeight - 10;
        
        colorPatch = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
        colorPatch.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if (indexPath.row == 2) {
            colorPatch.backgroundColor = [Constants fontColor];
            settingsAppearanceKey = @"fontColor";
        } else {
            colorPatch.backgroundColor = [Constants backgroundColor];
            settingsAppearanceKey = @"backgroundColor";
        }
        
        colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(10.0, 50.0, 300.0, 300.0)];
        colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [colorPicker setDelegate:self];
        [colorPicker setBrightness:1.0];
        [colorPicker setCropToCircle:NO]; // Defaults to YES (and you can set BG color)
        [colorPicker setBackgroundColor:[UIColor clearColor]];
        
        brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectMake(8.0, brightnessSliderY, 304.0, brightnessSliderHeight)];
        brightnessSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [brightnessSlider setColorPicker:colorPicker];
        [brightnessSlider setUseCustomSlider:YES]; // Defaults to NO
        
        UIView *blackPatch = [[UIView alloc] initWithFrame:CGRectMake(10.0, staticPatchY, staticPatchWidth, staticPatchHeight)];
        blackPatch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        blackPatch.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *blackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setToBlack:)];
        [blackPatch addGestureRecognizer:blackTap];
        
        UIView *whitePatch = [[UIView alloc] initWithFrame:CGRectMake(170.0, staticPatchY, staticPatchWidth, staticPatchHeight)];
        whitePatch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
        whitePatch.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *whiteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setToWhite:)];
        [whitePatch addGestureRecognizer:whiteTap];
        
        [self.view addSubview:colorPatch];
        [self.view addSubview:colorPicker];
        [self.view addSubview:brightnessSlider];
        [self.view addSubview:blackPatch];
        [self.view addSubview:whitePatch];
    }
    return self;
}

-(void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    if (!firstLoad) {
        firstLoad = YES;
    } else {
        colorPatch.backgroundColor = [cp selectionColor];
    }
}

- (void)setToBlack:(UITapGestureRecognizer *)sender {
    colorPatch.backgroundColor = [UIColor blackColor];
}

- (void)setToWhite:(UITapGestureRecognizer *)sender {
    colorPatch.backgroundColor = [UIColor whiteColor];
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


@end
