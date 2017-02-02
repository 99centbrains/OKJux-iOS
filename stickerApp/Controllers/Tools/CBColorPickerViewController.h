//
//  CBColorPickerViewController.h
//  catwang
//
//  Created by 99centbrains on 12/3/13.
//
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class CBColorPickerViewController;
@protocol CBColorPickerViewControllerDelegate <NSObject>


- (void) CBColorPickerVCChangeColor:(CBColorPickerViewController *)controller withImage:(UIImage *)pickedImage;

@end

@interface CBColorPickerViewController : OkJuxViewController

@property (nonatomic) BOOL highRes;
@property (nonatomic, unsafe_unretained) id <CBColorPickerViewControllerDelegate> delegate;

@property (nonatomic, strong) id someController;
@end
