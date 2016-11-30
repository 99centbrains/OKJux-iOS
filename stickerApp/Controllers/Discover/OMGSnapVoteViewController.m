//
//  OMGSnapVoteViewController.m
//  catwang
//
//  Created by Fonky on 2/17/15.
//
//

#import "OMGSnapVoteViewController.h"
#import "OMGSnapCollectionViewCell.h"
#import "DataHolder.h"
#import "TAOverlay.h"
#import "OMGTabBarViewController.h"
#import "DateTools.h"
#import "DTTimePeriod.h"
#import "OMGLightBoxViewController.h"
#import "NewUserViewController.h"
#import "SwitchHeaderCollectionReusableView.h"
#import "SnapServiceManager.h"

@interface OMGSnapVoteViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, OMGLightBoxViewControllerDelegate>{
    BOOL alreadyVoted;
    BOOL bool_nearMe;
}

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;

@property (nonatomic, strong) NSMutableArray *snapsArray;

@property (nonatomic, weak) IBOutlet UIView *ibo_notAvailableView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_notAvailableDescription;

@property (nonatomic, weak) IBOutlet UISegmentedControl *ibo_segmentControl;


@end


@implementation OMGSnapVoteViewController

enum {
    OMGVoteNone = 0,
    OMGVoteYES = 1,
    OMGVoteNO = 2
};

typedef NSInteger OMGVoteSpecifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [_ibo_collectionView addSubview:refreshControl];
    _ibo_notAvailableDescription.text = NSLocalizedString(@"PERMISSION_NO_PHOTOS", nil);
    _ibo_notAvailableView.hidden = YES;
    [_ibo_segmentControl setTitle:NSLocalizedString(@"TOGGLE_NEW", nil) forSegmentAtIndex:0];
    [_ibo_segmentControl setTitle:NSLocalizedString(@"TOGGLE_NEAR", nil) forSegmentAtIndex:1];

    bool_nearMe = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self queryTopSnapsByChannel];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kNewUserKey]) {
        NSLog(@"SHOULD SHOW FTUE");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FTUEStoryboard" bundle:nil];
        NewUserViewController *newVC = (NewUserViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_NewUserViewController"];
        [self presentViewController:newVC animated:NO completion:nil];
    }
}

- (void)startRefresh:(UIRefreshControl *)refresh {
    [(UIRefreshControl *)refresh endRefreshing];
    [self queryTopSnapsByChannel];
}

- (void)refreshData {
    if ([_snapsArray count]>0) {
        [_ibo_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)updateObject:(PFObject *)object {
    NSInteger objNum = [_snapsArray indexOfObject:object];
    NSLog(@"You Tapped Object %ld", (long)objNum);
    [_ibo_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:objNum inSection:0]]];
}


- (void) queryTopSnapsByChannel {
    _ibo_notAvailableView.hidden = YES;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (bool_nearMe) {
        params[@"my_location"] = [DataManager currentLocation];
        params[@"within_miles"] = [NSString stringWithFormat:@"%ld", (long)kMaxDistance];
    }
     
    params[@"user_id"] = [DataManager userID];
    params[@"type"] = bool_nearMe ? @"by_location" : @"by_creation_date";

    [SnapServiceManager getSnaps:params OnSuccess:^(NSArray* responseObject ) {
        _snapsArray = [NSMutableArray arrayWithArray:responseObject];
        [_ibo_collectionView reloadData];
        [TAOverlay hideOverlay];
        _ibo_notAvailableView.hidden = _snapsArray.count > 0;
        [self refreshData];
    } OnFailure:^(NSError *error) {
        [TAOverlay hideOverlay];
    }];
}

#pragma Toggle Near Me
- (IBAction)iba_toggleNear:(UISegmentedControl *)sender {
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
    [self refreshData];
    [_snapsArray removeAllObjects];
    [_ibo_collectionView reloadData];
    
    if (sender.selectedSegmentIndex == 0) {
        bool_nearMe = NO;
    } else {
        bool_nearMe = YES;
    }
    
    [self queryTopSnapsByChannel];
}

- (BOOL) locationGranted {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize sizer = CGSizeMake(_ibo_collectionView.frame.size.width, _ibo_collectionView.frame.size.height);
    return sizer;
}


#pragma COLLECTIONVIEW
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_snapsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Snap * snap = [_snapsArray objectAtIndex:indexPath.item];
    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"snapCell"
                                                                    forIndexPath:indexPath];
    cell.ibo_uploadDate.text = @"";
    cell.delegate = self;
    cell.snap = snap;
    cell.intCurrentSnap = indexPath.item;
    
    // IMAGE LOADING
    [cell setupImageView:[NSURL URLWithString:snap.imageUrl] andThumbnail:[NSURL URLWithString:snap.thumbnailUrl]];

    cell.ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)snap.netlikes];
    cell.ibo_voteContainer.hidden = NO;
    cell.ibo_shareBtn.hidden = NO;

    NSDate *createdDate = [NSDate dateWithString:snap.createdAt formatString:SERVER_FORMAT];
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timerPeriod = [nowDate timeIntervalSinceDate:createdDate];
    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timerPeriod];
    
    NSString *timeString = [@"🕑 " stringByAppendingString:timeAgoDate.timeAgoSinceNow];
    cell.ibo_uploadDate.text = timeString;

    [self setCellLocation:snap inCell: cell withTime:timeString];
    
    //CHECKS IF USER LIKES ALREADY
    [self setUserStatus:snap inCell:cell];
    
    return cell;
}

- (void) setCellLocation:(Snap *)snap inCell:(OMGSnapCollectionViewCell *)cell withTime: (NSString *)timeString {
    __block NSString *locationString;
    if (bool_nearMe) {
        locationString = [self getUserTimeZone:snap];
        cell.ibo_uploadDate.text = [timeString stringByAppendingString:locationString];
    } else {
        //TIMEZONE
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[snap.location[0] doubleValue] longitude:[snap.location[1] doubleValue]];

        [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"ERROR");
                return;
            }
            CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
            NSString *country = myPlacemark.country;
            NSString *city = myPlacemark.locality;
            if (city != nil && country != nil) {
                locationString = [NSString stringWithFormat:@" 📍 %@ - %@", country, city];
                cell.ibo_uploadDate.text = [timeString stringByAppendingString:locationString];
            }
        }];
    }
}

- (void) setUserStatus:(Snap *)snap inCell:(OMGSnapCollectionViewCell *)cell {
    cell.ibo_btn_likeUP.userInteractionEnabled = NO;
    cell.ibo_btn_likeDown.userInteractionEnabled = NO;

    [cell.ibo_btn_likeDown setSelected: snap.isLiked || snap.noAction ? NO : YES];
    [cell.ibo_btn_likeUP setSelected: !snap.isLiked || snap.noAction ? NO : YES];
    alreadyVoted = snap.noAction ? NO : YES;

    cell.ibo_btn_likeUP.userInteractionEnabled = YES;
    cell.ibo_btn_likeDown.userInteractionEnabled = YES;
}

- (NSString *) getUserTimeZone:(Snap*)snap {
    NSLocale *locale = [NSLocale currentLocale];
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    //DISTANCE
    CLLocation *locationCurrent = [[CLLocation alloc] initWithLatitude:[[DataManager currentLatitud] doubleValue]
                                                             longitude:[[DataManager currentLongitud] doubleValue]];

    CLLocation *locationSnap = [[CLLocation alloc] initWithLatitude:[snap.location[0] doubleValue]
                                                          longitude:[snap.location[1] doubleValue]];

    CLLocationDistance distance = [locationCurrent distanceFromLocation:locationSnap];
    NSString *miles = !isMetric ? [NSString stringWithFormat:@" 📍 %.1f Miles Away",(distance/1609.344)] : [NSString stringWithFormat:@" 📍 %.1f Kilometers Away",(distance/1000)];

    return miles;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;

    Snap *selectedSnap = [_snapsArray objectAtIndex:indexPath.item];
    [self showLightBoxViewSnap:indexPath.item andThumbnail:cellImage withSnap:selectedSnap];
}

//LIGHTBOX
- (void)showLightBoxViewSnap:(NSInteger)itemIndex andThumbnail:(UIImage *)thumbnail withSnap:(Snap *)snap {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showFullScreenSnap:snap preload:thumbnail shouldShowVoter:NO];
}

- (void)cleanUpItems:(NSInteger)snapIndex {
    if (!alreadyVoted) {
        [_ibo_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:snapIndex inSection:0]]];
    }
    
    if (snapIndex + 1 < [_snapsArray count]) {
        [_ibo_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:snapIndex + 1  inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
  
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner.ibo_headSpace updateKarma];
}

#pragma Cell Delegate
- (void) omgSnapVOTEUP:(NSInteger)snapIndex {
  Snap* snap = _snapsArray[snapIndex];
  snap.netlikes += 1;
  [SnapServiceManager rankSnap:snap.ID withLike:YES OnSuccess:^(NSDictionary *responseObject) {
    _snapsArray[snapIndex] = snap;
    [self cleanUpItems:snapIndex];
  } OnFailure:^(NSError *error) {
    snap.netlikes -= 1;
  }];
}

- (void) omgSnapVOTEDOWN:(NSInteger) snapIndex {
  Snap* snap = _snapsArray[snapIndex];
  snap.netlikes -= 1;
  [SnapServiceManager rankSnap:snap.ID withLike:NO OnSuccess:^(NSDictionary *responseObject) {
    _snapsArray[snapIndex] = snap;
    [self cleanUpItems:snapIndex];
  } OnFailure:^(NSError *error) {
    snap.netlikes += 1;
  }];
}



#pragma SHARE
- (void) omgSnapShareImage:(UIImage *)image {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner shareItem:image];
}


#pragma FLAG
//TODO this will be replaced for a method that receives a Snap
- (void) omgSnapFlagItem:(PFObject *)object {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner lightBoxItemFlag:object];
}

#pragma VOTING ARGUMENTS
- (BOOL) checkUserInArray:(NSMutableArray *)array {
    if ([array count] > 0) {
        for (NSString *userLike in array) {
            NSLog(@"USER LIKE %@", userLike);
            if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]){
                return NO;
            }
        }
    }
    
    return YES;
}


- (NSMutableArray *) removeUserInArray:(NSMutableArray *)array {
    if ([array count] > 0) {
        for (NSString *userLike in array) {
            if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]) {
                [array removeObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
                return array;
            }
        }
    }
    
    return array;
}

#pragma NO DATA AVAILABLE
- (IBAction)iba_notAvailableAction:(id)sender {
    NSString *textToShare = kShareDescription;
    NSURL *url = [NSURL URLWithString:@"http://okjux.com/"];
    UIImage *imgData = [UIImage imageNamed:@"icon_promo.png"];

    NSArray *activityItems = [[NSArray alloc]  initWithObjects:textToShare, imgData, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                             applicationActivities:applicationActivities];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

//TODO this method will be changed so that it works with Snap and User and not PFObjects
//This method leads to nothing, last call on stack was never implemented
- (void) iba_showUserForImage:(NSInteger) snapIndex {
    PFObject *snapObj= [_snapsArray objectAtIndex:snapIndex];
    PFUser *userObj = snapObj[@"userId"];
    NSLog(@"Object ID %@", userObj.objectId );
    [self.delegate showUserSnaps:userObj];
}


@end
