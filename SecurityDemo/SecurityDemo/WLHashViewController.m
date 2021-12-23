//
//  WLHashViewController.m
//  SecurityDemo
//
//  Created by 章子云 on 2021/10/18.
//

#import "WLHashViewController.h"
#import "NSString+WLHashEncryption.h"
#import "WLRSATool.h"
#import "ECDHTool.h"

#define kAESkey @"123AESKEY456"

@interface WLHashViewController ()


@property (weak, nonatomic) IBOutlet UITextView *encryptTextView;

@property (weak, nonatomic) IBOutlet UITextView *decryptTextView;


@end

@implementation WLHashViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubviews];
    [self _initDisplayDatas];
}


#pragma mark - init/Create Methods
- (void)_initSubviews {
    
}

- (void)_initDisplayDatas {

}
#pragma mark - Network Request
#pragma mark - Public Methods
#pragma mark - Private Methods

/// UTF8
- (void)_encodeUTF8 {
    NSData *data = [self.encryptTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *hexString = data.hexValueString;
    self.decryptTextView.text = hexString;
    NSLog(@"===============================");
    NSLog(@"原数据 = %@",self.encryptTextView.text);
    NSLog(@"UTF-8 16进制 = %@",hexString);
    NSLog(@"UTF-8 2进制数据 = %@",[NSString getBinaryByHex:hexString]);
    NSLog(@"===============================");
    self.decryptTextView.text = hexString;
}

/// UTF8-16
- (void)_encodeUTF16 {
    NSData *data = [self.encryptTextView.text dataUsingEncoding:NSUTF16BigEndianStringEncoding];
    NSString *hexString = data.hexValueString;
    self.decryptTextView.text = hexString;
    NSLog(@"===============================");
    NSLog(@"原数据 = %@",self.encryptTextView.text);
    NSLog(@"UTF-16大端 16进制 = %@",hexString);
    NSLog(@"UTF-16大端 2进制数据 = %@",[NSString getBinaryByHex:hexString]);
    NSLog(@"===============================");
    self.decryptTextView.text = hexString;
}
/// base64编码
- (void)_encodeBase64 {
    NSData *data = [self.encryptTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeBase64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    self.decryptTextView.text = encodeBase64;
    NSLog(@"===============================");
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"Base64String = %@",encodeBase64);
    NSLog(@"===============================");
}
/// base64解码
- (void)_decodeBase64 {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self.decryptTextView.text options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeBase64 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.encryptTextView.text = decodeBase64;
    NSLog(@"===============================");
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"Base64String = %@",decodeBase64);
    NSLog(@"===============================");
}

/// hash MD5
- (void)_md5 {
    self.decryptTextView.text = self.encryptTextView.text.md5Hash;
    NSLog(@"===============================");
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"MD5 String = %@",self.encryptTextView.text.md5Hash);
    NSLog(@"===============================");
}
/// hash SHA256
- (void)_sha256 {
    self.decryptTextView.text = self.encryptTextView.text.sha256Hash;
    NSLog(@"===============================");
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"SHA256 String = %@",self.encryptTextView.text.sha256Hash);
    NSLog(@"===============================");
}
/// aes 加密
- (void)_aesEncrypt {
    self.decryptTextView.text = [self.encryptTextView.text AES256EncryptWithKey:kAESkey];
    NSLog(@"===============================");
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"===============================");
}
/// aes 解密
- (void)_aesDecrypt {
    self.encryptTextView.text = [self.decryptTextView.text AES256DecryptWithKey:kAESkey];
    NSLog(@"===============================");
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"===============================");
}

/// rsa 加密
- (void)_rsaEncrypt {
    self.decryptTextView.text = [WLRSATool.shareRSATool SecRefPubcliKeyEncrypt:self.encryptTextView.text];
    NSLog(@"===============================");
    NSLog(@"\n公钥信息 = %@",WLRSATool.shareRSATool.publicKeyBase64);
    NSLog(@"\n密钥信息 = %@",WLRSATool.shareRSATool.privateKeyBase64);
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"===============================");
}
/// rsa 解密
- (void)_rsaDecrypt {
    self.encryptTextView.text = [WLRSATool.shareRSATool SecRefPrivateKeyDecrypt:self.decryptTextView.text];
    NSLog(@"===============================");
    NSLog(@"\n公钥信息 = %@",WLRSATool.shareRSATool.publicKeyBase64);
    NSLog(@"\n密钥信息 = %@",WLRSATool.shareRSATool.privateKeyBase64);
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"===============================");
}
/// rsa openssl 加密
- (void)_rsaEncryptOpenssl {
    self.decryptTextView.text = [WLRSATool.shareRSATool openssl_RSAEncrypt:self.encryptTextView.text];
    NSLog(@"===============================");
    NSLog(@"\n公钥信息 = %@",WLRSATool.shareRSATool.publicKeyBase64);
    NSLog(@"\n密钥信息 = %@",WLRSATool.shareRSATool.privateKeyBase64);
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"===============================");
}
/// rsa openssl 解密
- (void)_rsaDecryptOpenssl {
    self.encryptTextView.text = [WLRSATool.shareRSATool openssl_RSADecrypt:self.decryptTextView.text];
    NSLog(@"===============================");
    NSLog(@"\n公钥信息 = %@",WLRSATool.shareRSATool.publicKeyBase64);
    NSLog(@"\n密钥信息 = %@",WLRSATool.shareRSATool.privateKeyBase64);
    NSLog(@"密文数据 = %@",self.decryptTextView.text);
    NSLog(@"AES Key = %@",kAESkey);
    NSLog(@"明文数据 = %@",self.encryptTextView.text);
    NSLog(@"===============================");
}

/// ecdh 交换
- (void)_ecdh {
    ECDHTool *ecdhTool1 = ECDHTool.alloc.init;
    [ecdhTool1 generatekeyPairs];
    self.decryptTextView.text = @"请看控制台log打印";
    NSLog(@"===============第一组ECC================");
    NSLog(@"公钥信息 = \n%@\n",ecdhTool1.publicKeyBase64);
    NSLog(@"密钥信息 = \n%@\n",ecdhTool1.privateKeyBase64);
    NSLog(@"======================================");
    NSLog(@"\n");
    NSLog(@"\n");
    ECDHTool *ecdhTool2 = ECDHTool.alloc.init;
    [ecdhTool2 generatekeyPairs];
    NSLog(@"===============第二组ECC================");
    NSLog(@"公钥信息 = \n%@\n",ecdhTool2.publicKeyBase64);
    NSLog(@"密钥信息 = \n%@\n",ecdhTool2.privateKeyBase64);
    NSLog(@"=======================================");
    
    NSLog(@"\n");
    NSLog(@"公钥A+私钥B的交换key = %@",[ECDHTool getShareKeyFromPeerPublicKeyBase64:ecdhTool1.publicKeyBase64 privateKeyBase64:ecdhTool2.privateKeyBase64 length:32]);
    NSLog(@"\n");
    NSLog(@"私钥A+公钥B的交换key = %@",[ECDHTool getShareKeyFromPeerPublicKeyBase64:ecdhTool2.publicKeyBase64 privateKeyBase64:ecdhTool1.privateKeyBase64 length:32]);
}

#pragma mark - Event Action
/// 加密/编码 事件
- (IBAction)_encryptionAction:(id)sender {
    
    [self.view endEditing:YES];
    
    if (self.encryptTextView.text.length == 0) {
        return;
    }
    
    switch (self.securityType) {
        case WLSecurityTypeUTF8:
            [self _encodeUTF8];
            break;
        case WLSecurityTypeUTF16:
            [self _encodeUTF16];
            break;
        case WLSecurityTypeBase64:
            [self _encodeBase64];
            break;
        case WLSecurityTypeMD5:
            [self _md5];
            break;
        case WLSecurityTypeSHA256:
            [self _sha256];
            break;
        case WLSecurityTypeAES:
            [self _aesEncrypt];
            break;
        case WLSecurityTypeRSA:
            [self _rsaEncrypt];
            break;
        case WLSecurityTypeRSA_Openssl:
            [self _rsaEncryptOpenssl];
            break;
        case WLSecurityTypeECDH:
            [self _ecdh];
            break;

        default:
            break;
    }
}

/// 解密/解码 事件
- (IBAction)_decryptionAction:(id)sender {
    [self.view endEditing:YES];
    if (self.encryptTextView.text.length == 0) {
        return;
    }
    
    switch (self.securityType) {
        case WLSecurityTypeBase64:
            [self _decodeBase64];
            break;
        case WLSecurityTypeAES:
            [self _aesDecrypt];
            break;
        case WLSecurityTypeRSA:
            [self _rsaDecrypt];
            break;
        case WLSecurityTypeRSA_Openssl:
            [self _rsaDecryptOpenssl];
            break;
        case WLSecurityTypeECDH:
            [self _ecdh];
            break;
        default:
            break;
    }
}


#pragma mark - Getters Setters


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
