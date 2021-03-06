//
//  NSComposeButton.m
//  NestSound
//
//  Created by Apple on 16/5/19.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSComposeButton.h"



@implementation NSComposeButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.size = CGSizeMake(BtnW, BtnH);
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.x = 0;
    
    self.imageView.y = 0;
    
    self.imageView.width = BtnW;
    
    self.imageView.height = BtnW;
    
    self.titleLabel.x = 0;
    
    self.titleLabel.y = CGRectGetMaxY(self.imageView.frame) + 10;
    
    self.titleLabel.width = BtnW;
    
    self.titleLabel.height = 120 - BtnW - 10;
    
    if ([UIScreen mainScreen].bounds.size.height < 667) {
        
        self.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    
    
}


@end





