//
//  StickerCategoryViewController.h
//  catwang
//
//  Created by Fonky on 1/14/15.
//
//

#import <UIKit/UIKit.h>
#import "OkJuxViewController.h"

@class StickerCategoryViewController;

@protocol StickerCategoryViewControllerDelegate <NSObject>

-(void) stickerCategory:(StickerCategoryViewController *)controller withCategoryName:(NSString *)name andID:(NSString *)categoryID;
-(void) stickerCategory:(StickerCategoryViewController *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID;
-(void) stickerCategory:(StickerCategoryViewController *)controller didFinishedEmoji:(UIImage *)image withPackID:(NSString *)packID;
-(void) stickerCategoryDismiss:(StickerCategoryViewController *)controller;

@end

@interface StickerCategoryViewController : OkJuxViewController

@property (nonatomic, unsafe_unretained) id <StickerCategoryViewControllerDelegate> delegate;


@end
