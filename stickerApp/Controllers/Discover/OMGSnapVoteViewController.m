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
        [self queryTopSnapsByChannel:nil];
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
    [self queryTopSnapsByChannel:nil];
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


- (void) queryTopSnapsByChannel:(NSString *)channel {
    _ibo_notAvailableView.hidden = YES;
    PFQuery *query= [PFQuery queryWithClassName:@"snap"];
    query.limit = 100;
    if (bool_nearMe) {
        PFGeoPoint *geoPoint = [DataHolder DataHolderSharedInstance].userGeoPoint;
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:kMaxDistance];
    }
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"hidden" equalTo:[NSNumber numberWithBool:0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //ADDED
        _snapsArray = [objects mutableCopy];
        [TAOverlay hideOverlay];
        [_ibo_collectionView reloadData];
        [self refreshData];
        if ([objects count] <= 0){
            _ibo_notAvailableView.hidden = NO;
        }
    }];
}

#pragma Toggle Near Me
- (IBAction)iba_toggleNear:(UISegmentedControl *)sender {
    NSLog(@"TOGGLE TRENDING");
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
    [self refreshData];
    [_snapsArray removeAllObjects];
    NSLog(@"REMOVE ALL OBJECTS %lu", (unsigned long)[_snapsArray count]);
    [_ibo_collectionView reloadData];
    
    if (sender.selectedSegmentIndex == 0) {
        bool_nearMe = NO;
    } else {
        bool_nearMe = YES;
    }
    
    [self queryTopSnapsByChannel:nil];
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
    PFObject *currentObject = [_snapsArray objectAtIndex:indexPath.item];
    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"snapCell"
                                                                    forIndexPath:indexPath];
    cell.ibo_uploadDate.text = @"";
    cell.delegate = self;
    cell.snapObject = currentObject;
    cell.intCurrentSnap = indexPath.item;
    
    // IMAGE LOADING
    PFFile *file = currentObject[@"image"];
    PFFile *thumb = currentObject[@"thumbnail"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell setupImageView:[NSURL URLWithString:file.url] andThumbnail:[NSURL URLWithString:thumb.url]];
    });
    
    NSNumber *netLikes= currentObject[@"netlikes"];
    cell.ibo_photoKarma.text = [NSString stringWithFormat:@"%@", netLikes];
    cell.ibo_voteContainer.hidden = NO;
    cell.ibo_shareBtn.hidden = NO;
    
    NSDate *createdDate = currentObject.createdAt;
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timerPeriod = [nowDate timeIntervalSinceDate:createdDate];
    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timerPeriod];
    
    NSString *timeString = [@"🕑 " stringByAppendingString:timeAgoDate.timeAgoSinceNow];
    __block NSString *locationString;
    cell.ibo_uploadDate.text = timeString;

    if (bool_nearMe) {
        locationString = [self getUserTimeZone:currentObject];
        cell.ibo_uploadDate.text = [timeString stringByAppendingString:locationString];
    } else {
        //TIMEZONE
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        PFGeoPoint *geoLocation = currentObject[@"location"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:geoLocation.latitude longitude:geoLocation.longitude];
        
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
    
    cell.ibo_btn_likeUP.userInteractionEnabled = NO;
    cell.ibo_btn_likeDown.userInteractionEnabled = NO;
    
    //CHECKS IF USER LIKES ALREADY
    NSInteger userStatus = [[DataHolder DataHolderSharedInstance]
                            checkUserLikeStatus:cell.snapObject];
    NSLog(@"UserStatus %ld", (long)userStatus);

    switch (userStatus) {
        case 0:
            [cell.ibo_btn_likeDown setSelected:NO];
            [cell.ibo_btn_likeUP setSelected:NO];
            alreadyVoted = NO;
            break;
        case OMGVoteYES:
            [cell.ibo_btn_likeDown setSelected:NO];
            [cell.ibo_btn_likeUP setSelected:YES];
            alreadyVoted = YES;
            break;
        case OMGVoteNO:
            [cell.ibo_btn_likeDown setSelected:YES];
            [cell.ibo_btn_likeUP setSelected:NO];
            alreadyVoted = YES;
            break;
        default:
            break;
    }

    cell.ibo_btn_likeUP.userInteractionEnabled = YES;
    cell.ibo_btn_likeDown.userInteractionEnabled = YES;
    
    return cell;
}

- (NSString *) getUserTimeZone:(PFObject*)snap {
    NSLocale *locale = [NSLocale currentLocale];
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    //DISTANCE
     CLLocation *locationCurrent = [[CLLocation alloc] initWithLatitude:[DataHolder DataHolderSharedInstance].userGeoPoint.latitude
                                                              longitude:[DataHolder DataHolderSharedInstance].userGeoPoint.longitude];
     PFGeoPoint *snapDistance = snap[@"location"];
     CLLocation *locationSnap = [[CLLocation alloc] initWithLatitude:snapDistance.latitude
     longitude:snapDistance.longitude];
     CLLocationDistance distance = [locationCurrent distanceFromLocation:locationSnap];
    NSString *miles;
    if (!isMetric) {
        miles = [NSString stringWithFormat:@" 📍 %.1f Miles Away",(distance/1609.344)];
    } else {
        miles = [NSString stringWithFormat:@" 📍 %.1f Kilometers Away",(distance/1000)];
    }

    return miles;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;
    NSLog(@"INDEX PATH TAP %ld", (long)indexPath.item);
    PFObject *touchedObject = [_snapsArray objectAtIndex:indexPath.item];
    [self showLightBoxView:indexPath.item andThumbNail:cellImage withPFObject:touchedObject];
}

//LIGHTBOX
- (void)showLightBoxView:(NSInteger)itemIndex andThumbNail:(UIImage *)thumbnail withPFObject:(PFObject *)object {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showSnapFullScreen:object preload:thumbnail shouldShowVoter:NO];
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
    int pointsGranted = kParseLikingPoints;
    int imgVote = kParseLikedPoints;

    PFObject *voteSnap= [_snapsArray objectAtIndex:snapIndex];
    [voteSnap fetchInBackground];
    
    NSMutableArray *likeArray= [[NSMutableArray alloc] initWithArray:voteSnap[@"likes"]];
    NSMutableArray *disArray= [[NSMutableArray alloc] initWithArray:voteSnap[@"dislikes"]];
    if ([(OMGTabBarViewController *)self.parentViewController checkUserInArray:likeArray]) {
        [likeArray addObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
        voteSnap[@"dislikes"] = [self removeUserInArray:disArray];
    } else {
        pointsGranted = 0;
        imgVote = 0;
    }
    
    NSInteger likesnet= [voteSnap[@"netlikes"] integerValue];
    voteSnap[@"netlikes"] = [NSNumber numberWithInteger:likesnet + imgVote];
    voteSnap[@"likes"] = likeArray;
    
    [voteSnap saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSInteger score = [[DataHolder DataHolderSharedInstance].userObject[@"points"] integerValue] + pointsGranted;
        [DataHolder DataHolderSharedInstance].userObject[@"points"] = [NSNumber numberWithInteger:score];
        [[DataHolder DataHolderSharedInstance].userObject saveInBackground];
    }];
    
    [self cleanUpItems:snapIndex];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Action":@"VoteUp"} forEvent:@"Explore"];
}

- (void) omgSnapVOTEDOWN:(NSInteger) snapIndex {
    int pointsGranted = kParseLikingPoints;
    int imgVote = kParseLikedPoints;

    PFObject *voteSnap= [_snapsArray objectAtIndex:snapIndex];
    [voteSnap fetchInBackground];
    
    NSMutableArray *disLikeArray= [[NSMutableArray alloc] initWithArray:voteSnap[@"dislikes"]];
    NSMutableArray *likeArray= [[NSMutableArray alloc] initWithArray:voteSnap[@"likes"]];
    if ([(OMGTabBarViewController *)self.parentViewController checkUserInArray:disLikeArray]) {
        [disLikeArray addObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
        voteSnap[@"likes"] = [self removeUserInArray:likeArray];
    } else {
        pointsGranted = 0;
        imgVote = 0;
    }
    
    NSInteger likesnet= [voteSnap[@"netlikes"] integerValue];
    voteSnap[@"netlikes"] = [NSNumber numberWithInteger:likesnet - imgVote];
    if (kAdminDebug && likesnet <= 0) {
        voteSnap[@"netlikes"] = [NSNumber numberWithInteger:0];
    }

    voteSnap[@"dislikes"] = disLikeArray;
    [voteSnap saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSInteger score = [[DataHolder DataHolderSharedInstance].userObject[@"points"] integerValue] + pointsGranted;
        [DataHolder DataHolderSharedInstance].userObject[@"points"] = [NSNumber numberWithInteger:score];
        [[DataHolder DataHolderSharedInstance].userObject saveInBackground];
    }];
    
    [self cleanUpItems:snapIndex];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Action":@"VoteDown"} forEvent:@"Explore"];
}



#pragma SHARE
- (void) omgSnapShareImage:(UIImage *)image {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner shareItem:image];
}


#pragma FLAG
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

- (void) iba_showUserForImage:(NSInteger) snapIndex {
    PFObject *snapObj= [_snapsArray objectAtIndex:snapIndex];
    PFUser *userObj = snapObj[@"userId"];
    NSLog(@"Object ID %@", userObj.objectId );
    [self.delegate showUserSnaps:userObj];
}


@end
