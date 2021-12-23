//
//  WLHashViewController.h
//  SecurityDemo
//
//  Created by 章子云 on 2021/10/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WLSecurityType) {
    
    /// 字符编码
    WLSecurityTypeUTF8 = 0,
    WLSecurityTypeUTF16 = 1,
    /// 传输编码 Base64
    WLSecurityTypeBase64 = 2,
    /// hash
    WLSecurityTypeMD5 = 3,
    WLSecurityTypeSHA256 = 4,
    /// 对称加密
    WLSecurityTypeAES = 5,
    /// 非对称加密
    WLSecurityTypeRSA = 6,
    WLSecurityTypeRSA_Openssl = 7,
    /// 秘钥协商
    WLSecurityTypeECDH = 8,
//    WLSecurityTypeECC = 9,
//    WLSecurityTypeECDSA = 10,

};

NS_ASSUME_NONNULL_BEGIN

@interface WLHashViewController : UIViewController

@property (nonatomic, assign) WLSecurityType securityType;

@end

NS_ASSUME_NONNULL_END
