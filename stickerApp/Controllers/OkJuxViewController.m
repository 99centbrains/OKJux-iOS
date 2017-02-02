//
//  OkJuxViewController.m
//  okjux
//
//  Created by German Pereyra on 2/2/17.
//
//

#import "OkJuxViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface OkJuxViewController ()

@end

@implementation OkJuxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if !(DEBUG)
    NSLog(@"viewDidLoad %@", self.class);
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if !(DEBUG)
    NSLog(@"viewWillAppear %@", self.class);
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
#if !(DEBUG)
    NSLog(@"viewWillDisappear %@", self.class);
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
#if !(DEBUG)
    NSLog(@"didReceiveMemoryWarning %@", self.class);
#endif
}


@end
