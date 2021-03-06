//
//  GKImagePicker.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImagePicker.h"

#import "GKImageCropViewController.h"

@interface GKImagePicker ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, GKImageCropControllerDelegate>
@property (nonatomic, strong, readwrite) UIImagePickerController *imagePickerController;
- (void)_hideController;
@end

@implementation GKImagePicker{
    /** The scale mode for the image when cropping it. */
    GKScaleMode _scaleMode;
}

#pragma mark -
#pragma mark Getter/Setter

@synthesize cropSize, delegate;
@synthesize imagePickerController = _imagePickerController;


#pragma mark -
#pragma mark Init Methods

- (id)init{
    // For backwards compatibility, default to the photo library and aspect fit
    return [self initWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary scaleMode:GKScaleModeAspectFit];
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)sourceType scaleMode:(GKScaleMode)scaleMode{
    if (self = [super init]) {
        
        self.cropSize = CGSizeMake(320, 320);

        _scaleMode = scaleMode;
        
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = sourceType;
        
    }
    return self;
}

# pragma mark -
# pragma mark Private Methods

- (void)_hideController{
    
    if (![_imagePickerController.presentedViewController isKindOfClass:[UIPopoverController class]]){
        
        [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    } 
    
}

#pragma mark -
#pragma mark UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
      
        [self.delegate imagePickerDidCancel:self];
        
    } else {
        
        [self _hideController];
    
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{

    GKImageCropViewController *cropController = [[GKImageCropViewController alloc] initWithScaleMode:_scaleMode];
    cropController.contentSizeForViewInPopover = picker.contentSizeForViewInPopover;
    cropController.sourceImage = image;
    cropController.cropSize = self.cropSize;
    cropController.delegate = self;
    // Show the status bar again, or it won't come back if the picker gets dismissed
    // XXX This is a somewhat ugly workaround
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    [picker pushViewController:cropController animated:YES];
}

#pragma mark -
#pragma GKImagePickerDelegate

- (void)imageCropController:(GKImageCropViewController *)imageCropController didFinishWithCroppedImage:(UIImage *)croppedImage{
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
        [self.delegate imagePicker:self pickedImage:croppedImage];   
    }
}

@end
