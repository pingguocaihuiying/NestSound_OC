
//
//  IMHttpClient.m
//  iMei
//
//  Created by yandi on 15/3/19.
//  Copyright (c) 2015年 yinchao. All rights reserved.
//

#import "NSBaseModel.h"
#import "NSHttpClient.h"
#import "NSModelFactory.h"
#import "NSToastManager.h"

@interface NSHttpClient ()
{
    NSURLSessionDataTask *_dataTask;
}

@end

@implementation NSHttpClient
static NSHttpClient *client;

#pragma mark - client
+ (instancetype)client {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [NSHttpClient manager];
    });
    return client;
}

#pragma mark + actionCistomUsrAgent
+ (NSString *)actionCustomUsrAgent {
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *app_ver = [mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build_ver = [mainBundle.infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    
    NSString *channel = ([build_ver intValue] % 2) ? @"YinChaoTech" : @"appStore";
    
    NSString *userId = @"";
    //NSString *currentUserId = [DDUser user].userId;
    NSString *currentUserId = @"";
    if (currentUserId) {
        userId = [NSString stringWithFormat:@"UID/%d ",currentUserId.intValue];
    }
    
    NSString *deviceName = @"iPhone";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        deviceName = @"iPad";
    }
    return [NSString stringWithFormat:@"( NestSound; Client/%@%@ V/%@|%@ channel/%@ %@)"
            ,deviceName ,[UIDevice currentDevice].systemVersion , build_ver, app_ver, channel, userId];
}

#pragma mark -override initWithBaseURL
- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self  = [super initWithBaseURL:url]) {
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 90;
        [self.requestSerializer setValue:[self.class actionCustomUsrAgent] forHTTPHeaderField:@"User-Agent"];
        
        // 加上这行代码，https ssl 验证。
//        [self setSecurityPolicy:[self customSecurityPolicy]];
//        self.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
//        [self.requestSerializer setValue:@"iphone" forHTTPHeaderField:@"header-platform"];
//        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    }
    return self;
}

#pragma mark - responseObject
- (void)responseObject:(NSObject *)obj  withOperation:(NSURLSessionDataTask *)operation {

}


- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"*.yinchao.cn" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}

#pragma mark - requestWithURL ...
- (NSURLSessionDataTask *)requestWithURL:(NSString *)url
                                    type:(BOOL)requestType
                                     paras:(NSDictionary *)parasDict
                                   success:(void(^)(NSURLSessionDataTask *operation,NSObject *parserObject))success
                                   failure:(void(^)(NSURLSessionDataTask *operation,NSError *requestErr))failure {
    
    NSMutableDictionary *transferParas = [parasDict mutableCopy];
    CHLog(@"paraDisct%@",parasDict);
    // Loading
    BOOL showLoading = ![[transferParas objectForKey:kNoLoading] boolValue];
    [transferParas removeObjectForKey:kNoLoading];
    if (showLoading) {
        
        // show hud
//        [[NSToastManager manager] showprogress];
    }

    BOOL isLoadingMore = [[transferParas objectForKey:kIsLoadingMore] boolValue];
    [transferParas removeObjectForKey:kIsLoadingMore];
    
    WS(wSelf);
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@",[NSTool obtainHostURL],url];
    NSLog(@"requestURL ---  %@",requestURL);
    NSURLSessionDataTask *operation;
    /*
     https
     */
    
    
    if (requestType) {
        
        
        NSInteger i = [url rangeOfString:@"data="].location;
        NSString * str = [url substringWithRange:NSMakeRange(0, i)];
        
//        NSInteger pIndex = i + 5 ;
//        NSString *pString  =[url substringFromIndex:pIndex];
//        if (pString) {
//            NSDictionary *parameter = [self encryptWithDictionary:@{@"data":pString} isEncrypt:NO];
//
//        }
        
        NSString *cacheKey= [NSString stringWithFormat:@"%@%@",str,[self dictionaryToJson:parasDict]];

        
        
        operation = [self GET: requestURL
                   parameters:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                          
                          //hide toast
                          if (showLoading) {
                              
                              //                              [[NSToastManager manager] hideprogress];
                          }
                          CHLog(@"RESPONSE JSON:%@", responseObject);
                          
                          //                          if (!success) {
                          //                              return ;
                          //                          }
                          
                          if ([responseObject isKindOfClass:[NSDictionary class]]) {
                              
                              NSDictionary * dic =  [self encryptWithDictionary:responseObject isEncrypt:NO];
                              
                              NSBaseModel *model = [NSModelFactory modelWithURL:str
                                                                   responseJson:dic];
                              success(task,model);
                              
                              if (!model.success) {
                                  NSString *message = [responseObject objectForKey:@"message"];
                                  if (![message isEqualToString:@"操作成功"]) {
                                      [[NSToastManager manager] showtoast:message];
                                  }
                              }
                              
                              if (self.cacheManager) {
                                  if (model.code == 200) {
                                      [self.cacheManager setObject:dic forKey:cacheKey withBlock:^{
                                          
                                      }];
                                  }

                              }
                              
                          } else {
                              success(task,responseObject);
                          }
                          if (!wSelf) {
                              return ;
                          }
                          
                          [wSelf responseObject:responseObject withOperation:task];
                          
                      } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                          
                          if (showLoading) {
                              [[NSToastManager manager] hideprogress];
                          }
                          if (!failure) {
                              return ;
                          }
                          //请求失败
                          //缓存加载
                          if (self.cacheManager) {
                              
                              NSDictionary *dict = [self.cacheManager objectForKey:cacheKey];
                              
                              //有缓存数据
                              if (dict) {
                                  
                                  NSBaseModel *model = [NSModelFactory modelWithURL:str
                                                                       responseJson:dict];
                                  success(task,model);
                              }
                              
                          }else{
                              failure(task,error);

                          }
                      }];
        
        

        
    }else{
        
        operation = [self POST:requestURL
                    parameters:[self encryptWithDictionary:@{@"data":parasDict} isEncrypt:YES]
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                           
                           //hide toast
                           if (showLoading) {
                               
                               [[NSToastManager manager] hideprogress];
                           }
                           CHLog(@"RESPONSE JSON:%@", responseObject);
                           if (!success) {
                               return ;
                           }
                           
                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                               NSBaseModel *model = [NSModelFactory modelWithURL:url
                                                                    responseJson:[self encryptWithDictionary:responseObject isEncrypt:NO]];
                               
                               success(task,model);
                               
                               long resultCode = [responseObject[@"code"] longValue];
                               
                               if (resultCode == 200) {
                                   
                                   model.success = YES;
                               }
                               
                               if (!model.success) {
                                   NSString *message = [responseObject objectForKey:@"message"];
                                   if (![message isEqualToString:@"操作成功"]) {
                                       [[NSToastManager manager] showtoast:message];
                                   }
                               }
                           } else {
                               success(task,responseObject);
                           }
                           if (!wSelf) {
                               return ;
                           }
                           
                           [wSelf responseObject:responseObject withOperation:task];
                           
                       } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                           
                           if (showLoading) {
                               [[NSToastManager manager] hideprogress];
                           }
                           if (!failure) {
                               return ;
                           }
                           failure(task,error);
                       }];
    }
    operation.urlTag = url;
    operation.isLoadingMore = isLoadingMore;
    
    return operation;
}


#pragma  mark -downLoadWithFIleURL
-(void)downLoadWithFileURL:(NSString *)fileURL completionHandler:(void(^)())completion
{
    NSURLSessionConfiguration*sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.downloadManager = [[AFURLSessionManager alloc]initWithSessionConfiguration:sessionConfiguration];
    
    NSURLRequest*request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
    NSProgress *kProgress = nil;
    NSURLSessionDownloadTask *downloadTask = [self.downloadManager downloadTaskWithRequest:request progress:&kProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response){
        
        NSString * filePath = [LocalAccompanyPath stringByAppendingPathComponent:response.suggestedFilename];
        NSURL * url = [NSURL fileURLWithPath:filePath];
        
        return url;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        CHLog(@"File downloaded to: %@,%@", filePath, error);
        [kProgress removeObserver:self forKeyPath:@"fractionComplete"];
        
    }];
    [self.downloadManager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        self.progress = (CGFloat)kProgress.completedUnitCount/kProgress.totalUnitCount;
        if ([self.delegate respondsToSelector:@selector(passProgressValue:)]) {
            [self.delegate passProgressValue:[NSHttpClient client]];
        }
        if (kProgress.completedUnitCount/kProgress.totalUnitCount == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
        CHLog(@"总大小：%lld,当前大小:%lld",kProgress.totalUnitCount,kProgress.completedUnitCount);
    }];
    [kProgress addObserver:self
                forKeyPath:@"fractionComplete"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    [downloadTask resume];
}
- (void)cancelDownload {
    
    [self.downloadManager invalidateSessionCancelingTasks:YES];
}
- (void)cancelRequest {
//    [self invalidateSessionCancelingTasks:YES];
//    [[NSHttpClient client].operationQueue cancelAllOperations];
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
//    [manager.operationQueue cancelAllOperations];
    
    
}
- (void)requestCallBackWithTask:(id)currentTask target:(id)target withBackCall:(NSString*)call
{
    SEL selector = NSSelectorFromString(call);
    ((void (*)(id, SEL,id))[target methodForSelector:selector])(target, selector,currentTask);
}
@end
