//
//  DynamicToken.m
//  BM
//
//  Created by txooo on 17/3/22.
//  Copyright © 2017年 领琾. All rights reserved.
//

#import "DynamicToken.h"

@interface DynamicToken ()

@end

@implementation DynamicToken

- (NSMutableArray *)authURLs{
    if (!_authURLs) {
        _authURLs = [NSMutableArray array];
    }
    return _authURLs;
}

- (NSString *)createDynamicTokenWithAccount:(NSString *)account secret:(NSString *)secret secretType:(OTPType)OTPType{
    NSData *secretData = [OTPAuthURL base32Decode:secret];
    OTPAuthURL *authURL = nil;
    if (secretData.length) {
        if (OTPType == 2) {
            NSURL *url = [NSURL URLWithString:secret];
            authURL = [OTPAuthURL authURLWithURL:url secret:nil];
        }else {
            Class authURLClass = Nil;
            if (OTPType == 0) {
                authURLClass = [TOTPAuthURL class];
            } else {
                authURLClass = [HOTPAuthURL class];
            }
            NSString *name = account;
            authURL = [[authURLClass alloc] initWithSecret:secretData
                                                      name:name];
        }
        if (authURL) {
            NSString *checkCode = authURL.checkCode;
            if (checkCode) {
                
            }
            //响应事件
            [authURL saveToKeychain];
            [self.authURLs addObject:authURL];
        }
        self.authUrl = authURL;
    } else {
        NSString *title = @"提示";
        NSString *message = nil;
        if (secret.length) {
            message = [NSString stringWithFormat:
                       @"'%@'不合法",
                       secret];
        } else {
            message = @"你必须输入一个密令";
        }
        NSString *button = @"再试一次";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    DLog(@"%tu---%@",OTPType,authURL.checkCode);
    return authURL.checkCode;
}

- (void)saveKeychainArray {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *keychainReferences = [self valueForKeyPath:@"authURLs.keychainItemRef"];
    [ud setObject:keychainReferences forKey:kOTPKeychainEntriesArray];
    [ud synchronize];
}

@end
