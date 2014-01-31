    //
    //  DLSAd.m
    //  Depremler
    //
    //  Created by Dilisim Individual on 14/12/13.
    //  Copyright (c) 2013 modilişim. All rights reserved.
    //

#import "EECompanyAd.h"
#import "AFNetworking.h"
#import "NSTimer+Blocks.h"
#import "UIControl-JTTargetActionBlock.h"
#import <StoreKit/StoreKit.h>

@interface EECompanyAd ()
@property (nonatomic,strong) UIViewController * parentVC;
@property (nonatomic,strong) NSArray * appsArray;
@property (readwrite) int currentIndex;
@end


@implementation EECompanyAd



- (void)open:(NSString*)appId inAppStoreWithDelegate:(id)delegate {
        // Initialize Product View Controller
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
        // Configure View Controller
    storeProductViewController.title = appId;
    [storeProductViewController setDelegate:delegate];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : appId} completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
        } else {
                // Present Store Product View Controller
            [delegate presentViewController:storeProductViewController animated:YES completion:nil];
        }
    }];
}

- (void)getImage:(NSString*)urlString andSuccess:(void (^)(UIImage * responseObject))success failure:(void (^)(NSError * error))failure{
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    postOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id downloadedImage) {
        
        success(downloadedImage);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
        failure(error);
    }];
    
    [postOperation start];
}

-(void)swipeToDoMethodPrevious{
    NSLog(@"kaydırıldı.");
}

-(void)swipeToDoMethodNext{
    NSLog(@"kaydırıldı.");
}

-(void)tappedToView:(UITapGestureRecognizer*)tap{
    NSString* appId = self.appsArray[self.currentIndex%self.appsArray.count][@"trackId"];
    [self open:appId inAppStoreWithDelegate:self.parentVC];
       NSLog(@"kaydırıldı., %@",appId);
}

-(void)setViewsForLoopWithAPIResponse:(id)responseObject andWithInterval:(NSUInteger)interval{
    
    NSMutableArray * modilisimCompanyApps = [[NSMutableArray alloc] initWithArray:responseObject[@"results"]];
    
    [modilisimCompanyApps removeObject:modilisimCompanyApps.firstObject];
    self.appsArray = [NSArray arrayWithArray:modilisimCompanyApps];
    
    self.currentIndex = 0;
    if (!self.appsArray.count) return;
    
    [NSTimer scheduledTimerWithTimeInterval:interval block:^{
        
        UIView * view =  [self setViewForApp:self.appsArray[self.currentIndex%self.appsArray.count]];
        
        view.alpha = 0;
        
            [self addSubview:view];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            view.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            
        }];
        
        ++self.currentIndex;
        
    } repeats:YES];
    
    
    
}

-(UIView*)setViewForApp:(id)appInfo{
    if (self.subviews.count) {
        
        [self.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                view.alpha = 0;
                
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                
            }];
            
        }];
    }
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self getImage:appInfo[@"artworkUrl100"] andSuccess:^(UIImage *responseObject) {
        
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        
        [button addEventHandler:^(id sender, UIEvent *event) {
            
            [self open:appInfo[@"trackId"] inAppStoreWithDelegate:self.parentVC];
            
        } forControlEvent:UIControlEventTouchUpInside];
        
        [button setImage:responseObject forState:UIControlStateNormal];
        [view addSubview:button];
        
    } failure:^(NSError *error) {
        
    }];
    
    UILabel * appTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 240, 20)];
    appTitle.userInteractionEnabled  = NO;
    appTitle.font = [UIFont fontWithName:@"Avenir" size:13];
    appTitle.text = appInfo[@"trackCensoredName"];
    [view addSubview:appTitle];
    
    UILabel * appSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 240, 50)];
    appSubTitle.userInteractionEnabled  = NO;
    appSubTitle.numberOfLines =2;
    appSubTitle.textColor = [UIColor darkGrayColor];
    
    appSubTitle.font = [UIFont fontWithName:@"Avenir" size:11];
    appSubTitle.text = appInfo[@"description"];
    [view addSubview:appSubTitle];
    
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDoMethodPrevious)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer: swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDoMethodNext)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer: swipeGestureRight];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToView:)];
    [view addGestureRecognizer: tapGesture];
    

    return view;
}

- (void)getITunesApiWithCompanyId:(int)companyId {
    
    NSURL * url = [NSURL URLWithString:@"https://itunes.apple.com/"];
    
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    [manager GET:@"lookup" parameters:@{@"id": [NSString stringWithFormat:@"%d",companyId],@"entity":@"software"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self setViewsForLoopWithAPIResponse:responseObject andWithInterval:5];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error");
        
        [self removeFromSuperview];
        
    }];
}

- (id)initWithFrame:(CGRect)frame andCompanyId:(int)companyId andVC:(UIViewController*)VC
{
    self = [super initWithFrame:frame];
    if (self) {
       
        
        self.parentVC = VC;
        [self getITunesApiWithCompanyId:companyId];
    }
    return self;
}


@end
