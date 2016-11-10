//
//  CBFontCollectionViewController.m
//  catwang
//
//  Created by Fonky on 1/2/15.
//
//

#import "CBFontCollectionViewController.h"
#import "CBFontCollectionViewCell.h"

@interface CBFontCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>{
    
    IBOutlet UICollectionView *ibo_collectionView;

}

@property (nonatomic, strong) NSMutableArray *fontCollection;
@end

@implementation CBFontCollectionViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    _fontCollection = [[NSMutableArray alloc] init];
    NSArray *fontFamilies = [UIFont familyNames];
    
    for (int i = 0; i < [fontFamilies count]; i++) {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSLog(@"Font: %@", fontFamily);
        [_fontCollection addObject:fontFamily];
    }
    
    NSLog (@"%@", _fontCollection);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_fontCollection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CBFontCollectionViewCell *cell = (CBFontCollectionViewCell *)[collectionView
                                                                        dequeueReusableCellWithReuseIdentifier:@"fontCell"
                                                                        forIndexPath:indexPath];
    [cell.fontDisplayLabel setFont:nil];
    UIFont *font = [UIFont fontWithName:[_fontCollection objectAtIndex:indexPath.row] size:24];
    [cell.fontDisplayLabel setFont:font];
    cell.fontDisplayLabel.text = [_fontCollection objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CBFontCollectionViewCell *cell = (CBFontCollectionViewCell *)[collectionView
                                                                  dequeueReusableCellWithReuseIdentifier:@"fontCell"
                                                                  forIndexPath:indexPath];
    
    NSLog(@"Font: %@", cell.fontDisplayLabel.font.fontName);
    UIFont *font = [UIFont fontWithName:[_fontCollection objectAtIndex:indexPath.row] size:48];
    [self.delegate CBFontCollectionDidChooseFont:self withFont:font];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
