#import "AppManager.h"

@implementation AppManager

static AppManager *AppManagerSharedInstance = nil;

+ (id ) alloc 
{
	@synchronized([AppManager class])
	{
		NSAssert(AppManagerSharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		AppManagerSharedInstance = [super alloc];
		return AppManagerSharedInstance;
	}
	return nil;
}
- (id) init 
{
	self = [super init];
	if (self != nil)
	{
        WaitingAlert = nil;
	}
	return self;
}
+ (AppManager *) AppManagerSharedInstance
{
	@synchronized ([AppManager class])
	{
		if (!AppManagerSharedInstance) 
		{
			AppManagerSharedInstance = [[AppManager alloc] init];
		}
		return AppManagerSharedInstance;
	}
	return nil;
}
- (void)Show_Waiting_Alert_With_Title:(NSString*)title
{
    if (WaitingAlert) {
        [self Hide_Waiting_Alert];
    }
    if (WaitingAlert == nil)
    {
        WaitingAlert = [[UIAlertView alloc] initWithTitle:title
                                                  message:@""
                                                 delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(WaitingAlert.bounds.size.width / 2 + 135, WaitingAlert.bounds.size.height + 75);
        [indicator startAnimating];
        [WaitingAlert addSubview:indicator];
    }
    [WaitingAlert show];
}
- (void)Show_Waiting_Alert
{
    if (WaitingAlert) {
        [self Hide_Waiting_Alert];
    }
    if (WaitingAlert == nil)
    {
        WaitingAlert = [[UIAlertView alloc] initWithTitle:@"Please Wait..."
                                                  message:@""
                                                 delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(WaitingAlert.bounds.size.width / 2 + 135, WaitingAlert.bounds.size.height + 75);
        [indicator startAnimating];
        [WaitingAlert addSubview:indicator];
    }
    [WaitingAlert show];
}
- (void)Show_Alert_With_Title:(NSString*)title message:(NSString*)message
{
    if (WaitingAlert) {
        [self Hide_Waiting_Alert];
    }
    if (WaitingAlert == nil)
    {
        WaitingAlert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    [WaitingAlert show];
}

- (void)Hide_Waiting_Alert
{
    [WaitingAlert dismissWithClickedButtonIndex:0 animated:YES];
    WaitingAlert = nil;
}
- (void)Show_Network_Indicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)Hide_Network_Indicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
-(void)SetAppNotRunningFirstTime 
{
	NSUserDefaults * defaults= [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"NO" forKey:@"IsAppRunningFirstTime"];
	[defaults synchronize];
}
-(BOOL)IsAppRunningFirstTime
{
	NSUserDefaults * defaults= [NSUserDefaults standardUserDefaults];
	if ([defaults objectForKey:@"IsAppRunningFirstTime" ] == nil )
	{
		[self SetAppNotRunningFirstTime];
        return YES;
	}		
    return NO;
}

@end
