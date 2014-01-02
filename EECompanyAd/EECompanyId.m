    //
    //  DLSAd.m
    //  Depremler
    //
    //  Created by Dilisim Individual on 14/12/13.
    //  Copyright (c) 2013 modilişim. All rights reserved.
    //

#import "EECompanyId.h"
#import "AFNetworking.h"
#import "NSTimer+Blocks.h"
#import "UIControl-JTTargetActionBlock.h"


@implementation EECompanyId

-(NSDictionary*)getPlist{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EECompanyId" ofType:@"plist"];
    
    NSDictionary*   plist = [[NSDictionary alloc]initWithContentsOfFile:path];
    return  plist;
    
}

-(NSArray*)excludeTheseApps:(NSArray*)appIds fromAllApps:(NSArray*)allApps{
    
    NSIndexSet * set = [allApps indexesOfObjectsPassingTest:^BOOL(NSDictionary * dict, NSUInteger idx, BOOL *stop) {
        
        __block   bool var=1;
        
        [appIds enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
            
            if (obj.intValue ==  [dict[@"trackId"] intValue]) {
                var =0;
                *stop = YES;
                
            }
            
        }];
        
        return var;
    }];
    
    return [NSArray arrayWithArray:[allApps objectsAtIndexes:set]];
}

-(NSString*)includeTheseApps:(NSArray*)appIds toAllApps:(NSArray*)apps{
    
    __block   NSString * string = @"";
    
    [appIds enumerateObjectsUsingBlock:^(NSString * trackId, NSUInteger idx, BOOL *stop) {
        string = [string stringByAppendingString:trackId];
        if (idx != appIds.count-1)
            string = [string stringByAppendingString:@","];
    }];
    
    return string;
}

- (void)getImage:(NSString*)urlString andSuccess:(void (^)(UIImage * responseObject))success
         failure:(void (^)(NSError * error))failure{
    
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

-(void)setViewsForLoopWithAPIResponse:(id)responseObject andWithInterval:(NSUInteger)interval{
    
    NSMutableArray * modilisimCompanyApps = [[NSMutableArray alloc] initWithArray:responseObject[@"results"]];
    NSLog(@"sds %@",modilisimCompanyApps);
    [modilisimCompanyApps removeObject:modilisimCompanyApps.firstObject];
    self.appsArray =[NSArray arrayWithArray:modilisimCompanyApps];
        //   self.appsArray =   [self excludeTheseApps:[self getPlist][@"exclude"] fromAllApps:[NSArray arrayWithArray:modilisimCompanyApps]];
    
    [self.appsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSLog(@"sds %@ %@",obj[@"trackId"],obj[@"trackName"]);
    }];
    
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
        [button addEventHandler:^(id sender, UIEvent *event) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInfo[@"trackViewUrl"]]];
            
        } forControlEvent:UIControlEventTouchUpInside];
        [button setImage:responseObject forState:UIControlStateNormal];
        [view addSubview:button];
        
    } failure:^(NSError *error) {
        
        
        
    }];
    
    UILabel * appTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 240, 20)];
    appTitle.font = [UIFont fontWithName:@"Avenir" size:13];
    appTitle.text = appInfo[@"trackCensoredName"];
    [view addSubview:appTitle];
    
    UILabel * appSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 240, 50)];
    appSubTitle.numberOfLines =2;
    appSubTitle.textColor = [UIColor darkGrayColor];
    
    appSubTitle.font = [UIFont fontWithName:@"Avenir" size:11];
    appSubTitle.text = appInfo[@"description"];
    [view addSubview:appSubTitle];
    
    return view;
}

- (void)getITunesApiWithCompanyId:(NSString*)itemsId {
    
    NSURL * url = [NSURL URLWithString:@"https://itunes.apple.com/"];
    
    AFHTTPRequestOperationManager * manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    [manager GET:@"lookup" parameters:@{@"id": itemsId,@"entity":@"software"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [self setViewsForLoopWithAPIResponse:responseObject andWithInterval:5];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error");
        
    }];
}

-(void)main{
    
    NSArray* include =  [self getPlist][@"include"];
    NSArray* exclude =  [self getPlist][@"exclude"];
    
    if (!include.count && !exclude.count) {
            // eğer exclude ve include boşsa direk company id'den sorgu at ve ilk item ı çıkar
        
    }else if (include.count) {
        
        
        
    }else if (exclude.count) {
        
        
        
    }
    
    
        // eğer include varsa companyId ile birleştirip sorgu at ve ilk itemı çıkar
        // eğer yalnızca exclude varsa companyId ye sorgu at gelenden ilkini ve exclude u çıkar
    
    
}
-(void) setValue:(id)value forKey:(NSString *)key
{
    
    if ([key isEqualToString:@"companyId"])
        
    {
        [self getITunesApiWithCompanyId:value];
        
        [self getITunesApiWithCompanyId:[self includeTheseApps:[self getPlist][@"include"] toAllApps:nil]];
        
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self)
        self.clipsToBounds = YES;
    
    return self;
}


- (id)initWithFrame:(CGRect)frame andItemsId:(NSString*)itemsId
{
    self = [super initWithFrame:frame];
    if (self){
        self.clipsToBounds = YES;
        [self getITunesApiWithCompanyId:itemsId];
    }
    return self;
}


@end
