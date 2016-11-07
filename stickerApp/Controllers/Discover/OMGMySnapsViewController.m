//
//  OMGMySnapsViewController.m
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import "OMGMySnapsViewController.h"

#import "DataHolder.h"
#import "AppDelegate.h"
#import "OMGSnapCollectionViewCell.h"
#import "TAOverlay.h"
#import "OMGLightBoxViewController.h"
#import "OMGTabBarViewController.h"


@interface OMGMySnapsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, OMGSnapCollectionViewCellDelegate, OMGLightBoxViewControllerDelegate>{

}

@property (nonatomic, weak) IBOutlet UILabel *ibo_karmaPoints;
@property (nonatomic, weak) IBOutlet UILabel *ibo_karmaDescriptor;

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;
@property (nonatomic, strong ) PFObject *snapObject;
@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;


@property (nonatomic, weak) IBOutlet UIView *ibo_notAvailableView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_notAvailableDescription;


@end

@implementation OMGMySnapsViewController

@synthesize delegate;

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
     _ibo_notAvailableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [_ibo_collectionView addSubview:refreshControl];
    
    _ibo_notAvailableDescription.text = NSLocalizedString(@"PERMISSION_NO_PUBLISHED", nil);
    _ibo_notAvailableView.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self updateKarma];
        [TAOverlay hideOverlay];

        [self queryTopSnapsByChannel:nil];
    
    });
    
    _ibo_karmaDescriptor.text = NSLocalizedString(@"EXP_KARMA", nil);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)startRefresh:(UIRefreshControl *)refresh{
    
    [(UIRefreshControl *)refresh endRefreshing];
    [self queryTopSnapsByChannel:nil];

    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self updateKarma];

}

- (void) reloadData{

    if ([[DataHolder DataHolderSharedInstance].arrayMySnaps count] > 0){
        [_ibo_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    
    [TAOverlay showOverlayWithLabel:@"Loading Snaps" Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.1245123 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self queryTopSnapsByChannel:nil];
    });
    

}

- (void) loadUser:(PFUser *)userBlock{
    
    PFQuery *query= [PFQuery queryWithClassName:@"snap"];
    //query.limit = 100;
    
    [query whereKey:@"userId" equalTo:userBlock];
    [query orderByDescending:@"createdAt"];
    
    //[query whereKey:@"hidden" equalTo:[NSNumber numberWithBool:0]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [DataHolder DataHolderSharedInstance].arrayMySnaps = objects;
        [_ibo_collectionView reloadData];
        [TAOverlay hideOverlay];
        
        
        if ([objects count] <= 0){
            _ibo_notAvailableView.hidden = NO;
        }
        
    }];

}

- (void) queryTopSnapsByChannel:(NSString *)channel {
    

    PFQuery *query= [PFQuery queryWithClassName:@"snap"];
    query.limit = 100;

    [query whereKey:@"userId" equalTo:[DataHolder DataHolderSharedInstance].userObject];
    [query orderByDescending:@"createdAt"];
    
    //[query whereKey:@"hidden" equalTo:[NSNumber numberWithBool:0]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [DataHolder DataHolderSharedInstance].arrayMySnaps = objects;
        [_ibo_collectionView reloadData];
        [TAOverlay hideOverlay];
        
        
        if ([objects count] <= 0){
            _ibo_notAvailableView.hidden = NO;
        }
        
    }];
    
    
    
    
}


- (void) updateKarma {
    
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner.ibo_headSpace updateKarma];
    NSString *karmaPoints = [NSString stringWithFormat:@"%@",
                             [DataHolder DataHolderSharedInstance].userObject[@"points"]];
    _ibo_karmaPoints.text = karmaPoints;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iba_dismissVC:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSLog(@"SECTION %d", [stickerpack_dir count]);
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [[DataHolder DataHolderSharedInstance].arrayMySnaps count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    PFObject *currentObject = [[DataHolder DataHolderSharedInstance].arrayMySnaps objectAtIndex:indexPath.item];
    
    OMGSnapCollectionViewCell *cell = (OMGSnapCollectionViewCell *)[collectionView
                                                                    dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                    forIndexPath:indexPath];
    
    //NSLog(@"CELL");
    
    cell.intCurrentSnap = indexPath.item;
    cell.delegate = self;
    
    // IMAGE LOADING
    PFFile * imageFile;
    
    if (currentObject[@"thumbnail"]){
        imageFile = currentObject[@"thumbnail"];
    } else {
        imageFile = currentObject[@"image"];
    }
    
    [cell setThumbnailImage:[NSURL URLWithString:imageFile.url]];
    
    NSNumber *netLikes= currentObject[@"netlikes"];
    cell.ibo_photoKarma.text = [NSString stringWithFormat:@"%@", netLikes];
    
    
    cell.ibo_voteContainer.hidden = YES;
    cell.ibo_shareBtn.hidden = YES;
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    OMGSnapCollectionViewCell *featuredCell = (OMGSnapCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    UIImage *cellImage = featuredCell.ibo_userSnapImage.image;
    
    NSLog(@"INDEX PATH TAP %ld", (long)indexPath.item);
    PFObject *touchedObject = [[DataHolder DataHolderSharedInstance].arrayMySnaps objectAtIndex:indexPath.item];
    
    [self showLightBoxView:indexPath.item andThumbNail:cellImage withPFObject:touchedObject];
    
}

- (void)showLightBoxView:(NSInteger)itemIndex andThumbNail:(UIImage *)thumbnail withPFObject:(PFObject *)object {

    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showSnapFullScreen:object preload:thumbnail shouldShowVoter:NO];

}

#pragma CELL DELETE
- (void) omgsnapCellDelete:(NSInteger) snapIndex{
    

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Manage Posts" message:@"Manage your public pics." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
        
        PFObject *snapObject= [[DataHolder DataHolderSharedInstance].arrayMySnaps objectAtIndex:snapIndex];
        [snapObject fetchInBackground];
                
        [snapObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            NSMutableArray *tempArray = [[DataHolder DataHolderSharedInstance].arrayMySnaps
                                         mutableCopy];
            [tempArray removeObjectAtIndex:snapIndex];
            [DataHolder DataHolderSharedInstance].arrayMySnaps = [tempArray copy];
            
            [_ibo_collectionView reloadData];

        }];
        
                
        
        
    }];
    
    UIAlertAction *actionRemove = [UIAlertAction actionWithTitle:@"Nevermind" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // DO NOTHING
        
    }];
    
    
    
    
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
- (IBAction)iba_notAvailableAction:(id)sender{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
