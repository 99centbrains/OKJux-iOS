

#import "OMGSnapViewController.h"
#import "OMGSnapCollectionViewCell.h"
#import "DataHolder.h"
#import "TAOverlay.h"
#import "OMGLightBoxViewController.h"
#import "ChannelSelectViewController.h"
#import "OMGTabBarViewController.h"
#import "NewUserViewController.h"
@interface OMGSnapViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, OMGLightBoxViewControllerDelegate, ChannelSelectViewControllerDelegate>{
    
    BOOL alreadyVoted;
    NSInteger pagination;
    BOOL gettingData;
    


}


@property (nonatomic, weak) IBOutlet UICollectionView * ibo_snapCollectionView;

@property (nonatomic, strong ) PFObject *snapObject;

@property (nonatomic, strong) NSMutableArray *snapsArray;

@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;

@property (nonatomic, weak) IBOutlet UIButton *ibo_icon_emoji;
@property (nonatomic, weak) IBOutlet UILabel *ibo_channel_label;

@property (nonatomic, weak) IBOutlet UIView *ibo_notAvailableView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_notAvailableDescription;

@property (nonatomic, weak) IBOutlet UISegmentedControl *ibo_segmentControl;


@end

@implementation OMGSnapViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bool_trending = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];

    _snapsArray = [[NSMutableArray alloc] init];
   
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [_ibo_snapCollectionView addSubview:refreshControl];
    
    pagination = 0;
    gettingData = NO;
    
    
    [_ibo_segmentControl setTitle:NSLocalizedString(@"TOGGLE_RISING", nil) forSegmentAtIndex:0];
    [_ibo_segmentControl setTitle:NSLocalizedString(@"TOGGLE_TOP", nil) forSegmentAtIndex:1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self queryTopSnapsByChannel:nil];
        
    });
    
    _ibo_notAvailableDescription.text = NSLocalizedString(@"PERMISSION_NO_PHOTOS", nil);
    _ibo_notAvailableView.hidden = YES;
    
    
}


- (void)viewWillAppear:(BOOL)animated{

    
    
}

- (void)startRefresh:(UIRefreshControl *)refresh{

    [(UIRefreshControl *)refresh endRefreshing];
    [self queryTopSnapsByChannel:nil];
    
}

- (void)updateObject:(PFObject *)object{
    
    NSInteger objNum = [_snapsArray indexOfObject:object];
    NSLog(@"You Tapped Object %ld", (long)objNum);
    
    [_ibo_snapCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:objNum inSection:0]]];
    
}

- (void) queryTopSnapsByChannel:(NSString *)channel {
    
    gettingData = YES;
    
    _ibo_notAvailableView.hidden = YES;

    PFQuery *query= [PFQuery queryWithClassName:@"snap"];
    query.limit = 40;
    query.skip = 40 * pagination;

    [query addDescendingOrder:@"netlikes"];
    
    if (!_bool_trending){
        [query whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate dateWithTimeIntervalSinceNow:-86400]];
    }
    
    [query whereKey:@"hidden" equalTo:[NSNumber numberWithBool:0]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"OBJECTS %lu", (unsigned long)[objects count]);
        
        //[_snapsArray addObjectsFromArray:objects];
        //[_ibo_snapCollectionView reloadData];
        
        [self insertItemsIntoCollectionView:objects];
        
        [TAOverlay hideOverlay];
        
        if ([objects count] <= 0){
            _ibo_notAvailableView.hidden = NO;
        }
        
    }];
  
}

- (IBAction)iba_toggleTrending:(UISegmentedControl *)sender{
    
    NSLog(@"TOGGLE TRENDING");
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];

    
    gettingData = YES;
    pagination = 0;
    
    [self refreshData];
    [_snapsArray removeAllObjects];
    NSLog(@"REMOVE ALL OBJECTS %lu", (unsigned long)[_snapsArray count]);
    [_ibo_snapCollectionView reloadData];
    
    if (sender.selectedSegmentIndex == 0){
        
        _bool_trending = NO;
        
    } else {
        
        _bool_trending = YES;
    }
    
    NSLog(@"TOGGLE %d", _bool_trending);
    
    [self queryTopSnapsByChannel:nil];
    

}

- (void) insertItemsIntoCollectionView:(NSArray *)items {
    
    [_ibo_snapCollectionView performBatchUpdates:^{
        
        NSInteger resultsSize = [_snapsArray count];
        [_snapsArray addObjectsFromArray:[items copy]];
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        
        for (NSInteger i = resultsSize; i < resultsSize + items.count; i++)
            [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [_ibo_snapCollectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
        
    } completion:^(BOOL finished) {
        
        gettingData = NO;
        
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGSize sizer;
    
    
    if (CGRectIntersectsRect(scrollView.bounds, CGRectMake(0, _ibo_snapCollectionView.contentSize.height, CGRectGetWidth(self.view.frame), 200)) && _ibo_snapCollectionView.contentSize.height > 0) {
        
        if (!gettingData){
            pagination ++;
            [self queryTopSnapsByChannel:nil];
        }
        
    }

}


- (void)refreshData{
    
    if ([_snapsArray count] > 0){
        
        [_ibo_snapCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    NSLog(@"Refresh");
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize sizer;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sizer = CGSizeMake(_ibo_snapCollectionView.frame.size.width/4,
                           _ibo_snapCollectionView.frame.size.width /4 + 40);
    } else {
        sizer = CGSizeMake(_ibo_snapCollectionView.frame.size.width/2,
                           _ibo_snapCollectionView.frame.size.width /2 + 80);
    }
    
    
    return sizer;

}


#pragma COLLECTIONVIEW
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [_snapsArray count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    PFObject *currentObject = [_snapsArray objectAtIndex:indexPath.item];

    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                    forIndexPath:indexPath];
    

    
    cell.intCurrentSnap = indexPath.item;

    // IMAGE LOADING
    PFFile * imageFile = currentObject[@"image"];


    if (currentObject[@"thumbnail"]){
        imageFile = currentObject[@"thumbnail"];
    } else {
        imageFile = currentObject[@"image"];
    }

    [cell setThumbnailImage:[NSURL URLWithString:imageFile.url]];

    NSNumber *netLikes= currentObject[@"netlikes"];
    cell.ibo_photoKarma.text = [NSString stringWithFormat:@"%@", netLikes];

    [cell.ibo_btn_likeUP setSelected:NO];
    [cell.ibo_btn_likeDown setSelected:NO];

    cell.ibo_btn_likeUP.userInteractionEnabled = NO;
    cell.ibo_btn_likeDown.userInteractionEnabled = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.1244 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        cell.ibo_btn_likeUP.userInteractionEnabled = YES;
        cell.ibo_btn_likeDown.userInteractionEnabled = YES;

    });
    
    cell.ibo_voteContainer.hidden = YES;
    cell.ibo_shareBtn.hidden = YES;

    return cell;



}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;
    
    NSLog(@"INDEX PATH TAP %ld", (long)indexPath.item);
    PFObject *touchedObject = [_snapsArray objectAtIndex:indexPath.item];
    
    [self showLightBoxView:indexPath.item andThumbNail:cellImage withPFObject:touchedObject];
    
}

#pragma LIGHTBOX

- (void)showLightBoxView:(NSInteger)itemIndex andThumbNail:(UIImage *)thumbnail withPFObject:(PFObject *)object {
    
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showSnapFullScreen:object preload:thumbnail shouldShowVoter:NO];
    

}


#pragma NO DATA AVAILABLE
- (IBAction)iba_notAvailableAction:(id)sender{
    
    NSString *textToShare = kShareDescription;
    
    NSURL *url = [NSURL URLWithString:@"http://okjux.com/"];
    UIImage *imgData = [UIImage imageNamed:@"icon_promo.png"];
    
    
    
    NSArray *activityItems = [[NSArray alloc]  initWithObjects:textToShare, imgData, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];
    
    
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog(@"Activity Completion");
        
        if (activityType){
            
        }
        
    }];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        //        _popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        //        _popController.delegate = self;
        //        _popController.popoverContentSize = CGSizeMake(self.view.frame.size.width/2, 800); //your custom size.
        //        [_popController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
        //
    } else {
        
        [self presentViewController:activityVC animated:YES completion:nil];
        
    }
    
}



/*
#pragma mark - Navigation

 In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     Get the new view controller using [segue destinationViewController].
     Pass the selected object to the new view controller.
}
*/

@end
