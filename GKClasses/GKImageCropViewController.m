//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "GKImageCropView.h"

// from http://stackoverflow.com/questions/7848766
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *useButton;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton;

#pragma mark -
#pragma Private Methods


- (void)_actionCancel{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)_actionUse{
    _croppedImage = [self.imageCropView croppedImage];
    [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
}


- (void)_setupNavigationBar{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(_actionCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"GKIuse", @"") 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(_actionUse)];
}


- (void)_setupCropView{
    
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    [self.imageCropView setImageToCrop:sourceImage];
    [self.imageCropView setCropSize:cropSize];
    
    [self.view addSubview:self.imageCropView];
}

- (void)_setupCancelButton{
    NSString *title = NSLocalizedString(@"GKIcancel",nil);

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(_actionCancel)];
    }
    else {
        UIButton *containedCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [containedCancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        [containedCancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
        [[containedCancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
        [[containedCancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        [containedCancelButton setFrame:CGRectMake(0, 0, 50, 30)];
        [containedCancelButton setTitle:title forState:UIControlStateNormal];
        [containedCancelButton setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
        [containedCancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
        [containedCancelButton addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton = [[UIBarButtonItem alloc] initWithCustomView:containedCancelButton];
    }
}

- (void)_setupUseButton{
    NSString *title = NSLocalizedString(@"GKIuse",@"");

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        self.useButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(_actionUse)];
        self.useButton.tintColor = [UIColor colorWithRed:0.06 green:0.31 blue:0.83 alpha:1.];
    }
    else {
        UIButton *containedUseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [containedUseButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
        [containedUseButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
        [[containedUseButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
        [[containedUseButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];
        [containedUseButton setFrame:CGRectMake(0, 0, 50, 30)];
        [containedUseButton setTitle:title forState:UIControlStateNormal];
        [containedUseButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
        [containedUseButton addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
        self.useButton = [[UIBarButtonItem alloc] initWithCustomView:containedUseButton];
    }
}

- (UIImage *)_toolbarBackgroundImage{
    CGFloat components[] = {
        1., 1., 1., 1.,
        123./255., 125/255., 132./255., 1.
    };

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 54), YES, 0.0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, 54), kCGImageAlphaNoneSkipFirst);

    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return viewImage;
}

- (void)_setupToolbar{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [self.view addSubview:self.toolbar];
        
        [self _setupCancelButton];
        [self _setupUseButton];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectZero];
        info.text = NSLocalizedString(@"GKImoveAndScale", @"");
        info.backgroundColor = [UIColor clearColor];
        info.font = [UIFont boldSystemFontOfSize:18];
        info.shadowOffset = CGSizeMake(0, 1);
        [info sizeToFit];

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            // Use a dark iOS 5+ inspired style
            self.toolbar.barStyle = UIBarStyleBlackTranslucent;
            info.textColor = [UIColor colorWithWhite: 0.91 alpha: 1.];
            info.shadowColor = [UIColor colorWithWhite: 0.06 alpha: 1.];
        }
        else {
            info.textColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.173 alpha:1];
            info.shadowColor = [UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1];
            [self.toolbar setBackgroundImage:[self _toolbarBackgroundImage] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }

        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView:info];
        
        [self.toolbar setItems:[NSArray arrayWithObjects:self.cancelButton, flex, lbl, flex, self.useButton, nil]];
    }
}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"GKIchoosePhoto", @"");

    [self _setupNavigationBar];
    [self _setupCropView];
    [self _setupToolbar];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.imageCropView.frame = self.view.bounds;
    self.toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 54, 320, 54);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
