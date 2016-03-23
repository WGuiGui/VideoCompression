//
//  ChatPublicFunc.m
//  LoginAndRegister
//
//  Created by qian on 15/9/21.
//  Copyright (c) 2015年 topsci. All rights reserved.
//

#import "ChatPublicFunc.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ChatPublicFunc ()
{
    SystemSoundID sound;
}

@end

@implementation ChatPublicFunc

#define USER_AID_KEY @"user_aid.topsci.com"

+ (NSString *)chatTime : (NSString *)strDateTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
    NSDate *oldDate = [dateFormatter dateFromString:strDateTime];
    
    NSString *nowDate = [dateFormatter stringFromDate:date];
    if ([[nowDate substringToIndex:10] isEqualToString:[strDateTime substringToIndex:10]]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else if ([[nowDate substringToIndex:7] isEqualToString:[strDateTime substringToIndex:7]]) {
        [dateFormatter setDateFormat:@"dd HH:mm"];
    } else if ([[nowDate substringToIndex:4] isEqualToString:[strDateTime substringToIndex:4]]) {
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    return [dateFormatter stringFromDate:oldDate];
}

#pragma mark 返回当前日期时间字符串
+ (NSString*)currentDateTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)userId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userAID = [userDefaults stringForKey:USER_AID_KEY];
    return userAID;
}

#pragma mark - 判断图片格式
+ (NSString *)typeForImageData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

#pragma mark - 发送消息时播放声音
-(void)playSoundSendMessage
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"message_sent" ofType:@"aiff"];
    if (path) {
        //注册声音到系统
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
        AudioServicesPlayAlertSound(sound);
    }
}

+(NSString*)saveImg:(NSString *)imageName subPath:(NSString *)subPath imageObject:(UIImage *)imageObject
{
    // 图片的二进制
    NSString *imgPrefix = @"";
    NSData *imgData = UIImageJPEGRepresentation(imageObject, 0.2);
    if (!imgData) {
        imgData=UIImagePNGRepresentation(imageObject);
        imgPrefix=@".png";
    } else {
        imgPrefix=@".jpg";
    }
    
    // 图片保存路径
    NSString *relativeImgPath = [NSString stringWithFormat:@"%@%@%@", subPath, [imageName md5], imgPrefix];
    NSString *localImgStr=[NSHomeDirectory() stringByAppendingString:relativeImgPath];
    
    // 保存图片数据
    NSString *path=[NSHomeDirectory() stringByAppendingFormat:@"%@", subPath];
    NSError *err = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:localImgStr]) //如果不存在
    {
        if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err])
        {
            [imgData writeToFile:localImgStr options:NSDataWritingAtomic error:&err];
            if (err) {
                NSLog(@"保存图片失败：%@", err);
                return nil;
            } else {
                NSLog(@"保存图片成功");
            }
        } else {
            NSLog(@"创建目录失败:%@", err);
            return nil;
        }
    } else {
        //这个代表该路径已经存在，那就返回这个已经存在的路径
        NSArray * pathArr = [localImgStr componentsSeparatedByString:@"/Library/"];
        if (pathArr.count == 2) {
            localImgStr = [NSString stringWithFormat:@"/Library/%@",pathArr[1]];
        }
        return localImgStr;
    }
    
    return relativeImgPath;
}

#pragma mark - 获取图片的缩略图
+(UIImage *)generatePhotoThumbnail:(UIImage *)image {

    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 48.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;

    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }

    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);

    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);

    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return thumbnail;
}

#pragma mark - 注意图片的旋转角度
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(NSString *)getCallTimeWithSecond:(long)callTime
{
    long hour = callTime / 3600;
    long minute = (callTime % 3600) / 60;
    long second = (callTime % 3600) % 60;
    if (hour) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minute, second];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld",minute, second];
    }
}

+(void)deleteLocalChatMessageCache
{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/Library/NBCache",NSHomeDirectory()];
    
    if([fm fileExistsAtPath:cacheFilePath])
    {
        if ([fm removeItemAtPath:cacheFilePath error:nil]) {
            NSLog(@"所有缓存已清空");
        }
    }
}

#pragma mark - 删除userId对应的本地缓存
+(void)deleteChatRoomMessageCache:(NSString *)userId
{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/Library/NBCache/%@",NSHomeDirectory(),userId];
    if([fm fileExistsAtPath:cacheFilePath])
    {
        if ([fm removeItemAtPath:cacheFilePath error:nil]) {
            NSLog(@"所有缓存已清空");
        }
    }
}

+(NSMutableDictionary *)getTextMessageWith:(NSString *)text
{
    NSArray * textArray = [text componentsSeparatedByString:@","];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (textArray.count) {
        for (NSString * str in textArray) {
            
            if ([str hasPrefix:@"FROM"]) {
                dic[@"senderID"] = [str stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
            }
            
            if ([str hasPrefix:@"} "]) {
                NSArray * array = [str componentsSeparatedByString:@":{"];
                
                if (array.count == 2 && [array[0] hasSuffix:@":102"]) {
                    //某人修改了群名字
                    dic[@"messageCode"] = @"102";
                    NSLog(@"%@",array);
                    NSString * gIDStr = [array[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    if ([gIDStr hasPrefix:@"gID:"]) {
                        dic[@"gID"] = [gIDStr stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
                    }
                } else if (array.count == 2 && [array[0] hasSuffix:@"104"]) {
                    //某人修改了自己的昵称
                    dic[@"messageCode"] = @"104";
                    dic[@"gID"] = [[array[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
                } else if (array.count == 2 && [array[0] hasSuffix:@"105"]) {
                    //某人退出了群组
                    dic[@"messageCode"] = @"105";
                    dic[@"gID"] = [[array[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
                } else if (array.count == 2 && [array[0] hasSuffix:@"103"]) {
                    //某人把别人加入了群组
                    dic[@"messageCode"] = @"103";
                    dic[@"gID"] = [[array[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
                } else if (array.count == 2 && [array[0] hasSuffix:@"101"]) {
                    //某人把我加入了群组
                    dic[@"messageCode"] = @"101";
                    NSArray * arr = [array[1] componentsSeparatedByString:@"}"];
                    if (arr.count == 2) {
                        dic[@"gID"] = [[arr[0] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
                    }
                } else if (array.count == 1){
                    dic[@"messageText"] = [str stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
                }
            }
            
            if ([str hasPrefix:@"{TYPE"]) {
                NSString * typeString = [str stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@""];
                if ([typeString isEqualToString:@"group"]) {
                    dic[@"msgType"] = typeString;
                }
                if ([typeString isEqualToString:@"offline"]) {
                    dic[@"offline"] = typeString;
                }
            }
            if ([str hasPrefix:@"TYPE"]) {
                NSString * typeString = [str stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];
                if ([typeString isEqualToString:@"offline"]) {
                    dic[@"offline"] = typeString;
                }
                if ([typeString isEqualToString:@"group"]) {
                    dic[@"msgType"] = typeString;
                }
            }
            if ([str hasPrefix:@"TIME"]) {
                dic[@"msgTime"] = [str stringByReplacingCharactersInRange:NSMakeRange(0, 5) withString:@""];;
            }
            if ([str hasPrefix:@"\"gName"]) {
                NSArray * gNameArr = [[str stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@"}"];
                if (gNameArr.count == 2) {
                    dic[@"gName"] = [gNameArr[0] stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@""];
                }
            }
            if ([str hasPrefix:@"\"gNickname\""]) {
                
                dic[@"gNickName"] = [[str stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingCharactersInRange:NSMakeRange(0, 10) withString:@""];
            }
            if ([str hasPrefix:@"\"gUser\""]) {
                NSArray * gNameArr = [[str stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@"}"];
                if (gNameArr.count == 2) {
                    dic[@"gUserId"] = [gNameArr[0] stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@""];
                }
            }
            if ([str hasPrefix:@"\"gUsers\""]) {
                
                NSArray * textSubArr = [text componentsSeparatedByString:@",\"gUsers\":"];
                if (textSubArr.count == 2) {
                    NSArray * textSubArr2 = [textSubArr[1] componentsSeparatedByString:@"]"];
                    if (textSubArr2.count == 2) {
                        
                        NSDictionary * dict = [self getDicWithJsonString:[NSString stringWithFormat:@"%@]",textSubArr2[0]]];
                        NSMutableArray * usersArray = [NSMutableArray array];
                        for (NSDictionary * dict2 in dict) {
                            NSLog(@"%@",dict2);
                            [usersArray addObject:dict2];
                        }
                        dic[@"gUsers"] = usersArray;
                    }
                }
            }
        }
    }
    
    if (dic[@"gUserId"] && [dic[@"messageCode"] isEqualToString:@"103"]) {
        [dic removeObjectForKey:@"gUserId"];
    }
    return dic;
}

+(NSDictionary *)getDicWithJsonString:(NSString *)jsonString
{
    if (!jsonString) {
        return nil;
    }
    NSError * error;
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return nil;
    } else {
        return dic;
    }
}

@end
