//
//  OMGSnapVoteViewController.h
//  catwang
//
//  Created by Fonky on 2/17/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@class OMGSnapVoteViewController;

@interface OMGSnapVoteViewController : UIViewController

- (void)refreshData;
- (void)updateObjectInCollection:(Snap *)snap;


@end
