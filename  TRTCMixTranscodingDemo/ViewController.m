//
//  ViewController.m
//  ProductTest
//
//  Created by 陈荣科 on 2020/12/22.
//

#import "ViewController.h"
#import <TRTCCloud.h>
#import <TXLiteAVSDK.h>
#import "GenerateTestUserSig.h"
#import <ImSDK/ImSDK.h>

@interface ViewController ()<TRTCCloudDelegate,TRTCAudioFrameDelegate,V2TIMGroupListener>
@property(nonatomic, strong) TRTCCloud *trtcCloud;
@property(nonatomic, strong) UIButton *btnHiht;
@property(nonatomic, strong) UIButton *btnEnterRoom;
@property(nonatomic, strong) RoomInfo *roomInfo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.roomInfo = [RoomInfo sharedInstance];
    self.trtcCloud = [TRTCCloud sharedInstance];
    self.trtcCloud.delegate = self;
    [self initCloud];
    [self.view addSubview:self.btnHiht];
    [self.view addSubview:self.btnEnterRoom];//setGroupListener
}

- (void)onClick{
    [self.trtcCloud exitRoom];
}

- (void)onClickEnterRoom{
    [self.trtcCloud startLocalPreview:YES view:self.view];
    TRTCParams * param = [[TRTCParams alloc] init];
    param.sdkAppId = SDKAPPID;
    param.userId = _roomInfo.userID;
    param.strRoomId = _roomInfo.roomID;
    param.role = TRTCRoleAnchor;
    param.streamId = @"crkTest";
    param.userSig = [GenerateTestUserSig genTestUserSig:_roomInfo.userID];
    [self.trtcCloud enterRoom:param appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityDefault];

    [self setMinxStream];
}
- (void)setMinxStream{
    TRTCTranscodingConfig *config = [[TRTCTranscodingConfig alloc] init];
    // 设置分辨率为720 × 1280, 码率为1500kbps，帧率为20FPS
    config.videoWidth      = 720;
    config.videoHeight     = 1280;
    config.videoBitrate    = 1500;
    config.videoFramerate  = 20;
    config.videoGOP        = 2;
    config.audioSampleRate = 48000;
    config.audioBitrate    = 64;
    config.audioChannels   = 2;
    config.streamId = @"ABCStream";
    // 采用预排版模式
    config.mode = TRTCTranscodingConfigMode_Template_PresetLayout;

    NSMutableArray *users = [NSMutableArray new];
    // 主播摄像头的画面位置
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
    local.zOrder = 0;   // zOrder 为0代表主播画面位于最底层
    local.rect   = CGRectMake(0, 0, 720, 1280);
    local.roomID = nil; // 本地用户不用填写 roomID，远程需要
    [users addObject:local];
    

    // 连麦者的画面位置
    TRTCMixUser* remote1 = [TRTCMixUser new];
    remote1.userId = @"$PLACE_HOLDER_REMOTE$";
    remote1.zOrder = 1;
    remote1.rect   = CGRectMake(720-180, 1280-500, 180, 240); //仅供参考
    remote1.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要

    [users addObject:remote1];
//    // 连麦者的画面位置
//    TRTCMixUser* remote2 = [TRTCMixUser new];
//    remote2.userId = @"$PLACE_HOLDER_REMOTE$";
//    remote2.zOrder = 1;
//    remote2.rect   = CGRectMake(400, 500, 180, 240); //仅供参考
//    remote2.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要
//
//    [users addObject:remote2];
    config.mixUsers = users;
    // 发起云端混流
    [self.trtcCloud setMixTranscodingConfig:config];
//    [self.trtcCloud startPublishing:@"CDNStreamID" type:TRTCVideoStreamTypeSmall];
    
}

- (void)initCloud{
    // 视频编码参数
    TRTCVideoEncParam * videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.videoResolution = TRTCVideoResolution_960_720;
    videoEncParam.videoBitrate = 1200;
    videoEncParam.videoFps = 15;
    videoEncParam.enableAdjustRes = NO;
    [self.trtcCloud setVideoEncoderParam:videoEncParam];
    // 网络流控相关参数
    TRTCNetworkQosParam * networkQosParam = [[TRTCNetworkQosParam alloc] init];
   networkQosParam.preference = TRTCVideoQosPreferenceClear; // 保清晰
   [self.trtcCloud setNetworkQosParam:networkQosParam];
    
    TRTCRenderParams *renderParams = [[TRTCRenderParams alloc] init];
    renderParams.fillMode = TRTCVideoFillMode_Fit;
    
    [self.trtcCloud setLocalRenderParams:renderParams];
}
 
- (void)onStatistics: (TRTCStatistics *)statistics{
     
    for (TRTCLocalStatistics *local  in statistics.localStatistics) {
        NSLog(@"本地视频宽：%u，高：%u",local.width,local.height);
    }
    
    for (TRTCRemoteStatistics *remote  in statistics.remoteStatistics) {
        NSLog(@"远端视频宽：%u，高：%u",remote.width,remote.height);
    }
}

- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{
    if (![userId isEqual:self.roomInfo.userID]) {
        [self.trtcCloud startRemoteView:userId streamType:TRTCVideoStreamTypeSmall view:self.view];
    }
    NSLog(@"userId:%@",userId);
}

- (UIButton *)btnHiht{
    if (!_btnHiht) {
        _btnHiht = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnHiht.frame = CGRectMake(50, 200, 40, 40);
        [_btnHiht setTitle:@"退房" forState:UIControlStateNormal];
        [_btnHiht setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnHiht.backgroundColor = [UIColor redColor];
        [_btnHiht addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnHiht;
}

- (UIButton *)btnEnterRoom{
    if (!_btnEnterRoom) {
        _btnEnterRoom = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnEnterRoom.frame = CGRectMake(120, 200, 40, 40);
        [_btnEnterRoom setTitle:@"进房" forState:UIControlStateNormal];
        [_btnEnterRoom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnEnterRoom.backgroundColor = [UIColor redColor];
        [_btnEnterRoom addTarget:self action:@selector(onClickEnterRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnEnterRoom;
}
@end
