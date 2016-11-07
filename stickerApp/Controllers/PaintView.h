//
//  PaintView.h
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintView : UIView {
    void *cacheBitmap;
    CGContextRef cacheContext;
    float hue;
    
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
    NSString *colorType;
    BOOL eraser;
    
    NSTimer *touchTimer;
}
- (BOOL) initContext:(CGSize)size;
- (void) setImageBackground:(UIImage*)image;

- (void) drawToCache;
- (void) clearAll;

@property (nonatomic, retain) NSTimer *touchTimer;

- (void)addLoop;
- (void)handleAction:(id)timerObj;

@property (nonatomic) BOOL eraser;
@property (nonatomic) BOOL imagepainting;
@property (nonatomic) NSString *colorType;
@property (nonatomic) int strokeSize;

@property (nonatomic, strong) UIColor *brushcolor;
@property (nonatomic, strong) UIImage *imagePattern;
@end
