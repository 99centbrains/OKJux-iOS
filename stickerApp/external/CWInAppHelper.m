//
//  InAppHelper.m
//  catwang
//
//  Created by Franky Aguilar on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CWInAppHelper.h"
#import <StoreKit/StoreKit.h>
//#import "Flurry.h"
#import "TAOverlay.h"
@implementation CWInAppHelper

@synthesize products;
@synthesize productCount;

#define kAllProductsIdentifier  @"com.99centbrains.catwang.all"

#define kPurchaseRestoredButton @"btn_purchase_restore"
#define kPurchaseAllButton @"btn_purchase_all"

static CWInAppHelper * _sharedHelper;

+ (CWInAppHelper *)sharedHelper {
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[CWInAppHelper alloc] init];
    return _sharedHelper;
}


- (NSString *)productIdentifierForIndex:(NSUInteger)index {
    if (index < [self.productIDs count]) {
        return [self.productIDs objectAtIndex:index];
    }
    return nil;
}


- (id)init {
    
    if ((self = [super init])) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        
    }
    return self;
}


- (void)startRequest:(NSArray *)productsArray{
    
    NSLog(@"IAP Requesting with Array Count: %lu", (unsigned long)[productsArray count]);
    
    if (!self.request) {
        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:
                   [NSSet setWithArray:productsArray]];
        self.productIDs = productsArray;
        self.request.delegate = self;
        [self.request start];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    self.products = response.products;
    
    productCount = (int)[products count];
    
    NSLog(@"IAP Request Return: %d", productCount);
    
    for (SKProduct *productID in response.products){
        
       // NSLog(@"Returned :%@", productID.productIdentifier);
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:CWIAP_ProductsAvailable object:nil];

}


#pragma CHECK PURCHASE STATUS

- (BOOL) checkPackProducts:(NSString *)productID{
    if (!self.products){
        return NO;
    }
    
    for (SKProduct *skproduct in self.products){
        
        if ([skproduct.productIdentifier isEqualToString:productID]){
            return YES;
        }
        
    }
    
    return NO;

}
- (BOOL)product_isPurchased:(NSString *)prodID {
   
    //prodID = [prodID stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSLog(@"PRODUCT %@", prodID);
    BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:prodID];
    NSLog(@"CHECK PRODUCT STATUS %hhd", purchased);
    
    return purchased;
    
}

#pragma BUYING PRODUCTS

- (void)buyProductWithProductIdentifier:(NSString *)productIdentifier singleItem:(BOOL)flag{
    [TAOverlay showOverlayWithLabel:@"Unlocking Item" Options:(TAOverlayOptionOverlayTypeActivityDefault)];

    NSLog(@"BUY, %@", productIdentifier);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _singleItem = flag;
    
    if ([SKPaymentQueue canMakePayments]) {
        
        for(SKProduct *product in self.products) {
            
            if ([product.productIdentifier isEqualToString:productIdentifier]) {
                
                NSLog(@"Adding Payment for Product");
                SKPayment *payment = [SKPayment paymentWithProduct:product];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                
            } else {

            }
        }
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You are not allowed to make purchases.  Go ask your mom?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)buyAllProducts:(NSString *)productIdentifier{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([SKPaymentQueue canMakePayments]) {
        
        for(SKProduct *product in self.products) {
            if ([product.productIdentifier isEqualToString:kAllProductsIdentifier]) {
                
                
                NSLog(@"Adding Payment for Product");
                SKPayment *payment = [SKPayment paymentWithProduct:product];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                
            }
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You are not allowed to make purchases.  Go ask your mom?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}




- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                
                [self restoreTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStatePurchasing:
                
                break;
            default:
                break;
        }
    }
}

- (void)recordTransaction: (SKPaymentTransaction *)transaction {
    
    if (transaction.transactionState == SKPaymentTransactionStateRestored) {
        
        NSString *productIdentifier = transaction.payment.productIdentifier;
        NSString *productIdentifierAll = kAllProductsIdentifier;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CWIAP_Restore object:nil];
        
        
        [self product_setPurchased:productIdentifier];
        
        if ([productIdentifier isEqualToString: productIdentifierAll]){
            [self setAllProductsPuchased];
        }
        
    
    }
    
    if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
        
        NSString *productIdentifier = transaction.payment.productIdentifier;
        
        
        [self product_setPurchased:productIdentifier];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CWIAP_ProductPurchased object:nil];

        
        NSLog(@"We just bought %@", productIdentifier);
        
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

//RESTORE
- (void) restore_purchases {
    
    [TAOverlay showOverlayWithLabel:@"Restoring..." Options:(TAOverlayOptionOverlayTypeActivityDefault)];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction {
    
    [self recordTransaction: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    
    //[Flurry logError:@"Error: Payment Que:" message:[error localizedDescription] error:error];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [TAOverlay showOverlayWithLabel:@"Cancelled" Options:(TAOverlayOptionOverlayTypeError | TAOverlayOptionAutoHide)];
    
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


//TRANSACTIONS

- (void)completeTransaction: (SKPaymentTransaction *)transaction {
    
    [self recordTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction: (SKPaymentTransaction *)transaction {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"FAILED");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:[transaction.error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
    
    
    [TAOverlay showOverlayWithLabel:@"Transaction Failed" Options:(TAOverlayOptionOverlayTypeError | TAOverlayOptionAutoHide)];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// GET PRODUCT
- (NSString*)getProductPrice:(NSString *)productIdentifier{
    NSString *price;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setLocale:[NSLocale currentLocale]];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *string;
    
    
    //
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    for(SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            price = [product.price stringValue];
            
            if (price != nil){
                
//                NSNumber *someAmount = product.price;
                
                [numberFormatter setLocale:product.priceLocale];
                string = [numberFormatter stringFromNumber:product.price];
                
            }
            
        }
    }
    
    return string;
};

- (NSString*)getProductTitle:(NSString *)productIdentifier{
    NSString *title;
    for(SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            title = product.localizedTitle;
        }
        
    }
    
    return title;
}

- (NSString*)getProductDescription:(NSString *)productIdentifier{
    NSString *title;
    for(SKProduct *product in self.products) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            title = product.localizedDescription;
        }
        
    }
    
    return title;
}


//SET DEFAULTS




- (void)product_setPurchased:(NSString *)prodID {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:prodID];
    
}

- (void)setAllProductsPuchased {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    for (NSString *identifier in self.productIDs) {
//        [defaults setBool:YES forKey:identifier];
//    }
//    [defaults setBool:YES forKey:kPurchaseAllButton];
//    [defaults setBool:YES forKey:kPurchaseRestoredButton];
}

- (void)cancelPurchase {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
}


- (void)dealloc {
    
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
    
}


- (void)unlockALLITEMS {
    
    [self setAllProductsPuchased];
}

@end