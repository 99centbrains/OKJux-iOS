//
//  StickyImageView.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StickyImageView : UIImageView <UIGestureRecognizerDelegate>{
    CGPoint lastPoint;

    CGRect imageFrame;
}

- (void)flipImage;

- (void)setFrameForFrame;

@end
