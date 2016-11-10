//
//  StickyImageView.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StickyImageView.h"



@implementation StickyImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
    }
  
    return self;
}

- (void)setFrameForFrame {
    //self.image = [self imageWithImage:self.image scaledToSize:CGSizeMake(500, 500)];
    imageFrame = self.frame;
    NSLog(@"IMAGE FRAME %@", NSStringFromCGRect(imageFrame));
    NSLog(@"IMAGE SIZE %@", NSStringFromCGSize(self.image.size));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter]
      postNotificationName:@"SetCurrentStickerNotification"
                    object:self];
}

- (void)flipImage {
    UIImage * flippedImage;
    if (self.image.imageOrientation == UIImageOrientationUpMirrored) {
        flippedImage = [UIImage imageWithCGImage:self.image.CGImage scale:self.image.scale orientation:UIImageOrientationUp];
    } else {
        flippedImage = [UIImage imageWithCGImage:self.image.CGImage scale:self.image.scale orientation:UIImageOrientationUpMirrored];
    }
  
    self.image = flippedImage;
    flippedImage = nil;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
