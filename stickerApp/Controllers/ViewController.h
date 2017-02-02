//
//  ViewController.h
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCropViewController.h"
#import "OkJuxViewController.h"

@interface ViewController : OkJuxViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, CBCropViewControllerDelegate> {
    IBOutlet UIView *ibo_getphoto;
}

- (void)handleDocumentOpenURL:(NSString *)url;
- (void)handleExternalURL:(NSString*)url;
- (void)handleInternalURL:(NSString*)url;


@property (nonatomic, strong) IBOutlet UIView *ibo_getphoto;


@end
