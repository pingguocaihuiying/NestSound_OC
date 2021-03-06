//
//  NSUpvoteMessageListModel.h
//  NestSound
//
//  Created by 谢豪杰 on 16/5/25.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSBaseModel.h"

@protocol UpvoteMessage  <NSObject>
@end

@interface UpvoteMessage : NSBaseModel

@property (nonatomic,assign) long messageId;
@property (nonatomic,assign) long target_uid; //userID
@property (nonatomic,assign) long userId;//upvote userID
@property (nonatomic,assign) int type;
@property (nonatomic,assign) long workId;
@property (nonatomic,assign) NSTimeInterval  upvoteTime;
@property (nonatomic,copy) NSString * author;
@property (nonatomic,copy) NSString * headerUrl;
@property (nonatomic,copy) NSString * nickName;
@property (nonatomic,copy) NSString * titleImageUrl;
@property (nonatomic,copy) NSString * titleImageUrls;
@property (nonatomic,copy) NSString * workName;
@property (nonatomic,assign) NSTimeInterval add_time;
@property (nonatomic,assign) NSTimeInterval intabletime;
@end


@interface NSUpvoteMessageListModel : NSBaseModel

@property (nonatomic,assign) long totalCount;
@property (nonatomic,strong) NSArray <UpvoteMessage> * upvoteMessageList;

@end
