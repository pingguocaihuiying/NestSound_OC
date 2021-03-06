//
//  NSMessageViewController.m
//  NestSound
//
//  Created by 谢豪杰 on 16/5/7.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSMessageViewController.h"
#import "NSMessageListViewController.h"
#import "NSMessageListModel.h"
#import "NSLoginViewController.h"
#import "NSPlayMusicViewController.h"
@interface NSMessageViewController ()<
UITableViewDelegate,
UITableViewDataSource
>
{
    UITableView * _messageTypeTab;
    NSArray * imageAry;
    NSArray * titleAry;
    NSMutableArray * bageAry;
    NSString * userID;
    NSString * url;
    UIImageView * playStatus;
    NSLoginViewController * login;
    int count;
}

@property (nonatomic, strong)  NSPlayMusicViewController *playSongsVC;
@end



@implementation NSMessageViewController

- (NSPlayMusicViewController *)playSongsVC {
    
    if (!_playSongsVC) {
        
        _playSongsVC = [NSPlayMusicViewController sharedPlayMusic];
    }
    
    return _playSongsVC;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage)
                                                 name:@"refreshMessage"
                                               object:nil];
    count = 0;
    
    playStatus  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 21)];
    
    playStatus.animationDuration = 0.8;
    playStatus.animationImages = animationImgsArr;
    
    [playStatus stopAnimating];
    playStatus.userInteractionEnabled = YES;
    playStatus.image = [UIImage imageNamed:@"2.0_play_status_1"];
    UIButton * btn = [[UIButton alloc] initWithFrame:playStatus.frame ];
    [playStatus addSubview:btn];
    [btn addTarget:self action:@selector(musicPaly:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:playStatus];
    
    self.navigationItem.rightBarButtonItem = item;
    
    [self configureUIAppearance];
    
}
- (void)refreshMessage {
    [self fetchData];
}
#pragma mark -playMusic
- (void)musicPaly:(UIBarButtonItem *)palyItem {
    
    if (self.playSongsVC.player == nil) {
        [[NSToastManager manager] showtoast:@"您还没有听过什么歌曲哟"];
    } else {
        
        [self.navigationController pushViewController:self.playSongsVC animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    count ++;
    if (JUserID == nil && count ==1) {
        login = [[NSLoginViewController alloc] init];
        UINavigationController * loginNav = [[UINavigationController alloc] initWithRootViewController:login];
        loginNav.navigationBar.hidden = YES;
        
        [self presentViewController:loginNav animated:YES completion:nil];
        
    } else {
       
        [self fetchData];
    }
    
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!JUserID) {
        [self.tabBarController setSelectedIndex:0];
        count = 0;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!JUserID) {
        [self.tabBarController setSelectedIndex:0];
        count = 0;
    }else{
        
        if (self.playSongsVC.player == nil) {
            
        } else {
            
            if (self.playSongsVC.postion != 0.0) {
                [playStatus startAnimating];
            }else{
                [playStatus stopAnimating];
            }
        }
    }
}
#pragma mark -fetchData
-(void)fetchData
{
    self.requestType = YES;
    
    NSMutableDictionary * userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    
    if (userDic) {
        NSDictionary * dic =@{@"uid":JUserID,@"token":LoginToken,@"timeStamp": [NSNumber  numberWithDouble:[date getTimeStamp]]};
        NSString * str = [NSTool encrytWithDic:dic];
        url = [messageURL stringByAppendingString:str];
        self.requestURL = url;
    }
    
}


#pragma mark override actionFetchData
-(void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr
{
    if (requestErr) {
        
    } else {
        if ([operation.urlTag isEqualToString:url]) {
            if (!parserObject.success) {
                
                NSMessageListModel * messageList = (NSMessageListModel *)parserObject;
                
                messageCountModel * mess = messageList.messageCount;
                bageAry = [NSMutableArray array];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.commentCount]];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.upvoteCount]];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.collecCount]];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.preserveCount]];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.cooperationCount]];
                [bageAry addObject:[NSString stringWithFormat:@"%d",mess.systemCount]];
                if (mess.commentCount || mess.upvoteCount || mess.collecCount || mess.systemCount || mess.preserveCount || mess.cooperationCount) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarTipViewNotification object:@(0)];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHiddenTabBarTipViewNotification object:@(1)];
                }
            }
        }
        [_messageTypeTab reloadData];
    }
}


#pragma mark -configureUIAppearance
-(void)configureUIAppearance
{
    self.view.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    
    
    //imageAry;
    imageAry = @[@"2.0_message_comment.png",@"2.0_message_upvote.png",@"2.0_message_coll.png",@"2.2_message_preserve",@"2.3_message_cooperation",@"2.0_message_system.png"];
    
    //titleAry
    titleAry = @[@"评论",@"点赞",@"收藏",@"保全消息",@"合作消息",@"系统消息"];
//  @[LocalizedStr(@"prompt_commentMessage"),
//                 LocalizedStr(@"prompt_upvote"),
//                 LocalizedStr(@"prompt_collection"),
//                 LocalizedStr(@"prompt_systemMessage")
//                 ];
    
    
    //messageType table
    _messageTypeTab = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _messageTypeTab.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    _messageTypeTab.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _messageTypeTab.dataSource = self;
    _messageTypeTab.delegate = self;
    
    
    [self.view addSubview:_messageTypeTab];
    
    
    //constraints
    [_messageTypeTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
//
    WS(wSelf);
    //refresh
    [_messageTypeTab addDDPullToRefreshWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchData];
        }
    }];
    _messageTypeTab.showsPullToRefresh = NO;
    _messageTypeTab.showsInfiniteScrolling = NO;
}


#pragma mark tableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * MessageCellIdenfity = @"MessageCell";
    UITableViewCell * messageCell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdenfity];
    NSInteger section= indexPath.section;
    if (!messageCell) {
        messageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdenfity];
//        messageCell.backgroundColor = [UIColor whiteColor];
        UILabel * bage = [[UILabel alloc] init];
        bage.textAlignment = NSTextAlignmentCenter;
        bage.font = [UIFont systemFontOfSize:13];
        bage.tag = 100;
        bage.textColor = [UIColor whiteColor];
        bage.backgroundColor = [UIColor redColor];
        [messageCell.contentView addSubview:bage];
        messageCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //comstraints
        [bage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(messageCell.contentView.mas_centerY);
            make.right.equalTo(messageCell.contentView.mas_right).with.offset(-5);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(20);
        }];
        bage.layer.masksToBounds = YES;
        bage.layer.cornerRadius = 10;
    }
    UILabel * bage = (UILabel *)[messageCell.contentView viewWithTag:100];
    
    if ([bageAry[section] isEqualToString:@"0"] || bageAry[section] == nil) {
        bage.hidden = YES;
    }else{
        bage.hidden = NO;
        bage.text = bageAry[section];
    }
    messageCell.textLabel.text = titleAry[section];
    messageCell.imageView.image = [UIImage imageNamed:imageAry[section]];
    return messageCell;
}


#pragma mark tableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger section = indexPath.section;
    NSMessageListViewController * messageListVC;
    switch (section) {
        case 0:{
            messageListVC = [[NSMessageListViewController alloc] initWithMessageType:CommentMessageType];
            messageListVC.messageListType = @"评论";
//            LocalizedStr(@"prompt_commentMessage");
            break;}
        case 1:{
            messageListVC = [[NSMessageListViewController alloc] initWithMessageType:UpvoteMessageType];
            messageListVC.messageListType = @"赞";
//            LocalizedStr(@"prompt_upvote");
            break;
            }
        case 2:{
           messageListVC = [[NSMessageListViewController alloc] initWithMessageType:CollectionMessageType];
            messageListVC.messageListType = @"收藏";
//            LocalizedStr(@"prompt_collection");
            break;}
        case 3:{
            messageListVC = [[NSMessageListViewController alloc] initWithMessageType:PreserveMessageType];
            messageListVC.messageListType = @"保全消息";
//            LocalizedStr(@"prompt_systemMessage");
            break;}
        case 5:{
            messageListVC = [[NSMessageListViewController alloc] initWithMessageType:SystemMessageType];
            messageListVC.messageListType = @"系统消息";
            break;}
        case 4:{
            messageListVC = [[NSMessageListViewController alloc] initWithMessageType:cooperationMessageType];
            messageListVC.messageListType = @"合作消息";
            break;}
        default:
            break;
    }
    [self.navigationController pushViewController:messageListVC animated:YES];
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshMessage" object:nil];
}

@end
