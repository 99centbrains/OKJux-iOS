//
//  StickyImageView.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StickyImageView.h"



@implementation StickyImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        
        
    }
    return self;
}

- (void)setFrameForFrame{
    //self.image = [self imageWithImage:self.image scaledToSize:CGSizeMake(500, 500)];
    imageFrame = self.frame;
    NSLog(@"IMAGE FRAME %@", NSStringFromCGRect(imageFrame));
    NSLog(@"IMAGE SIZE %@", NSStringFromCGSize(self.image.size));

}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    NSLog(@"IMAGE FRAME %@", NSStringFromCGRect(self.frame));
//    //NSLog(@"IMAGE SIZE %@", NSStringFromCGSize(self.image.size));
//    
//    UITouch *touch = [touches anyObject];
//    NSLog(@"Touch %@", NSStringFromCGPoint([touch locationInView:self]));
//   lastPoint = [touch locationInView:self];
//
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//   // CGPoint lastPoint;
//    
//    UITouch *touch = [touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self];
//    
//
//    int scale = [[UIScreen mainScreen] scale];
//    
//    UIGraphicsBeginImageContextWithOptions(imageFrame.size, NO, scale);
//    [self.image drawInRect:CGRectMake(0, 0, imageFrame.size.width, imageFrame.size.height)];
//    
//    CGContextSaveGState(UIGraphicsGetCurrentContext());
//    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 40.0);
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, nil, lastPoint.x , lastPoint.y );
//    CGPathAddLineToPoint(path, nil, currentPoint.x , currentPoint.y );
//    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
//    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
//    CGContextStrokePath(UIGraphicsGetCurrentContext());
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    CGContextRestoreGState(UIGraphicsGetCurrentContext());
//    UIGraphicsEndImageContext();
//    
//     lastPoint = currentPoint;
//    
//    self.image = image;
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"TOUCHING ENDED");
    //lastPoint = 0;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SetCurrentStickerNotification"
     object:self];
    
    
}

//static CGPoint lastTouch;
//static CGPoint currentTouch;
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    UITouch *touch = [touches anyObject];
//    currentTouch = [touch locationInView:self];
//    
//    CGFloat brushSize;
//    brushSize = 20;
//    
//    CGColorRef strokeColor = [UIColor whiteColor].CGColor;
//    
//    UIGraphicsBeginImageContext(self.frame.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineWidth(context, brushSize);
//    
////    if (isEraser) {
////        
////        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor colorWithPatternImage:self.im].CGColor);
////    }
////    else
////    {
////        CGContextSetStrokeColorWithColor(context, strokeColor);
////        CGContextSetBlendMode(context, kCGBlendModeClear);
////    }
//
//    CGContextSetStrokeColorWithColor(context, strokeColor);
//    CGContextSetBlendMode(context, kCGBlendModeClear);
//    //
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, lastTouch.x, lastTouch.y);
//    CGContextAddLineToPoint(context, currentTouch.x, currentTouch.y);
//    CGContextStrokePath(context);
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    lastTouch = [touch locationInView:self];
//    
//    
//}
- (void)flipImage{

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
