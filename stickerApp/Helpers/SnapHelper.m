//
//  SnapHelper.m
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import "SnapHelper.h"
#import "SnapServiceManager.h"
#import "TAOverlay.h"

@implementation SnapHelper

+ (void)reportSnap:(Snap *)snap fromViewController:(UIViewController *)viewController {

    NSString *messageBody = snap.reported ?  NSLocalizedString(@"PROMPT_ALREADY_FLAGED_BODY", nil) : NSLocalizedString(@"PROMPT_FLAG_BODY", nil);

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PROMPT_FLAG_TITLE", nil)
                                                                         message:messageBody
                                                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action_spam = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_FLAG_ACTION", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [SnapServiceManager reportSnap:snap.ID OnSuccess:^(NSDictionary *responseObject) {
            [TAOverlay showOverlayWithLabel:NSLocalizedString(@"PUBLISH_DONE", nil) Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionAutoHide)];
            snap.reported = YES;
        } OnFailure:^(NSError *error) {
            [TAOverlay showOverlayWithLabel:@"Oops! Try again later." Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError];
        }];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:!snap.reported ? NSLocalizedString(@"PROMPT_FLAG_CANCEL", nil) : NSLocalizedString(@"OK_BUTTON", nil)
                                                     style:UIAlertActionStyleDefault handler:nil];

    if (!snap.reported) {
        [actionSheet addAction:action_spam];
    }
    [actionSheet addAction:cancel];

    [viewController presentViewController:actionSheet animated:YES completion:nil];
}

+ (void)shareItem:(UIImage *)image fromViewController:(UIViewController*)viewController {
    NSURL *url = [NSURL URLWithString:@"http://okjux.com/"];
    UIImage *imgData = image;

    NSArray *activityItems = [[NSArray alloc]  initWithObjects:imgData, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];

    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];

    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *_popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        _popController.popoverContentSize = CGSizeMake(viewController.view.frame.size.width/2, 800);
        [_popController presentPopoverFromRect:CGRectMake(viewController.view.frame.size.width/2, viewController.view.frame.size.height/4, 0, 0) inView:viewController.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    } else {
        [viewController presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
