//
//  CBColorPickerViewController.m
//  catwang
//
//  Created by 99centbrains on 12/3/13.
//
//

#import "CBColorPickerViewController.h"
#import "CBColorPickerCollectionCell.h"

@interface CBColorPickerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>{
    
    IBOutlet UICollectionView *ibo_CollectionView;
    NSMutableArray *borderColorPallette;
}

@end

@implementation CBColorPickerViewController
@synthesize delegate;
@synthesize highRes;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    borderColorPallette = [[NSMutableArray alloc] init];
    [borderColorPallette addObject:@"i_gradient0.png"];

    for (int i = 2; i <= 30; i++){
        [borderColorPallette addObject:[NSString stringWithFormat:@"i_swatch_%d.png", i]];
    }
    
    for (int i = 1; i <= 12; i++){
        [borderColorPallette addObject:[NSString stringWithFormat:@"i_gradient%d.png", i]];
    }
    
    
    for (int i = 0; i <= 15; i++){
        [borderColorPallette addObject:[NSString stringWithFormat:@"i_pattern_%d.png", i]];
    }
  
    ibo_CollectionView.delegate = self;
    ibo_CollectionView.dataSource = self;
    [ibo_CollectionView registerClass:[CBColorPickerCollectionCell class] forCellWithReuseIdentifier:@"cvCell"];
  
    [ibo_CollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"ADD NumberOfSectionsInCollectionView");
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"ADD Number of Items in Section");
    return [borderColorPallette count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CBColorPickerCollectionCell *cell = (CBColorPickerCollectionCell *)[collectionView
                                                          dequeueReusableCellWithReuseIdentifier:@"cvCell"
                                                          forIndexPath:indexPath];
    
    UIImage *btnImage = [UIImage imageNamed:[borderColorPallette objectAtIndex:indexPath.row]];
    [cell.ibo_btn setImage:btnImage];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger CellSize = collectionView.frame.size.width/5;
    return CGSizeMake(CellSize,CellSize);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *btnImage = [UIImage imageNamed:[borderColorPallette objectAtIndex:indexPath.row]];
    [self.delegate CBColorPickerVCChangeColor:self withImage:btnImage];
    
    NSLog(@"TAPPED %ld", (long)indexPath.section);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
