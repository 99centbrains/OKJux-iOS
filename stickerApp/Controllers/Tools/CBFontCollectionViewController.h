//
//  CBFontCollectionViewController.h
//  catwang
//
//  Created by Fonky on 1/2/15.
//
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class CBFontCollectionViewController;

@protocol CBFontCollectionViewControllerDelegate <NSObject>

-(void) CBFontCollectionDidChooseFont:(CBFontCollectionViewController *)controller  withFont:(UIFont *)font;

@end


@interface CBFontCollectionViewController : OkJuxViewController


@property (nonatomic, unsafe_unretained) id <CBFontCollectionViewControllerDelegate> delegate;

@end
