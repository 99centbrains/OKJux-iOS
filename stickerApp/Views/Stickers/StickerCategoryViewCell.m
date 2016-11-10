//
//  StickerCategoryViewCell.m
//  catwang
//
//  Created by Fonky on 1/16/15.
//
//

#import "StickerCategoryViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation StickerCategoryViewCell

- (void)setImageURL:(NSURL *)imageURL {
    if (_imageURL == imageURL) return;
    
    _ibo_categoryHero.contentMode = UIViewContentModeScaleAspectFill;
    _ibo_categoryHero.clipsToBounds = NO;
    
    
    [_ibo_categoryHero setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
   
        _ibo_categoryHero.image = image;
        // Update padding
        [self setImageOffset:self.imageOffset];
   
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"Failed Image");
    }];
}

- (void)setImageOffset:(CGPoint)imageOffset {
    // Store padding value
    _imageOffset = imageOffset;

    
    // Grow image view
    CGRect frame = _ibo_categoryHero.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset.x, _imageOffset.y);
   _ibo_categoryHero.frame = offsetFrame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_ibo_categoryHero setImageWithURL:nil];
    [_ibo_categoryHero setImage:nil];
}

@end
