//
//  NSTool.m
//  NestSound
//
//  Created by yandi on 4/16/16.
//  Copyright © 2016 yinchao. All rights reserved.
//

#import "NSTool.h"

void swizzled_Method(Class class,SEL originalSelector,SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzeldMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didSwizzle = class_addMethod(class, originalSelector, method_getImplementation(swizzeldMethod), method_getTypeEncoding(swizzeldMethod));
    
    if (didSwizzle) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzeldMethod);
    }
}

BOOL debugMode = NO;
NSString *host = @"";
NSString *port = @"";

@implementation NSTool
static NSDateFormatter *dateFormatter;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [[self class] configureHostURL];
        
        dateFormatter = [[NSDateFormatter alloc] init];
    });
}

#pragma mark + configureHostURL
+ (void)configureHostURL {
    
    if (debugMode) {
        
        if ([NSTool isStringEmpty:[USERDEFAULT objectForKey:customHostKey]]) {
            
#ifdef DEBUG
            host = debugHost;
            port = debugPort;
            
            [USERDEFAULT setValue:debugHost forKey:customHostKey];
            [USERDEFAULT setValue:debugPort forKey:customPortKey];
            [USERDEFAULT synchronize];
#else
            host = releaseHost;
            port = releasePort;
            
            [USERDEFAULT setValue:releaseHost forKey:customHostKey];
            [USERDEFAULT setValue:releasePort forKey:customPortKey];
            [USERDEFAULT synchronize];
#endif
        } else {
            
            host = [USERDEFAULT objectForKey:customHostKey];
            port = [USERDEFAULT objectForKey:customPortKey];
        }
        return ;
    }
#ifdef DEBUG
    host = debugHost;
    port = debugPort;
#else
    host = releaseHost;
    port = releasePort;
#endif
}

#pragma mark - obtainHostURL
+ (NSString *)obtainHostURL {
    
    NSString *requestURL = [USERDEFAULT objectForKey:customHostKey];
    if (![NSTool isStringEmpty:requestURL]) {
        if (![NSTool isStringEmpty:customPortKey]) {
            requestURL = [requestURL stringByAppendingFormat:@":%@",[USERDEFAULT objectForKey:customPortKey]];
        }
        return requestURL;
    }
    requestURL = host;
    if (![NSTool isStringEmpty:port]) {
        requestURL = [requestURL stringByAppendingFormat:@":%@",port];
    }
    return requestURL;
}

#pragma mark - appDelegate
+ (AppDelegate *)appDelegate {
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - isStringEmpty
+ (BOOL)isStringEmpty:(NSString *)targetString {
    
    if (![targetString isKindOfClass:[NSString class]]) {
        targetString = targetString.description;
    }
    if ([targetString isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([targetString isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([targetString isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([targetString isEqualToString:@"(null)(null)"]) {
        return YES;
    }
    if ([[targetString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

#pragma mark cutImage With size
//+ (UIImage *)cutImage:(UIImage*)image scaledToSize:(CGSize)newSize2
//{
//    //压缩图片
//    CGSize newSize;
//    CGImageRef imageRef;
//    
//    if ((image.size.width / image.size.height) < (newSize2.width / newSize2.height)) {
//        newSize.width = image.size.width;
//        newSize.height = image.size.width * newSize2.height / newSize2.width;
//        
//        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));
//        
//    } else {
//        newSize.height = image.size.height;
//        newSize.width = image.size.height * newSize2.width / newSize2.height;
//        
//        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
//        
//    }
//    
//    return [UIImage imageWithCGImage:imageRef];
//    
//}


#pragma mark saveImage to Document
+(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData * imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    
    NSString * fullPath = [LocalPath stringByAppendingPathComponent:imageName];
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:fullPath]) {
        [fm removeItemAtPath:fullPath error:nil];
    }
    [imageData writeToFile:fullPath atomically:NO];
}

#pragma mark uploade image to Qiniu
+(NSString *)uploadPhotoWith:(NSString *)photoPath type:(BOOL)type_ token:(NSString *)token url:(NSString *)url
{
    NSString *  fileURL;

    __block NSString * file = fileURL;
         NSFileManager *fileManager = [NSFileManager defaultManager];
         if ([fileManager fileExistsAtPath:photoPath]) {
             QNUploadManager * upManager = [[QNUploadManager alloc] init];
             NSData * imageData = [NSData dataWithContentsOfFile:photoPath];
             [upManager putData:imageData key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                 
                  file = [NSString stringWithFormat:@"%@",[resp objectForKey:@"key"]];
                 
                 
             } option:nil];
         }
    
    return file;
}


+(BOOL)isValidateMobile:(NSString *)mobile
{
    //cell number is 13， 15，18 begain，nine \d number
    NSString *phoneRegex = @"^((13[0-9])|(14[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,6,7,8]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


+(BOOL)compareWithUser:(long)userID
{
//    NSDictionary * userDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSString * user = [NSString stringWithFormat:@"%ld",userID];
    if ([user isEqualToString:JUserID]) {
        return YES;
    }else{
        
        return NO;
    
    }
        
    
}

+(NSString *)encrytWithDic:(NSDictionary *)dic
{
    NSDictionary * dic1 = [[NSHttpClient client] encryptWithDictionary:@{@"data":dic} isEncrypt:YES];
    NSString * str =  [NSString stringWithFormat:@"data=%@",[dic1 objectForKey:requestData]];
    return str;
}

+(NSString *)stringFormatWithTimeLong:(long)times
{
    NSString * minute;
    NSString * second;
    int seconds = times%60;
    long minutes = times/60;
    if (minutes/10 == 0) {
        minute = [NSString stringWithFormat:@"0%ld",minutes];
    }
    
    if (seconds/10 == 0) {
        second = [NSString stringWithFormat:@"0%d",seconds];
    }else{
        second = [NSString stringWithFormat:@"%d",seconds];
    }
    
    NSString * str = [NSString stringWithFormat:@"%@:%@",minute,second];
    return str;
}

@end

@implementation Memory

+(NSString *)getCacheSize
{
    
    NSFileManager * fm = [NSFileManager defaultManager];
   
    NSString * fileName;
    //获取cache
    //    if (![fm fileExistsAtPath:webPath]&&![fm fileExistsAtPath:cachePath]) {
    //        return @"0";
    //    }
    
    NSEnumerator * childFilesEnumerator = [[fm subpathsAtPath:LocalAccompanyPath] objectEnumerator];
    float folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject])!=nil) {
        NSLog(@"file%@",fileName);
        NSString * fileAbsolutePath = [LocalAccompanyPath stringByAppendingPathComponent:fileName];
        folderSize+=[[fm attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    
    
    folderSize = folderSize/(1024.0*1024.0);
    
    NSString * size = [NSString stringWithFormat:@"%0.2fM",folderSize];
    return size;
}

+(void)clearCache
{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * fileName;
    NSEnumerator * childFilesEnumerator = [[fm subpathsAtPath:LocalAccompanyPath] objectEnumerator];
    //    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject])!=nil) {
        NSLog(@"file%@",fileName);
        NSString * fileAbsolutePath = [LocalAccompanyPath stringByAppendingPathComponent:fileName];
        [fm removeItemAtPath:fileAbsolutePath error:nil];
    }
    
    
    
    //    [fm removeItemAtPath:webPath error:nil];
    //    [fm removeItemAtPath:cachePath error:nil];
    
    
}




@end

@implementation date

+(NSString *)datetoStringWithDate:(NSTimeInterval)date
{
//    NSLog(@"%f",date);
//    NSNumber * num = [NSNumber numberWithDouble:date];
//    NSString * str = [num stringValue];
//    NSLog(@"%@",str);
//    NSString * subStr = [str substringToIndex:9];
//    NSLog(@"%@",subStr);
//    NSTimeInterval timeSam = [subStr doubleValue];
    NSDate * dat = [NSDate dateWithTimeIntervalSince1970:date];
    NSDateFormatter * fomatter = [[NSDateFormatter alloc] init];
    [fomatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateString = [fomatter stringFromDate:dat];
    return dateString;
}

//date to string format like "1992-12-05 12:33"
+(NSString *)datetoLongStringWithDate:(NSTimeInterval)date
{
    
    NSDate * dat = [NSDate dateWithTimeIntervalSince1970:date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString * currentTimeString = [formatter stringFromDate:dat];
    return currentTimeString;
}

//date to string formatLike "4月5日"

+(NSString *)datetoMonthStringWithDate:(NSTimeInterval)date
{
     NSDate * dat = [NSDate dateWithTimeIntervalSince1970:date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日"];
    NSString * dateString = [formatter stringFromDate:dat];
    return dateString;
}

//get the time stamp
+(NSTimeInterval )getTimeStamp
{
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval  timeStamp = [date timeIntervalSince1970];
   
    return timeStamp;
}
@end

@implementation Share

+(void)ShareWithTitle:(NSString *)title_ andShareUrl:(NSString *)shareUrl_ andShareImage:(id)shareImage andShareText:(NSString *)shareText_ andVC:(UIViewController *)VC_
{
    
    [UMSocialData defaultData].extConfig.title = title_;
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;

    
    [UMSocialData defaultData].extConfig.wechatTimelineData.url =  shareUrl_;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl_;
   
    [UMSocialData defaultData].extConfig.qqData.url = shareUrl_;
    [UMSocialSnsService presentSnsIconSheetView:VC_ appKey:umAppKey shareText:shareText_ shareImage:shareImage shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone] delegate:nil];
    
}

+(BOOL)shareAvailableWeiXin
{
    if ([WXApi isWXAppInstalled]&&[WXApi isWXAppSupportApi]) {
        return YES;
    }else{
        return NO;
    }
}


+(BOOL)shareAvailableQQ
{
    if ([QQApiInterface isQQInstalled]&&[QQApiInterface isQQSupportApi]) {
        return YES;
    }else{
        return NO;
    }
}

+(BOOL)shareAvailableSina
{
//    if () {
//        <#statements#>
//    }
    return YES;
}

@end
