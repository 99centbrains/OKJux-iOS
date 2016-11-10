//
//  OMGSnapViewController.h
//  catwang
//
//  Created by Fonky on 2/16/15.
//
//

#import <UIKit/UIKit.h>

@class OMGSnapViewController;


@protocol OMGSnapViewControllerDelegate <NSObject>

@end


@interface OMGSnapViewController : UIViewController

- (void)refreshData;
- (void)updateObject:(PFObject *)object;

@property (nonatomic, unsafe_unretained) id <OMGSnapViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL bool_trending;


@end
