//
//  ADViewController.m
//  ProductTest
//
//  Created by 陈荣科 on 2020/12/22.
//

#import "ADViewController.h"
#import <TRTCCloud.h>
#import "GenerateTestUserSig.h"
#import <TXLiteAVSDK.h>
#import <ImSDK/ImSDK.h>

@interface ADViewController ()<TRTCCloudDelegate,TRTCAudioFrameDelegate,CAAnimationDelegate,V2TIMGroupListener>
@property(nonatomic, strong) TRTCCloud *trtcCloud;
@property(nonatomic, strong) RoomInfo *roomInfo;
@property(nonatomic, strong) UIView *vLoad;
@property(nonatomic, strong) UIView *vUpdate;
@property(nonatomic, strong) UIButton *btnHiht;
@property(nonatomic, strong) UIButton *btnDismiss;
@property(nonatomic,strong) UILabel *lbTest;

@end

@implementation ADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.roomInfo = [RoomInfo sharedInstance];
    self.trtcCloud = [TRTCCloud sharedInstance];
    self.trtcCloud.delegate = self;
    [self setUpate];
    
    [self initCloud];
    [self.view addSubview:self.btnHiht];
    [self.view addSubview:self.btnDismiss];
    
    self.lbTest = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 60, 40)];
    self.lbTest.text = @"test";
    self.lbTest.textColor = [UIColor whiteColor];
    self.lbTest.backgroundColor = [UIColor redColor];

    [[TRTCCloud sharedInstance] setAudioFrameDelegate:self];
   
}
- (void)initCloud{

    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAPPID;
    params.role = TRTCRoleAudience;
    params.userId = _roomInfo.userID;
    params.userSig = [GenerateTestUserSig genTestUserSig:_roomInfo.userID];
    params.strRoomId = _roomInfo.roomID;
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
}

- (void)onClick{
    [self.trtcCloud switchRole:TRTCRoleAnchor];
    [self.trtcCloud startLocalPreview:YES view:self.vUpdate];
}

- (void)onClick1{
    [[TRTCCloud sharedInstance] exitRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)btnHiht{
    if (!_btnHiht) {
        _btnHiht = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnHiht.frame = CGRectMake(50, 200, 40, 40);
        [_btnHiht setTitle:@"上麦" forState:UIControlStateNormal];
        [_btnHiht setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnHiht.backgroundColor = [UIColor redColor];
        [_btnHiht addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnHiht;
}

- (UIButton *)btnDismiss{
    if (!_btnDismiss) {
        _btnDismiss = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnDismiss.frame = CGRectMake(50, 300, 40, 40);
        [_btnDismiss setTitle:@"返回" forState:UIControlStateNormal];
        [_btnDismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnDismiss.backgroundColor = [UIColor redColor];
        [_btnDismiss addTarget:self action:@selector(onClick1) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDismiss;
}

- (void)setUpate{
    self.vUpdate = [[UIView alloc] initWithFrame:CGRectMake(20, 64, 300, 300)];
    self.vUpdate.layer.cornerRadius = 20.0f;
    self.vUpdate.layer.masksToBounds = YES;
    [self.view addSubview:_vUpdate];
}


- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
    [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeBig view:self.view];
    NSLog(@"userId:%@",userId);
}

- (void)onStatistics: (TRTCStatistics *)statistics{
     
    for (TRTCLocalStatistics *local  in statistics.localStatistics) {
        NSLog(@"本地视频宽：%u，高：%u",local.width,local.height);
    }

    for (TRTCRemoteStatistics *remote  in statistics.remoteStatistics) {
        NSLog(@"远端视频宽：%u，高：%u",remote.width,remote.height);
    }
}

@end
