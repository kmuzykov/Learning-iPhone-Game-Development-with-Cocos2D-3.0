//
//  ShopScene.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "ShopScene.h"

#import "MenuScene.h"
#import "IAPManager.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"

@implementation ShopScene
{
    CCLabelTTF *_lblLoading;
    CCLayoutBox *_items;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addLoadingLabel];
        [self addBackButton];
        [self addRestoreButton];
        
        [IAPManager sharedInstance].delegate = self;
        [[IAPManager sharedInstance] retrieveProducts];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"shop_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg];
}

-(void)addLoadingLabel
{
    _lblLoading =[CCLabelTTF labelWithString:@"Loading..."
                                    fontName:@"Helvetica"
                                    fontSize:48];
    _lblLoading.positionType = CCPositionTypeNormalized;
    _lblLoading.position = ccp(0.5f, 0.5f);
    [self addChild:_lblLoading];
}

-(void)addBackButton
{
    CCSpriteFrame *normal = [CCSpriteFrame frameWithImageNamed:@"btn_9slice.png"];
    CCSpriteFrame *pressed = [CCSpriteFrame frameWithImageNamed:@"btn_9slice_pressed.png"];
    
    CCButton *btnBack = [CCButton buttonWithTitle:@"Back"
                                      spriteFrame:normal
                           highlightedSpriteFrame:pressed
                              disabledSpriteFrame:nil];
    btnBack.block = ^(id sender)
    {
        [IAPManager sharedInstance].delegate = nil;
        [[CCDirector sharedDirector]
         replaceScene:[MenuScene node]];
    };
    
    btnBack.horizontalPadding = 12.0f;
    btnBack.verticalPadding = 4.0f;
    
    btnBack.anchorPoint = ccp(0,1);
    btnBack.positionType = CCPositionTypeNormalized;
    btnBack.position = ccp(0.05f, 0.95f);
    
    [self addChild:btnBack];
}

-(void)addRestoreButton
{
    CCSpriteFrame *normal = [CCSpriteFrame frameWithImageNamed:@"btn_9slice.png"];
    CCSpriteFrame *pressed = [CCSpriteFrame frameWithImageNamed:@"btn_9slice_pressed.png"];
    
    CCButton *btnRestore = [CCButton buttonWithTitle:@"Restore Purchases"
                                         spriteFrame:normal
                              highlightedSpriteFrame:pressed
                                 disabledSpriteFrame:nil];
    
    btnRestore.block = ^(id sender)
    {
        _lblLoading.visible = YES;
        _lblLoading.string = @"Restoring...";
        [_items removeFromParent];
        
        [[IAPManager sharedInstance] restorePurchases];
    };
    
    btnRestore.horizontalPadding = 12.0f;
    btnRestore.verticalPadding = 4.0f;
    
    btnRestore.anchorPoint = ccp(1,1);
    btnRestore.positionType = CCPositionTypeNormalized;
    btnRestore.position = ccp(0.95f, 0.95f);
    
    [self addChild:btnRestore];
}

-(void)productsLoaded:(NSArray *)products
{
    //1: Hiding Loading... label
    _lblLoading.visible = NO;
    
    //2: Using CCLayoutBox to layout items (if you have a longer list use table view)
    _items = [CCLayoutBox node];
    _items.direction = CCLayoutBoxDirectionVertical;
    _items.spacing = 10.0f;
    
    //3: Creating node for each product
    for (SKProduct *product in products)
    {
        CCNode *item = [self createPurchaseItemWithProduct:product];
        [_items addChild:item];
    }
    
    //4: dding to the scene
    [_items layout];
    _items.anchorPoint = ccp(0.5f, 1.0f);
    _items.positionType = CCPositionTypeNormalized;
    _items.position = ccp(0.5f, 0.8);
    [self addChild:_items];
}

-(CCNode *)createPurchaseItemWithProduct:(SKProduct *)product
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CCNodeColor *item =    [CCNodeColor nodeWithColor:[CCColor whiteColor]
                                                width:viewSize.width
                                               height:60.0f];
    
    CCLabelTTF *productName = [CCLabelTTF labelWithString:product.localizedTitle
                                                 fontName:@"Helvetica"
                                                 fontSize:22];
    productName.color = [CCColor blackColor];
    productName.anchorPoint = ccp(0,1);
    productName.positionType = CCPositionTypeNormalized;
    productName.position = ccp(0.05, 0.95);
    [item addChild:productName];
    
    CCLabelTTF *productDescription = [CCLabelTTF labelWithString:product.localizedDescription
                                                        fontName:@"Helvetica"
                                                        fontSize:14];
    productDescription.color = [CCColor darkGrayColor];
    productDescription.anchorPoint = ccp(0,1);
    productDescription.positionType = CCPositionTypeNormalized;
    productDescription.position = ccp(0.05, 0.4f);
    [item addChild:productDescription];
    
    //1: Already purchased?
    BOOL purchased = [[IAPManager sharedInstance] isProductPurchased:product.productIdentifier];
    
    if (purchased)
    {
        //2: If product is already purchased displaying label.
        CCLabelTTF *purchased = [CCLabelTTF labelWithString:@"Purchased!"
                                                   fontName:@"Helvetica"
                                                   fontSize:18];
        purchased.color = [CCColor grayColor];
        purchased.anchorPoint = ccp(1, 0.5f);
        purchased.positionType = CCPositionTypeNormalized;
        purchased.position = ccp(0.95f, 0.5f);
        [item addChild:purchased];
    }
    else
    {
        //3: Formatting price using player's locale
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        [formatter setLocale:product.priceLocale];
        NSString *price = [formatter stringFromNumber:product.price];
        
        //4: If not purchased displaying button
        CCSpriteFrame *normal = [CCSpriteFrame frameWithImageNamed:@"btn_9slice.png"];
        CCSpriteFrame *pressed = [CCSpriteFrame frameWithImageNamed:@"btn_9slice_pressed.png"];
        CCButton *btnPurchase = [CCButton buttonWithTitle:price
                                              spriteFrame:normal
                                   highlightedSpriteFrame:pressed
                                      disabledSpriteFrame:nil];
        btnPurchase.horizontalPadding = 12.0f;
        btnPurchase.verticalPadding = 12.0f;
        btnPurchase.anchorPoint = ccp(1, 0.5f);
        btnPurchase.positionType =
        CCPositionTypeNormalized;
        btnPurchase.position = ccp(0.95f, 0.5f);
        [item addChild:btnPurchase];
        
        //5: Saving reference to the product
        btnPurchase.userObject = product;
        
        //6: Setting button handler
        [btnPurchase setTarget:self selector:@selector(onPurchaseTap:)];
    }
    
    return item;
}

-(void)onPurchaseTap:(CCButton *)btn
{
    //1: Getting product saved in userObject before.
    SKProduct *product = btn.userObject;
    
    //2: Removing products list
    [_items removeFromParent];
    
    //3: Instead displaying Purchasing... label
    _lblLoading.string = @"Purchasing...";
    _lblLoading.visible = YES;
    
    //4: Initiating a purchase
    [[IAPManager sharedInstance] buyProduct:product];
}

-(void)purchaseCompleted:(BOOL)success
{
    if (success)
    {
        _lblLoading.string = @"Refreshing products...";
        [[IAPManager sharedInstance] retrieveProducts];
    }
    else
    {
        _lblLoading.string = @"Purchase failed!";
    }
}

-(void)purchasesRestored:(BOOL)success
{
    if (success)
    {
        _lblLoading.string = @"Refreshing products...";
        [[IAPManager sharedInstance] retrieveProducts];
    }
    else
    {
        _lblLoading.string = @"Restore failed!";
    }
}


@end
