//
//  CBDetailsViewController.m
//  99centbrains
//
//  Created by Franky Aguilar on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CBDetailsViewController.h"
#import <StoreKit/StoreKit.h>
#import <QuartzCore/CALayer.h>
#import "SVModalWebViewController.h"
#import "SVProgressHUD.h"
#import <Chartboost/Chartboost.h>

@interface CBDetailsViewController (){
    IBOutlet UILabel *versionNumber;
    IBOutlet UIWebView *mobileWebs;
}

- (IBAction)dismissSelf:(id)sender;

- (IBAction)visit_facebook:(id)sender;
- (IBAction)visit_twitter:(id)sender;
- (IBAction)visit_instagram:(id)sender;
- (IBAction)visit_tumblr:(id)sender;

- (IBAction)visit_web:(id)sender;

- (IBAction)reportbug:(id)sender;


@end



@implementation CBDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated{
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    
    NSString *urlAddress = kMoreAppsURL;
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [mobileWebs loadRequest:requestObj];
    mobileWebs.delegate = self;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *reportSubject =[NSString stringWithFormat:@"Version %@", majorVersion];
    versionNumber.text = reportSubject;
    
}

- (void)viewDidDisappear:(BOOL)animated{


}



- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
	NSURL *url = request.URL;
	NSLog(@"URL: %@", url.absoluteString);//http://mobile.99centbrains.com
    //NSLog(@"URL parameterString: %@", url.parameterString);
   
    //NSLog(@"URL relativeString: %@", url.relativeString);
    //NSLog(@"URL frag: %@", url.fragment);

    if (url.query){
         [self parseURLQuery:url.query];
    }
    if (url.fragment){
        //[self parseFrag:url.fragment];
    }
    
	return YES;
    
    
}

- (void)reloadWebView{

    //Load the request in the UIWebView.
    [mobileWebs goBack];

}

- (void)parseURLQuery:(NSString*)query{
  
  if (query!=nil){
    
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
    
    NSLog(@"URL QUERY %@", query);
    NSLog(@"URL COMPONENTES %d", [urlComponents count]);
    
    if ([urlComponents count] > 1) {
      NSString *keyValuePair = [urlComponents objectAtIndex:1];
      
      NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
      if ([pairComponents count] > 1) {
        
        
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        [queryStringDictionary setObject:value forKey:key];
        
        
        if ([queryStringDictionary objectForKey:@"website"]) {
          [self openSite:[queryStringDictionary objectForKey:@"website"]];
        }
        
        if ([queryStringDictionary objectForKey:@"weburl"]) {
          [self openURL:[queryStringDictionary objectForKey:@"weburl"]];
        }
        
        if ([queryStringDictionary objectForKey:@"app"]) {
          
          NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
          [f setNumberStyle:NSNumberFormatterDecimalStyle];
          NSNumber * myNumber = [f numberFromString:[queryStringDictionary objectForKey:@"app"]];
          [self buyApp:myNumber];
        }
      }
    }
  }
}

- (void)openURL:(NSString*)urlString{

    if (urlString!=nil){
      
        NSURL *URL = [NSURL URLWithString:urlString];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
        webViewController.barsTintColor = [UIColor blackColor];
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
      
        [self presentViewController:webViewController animated:YES completion:nil];
        
    }
}

- (void)openSite:(NSString*)urlString{
    
    if (urlString!=nil){
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:urlString]];
        
        
    }
}

- (void)buyApp:(NSNumber*)productId {
    
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending){
        SKStoreProductViewController* storeProductViewController = [[SKStoreProductViewController alloc] init];
        [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier :productId}
                                              completionBlock:nil];
        storeProductViewController.delegate = self;
        [self presentViewController:storeProductViewController animated:YES completion:nil];
        
    } else {
        
        NSString *appURL = [@"https://itunes.apple.com/app/id"
                            stringByAppendingString:[NSString stringWithFormat:@"%@%@", productId, @"&at=10ly5p"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:appURL]];
        
    }

   
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"Load");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [Chartboost showInterstitial:CBLocationDefault];
    NSLog(@"Finished");
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"Failed");
    
}



// ACTIONS
- (IBAction)iba_shareApp:(UIButton *)sender{

    NSString *textToShare = [NSString stringWithFormat:@"Hurry go download %@, on the App Store!", kAppShareName];
    UIImage *imageToShare = [UIImage imageNamed:@"icon_itunes.png"];
    NSURL *url = [NSURL URLWithString:kShareURL];
    
    NSArray *activityItems = [[NSArray alloc]  initWithObjects:textToShare, imageToShare, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:YES completion:^{
        }];
    } else {
        // Change Rect to position Popover
        UIPopoverController * popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }

    
    
}

- (IBAction)iba_dismiss:(id)sender{
    
    [SVProgressHUD dismiss];
    if (mobileWebs.isLoading){
        [mobileWebs stopLoading];
        
    }
    
    mobileWebs.delegate = nil;
    mobileWebs = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


//SHARE ACTIONS
- (IBAction)visit_facebook:(id)sender{
    
    
    NSURL *fanPageURL = [NSURL URLWithString:@"fb://profile/193823404061225"];
    if (![[UIApplication sharedApplication] openURL: fanPageURL]){
        
        [[UIApplication sharedApplication] openURL:[NSURL 
                                                    URLWithString:@"http://m.facebook.com/99centbrains"]];
        
    }
    
    else {
        [[UIApplication sharedApplication] openURL:fanPageURL];
        
    }


}
- (IBAction)visit_twitter:(id)sender{
    
    NSURL *fanPageURL = [NSURL URLWithString:@"twitter:///user?screen_name=99centbrains"];
    if (![[UIApplication sharedApplication] openURL: fanPageURL]){
        
        [[UIApplication sharedApplication] openURL:[NSURL 
                                                    URLWithString:@"http://twitter.com/99centbrains"]];
        
    }
    
    else {
        [[UIApplication sharedApplication] openURL:fanPageURL];
        
    }
    
}

- (IBAction)visit_instagram:(id)sender{
    
    NSURL *instagramURL = [NSURL 
                           URLWithString:@"instagram://user?username=99centbrains"];
    // OPENS USER 99CENTBRAINS
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you dont have Instagram on this Device!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }

}
- (IBAction)visit_tumblr:(id)sender{
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:@"http://blog.99centbrains.com"]];
}

- (IBAction)visit_web:(id)sender{
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:@"http://99centbrains.com"]];
}

- (IBAction)visit_shop:(id)sender{
    [self openURL:@"http://yoshirt.com"];
}


- (void)viewDidUnload {
    
    NSLog(@"UNLOADED");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
