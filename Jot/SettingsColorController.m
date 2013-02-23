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
        
        brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectMake(10.0, 370.0, 300.0, 30.0)];
        brightnessSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [brightnessSlider setColorPicker:colorPicker];
        [brightnessSlider setUseCustomSlider:YES]; // Defaults to NO
        
        UIView *blackPatch = [[UIView alloc] initWithFrame:CGRectMake(10.0, 410.0, 140.0, 30.0)];
        blackPatch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        blackPatch.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *blackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setToBlack:)];
        [blackPatch addGestureRecognizer:blackTap];
        
        UIView *whitePatch = [[UIView alloc] initWithFrame:CGRectMake(170.0, 410.0, 140.0, 30.0)];
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
	colorPatch.backgroundColor = [cp selectionColor];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
