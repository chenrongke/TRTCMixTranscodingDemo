//
//  LoginView.m
//  ProductTest
//
//  Created by 陈荣科 on 2021/4/3.
//

#import "LoginView.h"

@interface LoginView()
@property(nonatomic, strong) UIButton *btnLogin;
@end

@implementation LoginView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews{
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.tfUser = [[UITextField alloc] initWithFrame:CGRectMake((size.width-120)*0.5, 100, 120, 60)];
    self.tfUser.placeholder = @"输入用户名";
    [self addSubview:self.tfUser];
    
    self.tfRoom = [[UITextField alloc] initWithFrame:CGRectMake((size.width-120)*0.5, 180, 120, 60)];
    self.tfRoom.placeholder = @"输入房间号";
    [self addSubview:self.tfRoom];
    
    self.btnLogin = [[UIButton alloc] initWithFrame:CGRectMake((size.width-60)*0.5, size.height-100, 60, 60)];
    [self.btnLogin setTitle:@"登录" forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btnLogin addTarget:self action:@selector(onClickLogin) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnLogin];
}

- (void)onClickLogin{
    if ([self.delegate respondsToSelector:@selector(onRequestLogin)]) {
        [self.delegate onRequestLogin];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.tfRoom resignFirstResponder];
    [self.tfUser resignFirstResponder];
}
@end
