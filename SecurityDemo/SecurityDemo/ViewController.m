//
//  ViewController.m
//  SecurityDemo
//
//  Created by 章子云 on 2021/10/18.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "WLHashViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *datas;
@property (nonatomic, copy) NSArray *titleDatas;

@end

@implementation ViewController
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initSubviews];
    [self _initDisplayDatas];
}

#pragma mark - init/Create Methods
- (void)_initSubviews {
    
    self.title = @"数据与加密";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [UIView.alloc initWithFrame:CGRectMake(0, 0, CGFLOAT_MIN, CGFLOAT_MIN)];


    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass(TableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(TableViewCell.class)];
}

- (void)_initDisplayDatas {
    
    self.datas = @[
                  @(WLSecurityTypeUTF8),
                  @(WLSecurityTypeUTF16),
                  @(WLSecurityTypeBase64),
                  @(WLSecurityTypeMD5),
                  @(WLSecurityTypeSHA256),
                  @(WLSecurityTypeAES),
                  @(WLSecurityTypeRSA),
                  @(WLSecurityTypeRSA_Openssl),
                  @(WLSecurityTypeECDH),
                  ];
    
    self.titleDatas = @[
        @"字符编码 UTF-8",
        @"字符编码 UTF-16",
        @"传输编码 Base64",
        @"HASH算法 MD5",
        @"HASH算法 SHA256",
        @"对称加密 AES",
        @"非对称加密 RSA",
        @"非对称加密 RSA_Openssl 方法",
        @"秘钥协商 ECDH(ECC+DH)",
    ];
}
#pragma mark - Network Request
#pragma mark - Public Methods
#pragma mark - Private Methods
#pragma mark - Event Action
#pragma mark - Getters Setters

#pragma mark - UITableView Delegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.titleDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TableViewCell.class) forIndexPath:indexPath];
    
    if (indexPath.row < self.titleDatas.count) {
        cell.titleLabel.text = self.titleDatas[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WLHashViewController *vc = WLHashViewController.alloc.init;
    if (indexPath.row < self.datas.count) {
        vc.securityType = [self.datas[indexPath.row] integerValue];
        vc.title = self.titleDatas[indexPath.row];
    }
    [self.navigationController pushViewController:vc animated:YES];
}



@end
