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

@end
