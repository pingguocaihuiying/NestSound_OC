//
//  NSBaseViewController.h
//  NestSound
//
//  Created by yandi on 4/16/16.
//  Copyright © 2016 yinchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSBaseModel;
@interface NSBaseViewController : UIViewController

@property (nonatomic, assign) BOOL showBackBtn;
@property (nonatomic,copy) NSString *requestURL;
@property (nonatomic,strong) NSDictionary *requestParams;
@property (nonatomic,assign) BOOL  requestType;

//无数据显示

@property (nonatomic,strong)     UIImageView *noDataView;


- (void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject
                     error:(NSError *)requestErr; // subclass can override
-(void)upvoteItemId :(long)itemId_ _targetUID:(long)targetUID_ _type:(long)type_ _isUpvote:(BOOL)isUpvote;

-(NSString *)getQiniuDetailWithType:(int)type andFixx:(NSString *)fixx;
- (void)handleSendResult:(QQApiSendResultCode)sendResult;
@end
