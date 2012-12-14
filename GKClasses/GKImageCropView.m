//
//  GKImageCropView.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropView.h"
#import "GKImageCropOverlayView.h"

#import <QuartzCore/QuartzCore.h>

@interface ScrollView : UIScrollView
@end

@implementation ScrollView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    zoomView.frame = frameToCenter;
}

@end

@interface GKImageCropView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) GKImageCropOverlayView *cropOverlayView;
@end

@implementation GKImageCropView {
    /** The scale mode for the image when cropping it. */
    GKScaleMode _scaleMode;
}

#pragma mark -
#pragma Getter/Setter

@synthesize scrollView, imageView, cropOverlayView;

- (void)setImageToCrop:(UIImage *)imageToCrop{
    self.imageView.image = imageToCrop;
}

- (UIImage *)imageToCrop{
    return self.imageView.image;
}

- (void)setCropSize:(CGSize)cropSize{
    self.cropOverlayView.cropSize = cropSize;
}

- (CGSize)cropSize{
    return self.cropOverlayView.cropSize;
}

#pragma mark -
#pragma Public Methods

- (UIImage *)croppedImage{
    
    //renders the the zoomed area into the cropped image
    UIGraphicsBeginImageContextWithOptions(self.scrollView.frame.size, self.scrollView.opaque, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -self.scrollView.contentOffset.x, -self.scrollView.contentOffset.y);
    
    [self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

#pragma mark -
#pragma Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        
        self.scrollView = [[ScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.opaque = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.decelerationRate = 0.0; 
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:self.imageView];
        
        self.cropOverlayView = [[GKImageCropOverlayView alloc] initWithFrame:self.bounds];
        [self addSubview:self.cropOverlayView];
        
        self.scrollView.minimumZoomScale = CGRectGetWidth(self.scrollView.frame) / CGRectGetWidth(self.imageView.frame);
        self.scrollView.maximumZoomScale = 4.0;
        [self.scrollView setZoomScale:1.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame scaleMode:(GKScaleMode)scaleMode{
    self = [self initWithFrame:frame];
    if (!self) {
        return self;
    }

    _scaleMode = scaleMode;

    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return self.scrollView;
}

- (void)layoutSubviewsForAspectFill{
    // Calculate the offsets for the scrollview to fit behind the cropped region.
    // The image will still be drawn outside given that clipsToBounds is set to NO.
    CGSize cropSize = self.cropSize;
    CGFloat xOffset = floor((CGRectGetWidth(self.bounds) - cropSize.width) * 0.5);
    CGFloat yOffset = floor((CGRectGetHeight(self.bounds) - cropSize.height) * 0.5);

    CGFloat imageWidth = self.imageToCrop.size.width;
    CGFloat imageHeight = self.imageToCrop.size.height;

    CGFloat scale = 0.f;
    CGFloat scaledWidth = 0.f;
    CGFloat scaledHeight = 0.f;

    // Scale the image so it always fills up the crop rect and there's no empty space
    scale = MAX(cropSize.width, cropSize.height) / MIN(imageWidth, imageHeight);
    scaledWidth = imageWidth * scale;
    scaledHeight = imageHeight * scale;

    self.cropOverlayView.frame = self.bounds;
    self.scrollView.frame = CGRectMake(xOffset, yOffset, cropSize.width, cropSize.height);
    self.scrollView.contentSize = CGSizeMake(scaledWidth, scaledHeight);
    self.imageView.frame = CGRectMake(0, floor((cropSize.height - scaledHeight) * 0.5), scaledWidth, scaledHeight);

    // Make sure the zoom scale is set such that no empty space can be in the crop region
    self.scrollView.minimumZoomScale = MAX(self.scrollView.frame.size.width / scaledWidth,
                                           self.scrollView.frame.size.height / scaledHeight);
}

- (void)layoutSubviewsForAspectFit{
    CGSize size = self.cropSize;
    CGFloat xOffset = floor((CGRectGetWidth(self.bounds) - size.width) * 0.5);
    CGFloat yOffset = floor((CGRectGetHeight(self.bounds) - size.height) * 0.5);

    CGFloat height = self.imageToCrop.size.height;
    CGFloat width = self.imageToCrop.size.width;
    
    CGFloat faktor = 0.f;
    CGFloat faktoredHeight = 0.f;
    CGFloat faktoredWidth = 0.f;
    
    if(width > height){
        
        faktor = width / size.width;
        faktoredWidth = size.width;
        faktoredHeight =  height / faktor;
        
    } else {
        
        faktor = height / size.height;
        faktoredWidth = width / faktor;
        faktoredHeight =  size.height;
    }
    
    self.cropOverlayView.frame = self.bounds;
    self.scrollView.frame = CGRectMake(xOffset, yOffset, size.width, size.height);
    self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    self.imageView.frame = CGRectMake(0, floor((size.height - faktoredHeight) * 0.5), faktoredWidth, faktoredHeight);
}

- (void) layoutSubviews{
    [super layoutSubviews];

    if (_scaleMode == GKScaleModeAspectFit) {
        [self layoutSubviewsForAspectFit];
    } else if (_scaleMode == GKScaleModeAspectFill) {
        [self layoutSubviewsForAspectFill];
    } else {
        assert("Invalid value provided for scaleMode" && 0);
    }
}

#pragma mark -
#pragma UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end
