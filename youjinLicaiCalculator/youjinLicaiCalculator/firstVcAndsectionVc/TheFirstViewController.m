//
//  TheFirstViewController.m
//  youjinLicaiCalculator
//
//  Created by 柚今科技01 on 2017/6/21.
//  Copyright © 2017年 柚今科技01. All rights reserved.
//

#import "TheFirstViewController.h"
#import "PickerviewsView.h"
#import "CarLoansModel.h"

@interface TheFirstViewController ()<UIGestureRecognizerDelegate,UITextFieldDelegate>
@property (nonatomic ,strong)PickerviewsView *pickerView;
@property (nonatomic ,strong)UITextField *inputTextF;//请输入金额
@property (nonatomic ,strong)NSMutableArray *shoufuArr;//首付比例的数据
@property (nonatomic ,strong)NSMutableArray *daikuanArr;//贷款年限的数据
@property (nonatomic ,strong)NSMutableArray *lilvArr;//贷款利率的数据
@property (nonatomic ,strong)NSMutableArray *qicheArr;//汽车排量的数据
@property (nonatomic ,copy)NSString *jilustring;//记录是在那个按钮进去的
@property (nonatomic ,copy)NSString *shoufubiliString;//接受首付比例的值
@property (nonatomic ,copy)NSString *daikuanstring;//接受贷款年限的值
@property (nonatomic ,copy)NSString *daikuanlilvString;//接受贷款利率的值
@property (nonatomic ,copy)NSString *qichepailiangString;//接受汽车排量的值
@property (nonatomic ,strong)UILabel *moneyLabel;//每月月供
@end

@implementation TheFirstViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;//控制整个功能是否启用
    manager.shouldResignOnTouchOutside = YES;//点击背景是否收起键盘
    manager.shouldToolbarUsesTextFieldTintColor = YES;//工具条颜色是否自定义
    manager.shouldShowTextFieldPlaceholder = NO;//中间位置显示占位符
    manager.enableAutoToolbar = YES;//是否显示键盘上的工具条
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setStairViewDidLoadUINavigationBarTintColor];
//    self.title = @"车贷计算";
    self.navigationItem.title = @"车贷计算器";
//    self.tabBarItem.title = @"车贷计算";
    
    _shoufuArr = [[NSMutableArray alloc]initWithObjects:@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    _daikuanArr = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    _lilvArr = [[NSMutableArray alloc]initWithObjects:@"基础利率",@"9.5折",@"9折",@"8.5折",@"8折",@"7.5折",@"7折",@"6.5折",@"6折",@"5.5折",@"5折", nil];
    _qicheArr = [[NSMutableArray alloc]initWithObjects:@"1.1-1.6",@"1.7-2.0",@"2.1-2.5",@"2.6-3.0",@"3.1-4.0",@"4.0及以上",@"1.0及以下", nil];
    _shoufubiliString = @"3";
    _daikuanstring = @"3";
    _daikuanlilvString = @"6.15";
    _qichepailiangString = @"2";
    //每月月供背景view
    [self monthlyPaymentsView];
    
    //计算结果已加入购置税、车船使用税、交强险、上牌费
    UILabel *resultsLabel = [[UILabel alloc]initWithFrame:CGRectMake(30*BOScreenW/750, 339*BOScreenH/1334, 720*BOScreenW/750, 30*BOScreenH/1334)];
    resultsLabel.text = @"计算结果已加入购置税、车船使用税、交强险、上牌费";
    [resultsLabel setFont:[UIFont systemFontOfSize:13]];
    resultsLabel.textColor = [UIColor colorWithHexString:@"#999999" alpha:1];
    [self.view addSubview:resultsLabel];
    if (iPhone5)
    {
        [resultsLabel setFont:[UIFont systemFontOfSize:12]];
    }
    
    //裸车价格 汽车排量的view
    [self underView];
    
    //买车后手头紧？点我看看
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pointButton.frame = CGRectMake(135*BOScreenW/750, 928*BOScreenH/1334, 480*BOScreenW/750, 80*BOScreenH/1334);
    [pointButton setTitle:@"买车后手头紧？点我看看" forState:UIControlStateNormal];
    [pointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pointButton.titleLabel.font  = [UIFont systemFontOfSize:15];
    pointButton.backgroundColor = [UIColor colorWithHexString:@"#ffa238" alpha:1];
    pointButton.layer.cornerRadius = 20;
    if (iPhone6P)
    {
        pointButton.layer.cornerRadius = 23;
    }
    if (iPhone5)
    {
        pointButton.layer.cornerRadius = 17;
    }
    pointButton.layer.masksToBounds = YES;
    [pointButton addTarget:self action:@selector(pointButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pointButton];
    
    //pickerview
    _pickerView = [[PickerviewsView alloc]initWithFrame:CGRectMake(0, 0, BOScreenW, BOScreenH)];
    [_pickerView.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];//取消按钮的点击事件
    [_pickerView.sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];//确定按钮的点击事件
    //    [self.navigationController.view addSubview:_pickerView];
    [[UIApplication sharedApplication].keyWindow addSubview:_pickerView];
    _pickerView.hidden = YES;
    //添加手势单击事件
    UITapGestureRecognizer *Gess = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(GesClicks:)];
    Gess.delegate = self;
    Gess.numberOfTapsRequired = 1;
    [_pickerView addGestureRecognizer:Gess];
}
#pragma mark --买车后手头紧？点我看看 的点击事件----
- (void)pointButtonClick
{
    NSString  *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d",1232500861];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark---单击手势的代理---
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:_pickerView.buttonView] || [touch.view isDescendantOfView:_pickerView.payPicView])
    {
        return NO;
    }
    return YES;
}

- (void)GesClicks:(UITapGestureRecognizer *)sender
{
    _pickerView.hidden = YES;
}
#pragma mark---每月月供背景view---
- (void)monthlyPaymentsView
{
    //月供的背景view
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BOScreenW, 320*BOScreenH/1334)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    //每月月供
    UILabel *paymentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(225*BOScreenW/750, 50*BOScreenH/1334, 300*BOScreenW/750, 30*BOScreenH/1334)];
    paymentsLabel.text = @"每月月供(元)";
    paymentsLabel.font = [UIFont systemFontOfSize:14];
    paymentsLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    paymentsLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:paymentsLabel];
    //月供金额
    _moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(225*BOScreenW/750, 106*BOScreenH/1334, 300*BOScreenW/750, 55*BOScreenH/1334)];
    _moneyLabel.text = @"0";
    [_moneyLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26]];
    _moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5a00" alpha:1];
    _moneyLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:_moneyLabel];
    
    //首付总车款(元)  支付利息(元)  还款总额(元)
    NSArray *interestArr = @[@"首付总车款(元)",@"支付利息(元)",@"还款总额(元)",@"0",@"0",@"0"];
    for (int i = 0; i < 6; i ++)
    {
        int k = i%3;
        int j = i/3;
        UILabel *interestLabel = [[UILabel alloc]initWithFrame:CGRectMake(23*BOScreenW/750 + k*(200*BOScreenW/750+52*BOScreenW/750), 190*BOScreenH/1334 + j*(30*BOScreenH/1334+23*BOScreenH/1334), 200*BOScreenW/750, 40*BOScreenH/1334)];
        interestLabel.tag = 290+i;
        interestLabel.text = interestArr[i];
        interestLabel.font = [UIFont systemFontOfSize:12];
        interestLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        interestLabel.textAlignment = NSTextAlignmentCenter;
        [topView addSubview:interestLabel];
        if (i==3 || i==4 || i==5)
        {
            [interestLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        }
    }
}
#pragma mark---裸车价格 汽车排量的view---
- (void)underView
{
    //底部的白色view
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 388*BOScreenH/1334, BOScreenW, 500*BOScreenH/1334)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    NSArray *carArr = @[@"裸车价格(万)",@"首付比例",@"贷款年限",@"贷款利率(%)",@"汽车排量(T/L)"];
    for (int i = 0 ; i < 5; i ++)
    {
        UILabel *carLabel = [[UILabel alloc]initWithFrame:CGRectMake(30*BOScreenW/750, 35*BOScreenH/1334 + i*(30*BOScreenH/1334+70*BOScreenH/1334), 230*BOScreenW/750, 30*BOScreenH/1334)];
        carLabel.text = carArr[i];
        [carLabel setFont:[UIFont systemFontOfSize:14]];
        carLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        [bgView addSubview:carLabel];
    }
    //细线
    for (int i = 0; i < 4; i ++)
    {
        UIView *lineView= [[UIView alloc]initWithFrame:CGRectMake(30*BOScreenW/750, 99*BOScreenH/1334 + i*100*BOScreenH/1334, 720*BOScreenW/750, 1*BOScreenH/1334)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#dfe3e6" alpha:1];
        [bgView addSubview:lineView];
    }
    //请输入金额
    _inputTextF = [[UITextField alloc]initWithFrame:CGRectMake(400*BOScreenW/750, 35*BOScreenH/1334, 320*BOScreenW/750, 30*BOScreenH/1334)];
    _inputTextF.delegate = self;
    _inputTextF.placeholder = @"请输入金额";
    _inputTextF.textAlignment = NSTextAlignmentRight;
    _inputTextF.keyboardType = UIKeyboardTypeNumberPad;
    _inputTextF.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
    _inputTextF.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:_inputTextF];
    
    //箭头  9成 6.40% 1.1-1.6
    NSArray *arrowArr = @[@"3成",@"3年",@"6.15",@"1.1-1.6"];
    for (int i = 0; i < 4; i ++)
    {
        //箭头
        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(705*BOScreenW/750, 135*BOScreenH/1334 + i*100*BOScreenH/1334, 15*BOScreenW/750, 30*BOScreenH/1334)];
        arrowImage.image = [UIImage imageNamed:@"common_goto"];
        [bgView addSubview:arrowImage];
        
        //9成 6.40% 1.1-1.6
        UILabel *arrowLabel = [[UILabel alloc]initWithFrame:CGRectMake(380*BOScreenW/750, 135*BOScreenH/1334 + i*100*BOScreenH/1334, 315*BOScreenW/750, 30*BOScreenH/1334)];
        arrowLabel.tag = 50+i;
        arrowLabel.text = arrowArr[i];
        arrowLabel.textAlignment = NSTextAlignmentRight;
        [arrowLabel setFont:[UIFont systemFontOfSize:14]];
        arrowLabel.textColor = [UIColor colorWithHexString:@"#333333" alpha:1];
        [bgView addSubview:arrowLabel];
        
        //选择的四个按钮
        UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseButton.frame = CGRectMake(0, 100*BOScreenH/1334 + i*100*BOScreenH/1334, BOScreenW, 100*BOScreenH/1334);
        chooseButton.tag = 1000 + i;
        [chooseButton addTarget:self action:@selector(chooseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:chooseButton];
    }
}
#pragma mark---下面的四个按钮选项---
- (void)chooseButtonClick:(UIButton *)sender
{
    [_inputTextF resignFirstResponder];
    switch (sender.tag)
    {
        case 1000:
        {
            _pickerView.hidden = NO;
            _jilustring = @"111";
            _pickerView.titleLabel.text = @"首付比例(成)";
            _pickerView.number = _shoufuArr;
            [_pickerView.payPicView selectRow:0 inComponent:0 animated:NO];
            [_pickerView.payPicView reloadAllComponents];
            break;
        }
        case 1001:
        {
            _pickerView.hidden = NO;
            _jilustring = @"222";
            _pickerView.titleLabel.text = @"贷款年限(年)";
            _pickerView.number = _daikuanArr;
            [_pickerView.payPicView selectRow:0 inComponent:0 animated:NO];
            [_pickerView.payPicView reloadAllComponents];
            break;
        }
        case 1002:
        {
            _pickerView.hidden = NO;
            _jilustring = @"333";
            _pickerView.titleLabel.text = @"贷款利率(%)";
            _pickerView.number = _lilvArr;
            [_pickerView.payPicView selectRow:0 inComponent:0 animated:NO];
            [_pickerView.payPicView reloadAllComponents];
            break;
        }
        case 1003:
        {
            _pickerView.hidden = NO;
            _jilustring = @"444";
            _pickerView.titleLabel.text = @"汽车排量(T/L)";
            _pickerView.number = _qicheArr;
            [_pickerView.payPicView selectRow:0 inComponent:0 animated:NO];
            [_pickerView.payPicView reloadAllComponents];
            break;
        }
            
        default:
            break;
    }
}
#pragma mark  取消确定按钮点击事件
- (void)cancelButtonClick
{
    _pickerView.hidden = YES;
}
- (void)sureButtonClick
{
    //    NSLog(@"choose%@",_pickerView.chooseString);
    if ([_jilustring  isEqual: @"111"])
    {
        if (_pickerView.chooseString == nil)
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:50];
            labelOne.text = @"2成";
            _shoufubiliString = @"2";
        }else
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:50];
            labelOne.text = [NSString stringWithFormat:@"%@成",_pickerView.chooseString];
            _shoufubiliString = _pickerView.chooseString;
        }
    }
    if ([_jilustring  isEqual: @"222"])
    {
        if (_pickerView.chooseString == nil)
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:51];
            labelOne.text = @"1年";
            _daikuanstring = @"1";
        }else
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:51];
            labelOne.text = [NSString stringWithFormat:@"%@年",_pickerView.chooseString];
            _daikuanstring = _pickerView.chooseString;
        }
    }
    if ([_jilustring  isEqual: @"333"])
    {
        if (_pickerView.chooseString == nil)
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:52];
            labelOne.text = @"6.15";
            _daikuanlilvString = labelOne.text;
        }else
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:52];
            if ([_pickerView.chooseString isEqualToString:@"基础利率"])
            {
                labelOne.text = @"6.15";
                _daikuanlilvString = labelOne.text;
            }else
            {
                NSArray *newArray = [_pickerView.chooseString componentsSeparatedByString:@"折"];
                labelOne.text = [NSString stringWithFormat:@"%.3f",0.615*[newArray[0] floatValue]];
                _daikuanlilvString = labelOne.text;
            }
        }
    }
    if ([_jilustring  isEqual: @"444"])
    {
        if (_pickerView.chooseString == nil)
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:53];
            labelOne.text = @"1.1-1.6";
            _qichepailiangString = @"2";
        }else
        {
            UILabel *labelOne = (UILabel *)[self.view viewWithTag:53];
            labelOne.text = _pickerView.chooseString;
            if ([_pickerView.chooseString isEqualToString:@"1.1-1.6"])
            {
                _qichepailiangString = @"2";
            }
            if ([_pickerView.chooseString isEqualToString:@"1.7-2.0"])
            {
                _qichepailiangString = @"3";
            }
            if ([_pickerView.chooseString isEqualToString:@"2.1-2.5"])
            {
                _qichepailiangString = @"4";
            }
            if ([_pickerView.chooseString isEqualToString:@"2.6-3.0"])
            {
                _qichepailiangString = @"5";
            }
            if ([_pickerView.chooseString isEqualToString:@"3.1-4.0"])
            {
                _qichepailiangString = @"6";
            }
            if ([_pickerView.chooseString isEqualToString:@"4.0及以上"])
            {
                _qichepailiangString = @"7";
            }
            if ([_pickerView.chooseString isEqualToString:@"1.0及以下"])
            {
                _qichepailiangString = @"1";
            }
        }
    }
    
    _pickerView.chooseString = nil;
    _pickerView.hidden = YES;
    
    [self textfieldiskong];//数据接口
}
#pragma mark---数据接口----
- (void)CarLoansData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"at"] = tokenString;
    parameters[@"car_price"] = [NSString stringWithFormat:@"%f",[_inputTextF.text floatValue]*10000];
    parameters[@"shoufu_scale"] = _shoufubiliString;
    parameters[@"year"] = _daikuanstring;
    parameters[@"apr"] = _daikuanlilvString;
    parameters[@"pailiang"] = _qichepailiangString;
    [manager POST:[NSString stringWithFormat:@"%@Common/jisuanqiChedai",BASEURL] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"r"] integerValue] == 1)
        {
            CarLoansModel *model = [CarLoansModel mj_objectWithKeyValues:responseObject[@"data"]];
            _moneyLabel.text = model.meiyue;
            
            UILabel *lixiLabel = (UILabel *)[self.view viewWithTag:293];
            lixiLabel.text = model.shoufu_sum;
            UILabel *sumLabel = (UILabel *)[self.view viewWithTag:294];
            sumLabel.text = model.lixi;
            UILabel *sumLabels = (UILabel *)[self.view viewWithTag:295];
            sumLabels.text = model.huankuan_sum;
        }
        else
        {
            NSLog(@"返回信息描述%@",responseObject[@"msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败%@",error);
    }];
}
#pragma mark ---pop返回前一页---
- (void)leftBarButtonItemClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager]setEnable:NO];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textfieldiskong];
}

#pragma mark---判断输入框是否为空------
- (void)textfieldiskong
{
    if (_inputTextF.text.length>0)
    {
        unichar single = [_inputTextF.text characterAtIndex:0];//当前输入的字符
        if (single == '.')
        {
            NSLog(@"第一个字符不能为点");
        }else
        {
            if (tokenString)
            {
                [self CarLoansData];
            }else
            {
                //得到token
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                parameters[@"app_id"] = @"2";
                parameters[@"secret"] = @"2e1eec48cae70a2c3bd8b1f2f2e177ea";
                [manager POST:[NSString stringWithFormat:@"%@Auth/accessToken",BASEURL] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                 {
                     [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"at"] forKey:@"access_token"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     [self CarLoansData];
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     NSLog(@"token请求失败没有网络%@",error);
                 }];
            }
        }
    }else
    {
        NSLog(@"请输入金额");
        _moneyLabel.text = @"0";
        UILabel *lixiLabel = (UILabel *)[self.view viewWithTag:293];
        lixiLabel.text = @"0";
        UILabel *sumLabel = (UILabel *)[self.view viewWithTag:294];
        sumLabel.text = @"0";
        UILabel *sumLabels = (UILabel *)[self.view viewWithTag:295];
        sumLabels.text = @"0";
    }
}
@end
