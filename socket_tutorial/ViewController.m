//
//  ViewController.m
//  socket_tutorial
//
//  Created by xiaoliangwang on 17-4-18.
//  Copyright (c) 2017年 xiaoliangwang. All rights reserved.
//

#import "ViewController.h"

#import "Singleton.h"

#define SCREEN_WIDTH                 [UIScreen mainScreen].bounds.size.width //获取视图的宽
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height //获取视图的高
#define Tool_Height                         40//键盘工具栏高度
#define TableView_Height               64//tableview Y值

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    UITextView                 *txView;
    UITableView               *msgTbView;
    NSMutableArray         *msgArr;
    UIView                         * toolView; //工具栏
    UIButton                       *downBtn;//收回键盘按钮
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatData];
    [self connectServer];
    [self makeUI];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //kvo监听Singleton的msg属性（服务器发过来的消息）
    [[Singleton sharedInstance]   addObserver:self   forKeyPath:@"msg"   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld   context:@"我观察的是msg属性"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[Singleton sharedInstance] removeObserver:self forKeyPath:@"msg"];
}

#pragma mark - makeUI
- (void)creatData {
    msgArr = [[NSMutableArray alloc] init];
}

- (void)makeUI {
    
    msgTbView = [[UITableView alloc] initWithFrame:CGRectMake(0, TableView_Height, SCREEN_WIDTH, SCREEN_HEIGHT-TableView_Height-Tool_Height)];
    msgTbView.delegate = self;
    msgTbView.dataSource = self;
    [self.view addSubview:msgTbView];
    
    //初始化工具栏
    toolView  = [[UIView alloc]init];
    toolView.frame = CGRectMake(0, SCREEN_HEIGHT-Tool_Height, SCREEN_WIDTH, Tool_Height);
    toolView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    [self.view addSubview:toolView];
    
    downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downBtn.frame = CGRectMake(SCREEN_WIDTH-50, 5, 50, 30);
    downBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [downBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downBtn setTitle:@"收起" forState:UIControlStateNormal];
    [toolView addSubview:downBtn];
    
    txView = [[UITextView alloc] initWithFrame:CGRectMake(5, 1, SCREEN_WIDTH-50, Tool_Height-2)];
    txView.layer.borderColor = [UIColor orangeColor].CGColor;
    txView.layer.borderWidth = 1;
    txView.returnKeyType =UIReturnKeyDone;//键盘"换行"改为"完成"
    txView.autocorrectionType = UITextAutocorrectionTypeNo;//禁止键盘自动联想
    txView.delegate = self;
    [toolView addSubview:txView];
}


#pragma mark - action

//连接服务器
- (void)connectServer {
    [Singleton sharedInstance].socketHost = @"172.16.18.62";// host设定
    [Singleton sharedInstance].socketPort = 8080;// port设定
    
    // 在连接前先进行手动断开
    [Singleton sharedInstance].socket.userData = SocketOfflineByUser;
    [[Singleton sharedInstance] cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [Singleton sharedInstance].socket.userData = SocketOfflineByUser;
    [[Singleton sharedInstance] socketConnectHost];
}

//当服务器发过来消息
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [msgArr addObject:[NSString stringWithFormat:@"服务器消息：%@",[Singleton sharedInstance].msg]];
    
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgArr.count-1 inSection:0];
    [indexPaths addObject: indexPath];
    
    [msgTbView beginUpdates];
    [msgTbView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [msgTbView endUpdates];
    [msgTbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSLog(@"----===----%@",[Singleton sharedInstance].msg);
}

//发送消息
- (void)sendMsg {
    if (txView.text.length == 0) {
        return;
    }
    
    NSData   *dataStream  = [[NSString stringWithFormat:@"%@",txView.text] dataUsingEncoding:NSUTF8StringEncoding];
    [[Singleton sharedInstance].socket writeData:dataStream withTimeout:1 tag:0];
    
    [msgArr addObject:[NSString stringWithFormat:@"用户消息：%@",txView.text]];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgArr.count-1 inSection:0];
    [indexPaths addObject: indexPath];
    
    [msgTbView beginUpdates];
    [msgTbView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [msgTbView endUpdates];
    [msgTbView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    txView.text = @"";
    [downBtn setTitle:@"收起" forState:UIControlStateNormal];
}

//键盘升起
- (void)KeyboardWillShowNotification:(NSNotification*)aNotification {
    
    //键盘高度
    CGRect keyBoardFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    msgTbView.frame = CGRectMake(0, TableView_Height, SCREEN_WIDTH, SCREEN_HEIGHT-TableView_Height-keyBoardFrame.size.height-Tool_Height);
    
    //有数据滚动到最后一行cell位置
    if (msgArr.count != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgArr.count-1 inSection:0];
        [msgTbView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        
        toolView.frame = CGRectMake(0, SCREEN_HEIGHT-keyBoardFrame.size.height-Tool_Height, SCREEN_WIDTH, Tool_Height);
    }];
}

//键盘落下
-(void)KeyboardWillHideNotification:(NSNotification*)aNotification {
    msgTbView.frame = CGRectMake(0, TableView_Height, SCREEN_WIDTH, SCREEN_HEIGHT-TableView_Height-Tool_Height);
    
    //键盘消失时 隐藏工具栏
    [UIView animateWithDuration:0.1 animations:^{
        toolView.frame = CGRectMake(0, SCREEN_HEIGHT-Tool_Height, SCREEN_WIDTH, Tool_Height);
    }];
}

//空白区域收回键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [txView resignFirstResponder];
}

//工具栏收回键盘
- (void)btnClick :(UIButton *)sender{
    
    if ([sender.titleLabel.text isEqual:@"收起"]) {
        
        [txView resignFirstResponder];
    } else {
        [self sendMsg];
    }
    
}

#pragma mark -- 计算宽窄的函数
- (float)autoCalculateWidthOrHeight:(float)height
                              width:(float)width
                           fontsize:(float)fontsize
                            content:(NSString*)content
{
    //计算出rect
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, height)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontsize]} context:nil];
    
    //判断计算的是宽还是高
    if (height == MAXFLOAT) {
        return rect.size.height;
    }
    else
        return rect.size.width;
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return msgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [msgTbView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = msgArr[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss "];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    cell.detailTextLabel.text = dateString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = msgArr[indexPath.row];
    float height = [self autoCalculateWidthOrHeight:MAXFLOAT width:SCREEN_WIDTH-40 fontsize:17 content:str];
    return height + 18;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self sendMsg];
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
//    if ([textView.text length] + [text length] - range.length > 30){//限制字数
//        
//        return NO;
//        
//    }
    
    
    if (text.length != 0) {
        [downBtn setTitle:@"发送" forState:UIControlStateNormal];
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (txView.text.length != 0) {
        [downBtn setTitle:@"发送" forState:UIControlStateNormal];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (txView.text.length != 0) {
        [downBtn setTitle:@"发送" forState:UIControlStateNormal];
        return NO;
    }
    return YES;
}
@end
