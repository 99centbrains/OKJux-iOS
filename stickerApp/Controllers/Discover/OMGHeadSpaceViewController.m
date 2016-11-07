//
//  OMGHeadSpaceViewController.m
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import "OMGHeadSpaceViewController.h"

@interface OMGHeadSpaceViewController ()

@end

@implementation OMGHeadSpaceViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateKarma];
     [_ibo_karmabtn setTitle:@"0" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateKarma{

    NSLog(@"UPDATE KARMA **************************");
    PFUser *user = [DataHolder DataHolderSharedInstance].userObject;
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *karmaPoints = [NSString stringWithFormat:@"%@", object[@"points"]];
        [_ibo_karmabtn setTitle:karmaPoints forState:UIControlStateNormal];

    }];
    
    
//    [ fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        
//
//        
//    }];
    
  
    
}

- (IBAction)iba_emojiTime:(id)sender{
    
    [self.delegate omgEmojiTime];

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
