//
//  LoginView.h
//  ProductTest
//
//  Created by 陈荣科 on 2021/4/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginViewDelegate <NSObject>

- (void)onRequestLogin;

@end

@interface LoginView : UIView
@property(nonatomic,weak)id<LoginViewDelegate>delegate;
@property(nonatomic, strong) UITextField *tfUser;
@property(nonatomic, strong) UITextField *tfRoom;
@end

NS_ASSUME_NONNULL_END
