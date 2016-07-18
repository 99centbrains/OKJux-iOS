#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface AppManager : NSObject 
{
    UIAlertView *WaitingAlert;
}

+ (id )alloc;
- (id) init;
+ (AppManager *) AppManagerSharedInstance;

- (void)Show_Waiting_Alert;
- (void)Show_Waiting_Alert_With_Title:(NSString*)title;
- (void)Hide_Waiting_Alert;
- (void)Show_Alert_With_Title:(NSString*)title message:(NSString*)message;
- (void)Show_Network_Indicator;
- (void)Hide_Network_Indicator;
- (void)SetAppNotRunningFirstTime;
- (BOOL)IsAppRunningFirstTime;

@end
