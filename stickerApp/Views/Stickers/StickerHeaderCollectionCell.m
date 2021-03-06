//
//  StickerHeaderCollectionCell.m
//  catwang
//
//  Created by Fonky on 1/14/15.
//
//

#import "StickerHeaderCollectionCell.h"
#import "CWInAppHelper.h"
#import "SVModalWebViewController.h"
#import "MixPanelManager.h"

@implementation StickerHeaderCollectionCell
@synthesize delegate;

- (IBAction)iba_purchaseStickerPack:(id)sender{
    [[CWInAppHelper sharedHelper] buyProductWithProductIdentifier:_packID singleItem:YES];
}

- (IBAction)iba_TW:(id)sender{
    [self.delegate social_openURL:_url_Twitter];
    [MixPanelManager triggerEvent:@"Influencer" withData:@{ @"PackID": _packID, @"Viewed": [_url_Twitter absoluteString] }];
}

- (IBAction)iba_IG:(id)sender{
    [self.delegate social_openURL:_url_Instagram];
    
    [MixPanelManager triggerEvent:@"Influencer" withData:@{ @"PackID": _packID, @"Viewed": [_url_Instagram absoluteString] }];
}

@end
