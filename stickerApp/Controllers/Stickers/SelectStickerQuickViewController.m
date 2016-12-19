//
//  SelectStickerViewController.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectStickerQuickViewController.h"

#import "TAOverlay.h"
#import "Reachability.h"
#import "Flurry.h"
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>
#import "UIImage+ImageEffects.h"
#import "MixPanelManager.h"

#import "StickerCellCollectionViewCell.h"
#import "StickerCategoryViewController.h"
#import "StickerHeaderCollectionCell.h"

#import "SVModalWebViewController.h"
#import "StickerPackCollectionViewCell.h"




@interface SelectStickerQuickViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ADBannerViewDelegate, StickerCategoryViewControllerDelegate, StickerPackCollectionViewCellDelegate>{
    BOOL purchasedPack;
    ADBannerView *iAdBanner;
    BOOL iAdBannerVisible;
    BOOL adColonyReady;
    NSCache *imageCache;
}

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, weak) IBOutlet UIButton *ibo_closeButton;
@property (nonatomic, weak) IBOutlet UIImageView *ibo_bgImage;
@property (nonatomic, weak) IBOutlet UIPageControl *ibo_pageControl;

@property (nonatomic, strong) NSMutableArray *array_stickerpack_dir;
@property (nonatomic, strong) NSMutableArray *array_stickerpack_ids;
@property (nonatomic, strong) NSArray *prop_stickerPackItems;
@property (nonatomic, strong) NSMutableArray *prop_stickers;
@property (nonatomic, strong) NSMutableDictionary *stickerPackDictionary;

@property (nonatomic, strong) StickerCategoryViewController *ibo_categoryViewController;


@end

@implementation SelectStickerQuickViewController

@synthesize delegate = _delegate;
@synthesize prop_stickerPackItems;
@synthesize ibo_bgImage;
@synthesize ibo_closeButton;

- (IBAction)iba_dissmissSelectStickerView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    adColonyReady = NO;
    self.title = _prop_bundleName;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    NSInteger packCount = [[[CBJSONDictionary shared] getPacksFromBundleID:_prop_bundleID] count];
    _array_stickerpack_ids = [[NSMutableArray alloc] init];
    _stickerPackDictionary = [[NSMutableDictionary alloc] init];
    
    for (int index = 0; index < packCount ; index++) {
        //GETS Pack Dictionary
        NSMutableDictionary *pack = (NSMutableDictionary *)[[[CBJSONDictionary shared] getPacksFromBundleID:_prop_bundleID] objectAtIndex:index];
        [_array_stickerpack_ids addObject:[pack objectForKey:@"pack_id"]];
        [_stickerPackDictionary setObject:pack forKey:[pack objectForKey:@"pack_id"]];
    }

    _ibo_pageControl.numberOfPages = [_array_stickerpack_ids count];
    imageCache = [[NSCache alloc] init];

    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    for (NSString *packID in _array_stickerpack_ids) {
        NSString *last = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastPage"];
        if ([packID isEqualToString:last]) {
            NSInteger lastnt = [_array_stickerpack_ids indexOfObject:packID];
            [self.ibo_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:lastnt] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
    if (![self checkNetworkConnection]) {
        [TAOverlay hideOverlay];
        UIAlertView *noNet = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please connect device to a wifi connection to access stickers." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [noNet show];
    }
}

- (BOOL) checkNetworkConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    }
    [super viewWillDisappear:animated];
}

#pragma DATACOLLECTION
- (void) loadBundleSection {
    NSInteger packCount = [[[CBJSONDictionary shared] getPacksFromBundleID:_prop_bundleID] count];
    for (int index = 0; index < packCount ; index++) {
        //GETS Pack Dictionary
        NSMutableDictionary *pack = (NSMutableDictionary *)[[[CBJSONDictionary shared] getPacksFromBundleID:_prop_bundleID] objectAtIndex:index];
        [_array_stickerpack_ids addObject:[pack objectForKey:@"pack_id"]];
        [_stickerPackDictionary setObject:pack forKey:[pack objectForKey:@"pack_id"]];
    }
}


#pragma CollectionView Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_array_stickerpack_ids count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StickerPackCollectionViewCell *cell = (StickerPackCollectionViewCell *)[collectionView
                                                                            dequeueReusableCellWithReuseIdentifier:@"stickerPack"
                                                                            forIndexPath:indexPath];
    
    NSString *packID = [_array_stickerpack_ids objectAtIndex:indexPath.section];
    NSDictionary *pack = [_stickerPackDictionary objectForKey:packID];
    
    cell.stickerPack = pack;
    cell.stickerPackID = packID;
    cell.stickerBundleID = _prop_bundleID;
    cell.delegate = self;

    [cell setUpCell];
    
    _ibo_pageControl.currentPage = indexPath.section;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
}

#pragma StoryBoard
- (UIViewController *)viewControllerFromMainStoryboardWithName:(NSString *)name {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"StickerSelectStoryboard" bundle:[NSBundle mainBundle]];
    return [mainSB instantiateViewControllerWithIdentifier:name];
}

//GET STICKER PACK DIR FROM ID
- (NSMutableArray *) getStickerPackWithKey:(NSString *)key {
    NSError *error = nil;
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSString *categoryDirectory = [_stickerPackDictionary objectForKey:key];
    
    NSArray *filelist = [filemgr
                         contentsOfDirectoryAtPath:
                         [resourcePath stringByAppendingString:categoryDirectory]
                         error:&error];
    if (error) {
        NSLog(@"Error in getStickerPack: %@",[error localizedDescription]);
    }
    
    return [filelist mutableCopy];
}

- (NSMutableArray *) getStickerPackWithDir:(NSString *)key {
    NSError *error = nil;
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSString *categoryDirectory = key;
    
    NSArray *filelist = [filemgr
                         contentsOfDirectoryAtPath:
                         [resourcePath stringByAppendingString:categoryDirectory]
                         error:&error];
    if (error) {
        NSLog(@"Error in getStickerPack: %@",[error localizedDescription]);
    }
    
    if ([filelist count] > 0) {
        return [filelist mutableCopy];
    } else {
        return nil;
    }
}



-(void) stickerPackChoseImage:(StickerPackCollectionViewCell *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID {
  [MixPanelManager triggerEvent:@"Select sticker" withData:@{ @"PackID": packID }];
  [self.delegate selectStickerPackQuickViewController:self didFinishPickingStickerImage:image withPackID:packID];
}

- (void) stickerHeaderOpenURL:(StickerPackCollectionViewCell *)controller withURL:(NSURL *)url {
    SVModalWebViewController *modal = [[SVModalWebViewController alloc] initWithURL:url];
    [self presentViewController:modal animated:YES completion:nil];
}

@end
