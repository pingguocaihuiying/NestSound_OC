//
//  NSLyricViewController.m
//  NestSound
//
//  Created by Apple on 16/5/5.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSLyricViewController.h"
#import "NSLyricView.h"
#import "NSUserFeedbackViewController.h"
#import "NSLyricDetailModel.h"
#import "NSCommentViewController.h"
#import "NSUserPageViewController.h"
#import "NSLoginViewController.h"
#import "NSWriteLyricViewController.h"
#import "NSShareView.h"
#import "NSSelectLyricsViewController.h"
@interface NSLyricViewController ()<UMSocialUIDelegate>
{

    UIView *_bottomView;
    
    UIView *_maskView;
    
    UIView *_moreChoiceView;
    
    UIImage * tum ;
    //头像
    UIImageView * userIcon;
    
    UIButton * upVoteBtn;
    
    UIButton *collectionBtn;
    //作者名
    UILabel *_nameLabel;
    
    //日期
    UILabel * _dateLabel;
    
    UILabel *numLabel;
    
    //评论数
    long commentNum;
    // 分享
    NSShareView *shareView;
    //歌词
    NSLyricView * _lyricView;
    long itemId;
    long workAuthorId;
    NSString * shareURl;
    NSString * URl;
    NSArray *array;
}

@property (nonatomic,strong) LyricDetailModel * lyricDetail;

@property (nonatomic, weak) UIButton *commentBtn;

@end

@implementation NSLyricViewController


-(instancetype)initWithItemId:(long)itemId_
{
    if (self = [super init]) {
        itemId = itemId_;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2.0_moreChoice"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBtnsState) name:@"changeBtnsState" object:nil];
    
    [self fetchData];
    
}


- (void)rightBarButtonClick:(UIBarButtonItem *)rightBarButton {
    
    
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
//        shareView.y = ScreenHeight-shareView.height;
        _moreChoiceView.y = ScreenHeight - _moreChoiceView.height;
        
    }];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    
}
- (void)changeBtnsState {
    upVoteBtn.selected = NO;
    collectionBtn.selected = NO;
}
#pragma mark -fetchData
-(void)fetchData
{
    self.requestType = YES;
    NSDictionary * dic = @{@"id": [NSString stringWithFormat:@"%ld",itemId],@"uid":JUserID?JUserID:[NSNull null]};
    NSDictionary * dic1 = [[NSHttpClient client] encryptWithDictionary:@{@"data":dic} isEncrypt:YES];
    NSString * str = [NSString stringWithFormat:@"data=%@",[dic1 objectForKey:requestData]];
    
    self.requestURL = [lyricDetailURL stringByAppendingString:str];
    URl = self.requestURL;
}



#pragma mark -actionFetchData
-(void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr
{
    if (requestErr) {
        
    } else {
        if ([operation.urlTag isEqualToString:upvoteURL] || [operation.urlTag isEqualToString:collectURL]) {
            if (!parserObject.success) {
                [[NSToastManager manager] showtoast:@"操作成功"];
            }
        }else if([operation.urlTag isEqualToString:URl]) {
            if (!parserObject.success) {
                NSLyricDetailModel * lyric = (NSLyricDetailModel *)parserObject;
                [self setupBottomView];
                [self setupLyricView];

                self.lyricDetail = (LyricDetailModel *)lyric.lryicDetailModel;
                [self moreChoice];
            }
        }
    }
}

- (void)setupBottomView {
    
    _bottomView = [[UIView alloc] init];
    
    [self.view addSubview:_bottomView];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(self.view);
        
        make.height.mas_equalTo(50);
    }];
    
    
    UIView *line = [self cuttingLine];
    
    [_bottomView addSubview:line];
    
    
    
    userIcon = [[UIImageView alloc] init];
    userIcon.userInteractionEnabled = YES;
    userIcon.layer.cornerRadius = 17;
    userIcon.layer.masksToBounds = YES;
    [_bottomView addSubview:userIcon];
    
    
    //头像
    UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
       
        
    } action:^(UIButton *btn) {
        
        if (JUserID) {
            
            NSUserPageViewController * userPageVC = [[NSUserPageViewController alloc] initWithUserID:[NSString stringWithFormat:@"%ld",self.lyricDetail.userId]];
            userPageVC.who = Other;
            [self.navigationController pushViewController:userPageVC animated:YES];
            
        } else {
            
            NSLoginViewController *loginVC = [[NSLoginViewController alloc] init];
            
            [self presentViewController:loginVC animated:YES completion:nil];
        }
    
    
    }];
    
    
    [userIcon addSubview:iconBtn];
    [userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomView.mas_left).offset(15);
        
        make.top.equalTo(_bottomView.mas_top).offset(8);
        
        make.bottom.equalTo(_bottomView.mas_bottom).offset(-8);
        
        make.width.equalTo(iconBtn.mas_height);

    }];
    
    
    [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(userIcon);
        
    }];
    

    _nameLabel = [[UILabel alloc] init];
    
    _nameLabel.font = [UIFont systemFontOfSize:14];
    
    [_bottomView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(iconBtn.mas_right).offset(5);
        
        make.top.equalTo(iconBtn.mas_top);
        
    }];
    



    //dateLabel
    _dateLabel = [[UILabel alloc] init];

    
//    dateLabel.text = @"2016-05-05";
    
    _dateLabel.font = [UIFont systemFontOfSize:10];
    
    [_bottomView addSubview:_dateLabel];
    
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(iconBtn.mas_right).offset(5);
        
        make.bottom.equalTo(iconBtn.mas_bottom);
        
    }];
    
    
    WS(wSelf);
    //评论
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_comment_yes"] forState:UIControlStateNormal];
        
        [btn sizeToFit];
        
    } action:^(UIButton *btn) {
        
        if (JUserID) {
            
            NSCommentViewController *commentVC = [[NSCommentViewController alloc] initWithItemId: wSelf.lyricDetail.itemId andType:2];
            
            commentVC.musicName = self.lyricDetail.title;
            
            [self.navigationController pushViewController:commentVC animated:YES];
            
        } else {
            
            [[NSToastManager manager] showtoast:@"请登录后查看评论"];
        }
        
        
    }];
    
    self.commentBtn = commentBtn;
    
    [_bottomView addSubview:commentBtn];
    
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(_bottomView.mas_right).offset(-35);
        
        make.centerY.equalTo(_bottomView.mas_centerY);
        
    }];
    
    
    //评论数
    numLabel = [[UILabel alloc] init];
    
    numLabel.textColor = [UIColor hexColorFloat:@"181818"];
    
    numLabel.font = [UIFont boldSystemFontOfSize:10];
    
    [self.commentBtn addSubview:numLabel];
    
    [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.commentBtn.mas_top).offset(1.5);
        
        make.left.equalTo(self.commentBtn.mas_centerX).offset(3);
        
        make.width.mas_equalTo(30);
        
    }];
    
    
    //点赞
    upVoteBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_playSongs_upvote_normal"] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:@"2.0_playSongs_upvote_selected"] forState:UIControlStateSelected];
        
        [btn sizeToFit];
        
    } action:^(UIButton *btn) {
        
        if (!JUserID) {
            [[NSToastManager manager] showtoast:@"登陆后才能进行点赞和收藏操作哦"];
        }else{
            btn.selected = !btn.selected;
            [wSelf upvoteItemId:itemId _targetUID:workAuthorId _type:2 _isUpvote:YES];
        }
        
        
        
        
    }];
    
    [_bottomView addSubview:upVoteBtn];
    
    [upVoteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(commentBtn.mas_left).offset(-25);
        
        make.centerY.equalTo(_bottomView.mas_centerY);
       
    }];
    
    
    //收藏
    collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_playSongs_collection_normal"] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:@"2.0_playSongs_collection_selected"] forState:UIControlStateSelected];
        
        [btn sizeToFit];
        
    } action:^(UIButton *btn) {
        
        if (!JUserID) {
             [[NSToastManager manager] showtoast:@"登陆后才能进行点赞和收藏操作哦"];
        }else{
            
            btn.selected = !btn.selected;
            
            [wSelf upvoteItemId:itemId _targetUID:workAuthorId _type:2 _isUpvote:NO];

        }
        
    }];
    
    [_bottomView addSubview:collectionBtn];
    
    [collectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(upVoteBtn.mas_left).offset(-25);
        
        make.centerY.equalTo(_bottomView.mas_centerY);
        
    }];
    
    
}

#pragma mark -overrideUpvote
-(void)upvoteItemId:(long)itemId_ _targetUID:(long)targetUID_ _type:(long)type_ _isUpvote:(BOOL)isUpvote
{
    self.requestType = NO;
    self.requestParams = @{@"work_id":[NSNumber numberWithLong:itemId_],@"target_uid":[NSNumber numberWithLong:targetUID_],@"user_id":JUserID  ,@"wtype":[NSNumber numberWithLong:type_],@"token":LoginToken};
    if (isUpvote) {
        self.requestURL = upvoteURL;
    }else{
        self.requestURL = collectURL;
    }
}


- (void)setupLyricView {
    
    _lyricView = [[NSLyricView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 114)];
    
    _lyricView.lyricText.textAlignment = NSTextAlignmentCenter;
    
    _lyricView.lyricText.showsVerticalScrollIndicator = NO;
    
    _lyricView.lyricText.editable = NO;
    
    [self.view addSubview:_lyricView];
}

- (void)moreChoice {
    
    _maskView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    _maskView.backgroundColor = [UIColor lightGrayColor];
    
    _maskView.alpha = 0.5;
    
    [self.navigationController.view addSubview:_maskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    
    _maskView.hidden = YES;
    
    [_maskView addGestureRecognizer:tap];
    
    
    array = [[NSArray alloc] init];
    
    CGFloat moreChoiceViewH;
    
    if ([NSTool compareWithUser:self.lyricDetail.userId]) {
        
        array = @[@"举报",@"分享",@"编辑"];
        
    } else {
    
        array = @[@"举报",@"分享"];
        
    }
    
    moreChoiceViewH = 44 *array.count;
    
    _moreChoiceView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, moreChoiceViewH)];
     
    _moreChoiceView.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.view addSubview:_moreChoiceView];
    
    //分享
    shareView = [[NSShareView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180) withType:@"lyrics"];
    
    shareView.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < shareView.shareArr.count; i++) {

        UIButton *shareBtn = (UIButton *)[shareView viewWithTag:250+i];
        [shareBtn addTarget:self action:@selector(handleShareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.navigationController.view  addSubview:shareView];
    
    for (int i = 0; i < array.count; i++) {
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, _moreChoiceView.height / array.count * i, ScreenWidth, _moreChoiceView.height / array.count)];
        
        btn.tag = i;
        
        [btn setTitle:array[i] forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_moreChoiceView addSubview:btn];
        
        if (i != 0) {
            
            UIView *line = [self cuttingLine];
            
            [btn addSubview:line];
        }
        
    }
    
}

- (void)btnClick:(UIButton *)btn {
    
    if (btn.tag == 0) {
        
        if (JUserID) {
            //举报
            _maskView.hidden = YES;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                _moreChoiceView.y = ScreenHeight;
            }];
            
            CHLog(@"点击了举报");
            
            NSUserFeedbackViewController * feedBackVC = [[NSUserFeedbackViewController alloc] initWithType:@"post"];
            
            [self.navigationController pushViewController:feedBackVC animated:YES];
            
        } else {
            
            [[NSToastManager manager] showtoast:@"请登录后再举报"];
        }
        
    } else if (btn.tag == 1) {
        
       
        //分享
        [UIView animateWithDuration:0.25 animations:^{
            
            _moreChoiceView.y = ScreenHeight;
            
            shareView.y = ScreenHeight - shareView.height;
        }];
        
        
        CHLog(@"shareurl%@",[NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId]);
        
    } else {
        //编辑
        NSWriteLyricViewController * writeLyricVC = [[NSWriteLyricViewController alloc] init];
        writeLyricVC.lyricTitle = self.lyricDetail.title;
        writeLyricVC.lyricText = self.lyricDetail.lyrics;
        writeLyricVC.lyricDetail = self.lyricDetail.detail;
        writeLyricVC.lyricImgUrl = self.lyricDetail.titleImageUrl;
        writeLyricVC.lyricId = self.lyricDetail.itemId;
        [self.navigationController pushViewController:writeLyricVC animated:YES];
        _maskView.hidden = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _moreChoiceView.y = ScreenHeight;
        }];
        
    }
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (response.responseCode == UMSResponseCodeSuccess) {
        [[NSToastManager manager] showtoast:@"分享成功哦"];
        _maskView.hidden = YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            _moreChoiceView.y = ScreenHeight;
        }];

    }
}

- (void)tapClick:(UIGestureRecognizer *)tap {
    
    _maskView.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        shareView.y = ScreenHeight;
        _moreChoiceView.y = ScreenHeight;
        
    }];
//    [shareView removeFromSuperview];
}

- (UIView *)cuttingLine {
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    
    line.backgroundColor = [UIColor lightGrayColor];
    
    return line;
}


-(void)setLyricDetail:(LyricDetailModel *)lyricDetail
{
    _lyricDetail = lyricDetail;
    itemId = _lyricDetail.itemId;
    [userIcon setDDImageWithURLString:_lyricDetail.headerUrl placeHolderImage:[UIImage imageNamed:@"2.0_placeHolder"]];
    self.title = _lyricDetail.title;
    _nameLabel.text = _lyricDetail.author;
    
    _dateLabel.text = [date datetoStringWithDate:_lyricDetail.createDate];
    
    
    commentNum = _lyricDetail.commentNum;
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc ] init];
    paragraphStyle.lineSpacing = 10;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor blackColor]};
    if (lyricDetail.lyrics.length !=0) {
        _lyricView.lyricText.attributedText = [[NSAttributedString alloc] initWithString:self.lyricDetail.lyrics attributes:attributes];
    }
    
    _lyricView.lyricText.textAlignment = NSTextAlignmentCenter;

    if (_lyricDetail.isZan == 1) {
        upVoteBtn.selected = YES;
    }else{
        upVoteBtn.selected = NO;
    }
    
    if (_lyricDetail.isCollect == 1) {
        
        collectionBtn.selected = YES;
    
    }else{
        
        collectionBtn.selected = NO;
    
    }
    workAuthorId = _lyricDetail.userId;
    
    
    //评论数
    if (commentNum > 999) {
        
        numLabel.text = @"999+";
        
    } else if (commentNum < 1) {
        
        [self.commentBtn setImage:[UIImage imageNamed:@"2.0_comment_no"] forState:UIControlStateNormal];
        
        numLabel.text = nil;
        
    } else {
        
        [self.commentBtn setImage:[UIImage imageNamed:@"2.0_comment_yes"] forState:UIControlStateNormal];
        
        numLabel.text = [NSString stringWithFormat:@"%ld",commentNum];
        
    }
    
}
//分享
- (void)handleShareAction:(UIButton *)sender {
    CHLog(@"%@",sender.currentTitle);
    UIImage * imageShare;
    
    NSString *contentShare = [NSString stringWithFormat:@"%@用音巢APP创作了一首歌词，快来看看吧！《%@》,%@",_lyricDetail.author,_lyricDetail.title,[NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId]];
    if (_lyricDetail.titleImageUrl.length != 0) {
        imageShare = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_lyricDetail.titleImageUrl]]];
    }else{
        imageShare = [UIImage imageNamed:@"2.0_placeHolder"];
    }

    UMSocialUrlResource * urlResource  = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:_lyricDetail.titleImageUrl];
    [UMSocialData defaultData].extConfig.title = _lyricDetail.title;
    
    NSArray *shareArr = shareView.shareArr;
    NSDictionary *dic = shareArr[sender.tag-250];
    BOOL isShare = YES;

//    switch (sender.tag) {
            /**
             *  微信好友
             */
            if (dic[@"type"] == UMShareToWechatSession) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;

            [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId];

            } else if (dic[@"type"] == UMShareToWechatTimeline) {
            /**
             *  微信朋友圈
             */

            [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId];

            } else if (dic[@"type"] == UMShareToSina) {
            /**
             *  新浪微博
             */
            [UMSocialData defaultData].extConfig.sinaData.urlResource = urlResource;

            } else if (dic[@"type"] == UMShareToQQ) {

            /**
             *  qq好友
             */

            [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId];

            } else if (dic[@"type"] == UMShareToQzone) {

            /**
             *  qq空间
             */

            [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"%@?id=%ld",_lyricDetail.shareUrl,_lyricDetail.itemId];

            } else if ([dic[@"type"] isEqualToString:@"copy"]) {
                isShare = NO;
            /**
             *  复制链接
             */

            [UIPasteboard generalPasteboard].string = contentShare;
            [[NSToastManager manager] showtoast:@"复制成功"];
                [self tapClick:nil];

            }  else if ([dic[@"type"] isEqualToString:@"poster"]) {
                isShare = NO;
                [self tapClick:nil];

                NSSelectLyricsViewController *selectLyricVC = [[NSSelectLyricsViewController alloc] init];
                selectLyricVC.lyrics = _lyricDetail.lyrics;
                selectLyricVC.lyricTitle = _lyricDetail.title;
                selectLyricVC.author = _lyricDetail.author;
                selectLyricVC.themeImg = _lyricDetail.titleImageUrl;
                [self.navigationController pushViewController:selectLyricVC animated:YES];
            }
    
    if (isShare) {
        [[UMSocialDataService defaultDataService] postSNSWithTypes:@[dic[@"type"]] content:contentShare image:imageShare location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response) {
            if (response.responseCode == UMSResponseCodeSuccess) {
                [self tapClick:nil];

                [[NSToastManager manager] showtoast:@"分享成功"];
            }
        }];
    }



}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeBtnsState" object:nil];
}
@end

