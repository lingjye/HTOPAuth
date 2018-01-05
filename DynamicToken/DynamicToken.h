//
//  DynamicToken.h
//  BM
//
//  Created by txooo on 17/3/22.
//  Copyright © 2017年 领琾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTPAuthURL.h"
#import "TOTPGenerator.h"
#import "HOTPGenerator.h"
typedef NS_ENUM(NSUInteger,OTPType) {
    OTPTypeBasedOnTime,
    OTPTypeBasedOnCounter,
    OTPTypeOnlyUrl
};

static NSString *const kOTPKeychainEntriesArray = @"OTPKeychainEntries";

@interface DynamicToken : NSObject
@property (nonatomic,strong) OTPAuthURL *authUrl;
@property (nonatomic,strong) NSMutableArray *authURLs;
- (NSString *)createDynamicTokenWithAccount:(NSString *)account secret:(NSString *)secret secretType:(OTPType)OTPType;

@end
