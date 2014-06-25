//
//  IAPManager.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "IAPManager.h"

#define kUserDefaultsIAPKey @"IAP_USER_DEFAUTLS_KEY"

@implementation IAPManager
{
    NSMutableSet *_purchasedProducts;
}

-(instancetype)init
{
    if (self = [super init])
    {
        NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsIAPKey];
        
        if (tempArray)
            _purchasedProducts = [NSMutableSet setWithArray:tempArray];
        else
            _purchasedProducts = [NSMutableSet set];

    }
    
    return self;
}

-(BOOL)isProductPurchased:(NSString *)productIdentifier
{
    return [_purchasedProducts containsObject:productIdentifier];
}

-(void)buyProduct:(SKProduct *)product
{
    if ([self isProductPurchased:product.productIdentifier])
    {
        NSLog(@"You've already purchased this item!");
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Complete transaction: %@", transaction.payment.productIdentifier);
    
    [self purchaseSuccess:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"Restore transaction: %@", transaction.payment.productIdentifier);
    
    [self purchaseSuccess:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)purchaseSuccess:(NSString *)productIdentifier
{
    [_purchasedProducts addObject:productIdentifier];
    [self.delegate purchaseCompleted:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:[_purchasedProducts allObjects]  forKey:kUserDefaultsIAPKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Failed transaction: %@",
          transaction.payment.productIdentifier);
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@",
              transaction.error.localizedDescription);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase failed!"
                                                        message:transaction.error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self.delegate purchaseCompleted:NO];
}

-(void)retrieveProducts
{
    //1: Preparing set of products to retrieve
    NSSet *products = [NSSet setWithArray:@[kInAppLives, kInAppPoints]];
    
    //2: Creating request
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
    
    //3: Setting delegate to self, to get products.
    productsRequest.delegate = self;
    
    //4: Starting request.
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self.delegate productsLoaded:response.products];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request error %@", error.localizedDescription);
}

-(void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restoring purchases failed: %@", error);
    [self.delegate purchasesRestored:NO];
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self.delegate purchasesRestored:YES];
}

+(IAPManager *)sharedInstance
{
    static dispatch_once_t pred;
    static IAPManager * _sharedInstance;
    dispatch_once(&pred, ^{ _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}

@end
