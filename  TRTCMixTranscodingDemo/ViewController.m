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

//混流模式
@property(nonatomic, strong) UIButton *btnPureAdio;//纯音频模式
@property(nonatomic, strong) UIButton *btnPresetLayout;//预排版模式
@property(nonatomic, strong) UIButton *btnScreenSharing;//屏幕分享模式
@property(nonatomic, strong) UIButton *btnManual;//全手动模式

@property(nonatomic, assign) TRTCTranscodingConfigMode mode;
@property(nonatomic, strong) TRTCTranscodingConfig *config;
@end

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height
#define Marget (Width-4*120)/5

@implementation ViewController{
    NSMutableArray *_users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.roomInfo = [RoomInfo sharedInstance];
    self.trtcCloud = [TRTCCloud sharedInstance];
    self.trtcCloud.delegate = self;
    [self initCloud];
    [self.view addSubview:self.btnHiht];
    [self.view addSubview:self.btnEnterRoom];//setGroupListener
    
    [self.view addSubview:self.btnPureAdio];
    [self.view addSubview:self.btnPresetLayout];
    [self.view addSubview:self.btnScreenSharing];
    [self.view addSubview:self.btnManual];
    
    self.mode = TRTCTranscodingConfigMode_Template_PresetLayout;//默认预排版模式
    _users = [NSMutableArray array];
    self.config = [[TRTCTranscodingConfig alloc] init];
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
    param.roomId = 0;
    param.role = TRTCRoleAnchor;
    param.streamId = @"crkStreamid";
    param.userSig = [GenerateTestUserSig genTestUserSig:_roomInfo.userID];
    [self.trtcCloud enterRoom:param appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityDefault];

    [self mixModelType];
}

- (void)mixModelType{
    [_users removeAllObjects];
    switch (self.mode) {
        case TRTCTranscodingConfigMode_Template_PureAudio://纯音频模式
            [self setMinxPureAudio];
            break;
        case TRTCTranscodingConfigMode_Template_PresetLayout://预排版模式
            [self setMinxPresetLayout];
            break;
        case TRTCTranscodingConfigMode_Template_ScreenSharing://屏幕分享模式
            [self setMinxScreenSharing];
            break;
        default://手动模式
            [self setMinxManual];
            break;
    }
}


//纯音频模式
- (void)setMinxPureAudio{
    
    self.config.audioSampleRate = 48000;
    self.config.audioBitrate = 64;
    self.config.audioChannels = 2;
    self.config.mode = self.mode;
    [self.trtcCloud setMixTranscodingConfig:self.config];
}

//预排版模式
- (void)setMinxPresetLayout{
    
    // 设置分辨率为720 × 1280, 码率为1500kbps，帧率为20FPS
    self.config.videoWidth      = 720;
    self.config.videoHeight     = 1280;
    self.config.videoBitrate    = 1500;
    self.config.videoFramerate  = 20;
    self.config.videoGOP        = 3;
    self.config.audioSampleRate = 48000;
    self.config.audioBitrate    = 64;
    self.config.audioChannels   = 2;
    self.config.streamId = @"ABCStream";
    // 采用预排版模式
    self.config.mode = self.mode;

    
    // 主播摄像头的画面位置
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = @"$PLACE_HOLDER_LOCAL_MAIN$";
    local.zOrder = 0;   // zOrder 为0代表主播画面位于最底层
    local.rect   = CGRectMake(0, 0, 720, 1280);
    local.roomID = nil; // 本地用户不用填写 roomID，远程需要
    [_users addObject:local];
    
    // 连麦者的画面位置
    TRTCMixUser* remote1 = [TRTCMixUser new];
    remote1.userId = @"$PLACE_HOLDER_REMOTE$";
    remote1.zOrder = 1;
    remote1.rect   = CGRectMake(720-180, 1280-500, 180, 240); //仅供参考
    remote1.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要

    [_users addObject:remote1];
//    // 连麦者的画面位置
//    TRTCMixUser* remote2 = [TRTCMixUser new];
//    remote2.userId = @"$PLACE_HOLDER_REMOTE$";
//    remote2.zOrder = 1;
//    remote2.rect   = CGRectMake(400, 500, 180, 240); //仅供参考
//    remote2.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要
//
//    [users addObject:remote2];
    self.config.mixUsers = _users;
    // 发起云端混流
    [self.trtcCloud setMixTranscodingConfig:self.config];
    
}

//屏幕分享模式
- (void)setMinxScreenSharing{
    
    // 设置分辨率为720 × 1280, 码率为1500kbps，帧率为20FPS
    self.config.videoWidth      = 0;
    self.config.videoHeight     = 0;
    self.config.videoBitrate    = 0;
    self.config.videoFramerate  = 15;
    self.config.videoGOP        = 3;
    self.config.audioSampleRate = 48000;
    self.config.audioBitrate    = 64;
    self.config.audioChannels   = 2;
    self.config.mode = self.mode;
    [self.trtcCloud setMixTranscodingConfig:self.config];
}

//全手动模式
- (void)setMinxManual{
    
    // 设置分辨率为720 × 1280, 码率为1500kbps，帧率为20FPS
    self.config.videoWidth      = 720;
    self.config.videoHeight     = 1280;
    self.config.videoBitrate    = 1500;
    self.config.videoFramerate  = 15;
    self.config.videoGOP        = 3;
    self.config.audioSampleRate = 48000;
    self.config.audioBitrate    = 64;
    self.config.audioChannels   = 2;
    
    self.config.mode = self.mode;
    
    // 主播摄像头的画面位置
    TRTCMixUser* local = [TRTCMixUser new];
    local.userId = self.roomInfo.userID;
    local.zOrder = 0;   // zOrder 为0代表主播画面位于最底层
    local.rect   = CGRectMake(0, 0, 720, 1280);
    local.roomID =  self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要
    local.inputType = TRTCMixInputTypeAudioVideo;
    [_users addObject:local];
    
    [self.trtcCloud setMixTranscodingConfig:self.config];
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
    
    TRTCMixUser* remote1 = [TRTCMixUser new];
    remote1.userId = userId;
    remote1.zOrder = 1;
    remote1.rect   = CGRectMake(720-180, 1280-500, 180, 240); //仅供参考
    remote1.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要
    remote1.inputType = TRTCMixInputTypeAudioVideo;
    [_users addObject:remote1];
    self.config.mixUsers = _users;
    [self.trtcCloud setMixTranscodingConfig:self.config];
    NSLog(@"userId:%@",userId);
}

- (void)onUserAudioAvailable:(NSString *)userId available:(BOOL)available{
    TRTCMixUser* remote1 = [TRTCMixUser new];
    remote1.userId = userId;
    remote1.roomID = self.roomInfo.roomID; // 本地用户不用填写 roomID，远程需要
    remote1.inputType = TRTCMixInputTypeAudioVideo;
    [_users addObject:remote1];
    self.config.mixUsers = _users;
    [self.trtcCloud setMixTranscodingConfig:self.config];
    NSLog(@"onUserAudioAvailable");
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

- (void)setModel:(UIButton*)sender{
    switch (sender.tag) {
        case 1001:
            self.mode = TRTCTranscodingConfigMode_Template_PureAudio;
            break;
        case 1002:
            self.mode = TRTCTranscodingConfigMode_Template_PresetLayout;
            break;
        case 1003:
            self.mode = TRTCTranscodingConfigMode_Template_ScreenSharing;
            break;
        default:
            self.mode = TRTCTranscodingConfigMode_Manual;
            break;
    }
}

-(UIButton *)btnPureAdio{
    if (!_btnPureAdio) {
        _btnPureAdio = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnPureAdio setTitle:@"纯音频模式" forState:UIControlStateNormal];
        
        _btnPureAdio.frame = CGRectMake(Marget, Height-40-20, 120, 40);
        _btnPureAdio.tag = 1001;
        [_btnPureAdio addTarget:self action:@selector(setModel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPureAdio;
}

- (UIButton *)btnPresetLayout{
    if (!_btnPresetLayout) {
        _btnPresetLayout = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnPresetLayout setTitle:@"预排版模式" forState:UIControlStateNormal];
        
        _btnPresetLayout.frame = CGRectMake(Marget*2+120, Height-40-20, 120, 40);
        _btnPresetLayout.tag = 1002;
        [_btnPresetLayout addTarget:self action:@selector(setModel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPresetLayout;
}

- (UIButton *)btnScreenSharing{
    if (!_btnScreenSharing) {
        _btnScreenSharing = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnScreenSharing setTitle:@"屏幕分享模式" forState:UIControlStateNormal];
        
        _btnScreenSharing.frame = CGRectMake(Marget*3+120*2, Height-40-20, 120, 40);
        _btnScreenSharing.tag = 1003;
        [_btnScreenSharing addTarget:self action:@selector(setModel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnScreenSharing;
}

- (UIButton *)btnManual{
    if (!_btnManual) {
        _btnManual = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnManual setTitle:@"全手动模式" forState:UIControlStateNormal];
        _btnManual.frame = CGRectMake(Marget*4+120*3, Height-40-20, 120, 40);
        _btnManual.tag = 1004;
        [_btnManual addTarget:self action:@selector(setModel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnManual;
}

@end
