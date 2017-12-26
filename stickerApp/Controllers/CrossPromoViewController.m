//
//  CrossPromoViewController.m
//  Catwang
//
//  Created by German Pereyra on 12/1/17.
//

#import "CrossPromoViewController.h"

#define kCrossPromoURL @"https://crosspromo.neonroots.com/okjux-ios"

@interface CrossPromoViewController ()  <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation CrossPromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(close)];
    self.navigationItem.rightBarButtonItem = doneButton;
    _webView.delegate = self;
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:kCrossPromoURL]]];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _webView.frame = self.view.bounds;
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request.URL.absoluteString);
    if ([request.URL.absoluteString containsString:@"cross_promo_link"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CrossPromoOpened"];
        [self close];
    }
    return YES;
}
@end
