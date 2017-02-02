//
//  OMGMySnapsViewController.h
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "OkJuxViewController.h"

@class OMGMySnapsViewController;


@protocol OMGMySnapsViewControllerDelegate <NSObject>


@end

@interface OMGMySnapsViewController : OkJuxViewController

- (void) reloadData;
- (void) updateObjectInCollection:(Snap *)snap;
- (void) updateKarma;

@property (nonatomic, unsafe_unretained) id <OMGMySnapsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *mySnaps;

@end
