//
//  GKImageCropView.h
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GKScaleMode.h"

@interface GKImageCropView : UIView

- (id)initWithFrame:(CGRect)frame scaleMode:(GKScaleMode)scaleMode;

@property (nonatomic, strong) UIImage *imageToCrop;
@property (nonatomic, assign) CGSize cropSize;

- (UIImage *)croppedImage;

@end
