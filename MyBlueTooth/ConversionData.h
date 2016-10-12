//
//  ConversionData.h
//  MyBlueTooth
//
//  Created by 郑冰津 on 16/5/3.
//  Copyright © 2016年 JiangMen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversionData : NSObject

///十六进制转换为普通字符串的。
+ (NSString *)ConvertHexStringToString:(NSString *)hexString;
///普通字符串转换为十六进制
+ (NSString *)ConvertStringToHexString:(NSString *)string;
///int转data
+(NSData *)ConvertIntToData:(int)i;
///data转int
+(int)ConvertDataToInt:(NSData *)data;
///十六进制转换为data的。
+ (NSData *)ConvertHexStringToData:(NSString *)hexString;
@end
