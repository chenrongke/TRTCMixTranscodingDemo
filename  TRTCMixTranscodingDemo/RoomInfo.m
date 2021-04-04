//
//  RoomInfo.m
//  ProductTest
//
//  Created by 陈荣科 on 2021/4/3.
//

#import "RoomInfo.h"

@implementation RoomInfo
static RoomInfo *_instance;
+ (instancetype)sharedInstance{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}
@end
