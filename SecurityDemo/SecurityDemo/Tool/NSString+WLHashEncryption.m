//
//  NSString+WLHashEncryption.m
//  Demo
//
//  Created by 章子云 on 2021/5/11.
//

#import "NSString+WLHashEncryption.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


@implementation NSString (WLHashEncryption)


- (NSString *)sha256Hash {
    const char *str = self.UTF8String;
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    CC_SHA256(str, (CC_LONG)strlen(str), digest);
    NSMutableString *strM = [NSMutableString string];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [strM appendFormat:@"%02X", digest[i]];
    }
    free(digest);
    return [strM copy];
}

- (NSString *)md5Hash {
    const char *str = self.UTF8String;
    unsigned char *result;
    result = malloc(CC_MD5_DIGEST_LENGTH);
    CC_MD5(str, (uint32_t)[self length], result);
    
    NSMutableString *mutableString = [NSMutableString string];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [mutableString appendFormat:@"%02X", result[i]];
    }
    free(result);
    
    return mutableString;
}

- (NSData *)dataFromHexString {
    
    const char *chars = [self UTF8String];
    int i = 0;
    int len = (int)self.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i<len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
 
    return data.copy;
}

#pragma mark - AES加解密
- (NSString *)AES256EncryptWithKey:(NSString*)key {
    return [self AESEncryptWithKey:key keyLength:kCCKeySizeAES256 iv:NULL];
}

- (NSString *)AES256DecryptWithKey:(NSString*)key {
    return [self AESDecryptWithKey:key keyLength:kCCKeySizeAES256 iv:NULL];
}
- (NSString *)AESEncryptWithKey:(NSString*)key keyLength:(size_t)keyLength iv:(nullable const void *)iv {
    
    // 1、处理秘钥gkey
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[keyLength + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    if (keyData) {
        [keyData getBytes:keyPtr length:keyData.length];
    } else {
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    }

    // 2、明文数据处理
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    // 3、输出密文数据 空间声明
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    
    // 4、执行 加密算法
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          keyLength,
                                          iv,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    // 5、密文数据处理
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        NSString *result = resultData.hexValueString;
        return result;
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSString *)AESDecryptWithKey:(NSString*)key keyLength:(size_t)keyLength iv:(nullable const void *)iv {
    
    // 1、处理秘钥gkey
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];

    char keyPtr[keyLength + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    if (keyData) {
        [keyData getBytes:keyPtr length:keyData.length];
    } else {
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    }
    
    // 2、明文数据处理
    NSData *data = self.dataFromHexString;
    NSUInteger dataLength = [data length];
    
    // 3、输出明文数据 空间声明
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    size_t numBytesDecrypted    = 0;
    // 4、执行 解密算法
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          keyLength,
                                          iv /* initialization vector (optional) */,
                                          [data bytes],
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesDecrypted);
    // 7、明文数据处理
    if (cryptStatus == kCCSuccess) {
        
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        return result;
    }
    
    free(buffer); //free the buffer;
    return nil;
}

 

/**
 十六进制转换为二进制
   
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex {
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
            if ((i+1)%2==0) {
                binary = [binary stringByAppendingString:@" "];
            }
        }
    }
    return binary;
}


@end



@implementation NSData (NSStringExtensionMethods)


 - (NSString *)hexValueString {
     
    const unsigned char *dataBytes = [self bytes];
    NSUInteger groupNum = self.length;
    NSString *result = [NSString string];
    for (int i=0;i<groupNum;i++) {
        NSString *subStr = [NSString stringWithFormat:@"%02x",dataBytes[i]];
        result = [NSString stringWithFormat:@"%@%@",result,subStr];
    }
    
    return result;
}

@end
