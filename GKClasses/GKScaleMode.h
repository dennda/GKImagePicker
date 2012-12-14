//
//  GKScaleMode.h
//  Kiwi
//
//  Created by Christopher Denter on 12/14/12.
//  Copyright (c) 2012 Turntable. All rights reserved.
//

/** Define a type for the different ways we support for drawing the image to be cropped in crop mode. */
typedef enum {
    /** Scale the image to fit the crop region so the image does not extend beyond the crop region, while preserving the original aspect ratio. */
    GKScaleModeAspectFit = 0,

    /** Scale the image to fill the entire crop region extending beyond the crop region if necessary, while preserving the original aspect ratio. */
    GKScaleModeAspectFill = 1
} GKScaleMode;