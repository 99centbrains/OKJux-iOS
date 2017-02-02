//
//  OMGSnapVoteViewController.h
//  catwang
//
//  Created by Fonky on 2/17/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "OkJuxViewController.h"

@class OMGSnapVoteViewController;

@interface OMGSnapVoteViewController : OkJuxViewController

- (void)refreshData;
- (void)updateObjectInCollection:(Snap *)snap;


@end
