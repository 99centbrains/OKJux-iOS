//
//  InAppHelper.h
//  catwang
//
//  Created by Franky Aguilar on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class CWInAppHelper;

#define CWIAP_ProductPurchased @"CWInAppPurchase_Purchased"
#define CWIAP_Restore @"CWInAppPurchase_RestoreTitle"
#define CWIAP_ProductsAvailable @"CWInAppPurchase_ProductsAvailable"

//INTERFACE
@interface CWInAppHelper : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    
}

@property (nonatomic, strong) NSArray *productIDs;
@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic) BOOL singleItem;

+ (CWInAppHelper *) sharedHelper;

- (void)startRequest:(NSArray *)products;

- (BOOL)product_isPurchased:(NSString *)prodID;
- (void)product_setPurchased:(NSString *)prodID;

- (void)restore_purchases;



- (void)buyProductWithProductIdentifier:(NSString *)productIdentifier singleItem:(BOOL)flag;
- (void)buyAllProducts:(NSString *)productIdentifier;

- (BOOL) checkPackProducts:(NSString *)productID;



- (NSString*) getProductPrice:(NSString *)productIdentifier;
- (NSString*) getProductTitle:(NSString *)productIdentifier;
- (NSString*) getProductDescription:(NSString *)productIdentifier;
- (NSString *)productIdentifierForIndex:(NSUInteger)index;



@property (nonatomic) NSArray *products;
@property (nonatomic, readonly) int productCount;


@end
