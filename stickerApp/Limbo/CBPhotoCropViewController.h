//
//  CBPhotoCropViewController.h
//  thecreator
//
//  Created by Franky Aguilar on 1/7/13.
//  Copyright (c) 2013 99centbrains. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPhotoCropViewController;
@protocol CBPhotoCropViewControllerDelegate <NSObject>

- (void)photoRetakeImage:(CBPhotoCropViewController*)controller;
- (void)photoCropUseImage:(CBPhotoCropViewController*)controller withImage:(UIImage*)image;

@end

@interface CBPhotoCropViewController : UIViewController{

}

@property (nonatomic, strong)UIImage* userImage;
@property (nonatomic, strong)UIImage* userImageOverlay;

@property (nonatomic) CGRect cropRectangle;

@property (nonatomic, assign) id <CBPhotoCropViewControllerDelegate> delegate;

@end
