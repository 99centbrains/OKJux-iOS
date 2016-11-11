//
//  StickerPackCollectionViewCell.m
//  catwang
//
//  Created by Fonky on 2/1/15.
//
//

#import "StickerPackCollectionViewCell.h"
#import "StickerHeaderCollectionCell.h"
#import "StickerCellCollectionViewCell.h"
#import "CWInAppHelper.h"
#import "TAOverlay.h"
#import "TMCache.h"

@interface StickerPackCollectionViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate, StickerHeaderCollectionCellDelegate, NSURLConnectionDelegate>{
    

    NSInteger packInt;
    
    //NSMutableData *_responseData;
    
}

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, strong) NSMutableArray *array_images;


@end


@implementation StickerPackCollectionViewCell

@synthesize delegate;

- (void) setUpCell{
    
    [_ibo_collectionView reloadData];
    _array_images = [[NSMutableArray alloc] init];
  
    [[NSNotificationCenter defaultCenter] addObserverForName:CWIAP_ProductPurchased
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      
                                                      [TAOverlay showOverlayWithLabel:@"Success item has been purchased" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionAutoHide)];
                                                      NSLog(@"******************* purchased");
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_ibo_collectionView reloadData];
                                                      });
                                                      
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CWIAP_Restore
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      
                                                      [TAOverlay showOverlayWithLabel:@"Success items have been Restored!" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionAutoHide)];
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_ibo_collectionView reloadData];
                                                      });
                                                      
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CWIAP_ProductsAvailable
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_ibo_collectionView reloadData];
                                                      });
                                                      
                                                  }];

    [self loadPack];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_array_images count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
        StickerHeaderCollectionCell *header = (StickerHeaderCollectionCell *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerCell" forIndexPath:indexPath];
  
    header.ibo_headerLabel.text = @"";
    packInt = indexPath.item;
  
    //NOT FREE
    if (![self stickerPackFree:_stickerPackID]) {
        NSString *price = [[CWInAppHelper sharedHelper] getProductPrice:_stickerPackID];
     
        [header.ibo_unlockButton setTitle:price forState:UIControlStateNormal];
        header.ibo_unlockButton.hidden = NO;
        header.ibo_unlockButton.tag = indexPath.row;
        header.ibo_unlockButton.layer.cornerRadius = 2;
        header.ibo_unlockButton.clipsToBounds = YES;
    } else {
         header.ibo_unlockButton.hidden = YES;
    }
    
    
    //CHECK SOCIALS
    if ([[CBJSONDictionary shared] getSocialLinksFromPackID:_stickerBundleID byPackID:_stickerPackID]){
        NSDictionary *socialLinks = [[CBJSONDictionary shared] getSocialLinksFromPackID:_stickerBundleID byPackID:_stickerPackID ];

        header.ibo_btn_social_ig.hidden = NO;
        header.ibo_btn_social_tw.hidden = NO;
        header.url_Twitter = [NSURL URLWithString:[socialLinks objectForKey:@"social_twitter"]];
        header.url_Instagram = [NSURL URLWithString:[socialLinks objectForKey:@"social_instagram"]];
        header.delegate = self;
    } else {
        header.ibo_btn_social_ig.hidden = YES;
        header.ibo_btn_social_tw.hidden = YES;
    }

    header.packID = _stickerPackID;
    header.ibo_headerLabel.text = [_stickerPack objectForKey:@"pack_name"];

    return header;
}

- (void) social_openURL:(NSURL *)url{
    [self.delegate stickerHeaderOpenURL:self withURL:url];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    StickerCellCollectionViewCell *cell = (StickerCellCollectionViewCell *)[collectionView
                                                                        dequeueReusableCellWithReuseIdentifier:@"stickerCell"
                                                                        forIndexPath:indexPath];
    
    cell.imageURL = nil;
    cell.ibo_spinner.hidden = NO;

    if (![self stickerPackFree:_stickerPackID]){
        cell.ibo_lock.hidden = NO;
    } else {
        cell.ibo_lock.hidden = YES;
    }

    NSURL *fileName = [_array_images objectAtIndex:indexPath.item];
    NSURL * iconImage = fileName;

    cell.imageURL = iconImage;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.frame.size.width/3, self.frame.size.width/3);
    
}

#pragma TOUCH
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (![self stickerPackFree:_stickerPackID]){
        [self iba_buyPack:_stickerPackID];
        return;
    }
    
    StickerCellCollectionViewCell *cell = (StickerCellCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *btnImage = cell.ibo_btn.image;
    
    if (!btnImage){
        return;
    }

    [self.delegate stickerPackChoseImage:self didFinishPickingStickerImage:btnImage withPackID:_stickerPackID];
    [[NSUserDefaults standardUserDefaults] setObject:_stickerPackID forKey:@"kLastPage"];
}

#pragma DATA
//TODO here pack is loaded
- (void) loadPack {
    if ([[TMCache sharedCache] objectForKey:_stickerPackID]){
        [[TMCache sharedCache] objectForKey:_stickerPackID
                                      block:^(TMCache *cache, NSString *key, id object) {
                                           NSLog(@"HAS PACK %@", (NSArray *)object);
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self addStickersInSection:(NSArray *)object];
                                          });
                                      }];
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [TAOverlay showOverlayWithLabel:@"" Options:TAOverlayOptionOverlaySizeRoundedRect | TAOverlayOptionOverlayTypeActivityDefault];
        }else{
            [TAOverlay showOverlayWithLabel:@"" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSString *pathURL = [_stickerPack objectForKey:@"pack_path"];
        NSURL *myURL = [NSURL URLWithString:[pathURL stringByAppendingString:@"index.php"]];
        NSLog(@"My URL %@", myURL);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:30.0f];
        
        NSOperationQueue *jsonQueue = [[NSOperationQueue alloc] init];
      
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:jsonQueue
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *error) {
                                   
                                   if ([data length] > 0 && error == nil){
                                       
                                       NSError *error;
                                       id jsonObject = [NSJSONSerialization
                                                        JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                        error:&error];
                                       
                                       if (jsonObject != nil && error == nil){
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSArray *stickers = [self formatFilePathsWithURL:pathURL stickerList:(NSArray *)jsonObject];
                                               
                                               [self addStickersInSection:stickers];
                                               [[TMCache sharedCache] setObject:stickers forKey:_stickerPackID block:nil];

                                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                           });
                                       }
                                   }
                               }];
    }
}

- (void) addStickersInSectionSequence:(NSArray *)stickerList{
    [_array_images addObjectsFromArray:stickerList];
    [_ibo_collectionView reloadData];
}

- (void) addStickersInSection:(NSArray *)stickerList{
    [_array_images addObjectsFromArray:stickerList];
    [_ibo_collectionView reloadData];
    [TAOverlay hideOverlay];
}


- (NSArray *) formatFilePathsWithURL:(NSString *)pathURL stickerList:(NSArray *)list{
    NSLog(@"Path URL %@", pathURL);
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    if (!list){
        return nil;
    }
    for (NSString *item in list){
        [temp addObject:[NSURL URLWithString:[pathURL stringByAppendingString:[item stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
    }
    
    return [temp copy];
}


#pragma IAP
- (BOOL) stickerPackFree:(NSString *)packID{
    
    //FREE
    if ([[_stickerPack objectForKey:@"pack_free"] boolValue]){
        return YES;
    }
    
    //DEBUG IN CONSTANTS
    if (kStickerDebug){
        return YES;
    }
    
    return [[CWInAppHelper sharedHelper] product_isPurchased:packID];
}

- (void)iba_buyPack:(NSString *)packID{
    [[CWInAppHelper sharedHelper] buyProductWithProductIdentifier:packID singleItem:YES];
}

@end
