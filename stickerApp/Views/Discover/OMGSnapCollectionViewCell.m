//
//  OMGSnapCollectionViewCell.m
//  catwang
//
//  Created by Fonky on 2/3/15.
//
//

#import "OMGSnapCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"



@implementation OMGSnapCollectionViewCell


@synthesize delegate;

- (void)setThumbnailImage:(NSURL *)file {
    [_ibo_userSnapImage setImageWithURLRequest:[NSURLRequest requestWithURL:file] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        _ibo_userSnapImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
}

- (void)setupFullImage:(NSURL *)file {
    [_ibo_userSnapImage setImageWithURLRequest:[NSURLRequest requestWithURL:file] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        _ibo_userSnapImage.image = image;

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
}

- (void)setupImageView:(NSURL *)file andThumbnail:(NSURL *)thumb {
    if (_ibo_userSnapImage.image){
        return;
    }
    
    [_ibo_userSnapImage setImageWithURLRequest:[NSURLRequest requestWithURL:thumb] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        _ibo_userSnapImage.image = image;
        [self setupFullImage:file];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self setupFullImage:file];
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_ibo_userSnapImage setImage:nil];
}


- (IBAction) iba_likeOMGSnap:(UIButton *)sender {
    [sender setSelected:YES];
    [self.delegate omgSnapVOTEUP:_intCurrentSnap];
    [_ibo_btn_likeDown setSelected:NO];
}

- (IBAction) iba_dislikeOMGSnap:(UIButton *)sender{
    [sender setSelected:YES];
    [self.delegate omgSnapVOTEDOWN:_intCurrentSnap];
    [_ibo_btn_likeUP setSelected:NO];
}

- (IBAction) iba_shareItem:(id)sender {
    [self.delegate omgSnapShareImage:_ibo_userSnapImage.image];
}


- (IBAction)iba_flagImage:(id)sender {
    [self.delegate omgSnapFlagItem:_snap];
}

- (IBAction)iba_deleteItem:(id)sender {
    [self.delegate omgsnapCellDelete:_intCurrentSnap];
}

- (void)loadSnap:(Snap*)snap {
    self.ibo_btn_likeUP.hidden = YES;
    self.ibo_btn_likeDown.hidden = YES;
    [self setupImageView:[NSURL URLWithString:snap.imageUrl] andThumbnail:[NSURL URLWithString:snap.thumbnailUrl]];
    self.ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)snap.netlikes];
}

@end
