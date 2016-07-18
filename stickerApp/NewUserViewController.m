//
//  NewUserViewController.m
//  catwang
//
//  Created by Fonky on 2/9/15.
//
//

#import "NewUserViewController.h"
#import "NewUserViewCell.h"

#import "AppDelegate.h"

@interface NewUserViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView * ibo_collectionView;

@property (nonatomic, weak) IBOutlet UIButton * ibo_btnNext;

@property (nonatomic) NSInteger currentpage;

@property (nonatomic, strong) NSArray * array_ftueInstructions;
@property (nonatomic, strong) NSArray * array_ftueInstructionsDesc;
@property (nonatomic, strong) NSArray * array_ftueImages;

@end

@implementation NewUserViewController

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];

    
    _array_ftueInstructions = @[NSLocalizedString(@"TUT_SNAP_TITLE", nil),
                                NSLocalizedString(@"TUT_STYLE_TITLE", nil),
                                NSLocalizedString(@"TUT_DROP_TITLE", nil),
                                NSLocalizedString(@"TUT_KARMA_TITLE", nil),
                                NSLocalizedString(@"TUT_START_TITLE", nil)];
    
    _array_ftueInstructionsDesc = @[NSLocalizedString(@"TUT_SNAP_BODY", nil),
                                    NSLocalizedString(@"TUT_STYLE_BODY", nil),
                                    NSLocalizedString(@"TUT_DROP_BODY", nil),
                                    NSLocalizedString(@"TUT_KARMA_BODY", nil),
                                    NSLocalizedString(@"TUT_START_BODY", nil)];
    
    _array_ftueImages = @[@"i_ftue_01.png",
                         @"i_ftue_02.png",
                         @"i_ftue_03.png",
                         @"i_ftue_04.png",
                         @"i_ftue_05.png"];
    
    
    [_ibo_collectionView reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSections{
    
    return 1;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   return [_array_ftueInstructions count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NewUserViewCell *cell = (NewUserViewCell *)[collectionView
                                                dequeueReusableCellWithReuseIdentifier:@"cell"
                                                forIndexPath:indexPath];
    
    cell.ibo_titleLabel.text = [_array_ftueInstructions objectAtIndex:indexPath.item];
    cell.ibo_discriptionLabel.text = [_array_ftueInstructionsDesc objectAtIndex:indexPath.item];
    cell.ibo_panelImage.image = [UIImage imageNamed:[_array_ftueImages objectAtIndex:indexPath.item]];
    _currentpage = indexPath.item;
    

    
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    

    
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Collection Size %@", NSStringFromCGSize(_ibo_collectionView.frame.size));
    
    return CGSizeMake(_ibo_collectionView.frame.size.width, _ibo_collectionView.frame.size.height);


}


- (IBAction)iba_btnNext:(id)sender{
    
    AppDelegate *delegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (_currentpage < [_array_ftueInstructions count]-1){
        
        [_ibo_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentpage + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewUserKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewUserMakeSomething];
        [self dismissViewControllerAnimated:NO completion:^(void){
           
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        switch (_currentpage) {
            case 1:
                [delegate askForLocation];
                break;
                
            case 3:
                [delegate askForPush];
                break;
                
            default:
                break;
        }
    
        
    });
    

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
