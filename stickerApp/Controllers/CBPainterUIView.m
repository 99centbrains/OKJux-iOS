//
//  TSignatureView.m
//  TSignature
//
//  Created by T. A. Weerasooriya on 3/20/14.
//  Copyright (c) 2014 T. A. Weerasooriya. All rights reserved.
//

#import "CBPainterUIView.h"
#import <QuartzCore/QuartzCore.h>

@interface CBPainterUIView (){
    
    NSMutableArray *paths;
    UIBezierPath *currentPath;

    CGContextRef cacheContext;
    void *cacheBitmap;


}

@end

// pi is approximately equal to 3.14159265359.
#define   DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

@implementation CBPainterUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        (void)[self initContext:frame.size];
        // Initialization code
    }
    return self;
}

- (void)dealloc{
    paths = nil;
    
}

- (BOOL) initContext:(CGSize)size {
    
    float scale = [[UIScreen mainScreen] scale];
    
    int bitmapByteCount;
    int	bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (size.width  * 4 * scale);
    bitmapByteCount = (bitmapBytesPerRow * size.height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    cacheBitmap = malloc( bitmapByteCount );
    if (cacheBitmap == NULL){
        return NO;
    }
    
    
    cacheContext = CGBitmapContextCreate (NULL, size.width * scale, size.height * scale, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    
    CGContextScaleCTM(cacheContext, scale, scale);// <- DOES NOTHING
    
    CGContextSetRGBFillColor(cacheContext, 1.0, 1.0, 1.0, 0.0);
    //CGContextSetRGBStrokeColor(cacheContext, 1.0, 0.0, 1.0, 1.0);
    //CGContextSetLineWidth(cacheContext, 10.0f);
    
    //CGContextStrokeRect(cacheContext, CGRectMake(0, 0, size.width, size.height));
    CGContextFillRect(cacheContext, CGRectMake(0, 0, size.width, size.height));

    return YES;
}

#pragma mark - Drawing code

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, self.frame);
    
    [_brushcolor set];
    
    UIBezierPath *path = [paths lastObject];
    [path stroke];
    
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
    

//    //
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextFillRect(context, self.frame);
//    
//    [_brushcolor set];
//    
//    UIBezierPath *path = [paths lastObject];
//    [path stroke];
//    for (UIBezierPath *path in paths) {
//        
//    }
    
    NSLog(@"Drawing");
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    // Get the specific point that was touched
    if (CGRectContainsPoint(self.frame, [touch locationInView:self])) {
        
        if (!paths) {
            paths = [[NSMutableArray alloc]init];
        }
        
        currentPath = [UIBezierPath bezierPathWithArcCenter:[touch locationInView:self]
                                                             radius:1
                                                         startAngle:0
                                                           endAngle:DEGREES_TO_RADIANS(360)
                                                          clockwise:YES];
        
        currentPath.lineWidth = 20;
        currentPath.lineCapStyle =  kCGLineCapRound;
        currentPath.lineJoinStyle = kCGLineJoinRound;
        [currentPath moveToPoint:[touch locationInView:self]];
        [paths addObject:currentPath];
        
        NSLog(@"PathCount %d", [paths count]);
        
        [self setNeedsDisplay];

    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    // Get the specific point that was touched
    if (CGRectContainsPoint(self.frame, [touch locationInView:self])) {
        [currentPath addLineToPoint:[touch locationInView:self]];
        [self setNeedsDisplay];
        
        
    }
}



#pragma mark -

- (IBAction)btnClearTapped:(id)sender{
    if (paths) {
        [paths removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)setBrushcolor:(UIColor *)brushcolor{
    
    _brushcolor = brushcolor;

}

- (void) action_undoLastStroke{
    
}

@end
