//
//  OMGMySnapsViewController.h
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import <UIKit/UIKit.h>

@class OMGMySnapsViewController;


@protocol OMGMySnapsViewControllerDelegate <NSObject>




@end

@interface OMGMySnapsViewController : UIViewController

- (void) reloadData;

- (void) loadUser:(PFUser *)userBlock;

@property (nonatomic, unsafe_unretained) id <OMGMySnapsViewControllerDelegate> delegate;

@end
