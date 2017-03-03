//
//  OMGSnapsViewController.m
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import "OMGSnapsViewController.h"
#import "SnapServiceManager.h"
#import "Snap.h"
#import "TAOverlay.h"
#import "OMGSnapCollectionViewCell.h"
#import "SnapHelper.h"
#import "NSDate+DateTools.h"
#import "GeneralHelper.h"
#import "OMGSnapHeaderView.h"
#import "OMGHeadSpaceViewController.h"
#import "OMGLightBoxViewController.h"
#import "OMGSnapLocationPicker.h"

@protocol OMGSnapsCollectionSectionHeaderViewDelegate <NSObject>
- (void)collectionHeaderHasBeenTapped;
@end

@interface OMGSnapsCollectionSectionHeaderView : UICollectionReusableView
+ (NSString *)reuseIdentifier;
@property (nonatomic, weak) id<OMGSnapsCollectionSectionHeaderViewDelegate> delegate;
@end

@implementation OMGSnapsCollectionSectionHeaderView
+ (NSString *)reuseIdentifier {
    return  @"OMGSnapsCollectionSectionHeaderViewReuseIdentifier";
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)]];
    }
    return self;
}

- (void)tapGestureHandler {
    [self.delegate collectionHeaderHasBeenTapped];
}

@end

@interface OMGSnapsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout, OMGSnapsCollectionSectionHeaderViewDelegate>
//UI elements
@property (nonatomic, weak) IBOutlet UICollectionView *newestCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *hottestCollectionView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet OMGSnapHeaderView *mapHeaderView;
@property (weak, nonatomic) IBOutlet UIView *bodyContainerView;
@property (weak, nonatomic) IBOutlet UIView *draggableView;
@property (nonatomic, strong) OMGHeadSpaceViewController *navigation;
@property (nonatomic, strong) OMGLightBoxViewController *lightboxView;
@property (weak, nonatomic) IBOutlet UIView *backgroundCropView;

//Gestures
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *dragToCloseGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapToCloseGesture;

//UI Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newestCollectionTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyContainerTopSpaceConstraint;

//Data
@property (nonatomic, strong) NSMutableArray *newestSnapsArray;
@property (nonatomic, strong) NSMutableArray *hottestSnapsArray;
@property (nonatomic, assign) int currentHottestPage;
@property (nonatomic, assign) int currentNewestPage;
@property (nonatomic, assign) CGFloat collectionHeaderHeight;
@property (nonatomic, assign) BOOL isMapExpanded;
@property (nonatomic, assign) BOOL isFetchingData;
@end

//#define kStartVisibleScreenPosition (CGFloat)65
#define kMapExtraHeightSize (CGFloat)50
#define kMapAndCollectionsHeaderHeight (CGFloat) 170
#define kSegmentTopMinPosition (CGFloat)0
#define kExpandMapScrollTriggerPoint (CGFloat)100
#define kStatusBarHeight (CGFloat)20

@implementation OMGSnapsViewController
@synthesize lightboxView;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentNewestPage = self.currentHottestPage = 1;
    self.hottestCollectionView.hidden = YES;
    [self fetchNewestSnaps];
    [self transitionBetweenCollections:NO];
    [self setUpUI];
}

- (void)setUpUI {
    [self setUpNavigation];

    self.collectionHeaderHeight = kMapAndCollectionsHeaderHeight + self.segmentControl.frame.size.height + kStatusBarHeight;
    self.segmentTopSpaceConstraint.constant = kMapAndCollectionsHeaderHeight;
    self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize;
    self.bodyContainerTopSpaceConstraint.constant = self.navigation.view.frame.size.height - kStatusBarHeight;
    self.draggableView.hidden = YES;

    self.backgroundCropView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.draggableView.bounds;
    gradientMask.colors = @[(id)[UIColor whiteColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor clearColor].CGColor];
    gradientMask.locations = @[@0.0, @0.10, @0.30];
    self.draggableView.layer.mask = gradientMask;

    self.newestCollectionView.delegate = self;
    self.newestCollectionView.dataSource = self;
    self.hottestCollectionView.delegate = self;
    self.hottestCollectionView.dataSource = self;
    self.mapHeaderView.parent = self;
}

- (void)setUpNavigation {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:nil];
    self.navigation = (OMGHeadSpaceViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_OMGHeadSpaceViewController"];
    self.navigation.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
    self.navigation.delegate = self.mapHeaderView;
    self.navigation.ibo_titleLabel.text = NSLocalizedString(@"TABBAR_MAP_TITLE", nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.navigation updateKarma];
    });
    [self.view addSubview:self.navigation.view];
}

#pragma mark -
#pragma mark Fetch data and refresh

- (void)fetchNewestSnaps {
    if (self.currentNewestPage != 1 && (self.newestSnapsArray.count % SNAP_PER_PAGE) != 0) {
        return;
    }
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault];

    self.isFetchingData = YES;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user_id"] = [DataManager userID];
    params[@"type"] = @"newest";
    params[@"page"] = [NSString stringWithFormat:@"%ld", (long)self.currentNewestPage];

    [SnapServiceManager getSnaps:params OnSuccess:^(NSArray* responseObject ) {
        if (self.currentNewestPage == 1) {
            self.newestSnapsArray = [NSMutableArray arrayWithArray:responseObject];
        }else {
            for (Snap *snap in responseObject) {
                if (![self.newestSnapsArray containsObject:snap]){
                    [self.newestSnapsArray addObject:snap];
                }
            }
        }

        [TAOverlay hideOverlay];
        [self.newestCollectionView reloadData];
        self.isFetchingData = NO;

    } OnFailure:^(NSError *error) {
        [TAOverlay hideOverlay];
    }];
}

- (void)fetchHottestSnaps {
    if (self.currentHottestPage != 1 && (self.hottestSnapsArray.count % SNAP_PER_PAGE) != 0) {
        return;
    }
    self.isFetchingData = YES;

    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user_id"] = [DataManager userID];
    params[@"type"] = @"top";
    params[@"page"] = [NSString stringWithFormat:@"%ld", (long)self.currentHottestPage];

    [SnapServiceManager getSnaps:params OnSuccess:^(NSArray* responseObject ) {
        if (self.currentHottestPage == 1) {
            self.hottestSnapsArray = [NSMutableArray arrayWithArray:responseObject];
        }else {
            for (Snap *snap in responseObject) {
                if (![self.hottestSnapsArray containsObject:snap]){
                    [self.hottestSnapsArray addObject:snap];
                }
            }
        }
        [TAOverlay hideOverlay];
        [self.hottestCollectionView reloadData];
        self.isFetchingData = NO;

    } OnFailure:^(NSError *error) {
        [TAOverlay hideOverlay];
    }];
}

#pragma mark -
#pragma mark Utils

- (void)transitionBetweenCollections:(BOOL)animated {
    //TODO: animate transition
    self.hottestCollectionView.hidden = [self isShowingNewest];
    self.newestCollectionView.hidden = ![self isShowingNewest];
}

- (BOOL)isShowingNewest {
    return self.segmentControl.selectedSegmentIndex == 0;
}

- (BOOL)isShowingHottest {
    return self.segmentControl.selectedSegmentIndex == 1;
}

- (void)expandMap {
    self.mapHeightConstraint.constant = self.view.bounds.size.height - 50;
    self.bodyContainerTopSpaceConstraint.constant = self.view.frame.size.height - self.segmentControl.frame.size.height - 30;
    self.draggableView.alpha = 0;
    self.draggableView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.draggableView.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self.newestCollectionView setContentOffset:CGPointMake(0, self.collectionHeaderHeight) animated:NO];
        [self.hottestCollectionView setContentOffset:CGPointMake(0, self.collectionHeaderHeight) animated:NO];
        self.newestCollectionView.scrollEnabled = NO;
        self.hottestCollectionView.scrollEnabled = NO;
        self.tapToCloseGesture.enabled = YES;
        self.dragToCloseGesture.enabled = YES;
        self.draggableView.alpha = 1;

        [self.mapHeaderView showLocationPicker];
    }];
}

- (void)collapseMap {
    self.isMapExpanded = NO;
    self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize;
    self.bodyContainerTopSpaceConstraint.constant = self.navigation.view.frame.size.height - kStatusBarHeight;
    self.segmentControl.superview.alpha = 0;
    [self.mapHeaderView hideLocationPicker];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self.newestCollectionView setContentOffset:CGPointZero animated:NO];
        [self.hottestCollectionView setContentOffset:CGPointZero animated:NO];
        self.draggableView.alpha = 0;
        self.segmentControl.superview.alpha = 0.5;
    } completion:^(BOOL finished) {
        self.segmentControl.superview.alpha = 1;
        self.draggableView.hidden = YES;
        self.newestCollectionView.scrollEnabled = YES;
        self.hottestCollectionView.scrollEnabled = YES;
        self.tapToCloseGesture.enabled = NO;
        self.dragToCloseGesture.enabled = NO;
    }];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    if (self.hottestSnapsArray.count == 0) {
        [self fetchHottestSnaps];
    }
    [self transitionBetweenCollections:YES];
}

#pragma mark -
#pragma mark CollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.hottestCollectionView) {
        return [self.hottestSnapsArray count];
    }
    return [self.newestSnapsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Snap * snap;
    if (collectionView == self.hottestCollectionView) {
        snap = [self.hottestSnapsArray objectAtIndex:indexPath.item];
    } else {
        snap = [self.newestSnapsArray objectAtIndex:indexPath.item];
    }

    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"snapCell"
                                                                    forIndexPath:indexPath];
    cell.ibo_uploadDate.text = @"";
    cell.delegate = self;
    cell.snap = snap;
    cell.intCurrentSnap = indexPath.item;
    cell.ibo_voteContainer.hidden = NO;
    cell.ibo_shareBtn.hidden = NO;
    [cell loadSnap:snap];

    if ([self isShowingNewest]) {
        __block NSString *timeString = [GeneralHelper getTimeAgoFromString:snap.createdAt];
        cell.ibo_uploadDate.text = timeString;

        [GeneralHelper reverseGeoLocation:[snap.location[0] doubleValue] lng:[snap.location[1] doubleValue] completionHandler:^(NSString *locationString) {
            cell.ibo_uploadDate.text = [timeString stringByAppendingString:locationString];
        }];
    } else {
        cell.ibo_shareBtn.hidden = YES;
    }
    return cell;
}

#pragma mark -
#pragma mark CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;

    Snap *selectedSnap;
    if ([self isShowingNewest])
        selectedSnap = [self.newestSnapsArray objectAtIndex:indexPath.item];
    else
        selectedSnap = [self.hottestSnapsArray objectAtIndex:indexPath.item];
    [self showFullScreenSnap:selectedSnap preload:cellImage shouldShowVoter:NO];

}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {


        OMGSnapsCollectionSectionHeaderView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[OMGSnapsCollectionSectionHeaderView reuseIdentifier] forIndexPath:indexPath];

        if (reusableview == nil) {
            reusableview = [[OMGSnapsCollectionSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.newestCollectionView.frame.size.width, self.collectionHeaderHeight)];
        }
        reusableview.delegate = self;

        return reusableview;
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.isMapExpanded)
        return;

    //MOVE SEGMENT
    CGFloat newSegmentPosition = kMapAndCollectionsHeaderHeight + -scrollView.contentOffset.y;
    if (newSegmentPosition >= 0) {
        self.segmentTopSpaceConstraint.constant = newSegmentPosition;

        //MOVE BOTH COLLECTIONS AT THE SAME TIME
        if (scrollView == self.hottestCollectionView) {
            self.newestCollectionView.contentOffset = scrollView.contentOffset;
        } else {
            self.hottestCollectionView.contentOffset = scrollView.contentOffset;
        }
    } else {
        self.segmentTopSpaceConstraint.constant = 0;

        if (scrollView == self.hottestCollectionView) {
            self.newestCollectionView.contentOffset = CGPointMake(0, kMapAndCollectionsHeaderHeight);
        } else {
            self.hottestCollectionView.contentOffset = CGPointMake(0, kMapAndCollectionsHeaderHeight);
        }
    }

    //RESIZE MAP
    if (scrollView.contentOffset.y < 0) {
        self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize + -scrollView.contentOffset.y;
    }


    //GET MORE SNAPS WHEN USER REACH THE END
    if ([self isShowingNewest]) {
        if (CGRectIntersectsRect(self.newestCollectionView.bounds, CGRectMake(0, self.newestCollectionView.contentSize.height, CGRectGetWidth(self.view.frame), 200)) && self.newestCollectionView.contentSize.height > 0) {
            if (!self.isFetchingData) {
                self.currentNewestPage++;
                [self fetchNewestSnaps];
            }
        }
    }

    if ([self isShowingHottest]) {
        if (CGRectIntersectsRect(self.hottestCollectionView.bounds, CGRectMake(0, self.hottestCollectionView.contentSize.height, CGRectGetWidth(self.view.frame), 200)) && self.hottestCollectionView.contentSize.height > 0) {
            if (!self.isFetchingData) {
                self.currentHottestPage++;
                [self fetchHottestSnaps];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (-scrollView.contentOffset.y >= kExpandMapScrollTriggerPoint) {
        self.isMapExpanded = YES;
        [self expandMap];
    }
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.newestCollectionView.frame.size.width, self.collectionHeaderHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize sizer;

    if (collectionView == self.hottestCollectionView) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            sizer = CGSizeMake(self.hottestCollectionView.frame.size.width/4,
                               self.hottestCollectionView.frame.size.width/4 + 40);
        } else {
            sizer = CGSizeMake(self.hottestCollectionView.frame.size.width/2,
                               self.hottestCollectionView.frame.size.width/2 + 80);
        }
    } else {
        sizer = CGSizeMake(self.newestCollectionView.frame.size.width, self.newestCollectionView.frame.size.height);
    }
    return sizer;
}


#pragma mark -
#pragma mark OMGSnapCollectionViewCellDelegate

- (void)omgSnapFlagItem:(Snap *)object {
    [SnapHelper reportSnap:object fromViewController:self];
}

- (void)omgSnapShareImage:(UIImage *)image {
    [SnapHelper shareItem:image fromViewController:self];
}

#pragma mark -
#pragma mark Gestures

- (IBAction)draggableViewPanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];

    CGFloat initialValue = self.view.frame.size.height - CGRectGetMaxY(self.segmentControl.frame) - kStatusBarHeight;
    NSLog(@"%f, %f %f", translation.x, translation.y, initialValue + translation.y);
    self.bodyContainerTopSpaceConstraint.constant = initialValue + translation.y;
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self collapseMap];
    }
}
- (IBAction)tapToCollapse:(UIPanGestureRecognizer *)sender {
    [self collapseMap];
}

#pragma mark - 
#pragma mark OMGSnapsCollectionSectionHeaderViewDelegate

- (void)collectionHeaderHasBeenTapped {
    [self expandMap];
}

#pragma mark -
#pragma mark LightboxViewer

- (void)showFullScreenSnap:(Snap *)snap preload:(UIImage*)thumbnail shouldShowVoter:(BOOL)voter {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:[NSBundle mainBundle]];
    lightboxView = (OMGLightBoxViewController*)[mainSB instantiateViewControllerWithIdentifier: @"seg_OMGLightBoxViewController"];
    lightboxView.view.frame = self.view.frame;
    lightboxView.delegate = self;
    lightboxView.preloadImage = thumbnail;
    lightboxView.ibo_fade_voter.hidden = voter;
    [lightboxView setSnap:snap];

    [self.view addSubview:lightboxView.view];
}

- (void) omgSnapDismissLightBox:(Snap *)snap {
    [self.navigation updateKarma];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [lightboxView.view removeFromSuperview];
    lightboxView.delegate = nil;
    lightboxView = nil;

//    //Update snap cell on parent view
//    switch (self.selectedIndex) {
//        case 0:
//            _ibo_omgVoteVC = (OMGSnapVoteViewController *)[self.viewControllers objectAtIndex:0];
//            [_ibo_omgVoteVC updateObjectInCollection:snap];
//            break;
//        case 1:
//            _ibo_omgsnapVC = (OMGSnapViewController *)[self.viewControllers objectAtIndex:1];
//            [_ibo_omgsnapVC updateObjectInCollection:snap];
//            break;
//        case 3:
//            _ibo_mysnapsVC = (OMGMySnapsViewController *)[self.viewControllers objectAtIndex:3];
//            [_ibo_mysnapsVC updateKarma];
//            [_ibo_mysnapsVC updateObjectInCollection:snap];
//            break;
//        default:
//            break;
//    }
}


@end
