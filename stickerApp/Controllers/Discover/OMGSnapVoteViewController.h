//
//  OMGSnapVoteViewController.h
//  catwang
//
//  Created by Fonky on 2/17/15.
//
//

#import <UIKit/UIKit.h>

@class OMGSnapVoteViewController;


@protocol OMGSnapVoteViewControllerDelegate <NSObject>

- (void) showUserSnaps:(PFUser *)user;
- (void) showSnapFullScreen:(PFObject *)snap;

@end

@interface OMGSnapVoteViewController : UIViewController

- (void)refreshData;
- (void)updateObject:(PFObject *)object;

@property (nonatomic, unsafe_unretained) id <OMGSnapVoteViewControllerDelegate> delegate;


@end
