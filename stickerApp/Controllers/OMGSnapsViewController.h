//
//  OMGSnapsViewController.h
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@interface OMGSnapsViewController : UIViewController

- (void)showFullScreenSnap:(Snap *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter;

@end
