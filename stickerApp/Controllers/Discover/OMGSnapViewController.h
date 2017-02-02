//
//  OMGSnapViewController.h
//  catwang
//
//  Created by Fonky on 2/16/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "OkJuxViewController.h"

@class OMGSnapViewController;


@protocol OMGSnapViewControllerDelegate <NSObject>

@end


@interface OMGSnapViewController : OkJuxViewController

- (void)refreshData;
- (void)updateObjectInCollection:(Snap *)snap;

@property (nonatomic, unsafe_unretained) id <OMGSnapViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL bool_trending;


@end
