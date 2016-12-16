//
//  OMGLightBoxViewController.h
//  catwang
//
//  Created by Fonky on 2/7/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@class OMGLightBoxViewController;

@protocol OMGLightBoxViewControllerDelegate <NSObject>

- (void) lightBoxShareImage:(UIImage *)image;
- (void) lightBoxItemFlag:(Snap *)flagItem;
- (void) omgSnapDismissLightBox:(Snap *)object;

@end

@interface OMGLightBoxViewController : UIViewController

@property (nonatomic, strong ) Snap *snap;
@property (nonatomic, strong ) UIImage *preloadImage;

@property (nonatomic, weak) IBOutlet UIView *ibo_fade_voter;

@property (nonatomic, unsafe_unretained) id <OMGLightBoxViewControllerDelegate> delegate;

@end
