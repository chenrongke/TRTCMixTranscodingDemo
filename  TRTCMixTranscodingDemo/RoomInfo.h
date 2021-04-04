//
//  RoomInfo.h
//  ProductTest
//
//  Created by 陈荣科 on 2021/4/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomInfo : NSObject
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *roomID;

+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
