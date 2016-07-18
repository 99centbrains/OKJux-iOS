//
//  StickerCategoryViewCell.h
//  catwang
//
//  Created by Fonky on 1/16/15.
//
//

#import <UIKit/UIKit.h>

#define IMAGE_HEIGHT 200
#define IMAGE_OFFSET_SPEED 25

@interface StickerCategoryViewCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *imageURL;


@property (nonatomic, assign, readwrite) CGPoint imageOffset;

@property (nonatomic, weak) IBOutlet UIImageView * ibo_categoryHero;
@property (nonatomic, weak) IBOutlet UIImageView * ibo_chevy;
@property (nonatomic, weak) IBOutlet UILabel * ibo_categoryTitle;
@property (nonatomic, weak) IBOutlet UIButton * ibo_buyAllButton;

@end
