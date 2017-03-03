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

@interface OMGSnapsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout>
//UI elements
@property (nonatomic, weak) IBOutlet UICollectionView *newestCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *hottestCollectionView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet OMGSnapHeaderView *mapHeaderView;
@property (weak, nonatomic) IBOutlet UIView *bodyContainerView;
@property (weak, nonatomic) IBOutlet UIView *draggableView;
@property (nonatomic, strong) OMGHeadSpaceViewController *navigation;

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
@end

//#define kStartVisibleScreenPosition (CGFloat)65
#define kMapExtraHeightSize (CGFloat)50
#define kMapAndCollectionsHeaderHeight (CGFloat) 170
#define kSegmentTopMinPosition (CGFloat)0
#define kExpandMapScrollTriggerPoint (CGFloat)100
#define kStatusBarHeight (CGFloat)20

@implementation OMGSnapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentNewestPage = self.currentHottestPage = 1;
    self.hottestCollectionView.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    [self fetchNewestSnaps];
    [self transitionBetweenCollections:NO];
    [self setUpUI];
}

- (void)setUpUI {
    [self setUpNavigation];

    self.segmentTopSpaceConstraint.constant = kMapAndCollectionsHeaderHeight;
    self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize;
    self.bodyContainerTopSpaceConstraint.constant = self.navigation.view.frame.size.height - kStatusBarHeight;
    self.draggableView.hidden = YES;

    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.draggableView.bounds;
    gradientMask.colors = @[(id)[UIColor whiteColor].CGColor,
                            (id)[UIColor whiteColor].CGColor,
                            (id)[UIColor clearColor].CGColor];
    gradientMask.locations = @[@0.0, @0.10, @0.30];
    self.draggableView.layer.mask = gradientMask;
}

- (void)setUpNavigation {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:nil];
    self.navigation = (OMGHeadSpaceViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_OMGHeadSpaceViewController"];
    self.navigation.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 65);
    self.navigation.delegate = self;
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

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user_id"] = [DataManager userID];
    params[@"type"] = @"newest";
    params[@"page"] = [NSString stringWithFormat:@"%ld", (long)self.currentNewestPage];

    [SnapServiceManager getSnaps:params OnSuccess:^(NSArray* responseObject ) {
        if (self.currentNewestPage == 1) {
            self.newestSnapsArray = [NSMutableArray arrayWithArray:responseObject];
        }else {
            [self.newestSnapsArray addObjectsFromArray:responseObject];
        }
        self.currentNewestPage++;

        [TAOverlay hideOverlay];
        [self.newestCollectionView reloadData];

    } OnFailure:^(NSError *error) {
        [TAOverlay hideOverlay];
    }];
}

- (void)fetchHottestSnaps {
    if (self.currentHottestPage != 1 && (self.hottestSnapsArray.count % SNAP_PER_PAGE) != 0) {
        return;
    }

    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"user_id"] = [DataManager userID];
    params[@"type"] = @"top";
    params[@"page"] = [NSString stringWithFormat:@"%ld", (long)self.currentHottestPage];

    [SnapServiceManager getSnaps:params OnSuccess:^(NSArray* responseObject ) {
        if (self.currentHottestPage == 1) {
            self.hottestSnapsArray = [NSMutableArray arrayWithArray:responseObject];
        }else {
            [self.hottestSnapsArray addObjectsFromArray:responseObject];
        }
        self.currentHottestPage++;

        [TAOverlay hideOverlay];
        [self.hottestCollectionView reloadData];

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

- (void)expandMap {
    self.mapHeightConstraint.constant = self.view.bounds.size.height - 50;
    self.bodyContainerTopSpaceConstraint.constant = self.view.frame.size.height - self.segmentControl.frame.size.height - 30;
    self.draggableView.alpha = 0;
    self.draggableView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.draggableView.alpha = 1;
    } completion:^(BOOL finished) {
        [self.newestCollectionView setContentOffset:CGPointMake(0, self.collectionHeaderHeight) animated:NO];
        [self.hottestCollectionView setContentOffset:CGPointMake(0, self.collectionHeaderHeight) animated:NO];
        self.newestCollectionView.scrollEnabled = NO;
        self.hottestCollectionView.scrollEnabled = NO;
        self.tapToCloseGesture.enabled = YES;
        self.dragToCloseGesture.enabled = YES;
    }];
}

- (void)collapseMap {

    self.isMapExpanded = NO;
    self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize;
    self.bodyContainerTopSpaceConstraint.constant = self.navigation.view.frame.size.height - kStatusBarHeight;
    self.segmentControl.superview.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self.newestCollectionView setContentOffset:CGPointZero animated:NO];
        [self.hottestCollectionView setContentOffset:CGPointZero animated:NO];
        self.draggableView.alpha = 0;
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.3 animations:^{
            self.segmentControl.superview.alpha = 1;
        } completion:^(BOOL finished) {
            self.draggableView.hidden = YES;
            self.newestCollectionView.scrollEnabled = YES;
            self.hottestCollectionView.scrollEnabled = YES;
            self.tapToCloseGesture.enabled = NO;
            self.dragToCloseGesture.enabled = NO;
        }];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.isMapExpanded)
        return;

    //MOVE SEGMENT
    CGFloat newSegmentPosition = kMapAndCollectionsHeaderHeight + -scrollView.contentOffset.y;
    if (newSegmentPosition >= 0) {
        self.segmentTopSpaceConstraint.constant = newSegmentPosition;
    } else {
        self.segmentTopSpaceConstraint.constant = 0;
    }

    //RESIZE MAP
    if (scrollView.contentOffset.y < 0) {
        self.mapHeightConstraint.constant = kMapAndCollectionsHeaderHeight + kMapExtraHeightSize + -scrollView.contentOffset.y;
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
    self.collectionHeaderHeight = kMapAndCollectionsHeaderHeight + self.segmentControl.frame.size.height + kStatusBarHeight;
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

@end
