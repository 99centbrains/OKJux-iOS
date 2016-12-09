//
//  OMGSnapCollectionViewCell.h
//  catwang
//
//  Created by Fonky on 2/3/15.
//
//

#import <UIKit/UIKit.h>
#import "Snap.h"

@class OMGSnapCollectionViewCell;

@protocol OMGSnapCollectionViewCellDelegate <NSObject>

- (void) omgSnapVOTEUP:(NSInteger) snapIndex;
- (void) omgSnapVOTEDOWN:(NSInteger) snapIndex;

- (void) omgSnapShareImage:(UIImage *)image;

- (void) omgSnapFlagItem:(Snap *)object;

- (void) omgsnapCellDelete:(NSInteger) snapIndex;

- (void) iba_showUserForImage:(NSInteger) snapIndex;

@end


@interface OMGSnapCollectionViewCell : UICollectionViewCell


- (void)setupImageView:(NSURL *)file andThumbnail:(NSURL *)thumb;
- (void)setThumbnailImage:(NSURL *)file;

@property (nonatomic, weak) IBOutlet UIImageView *ibo_userSnapImage;
@property (nonatomic, strong) NSURL *imageURL;



@property (nonatomic, weak) IBOutlet UIImageView *ibo_heartView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_photoKarma;
@property (nonatomic, weak) IBOutlet UILabel *ibo_uploadDate;

@property (nonatomic, weak) IBOutlet UIButton *ibo_shareBtn;

@property (nonatomic, weak) IBOutlet UIView *ibo_voteContainer;
@property (nonatomic, weak) IBOutlet UIButton *ibo_btn_likeUP;
@property (nonatomic, weak) IBOutlet UIButton *ibo_btn_likeDown;

@property (nonatomic) NSInteger intCurrentSnap;
@property (nonatomic, strong) PFObject* snapObject;
//TODO delete above snapObject and leave bottom one
@property (nonatomic, strong) Snap* snap;


@property (nonatomic, unsafe_unretained) id <OMGSnapCollectionViewCellDelegate> delegate;


@end
