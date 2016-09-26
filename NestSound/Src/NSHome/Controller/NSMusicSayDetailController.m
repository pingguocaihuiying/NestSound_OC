//
//  NSMusicSayDetailController.m
//  NestSound
//
//  Created by yintao on 16/9/22.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSMusicSayDetailController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSShareView.h"
#import "NSThemeCommentController.h"
@interface NSMusicSayDetailController ()<UIWebViewDelegate>
{
    UIButton *_favourButton;
    UIButton *_commentButton;
    UIButton *_sharebutton;
    UIWebView *_webView;
    NSString *_urlString;
    NSShareView *_shareView;
    UIView *_maskView;


}

@end

@implementation NSMusicSayDetailController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self setupUI];
}

- (void)setupUI{
    self.title = @"乐说";
    
    //webView
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-45);
        
    }];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 45 - 64, ScreenWidth, 45)];
    [self.view addSubview:bottomView];
    NSArray *normalIconArr = @[@"",@"",@""];
    NSArray *selectedIconArr = @[@"",@"",@""];
    CGFloat buttonWidth = ScreenWidth/3.0f;

    for (NSInteger i = 0; i < 3; i ++) {
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
            btn.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, 45);
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [btn setTitleColor:[UIColor hexColorFloat:@"646464"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"gouxuan_No"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"gouxuan"] forState:UIControlStateSelected];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);

            //            [btn setImage:[UIImage imageNamed:normalIconArr[i]] forState:UIControlStateNormal];
//            [btn setImage:[UIImage imageNamed:selectedIconArr[i]] forState:UIControlStateSelected];

        } action:^(UIButton *btn) {
            
            if (btn == _favourButton) {
                CHLog(@"_favourButton");
                /**
                 *  点赞
                 */
            }else if (btn == _commentButton){
                CHLog(@"_commentButton");

            }else if (btn == _sharebutton){
                CHLog(@"_sharebutton");
                _maskView.hidden = NO;

                //分享
                [UIView animateWithDuration:0.25 animations:^{
                    
                    _shareView.y = ScreenHeight - _shareView.height;
                }];
            }
        }];
        switch (i) {
            case 0:
            {
                _favourButton = newButton;
            }
                break;
            case 1:
            {
                _commentButton = newButton;
            }
                break;
            case 2:
            {
                _sharebutton = newButton;
            }
                break;
            default:
                break;
        }
        [bottomView addSubview:newButton];
        
        CGPoint separatorPosition = CGPointMake((i + 1) * buttonWidth, 45/2.0f);
        CAShapeLayer *separator = [self createSeparatorLineWithColor:[UIColor hexColorFloat:@"dddfdf"] originPoint:CGPointMake(separatorPosition.x, 8) destPoint:CGPointMake(separatorPosition.x, 42) andPosition:separatorPosition ];
        [bottomView.layer addSublayer:separator];
    }
    CGPoint separatorPosition = CGPointMake(ScreenWidth/2.0f, 0.5);
    CAShapeLayer *separator = [self createSeparatorLineWithColor:[UIColor hexColorFloat:@"dddfdf"] originPoint:CGPointMake(0, 0.5) destPoint:CGPointMake(ScreenWidth, 0.5) andPosition:separatorPosition ];
    [bottomView.layer addSublayer:separator];
    
    
    
    _maskView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _maskView.backgroundColor = [UIColor lightGrayColor];
    _maskView.alpha = 0.5;
    [self.navigationController.view addSubview:_maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    _maskView.hidden = YES;
    [_maskView addGestureRecognizer:tap];
    /**
     *  分享界面
     */
    _shareView = [[NSShareView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180) withType:@"yueshuo"];
    
    _shareView.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < _shareView.shareArr.count; i++) {
        
        UIButton *shareBtn = (UIButton *)[_shareView viewWithTag:250+i];
        [shareBtn addTarget:self action:@selector(handleShareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view  addSubview:_shareView];

    
    [self setupData];
    
}



- (void)setupData{
    [_favourButton setTitle:[NSString stringWithFormat:@"(%d)",123] forState:UIControlStateNormal];
    [_commentButton setTitle:[NSString stringWithFormat:@"(%d)",123] forState:UIControlStateNormal];
    [_sharebutton setTitle:[NSString stringWithFormat:@"(%d)",123] forState:UIControlStateNormal];
    
    
    [self httpPostDianzanWith:self.itemUid];
    
}


#pragma mark - internet request 


- (void)httpPostDianzanWith:(NSString *)itemId{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];

    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%d", a];
    NSDictionary* dict = @{
                           //                           @"channel" : self.channel,
                           @"orderNo":timeString,
                           @"amount"  : @20.6,
                           @"sort_id":@"1"};
    self.requestType = NO;
    self.requestParams = dict;
    self.requestURL = getGoodChargeUrl;
}


- (void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr{
    if (requestErr) {
        
    }else{
        CHLog(@"%@",parserObject);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  画线
 *
 *  @param color     颜色
 *  @param oriPoint  起始位置
 *  @param destPoint 结束位置
 *  @param position  线条中心
 *
 *  @return 线条
 */
- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color
                                   originPoint:(CGPoint)oriPoint
                                     destPoint:(CGPoint)destPoint
                                   andPosition:(CGPoint)position {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(oriPoint.x,oriPoint.y)];
    [path addLineToPoint:CGPointMake(destPoint.x, destPoint.y)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    
    CGPathRelease(bound);
    
    layer.position = position;
    
    return layer;
}

//分享
- (void)handleShareAction:(UIButton *)sender {
    BOOL isShare;
    UMSocialUrlResource * urlResource  = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:self.contentUrl];
    [UMSocialData defaultData].extConfig.title = self.name;
    
    NSDictionary *dic = _shareView.shareArr[sender.tag-250];
    if (dic[@"type"] == UMShareToWechatSession) {
        
        [UMSocialData defaultData].extConfig.wechatSessionData.url = self.contentUrl;
        isShare = YES;
    } else if (dic[@"type"] == UMShareToWechatTimeline) {
        
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.contentUrl;
        isShare = YES;
    } else if (dic[@"type"] == UMShareToSina) {
        
        [UMSocialData defaultData].extConfig.sinaData.urlResource = urlResource;
        isShare = YES;
    } else if (dic[@"type"] == UMShareToQQ) {
        
        [UMSocialData defaultData].extConfig.qqData.url = self.contentUrl;
        isShare = YES;
    } else if (dic[@"type"] == UMShareToQzone) {
        
        [UMSocialData defaultData].extConfig.qqData.url = self.contentUrl;
        isShare = YES;
    } else if ([dic[@"type"] isEqualToString:@"copy"]) {
        
        [UIPasteboard generalPasteboard].string = self.contentUrl;
        [[NSToastManager manager] showtoast:@"复制成功"];
        isShare = NO;
    }
    if (isShare) {
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[dic[@"type"]] content:[NSString stringWithFormat:@"欢迎阅读乐说——%@,作品链接：%@",self.name,self.contentUrl] image:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.picUrl]] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response) {
            if (response.responseCode == UMSResponseCodeSuccess) {
                [self tapClick:nil];
                [[NSToastManager manager] showtoast:@"分享成功"];
            }
        }];
    }
}
- (void)tapClick:(UIGestureRecognizer *)tap {
    
    _maskView.hidden = YES;

    [UIView animateWithDuration:0.25 animations:^{
        _shareView.y = ScreenHeight;
        
    }];
}

@end