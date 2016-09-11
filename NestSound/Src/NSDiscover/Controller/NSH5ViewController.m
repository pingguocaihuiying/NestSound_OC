//
//  NSH5ViewController.m
//  NestSound
//
//  Created by 谢豪杰 on 16/5/8.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSH5ViewController.h"

@interface NSH5ViewController ()
<
UIWebViewDelegate
>
{
    UIWebView * h5WebView;
}


@end


@implementation NSH5ViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    //    [self configureUIAppearance];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureUIAppearance];

    NSLog(@"%@",self.h5Url);
}

#pragma mark configureUIAppearance
-(void)configureUIAppearance
{
    
    //webView
    h5WebView = [[UIWebView alloc] init];
    h5WebView.delegate = self;
    h5WebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [h5WebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.h5Url]]];
    [self.view addSubview:h5WebView];
    
    [h5WebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *clickStr=request.URL.absoluteString;
    if (![self.h5Url isEqualToString:clickStr]) {
        NSH5ViewController * eventVC = [[NSH5ViewController alloc] init];
        eventVC.h5Url = clickStr;
        [self.navigationController pushViewController:eventVC animated:YES];
    }

    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
