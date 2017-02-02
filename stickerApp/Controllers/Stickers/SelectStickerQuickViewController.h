//
//  SelectStickerViewController.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWInAppHelper.h"
#import "OkJuxViewController.h"

@class SelectStickerQuickViewController;

@protocol SelectStickerQuickViewControllerDelegate <NSObject>

-(void) selectStickerPackQuickViewController:(SelectStickerQuickViewController *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID;

@end

@interface SelectStickerQuickViewController : OkJuxViewController <UIScrollViewDelegate> {
    
}

@property (nonatomic, strong) UIImage* prop_BGImage;
@property (nonatomic, strong) NSString* prop_bundleID;
@property (nonatomic, strong) NSString* prop_bundleName;

@property (nonatomic) BOOL bool_iapProductsAvailable;

@property (nonatomic, unsafe_unretained) id <SelectStickerQuickViewControllerDelegate> delegate;

@end
