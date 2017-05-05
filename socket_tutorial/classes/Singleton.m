//
//  Singleton.m
//  socket_tutorial
//
//  Created by xiaoliangwang on 17-4-18.
//  Copyright (c) 2017年 . All rights reserved.
//


/*
 这个库若想监听网络，必须先设置[socket readDataWithTimeout:-1 tag:0];这里面的tag很重要。如果你写的时候用的tag与读的不相同，那么永远在回调的地方没有回复。'-1'一直监听
 当读的时候，需要判断长度是否足够，如果不够需要再次设置[socket readDataWithTimeout:-1 tag:0];
 如果你需要保持这条链路，就不要用它的超时，因为默认超时，会断开连接。你再超时回调处，再次设置时间，也只是延长等待时间，到点仍是断链。
 */


#import "Singleton.h"

#import <sys/socket.h>

#import <netinet/in.h>

#import <arpa/inet.h>

#import <unistd.h>

@implementation Singleton

+(Singleton *) sharedInstance
{
    
    static Singleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}
// socket连接
-(void)socketConnectHost{
    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
   
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];

}
// 连接成功回调
#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功");
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    [self.connectTimer fire];
    //如果我们想读取数据  就在连接成功之后加入  [self.socket readDataWithTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
   
}
// 心跳连接
-(void)longConnectToSocket{
    
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    
    NSString *longConnect = @"longConnect";
    
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    
}
// 切断socket
-(void)cutOffSocket{
    
    self.socket.userData = SocketOfflineByUser;
    
    [self.connectTimer invalidate];
    
    [self.socket disconnect];
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
    
}

//接收消息回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    //若想一直监听网络  ]加入[socket readDataWithTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
    
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.msg = aStr;
    NSLog(@"===%@",aStr);
}




@end
