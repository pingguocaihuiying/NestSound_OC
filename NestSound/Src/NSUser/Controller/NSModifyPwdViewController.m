//
//  NSModifyPwdViewController.m
//  NestSound
//
//  Created by 李龙飞 on 16/8/2.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSModifyPwdViewController.h"

#define KColor_Background [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1]

@interface NSModifyPwdViewController ()<UITextFieldDelegate>
{
    NSTextField *oldPwdTF;
    NSTextField *newPwdTF;
    NSTextField *ensurePwdTF;
    UIButton *ensureBtn;
}
@end

@implementation NSModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUIAppearance];
}
- (void)resetThePassword {
    [[NSToastManager manager] showprogress];
    if (![newPwdTF.text isEqualToString:ensurePwdTF.text]) {
        [[NSToastManager manager] showtoast:@"两次密码不一致"];
        return;
    }
    self.requestType = NO;
    
    self.requestParams = @{@"id":JUserID,
                           @"opwd":[oldPwdTF.text stringToMD5],
                           @"newpwd":[newPwdTF.text stringToMD5],
                           @"comfirmpwd":[ensurePwdTF.text stringToMD5],
                           @"token":LoginToken
                           };
    self.requestURL = changePasswordUrl;
}
-(void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr
{
    if (requestErr) {
        
    } else {
        if (!parserObject.success) {
            [[NSToastManager manager] hideprogress];
            if ([operation.urlTag isEqualToString:changePasswordUrl]) {
                if (parserObject.code == 200) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [[NSToastManager manager] showtoast:parserObject.message];
                
            }
        }
    }
}
- (void)configureUIAppearance {
    self.title = @"修改密码";
    self.view.backgroundColor = [UIColor whiteColor];
    //旧密码
    UIImage *oldPwdImg = [UIImage imageNamed:@"2.0_password_gray"];
    UIImageView *oldPwdImgView = [[UIImageView alloc] initWithImage:oldPwdImg];
    oldPwdImgView.frame = CGRectMake(0, 0, 12, 15);
    oldPwdTF = [[NSTextField alloc] initWithFrame:CGRectMake(15, 20, ScreenWidth -30, 40) drawingLeft:oldPwdImgView];
    oldPwdTF.delegate = self;
    oldPwdTF.secureTextEntry = YES;
    oldPwdTF.layer.borderColor = [[UIColor hexColorFloat:@"ffd00b"] CGColor];
    oldPwdTF.font = [UIFont systemFontOfSize:15];
    oldPwdTF.placeholder = @" 旧密码";
    [oldPwdTF addTarget:self action:@selector(textFieldContentChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:oldPwdTF];
    
    //新密码
    UIImage *newPwdImg = [UIImage imageNamed:@"2.0_repassword_gray"];
    UIImageView *newPwdImgView = [[UIImageView alloc] initWithImage:newPwdImg];
    newPwdImgView.frame = CGRectMake(0, 0, 12, 15);
    newPwdTF = [[NSTextField alloc] initWithFrame:CGRectMake(15, 75, ScreenWidth - 30, 40) drawingLeft:newPwdImgView];
    newPwdTF.delegate = self;
    newPwdTF.secureTextEntry = YES;
    newPwdTF.layer.borderColor = [[UIColor hexColorFloat:@"ffd00b"] CGColor];
    newPwdTF.font = [UIFont systemFontOfSize:15];
    newPwdTF.placeholder = @" 新密码";
    [newPwdTF addTarget:self action:@selector(textFieldContentChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:newPwdTF];
    
    //确认密码
    UIImage *ensurePwdImg = [UIImage imageNamed:@"2.0_ensurepassword_gray"];
    UIImageView *ensurePwdImgView = [[UIImageView alloc] initWithImage:ensurePwdImg];
    ensurePwdImgView.frame = CGRectMake(0, 0, 12, 15);
    ensurePwdTF = [[NSTextField alloc] initWithFrame:CGRectMake(15, 130, ScreenWidth - 30, 40) drawingLeft:ensurePwdImgView];
    ensurePwdTF.delegate = self;
    ensurePwdTF.secureTextEntry = YES;
    ensurePwdTF.layer.borderColor = [[UIColor hexColorFloat:@"ffd00b"] CGColor];
    ensurePwdTF.font = [UIFont systemFontOfSize:15];
    ensurePwdTF.placeholder = @" 确认密码";
    [ensurePwdTF addTarget:self action:@selector(textFieldContentChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:ensurePwdTF];
    
    ensureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ensureBtn.frame = CGRectMake(30, 200, ScreenWidth - 60, 40);
    ensureBtn.layer.cornerRadius = 20;
    ensureBtn.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1];
    ensureBtn.userInteractionEnabled = NO;
    [ensureBtn setTitle:@"确定重置密码" forState:UIControlStateNormal];
    [ensureBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [ensureBtn addTarget:self action:@selector(resetThePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ensureBtn];
}
- (void)textFieldContentChange:(UITextField *)textField {
    if (oldPwdTF.text.length && newPwdTF.text.length && ensurePwdTF.text.length) {
        ensureBtn.userInteractionEnabled = YES;
        [ensureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ensureBtn.backgroundColor = [UIColor hexColorFloat:@"ffd00b"];
    } else {
        ensureBtn.userInteractionEnabled = NO;
        ensureBtn.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
        [ensureBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
