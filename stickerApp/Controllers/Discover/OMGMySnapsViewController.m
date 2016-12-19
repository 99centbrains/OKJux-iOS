//
//  OMGMySnapsViewController.m
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import "OMGMySnapsViewController.h"

#import "AppDelegate.h"
#import "OMGSnapCollectionViewCell.h"
#import "TAOverlay.h"
#import "OMGLightBoxViewController.h"
#import "OMGTabBarViewController.h"
#import "Snap.h"
#import "UserServiceManager.h"
#import "DataManager.h"
#import "UserServiceManager.h"


@interface OMGMySnapsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, OMGLightBoxViewControllerDelegate>{

}

@property (nonatomic, weak) IBOutlet UILabel *ibo_karmaPoints;
@property (nonatomic, weak) IBOutlet UILabel *ibo_karmaDescriptor;

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;

@property (nonatomic, weak) IBOutlet UIView *ibo_notAvailableView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_notAvailableDescription;


@end

@implementation OMGMySnapsViewController

@synthesize delegate;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
     _ibo_notAvailableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [_ibo_collectionView addSubview:refreshControl];
    
    _ibo_notAvailableDescription.text = NSLocalizedString(@"PERMISSION_NO_PUBLISHED", nil);
    _ibo_notAvailableView.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self updateKarma];
        [TAOverlay hideOverlay];
        [self getCurrentUserSnaps];
    });
    
    _ibo_karmaDescriptor.text = NSLocalizedString(@"EXP_KARMA", nil);
    [super viewDidLoad];
}

- (void)startRefresh:(UIRefreshControl *)refresh {
    [(UIRefreshControl *)refresh endRefreshing];
    [self getCurrentUserSnaps];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateKarma];
}

- (void) getCurrentUserSnaps {
    [UserServiceManager getUserSnaps:[DataManager deviceToken] OnSuccess:^(NSArray* responseObject ) {
        _mySnaps = responseObject;
        [_ibo_collectionView reloadData];
        [TAOverlay hideOverlay];
        _ibo_notAvailableView.hidden = _mySnaps.count > 0;
    } OnFailure:^(NSError *error) {
        [TAOverlay hideOverlay];
        [TAOverlay showOverlayWithLabel:@"Oops! Try again later." Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError ];
    }];
}

//TODO check this
- (void)updateObjectInCollection:(Snap *)snap {
    NSInteger snapIndex = [_mySnaps indexOfObject:snap];
    [_ibo_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:snapIndex inSection:0]]];
}

- (void) updateKarma {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner.ibo_headSpace updateKarma];
  NSString *karmaPoints = [NSString stringWithFormat:@"%ld",
                           (long)[DataManager karma]];
    _ibo_karmaPoints.text = karmaPoints;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)iba_dismissVC:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_mySnaps count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Snap *snap = [_mySnaps objectAtIndex:indexPath.item];
    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                    forIndexPath:indexPath];
    cell.intCurrentSnap = indexPath.item;
    cell.delegate = self;
    NSString *imageUrl = snap.thumbnailUrl ? snap.thumbnailUrl : snap.imageUrl;
    [cell setThumbnailImage:[NSURL URLWithString:imageUrl]];
    cell.ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)snap.netlikes];
    cell.ibo_voteContainer.hidden = YES;
    cell.ibo_shareBtn.hidden = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;
    Snap *selectedSnap = [_mySnaps objectAtIndex:indexPath.item];
    [self showLightBoxViewSnap:indexPath.item andThumbnail:cellImage withSnap:selectedSnap];
}

- (void)showLightBoxViewSnap:(NSInteger)itemIndex andThumbnail:(UIImage *)thumbnail withSnap:(Snap *)snap {
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showFullScreenSnap:snap preload:thumbnail shouldShowVoter:NO];
}

#pragma CELL DELETE
- (void) omgsnapCellDelete:(NSInteger) snapIndex {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"DELETE_TITLE", nil)
                                                                         message:NSLocalizedString(@"DELETE_MESSAGE", nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:NSLocalizedString(@"DELETE", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                           [UserServiceManager deleteSnap:[_mySnaps[snapIndex] ID] OnSuccess:^(NSDictionary *responseObject) {
                                                             NSMutableArray *snaps = [_mySnaps mutableCopy];
                                                             [snaps removeObjectAtIndex:snapIndex];
                                                             _mySnaps = [snaps copy];
                                                             [_ibo_collectionView reloadData];
                                                             
                                                           } OnFailure:^(NSError *error) {
                                                             [TAOverlay showOverlayWithLabel:@"Oops! Try again later." Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError ];
                                                           }];
    }];
    
    UIAlertAction *actionRemove = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_REMIX_CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];

    [actionSheet addAction:actionDelete];
    [actionSheet addAction:actionRemove];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize sizer;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sizer = CGSizeMake(_ibo_collectionView.frame.size.width/4,
                           _ibo_collectionView.frame.size.width /4 + 40);
    } else {
        sizer = CGSizeMake(_ibo_collectionView.frame.size.width/2,
                           _ibo_collectionView.frame.size.width /2 + 80);
    }
    
    return sizer;
}


#pragma NO DATA AVAILABLE
- (IBAction)iba_notAvailableAction:(id)sender{}


@end
