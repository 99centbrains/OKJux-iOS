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

@implementation StickerHeaderCollectionCell
@synthesize delegate;

- (IBAction)iba_purchaseStickerPack:(id)sender{
    
    [[CWInAppHelper sharedHelper] buyProductWithProductIdentifier:_packID singleItem:YES];

}

- (IBAction)iba_TW:(id)sender{
    
    [self.delegate social_openURL:_url_Twitter];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"PackID":_packID, @"Viewed":[_url_Twitter absoluteString]} forEvent:@"Influencer"];
    
}

- (IBAction)iba_IG:(id)sender{
    
    [self.delegate social_openURL:_url_Instagram];
    
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"PackID":_packID, @"Viewed":[_url_Instagram absoluteString]} forEvent:@"Influencer"];
    
}


@end
