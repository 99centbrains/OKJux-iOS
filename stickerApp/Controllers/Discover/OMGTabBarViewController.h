//
//  OMGTabBarViewController.h
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import <UIKit/UIKit.h>
#import "OMGHeadSpaceViewController.h"
#import "Snap.h"

@interface OMGTabBarViewController : UITabBarController

@property (nonatomic, strong) OMGHeadSpaceViewController *ibo_headSpace;

- (void)shareItem:(UIImage *)image;
//TODO delete this method
- (void)showSnapFullScreen:(PFObject *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;
//TODO new backend method instead of showSnapFullScreen
- (void)showFullScreenSnap:(Snap *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;
- (void)lightBoxItemFlag:(PFObject *)flagItem;
- (BOOL)checkUserInArray:(NSMutableArray *)array;

@end
