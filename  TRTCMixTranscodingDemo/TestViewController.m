//
//  TestViewController.m
//  ProductTest
//
//  Created by 陈荣科 on 2021/1/22.
//

#import "TestViewController.h"

@interface TestViewController ()<LoginViewDelegate,V2TIMSDKListener>

@property(nonatomic, strong) LoginView *loginView;
@property(nonatomic,strong) UIButton *btnAudience;
@property(nonatomic,strong) UIButton *btnAnchor;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.btnAudience];
    [self.view addSubview:self.btnAnchor];
    [self.view addSubview:self.loginView];
    
}

- (LoginView *)loginView{
    if (!_loginView) {
        _loginView = [[LoginView alloc] initWithFrame:self.view.bounds];
        _loginView.delegate = self;
    }
    return _loginView;
}

- (UIButton *)btnAudience{
    if (!_btnAudience) {
        _btnAudience = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnAudience.frame = CGRectMake((ScreenWith - 60)*0.5, (ScreenHeight - 60)*0.5, 60, 60);
        [_btnAudience setTitle:@"观众" forState:UIControlStateNormal];
        [_btnAudience addTarget:self action:@selector(onClickAudience) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAudience;
}

- (UIButton *)btnAnchor{
    if (!_btnAnchor) {
        _btnAnchor = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnAnchor.frame = CGRectMake((ScreenWith - 60)*0.5, (ScreenHeight - 60)*0.5 - 80, 60, 60);
        [_btnAnchor setTitle:@"主播" forState:UIControlStateNormal];
        [_btnAnchor addTarget:self action:@selector(onClickAnchor) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAnchor;
}


- (void)onClickAnchor{
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onClickAudience{
    ADViewController *vc = [[ADViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRequestLogin{
    // 1. 从 IM 控制台获取应用 SDKAppID，详情请参考 SDKAppID。
    // 2. 初始化 config 对象
    V2TIMSDKConfig *config = [[V2TIMSDKConfig alloc] init];
    // 3. 指定 log 输出级别，详情请参考 [SDKConfig](#SDKAppID)。
    config.logLevel = V2TIM_LOG_INFO;
    // 4. 初始化 SDK 并设置 V2TIMSDKListener 的监听对象。
    // initSDK 后 SDK 会自动连接网络，网络连接状态可以在 V2TIMSDKListener 回调里面监听。
    [[V2TIMManager sharedInstance] initSDK:SDKAPPID config:config listener:self];
    NSString *userSig = [GenerateTestUserSig genTestUserSig:self.loginView.tfUser.text];
    [[V2TIMManager sharedInstance] login:self.loginView.tfUser.text userSig:userSig succ:^{
        self.loginView.hidden = YES;
        [self setRoomData];
        NSLog(@"登录成功");
        } fail:^(int code, NSString *desc) {
            NSLog(@"登录失败");
        }];
}

- (void)setRoomData{
    RoomInfo *room = [RoomInfo sharedInstance];
    room.userID = self.loginView.tfUser.text;
    room.roomID = self.loginView.tfRoom.text;
}


// 5. 监听 V2TIMSDKListener 回调
- (void)onConnecting {
    // 正在连接到腾讯云服务器
}
- (void)onConnectSuccess {
    // 已经成功连接到腾讯云服务器
}
- (void)onConnectFailed:(int)code err:(NSString*)err {
    // 连接腾讯云服务器失败
}

@end
