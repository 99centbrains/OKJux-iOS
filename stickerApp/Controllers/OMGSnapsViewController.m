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

@interface OMGSnapsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *newestCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *hottestCollectionView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) NSMutableArray *newestSnapsArray;
@property (nonatomic, strong) NSMutableArray *hottestSnapsArray;
@property (nonatomic, assign) int currentHottestPage;
@property (nonatomic, assign) int currentNewestPage;
@end


@implementation OMGSnapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentNewestPage = self.currentHottestPage = 1;
    self.hottestCollectionView.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    [self fetchNewestSnaps];
    [self transitionBetweenCollections:NO];
}

- (void)transitionBetweenCollections:(BOOL)animated {
    //TODO: animate transition
    self.hottestCollectionView.hidden = [self isShowingNewest];
    self.newestCollectionView.hidden = ![self isShowingNewest];
}

- (BOOL)isShowingNewest {
    return self.segmentControl.selectedSegmentIndex == 0;
}

#pragma mark -
#pragma mark Load methods

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
    }

    return cell;
}

#pragma mark -
#pragma mark CollectionViewDelegate

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

@end
