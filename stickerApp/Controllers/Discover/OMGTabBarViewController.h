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
- (void)showSnapFullScreen:(PFObject *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;
//TODO the above method will be deleted and the new one is the one below
- (void)showFullScreenSnap:(Snap *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;
- (void)lightBoxItemFlag:(PFObject *)flagItem;
- (BOOL)checkUserInArray:(NSMutableArray *)array;

@end
