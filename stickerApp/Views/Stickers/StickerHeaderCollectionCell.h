//
//  StickerHeaderCollectionCell.h
//  catwang
//
//  Created by Fonky on 1/14/15.
//
//

#import <UIKit/UIKit.h>

@class StickerHeaderCollectionCell;

@protocol StickerHeaderCollectionCellDelegate <NSObject>

- (void) social_openURL:(NSURL *)url;

@end

@interface StickerHeaderCollectionCell : UICollectionReusableView

@property (nonatomic, weak) IBOutlet UILabel * ibo_headerLabel;
@property (nonatomic, weak) IBOutlet UIButton * ibo_unlockButton;


@property (nonatomic, weak) IBOutlet UIButton * ibo_btn_social_ig;
@property (nonatomic, weak) IBOutlet UIButton * ibo_btn_social_tw;

@property (nonatomic, strong) NSURL * url_Twitter;
@property (nonatomic, strong) NSURL * url_Instagram;

@property (nonatomic, strong) NSString *packID;

@property (nonatomic, unsafe_unretained) id <StickerHeaderCollectionCellDelegate> delegate;


@end
