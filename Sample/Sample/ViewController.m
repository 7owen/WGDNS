//
//  ViewController.m
//  Sample
//
//  Created by 7owen on 16/3/15.
//  Copyright © 2016年 7owen. All rights reserved.
//

#import "ViewController.h"
#import "WGDNSManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *domain = @"baidu.com";
    NSString *ip = [[WGDNSManager instance]queryWithDomain:domain];
    NSLog(@"query ip = %@",ip);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
