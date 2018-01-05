//
//  ViewController.m
//  HTOPAuth
//
//  Created by txooo on 2018/1/5.
//  Copyright © 2018年 iBo. All rights reserved.
//

#import "ViewController.h"
#import "DynamicToken.h"
#import "OTPAuthBarClock.h"

@interface ViewController ()
@property (nonatomic,strong) OTPAuthBarClock *clock;
@property (nonatomic,strong) DynamicToken *dynamicToken;
@property (nonatomic,strong) UILabel *codeLabel;
@property (nonatomic,strong) UILabel *codeWarningLabel;
@property (nonatomic,strong) UIView *bgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"动态密码";
    self.view.backgroundColor = RGBCOLOR(240,240,240);
    [self configSubViews];
}

- (void)updateViewConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.view).offset(20);
    }];
    [self.codeWarningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.bgView);
    }];
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.bgView);
    }];
    [self.clock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.codeLabel).offset(-30);
        make.centerY.mas_equalTo(self.codeLabel);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [super updateViewConstraints];
}

- (void)configSubViews {
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.codeWarningLabel];
    [self.view addSubview:self.codeLabel];
    
    //
    //系统时间
    NSTimeInterval timeinterval = [[NSDate date] timeIntervalSince1970];
    //30秒作为有效期(时间片) 使用自 1970年1月1日 00:00:00 来经历的30秒的个数
    long long int interval = (long long int)timeinterval/30;
    NSString *intervalStr = [NSString stringWithFormat:@"%lld",interval];
    DLog(@"时间戳:%@--%f",intervalStr,timeinterval);
    self.dynamicToken = [[DynamicToken alloc]init];
    [self.dynamicToken createDynamicTokenWithAccount:intervalStr secret:@"abcdefghijklmnop" secretType:OTPTypeBasedOnTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otpAuthURLDidGenerateNewOTP:) name:OTPAuthURLDidGenerateNewOTPNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otpAuthURLWillGenerateNewOTP:) name:OTPAuthURLWillGenerateNewOTPWarningNotification object:self.dynamicToken.authUrl];
    
    self.clock = [[OTPAuthBarClock alloc] initWithFrame:CGRectMake(80,20,30,30)
                                                 period:[TOTPGenerator defaultPeriod]];
    [self.view addSubview:self.clock];
    
    [self.view updateConstraintsIfNeeded];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *savedKeychainReferences = [ud arrayForKey:kOTPKeychainEntriesArray];
    self.dynamicToken.authURLs = [NSMutableArray arrayWithCapacity:[savedKeychainReferences count]];
    for (NSData *keychainRef in savedKeychainReferences) {
        OTPAuthURL *authURL = [OTPAuthURL authURLWithKeychainItemRef:keychainRef];
        if (authURL) {
            [self.dynamicToken.authURLs addObject:authURL];
        }
    }
    DLog(@"%@",self.dynamicToken.authURLs);
    OTPAuthURL *authUrl = self.dynamicToken.authURLs.firstObject;
    self.codeLabel.text = authUrl.otpCode;
    self.codeWarningLabel.text = authUrl.otpCode;
}

- (void)otpAuthURLWillGenerateNewOTP:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *nsSeconds = [userInfo objectForKey:OTPAuthURLSecondsBeforeNewOTPKey];
    NSUInteger seconds = [nsSeconds unsignedIntegerValue];
    self.codeWarningLabel.alpha = 0;
    self.codeWarningLabel.hidden = NO;
    [UIView beginAnimations:@"Warning" context:nil];
    [UIView setAnimationDuration:seconds];
    self.codeLabel.alpha = 0;
    self.codeWarningLabel.alpha = 1;
    [UIView commitAnimations];
}

- (void)otpAuthURLDidGenerateNewOTP:(NSNotification *)notification{
    DLog(@"%@",self.dynamicToken.authUrl.otpCode);
    self.codeLabel.alpha = 1;
    self.codeWarningLabel.alpha = 0;
    [UIView beginAnimations:@"otpFadeOut" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(otpChangeDidStop:finished:context:)];
    self.codeWarningLabel.alpha = 0;
    [UIView commitAnimations];
}

- (void)otpChangeDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context {
    if ([animationID isEqual:@"otpFadeOut"]) {
        self.codeWarningLabel.alpha = 0;
        self.codeLabel.alpha = 0;
        NSString *otpCode = self.dynamicToken.authUrl.otpCode;
        self.codeLabel.text = otpCode;
        self.codeWarningLabel.text = otpCode;
        [UIView beginAnimations:@"otpFadeIn" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(otpChangeDidStop:finished:context:)];
        self.codeLabel.alpha = 1;
        [UIView commitAnimations];
    } else {
        self.codeLabel.alpha = 1;
        self.codeWarningLabel.alpha = 0;
        self.codeWarningLabel.hidden = YES;
    }
}

- (void)dealloc{
    [_clock invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = white_color;
    }
    return _bgView;
}

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [UILabel new];
        _codeLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:30];
        _codeLabel.textColor = RGBCOLOR(50, 79, 133);
        _codeLabel.backgroundColor = white_color;
        _codeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _codeLabel;
}

- (UILabel *)codeWarningLabel {
    if (!_codeWarningLabel) {
        _codeWarningLabel = [UILabel new];
        _codeWarningLabel.font = [UIFont fontWithName:@"Helvetica" size:30];
        _codeWarningLabel.textColor = red_color;
        _codeWarningLabel.backgroundColor = white_color;
        _codeWarningLabel.textAlignment = NSTextAlignmentCenter;
        _codeWarningLabel.hidden = YES;
    }
    return _codeWarningLabel;
}

@end
