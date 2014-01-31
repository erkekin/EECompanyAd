//
//  EEViewController.m
//  EECompanyAd
//
//  Created by Erk EKIN on 16/12/13.
//  Copyright (c) 2013 erkekin. All rights reserved.
//

#import "EEViewController.h"
#import <StoreKit/StoreKit.h>
#import "EECompanyAd.h"

@interface EEViewController ()<SKStoreProductViewControllerDelegate>

@end

@implementation EEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EECompanyAd *ad= [[EECompanyAd alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-60, self.view.bounds.size.width, 60) andCompanyId:635874236 andVC:self];
    
    [self.view addSubview:ad];
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
