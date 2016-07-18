//
//  StickerCellCollectionViewCell.h
//  catwang
//
//  Created by Fonky on 12/28/14.
//
//

#import <UIKit/UIKit.h>

@interface StickerCellCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView * ibo_btn;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView * ibo_spinner;
@property (nonatomic, weak) IBOutlet UILabel * ibo_lock;

@property (nonatomic, strong) NSString *fileDIR;
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) NSURL *imageURL;

@end
