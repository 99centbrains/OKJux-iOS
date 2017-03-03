//
//  SnapHelper.h
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Snap.h"

@interface SnapHelper : NSObject

+ (void)shareItem:(UIImage *)image fromViewController:(UIViewController*)viewController;
+ (void)reportSnap:(Snap *)snap fromViewController:(UIViewController *)viewController;

@end
