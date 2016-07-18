//
//  CBFontToolViewController.h
//  catwang
//
//  Created by Fonky on 12/13/14.
//
//

#import <UIKit/UIKit.h>
@class CBFontToolViewController;

@protocol CBFontToolViewControllerDelegate <NSObject>

- (void) cbFontToolChangeFont:(CBFontToolViewController *)controller;
- (void) cbFontToolChangeColor:(CBFontToolViewController *)controller;
- (void) cbFontToolToggleStroke:(CBFontToolViewController *)controller withBool:(BOOL)stroked;

@end
@interface CBFontToolViewController : UIViewController


@property (nonatomic, unsafe_unretained) id <CBFontToolViewControllerDelegate> delegate;

@end
