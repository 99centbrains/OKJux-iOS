//
//  CBVideoCaptureViewController.h
//  OMFGif
//
//  Created by 99centbrains on 2/27/14.
//  Copyright (c) 2014 99centbrains. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class CBImagePickerViewController;

@protocol CBImagePickerViewControllerDelegate <NSObject>

- (void)cbVideoCaptureDidDismiss:(CBImagePickerViewController *)sender;
- (void)cbVideoCaptureDidFinish:(CBImagePickerViewController *)sender withImage:(UIImage *)image;
- (void)cbVideoCaptureDidFinishBlank:(CBImagePickerViewController *)sender;

@end


@interface CBImagePickerViewController : OkJuxViewController

@property (nonatomic, unsafe_unretained) id <CBImagePickerViewControllerDelegate> delegate;

@end
