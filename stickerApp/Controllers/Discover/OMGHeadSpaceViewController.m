//
//  OMGHeadSpaceViewController.m
//  catwang
//
//  Created by Fonky on 2/19/15.
//
//

#import "OMGHeadSpaceViewController.h"
#import "DataManager.h"

@interface OMGHeadSpaceViewController ()

@end

@implementation OMGHeadSpaceViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateKarma];
    [_ibo_karmabtn setTitle:@"0" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateKarma {
  NSString* newKarma = [NSString stringWithFormat:@"%ld", (long)([DataManager karma] + 1)];
  [DataManager storeKarma:newKarma];
  [_ibo_karmabtn setTitle:newKarma forState:UIControlStateNormal];
}

- (IBAction)iba_emojiTime:(id)sender {
    [self.delegate omgEmojiTime];
}


@end
