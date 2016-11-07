//
//  StickerCellCollectionViewCell.m
//  catwang
//
//  Created by Fonky on 12/28/14.
//
//

#import "StickerCellCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "HNKCache.h"


@implementation StickerCellCollectionViewCell

- (void)setImageURL:(NSURL *)imageURL
{
    if (_imageURL == imageURL) return;
    
    _ibo_btn.clipsToBounds = NO;
    _ibo_lock.layer.cornerRadius = _ibo_lock.frame.size.width/2;
    _ibo_lock.layer.borderColor = [UIColor whiteColor].CGColor;
    _ibo_lock.layer.borderWidth = 2;
    _ibo_lock.clipsToBounds = YES;
    _ibo_spinner.hidden = NO;
    
    [[HNKCache sharedCache] fetchImageForKey:[imageURL absoluteString] formatName:@"sticker" success:^(UIImage *image) {
        
        // found image in cache, set right away
        dispatch_async(dispatch_get_main_queue(), ^{
            _ibo_btn.image = image;
            _ibo_spinner.hidden = YES;
        });
        
    } failure:^(NSError *error) {
        
        __weak __typeof(self)weakSelf = self;
        // no image in cache, make network request
        [_ibo_btn setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;

            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.ibo_btn.image = image;
                strongSelf.ibo_spinner.hidden = YES;
            });
            
            // save image in cache when it is done
            [[HNKCache sharedCache] setImage:image forKey:[imageURL absoluteString] formatName:@"sticker"];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
            NSLog(@"Failed Image");
        }];
    }];
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_ibo_btn setImage:nil];
}


@end
