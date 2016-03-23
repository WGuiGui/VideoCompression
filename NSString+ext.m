//
//  NSString+ext.m
//  LoginAndRegister
//
//  Created by qian on 15/10/13.
//  Copyright © 2015年 topsci. All rights reserved.
//

#import "NSString+ext.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ext)

-(NSString*)md5
{
    const char *cStr=[self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr,(CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - 判断是不是手机号
- (BOOL)isPhoneNumber
{
    if (self.length == 11) {
        NSString *channelString = @"^1[3578][0-9]{9}$";
        
        NSPredicate *channel = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",channelString];
        return [channel evaluateWithObject:self];
    }
    return NO;
}

@end
