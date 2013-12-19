//
//  DLSAd.h
//  Depremler
//
//  Created by Dilisim Individual on 14/12/13.
//  Copyright (c) 2013 modilişim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EECompanyId : UIView
- (id)initWithFrame:(CGRect)frame andCompanyId:(NSString *)companyId;

@property (nonatomic,strong) NSArray * appsArray;
@property (readwrite) int currentIndex;
@end
