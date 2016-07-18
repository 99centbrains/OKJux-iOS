//
//  StickerPackCollectionViewCell.h
//  catwang
//
//  Created by Fonky on 2/1/15.
//
//

#import <UIKit/UIKit.h>
@class StickerPackCollectionViewCell;

@protocol StickerPackCollectionViewCellDelegate <NSObject>

-(void) stickerPackChoseImage:(StickerPackCollectionViewCell *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID;

- (void) stickerHeaderOpenURL:(StickerPackCollectionViewCell *)controller withURL:(NSURL *)url;



@end

@interface StickerPackCollectionViewCell : UICollectionViewCell


- (void) setUpCell;

@property (nonatomic, strong) NSString * stickerBundleID;
@property (nonatomic, strong) NSString * stickerPackID;
@property (nonatomic, strong) NSDictionary * stickerPack;


@property (nonatomic, strong) NSURLConnection *connection;


@property (nonatomic, unsafe_unretained) id <StickerPackCollectionViewCellDelegate> delegate;


@end
