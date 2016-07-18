//
//  CBCropViewController.h
//  StickyApp
//
//  Created by 99centbrains on 10/22/13.
//  Copyright (c) 2013 99centbrains. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBCropViewController;
@protocol CBCropViewControllerDelegate <NSObject>

- (void)photoCropUseImage:(CBCropViewController*)controller withImage:(UIImage*)image;

@end

@interface CBCropViewController : UIViewController


@property (nonatomic, strong)UIImage *userImage;

@property (nonatomic, assign) id <CBCropViewControllerDelegate> delegate;

@end
