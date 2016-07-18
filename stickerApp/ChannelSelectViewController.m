//
//  ChannelSelectViewController.m
//  catwang
//
//  Created by Fonky on 2/18/15.
//
//

#import "ChannelSelectViewController.h"
#import "ChannelSelectViewCell.h"

@interface ChannelSelectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>



@property (nonatomic, weak) IBOutlet UICollectionView *ibo_collectionView;
@end

@implementation ChannelSelectViewController
@synthesize delegate;

- (void)viewDidLoad {
    
    self.title = @"Channels";
    
    _array_channels = @[@"Animals",
                        @"Art",
                        @"Funny",
                        @"Fashion",
                        @"Food",
                        @"Gaming",
                        @"Music",
                        @"Nerd",
                        @"Party",
                        @"Places",
                        @"Quotes",
                        @"Selfie",
                        @"Stickers",
                        @"TV"
                        
                        ];
    
    _array_icons = @[   @"🐱",
                        @"🎨",
                        @"😜",
                        @"👓",
                        @"🍕",
                        @"👾",
                        @"🎹",
                        @"📱",
                        @"🎉",
                        @"🏠",
                        @"💬",
                        @"👀",
                        @"✨",
                        @"📺"
                        
                        ];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSLog(@"SECTION %d", [stickerpack_dir count]);
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //NSLog(@"Items %d", [[_array_stickerpack_dir objectAtIndex:section] count]);
    return [_array_channels count];
    
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ChannelSelectViewCell *cell = (ChannelSelectViewCell *)[collectionView
                                                                            dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                            forIndexPath:indexPath];
    
    
    
    cell.ibo_channelTitle.text = [_array_channels objectAtIndex:indexPath.item];
    cell.ibo_channelIcon.text = [_array_icons objectAtIndex:indexPath.item];

    
    
    return cell;
}

//
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:YES];
   [self.delegate channelSelectWithTitle:self withChannel:[_array_channels objectAtIndex:indexPath.item] withIcon:[_array_icons objectAtIndex:indexPath.item]];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionView.frame.size.width, 60);
    
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
