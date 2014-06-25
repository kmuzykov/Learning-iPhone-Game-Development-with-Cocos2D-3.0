//
//  IAPManager.h
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

@import StoreKit;

#define kInAppPoints @"com.packtpub.coconutfall.iap.doublepoints"
#define kInAppLives  @"com.packtpub.coconutfall.iap.doublelives"

@protocol IAPManagerDelegate

-(void)productsLoaded:(NSArray *)products;

-(void)purchaseCompleted:(BOOL)success;

-(void)purchasesRestored:(BOOL)success;

@end

@interface IAPManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, weak) id<IAPManagerDelegate> delegate;

-(void)retrieveProducts;

-(BOOL)isProductPurchased:(NSString *)productIdentifier;

-(void)buyProduct:(SKProduct *)product;

-(void)restorePurchases;

+(IAPManager *)sharedInstance;

@end
