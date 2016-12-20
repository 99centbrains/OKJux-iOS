//
//  OMGMySnapsViewController.h
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@class OMGMySnapsViewController;


@protocol OMGMySnapsViewControllerDelegate <NSObject>


@end

@interface OMGMySnapsViewController : UIViewController

- (void) reloadData;
- (void) updateObjectInCollection:(Snap *)snap;
- (void) updateKarma;

@property (nonatomic, unsafe_unretained) id <OMGMySnapsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *mySnaps;

@end
