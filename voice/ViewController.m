//
//  ViewController.m
//  voice
//
//  Created by dasheng on 15/4/15.
//  Copyright (c) 2015年 dasheng. All rights reserved.
//

#import "ViewController.h"
#import "DSTrack+Provider.h"
#import "PlayViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *urlMusic = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 150, 50)];
    [urlMusic setBackgroundColor:[UIColor redColor]];
    [urlMusic setTitle:@"url音乐" forState:UIControlStateNormal];
    [urlMusic addTarget:self action:@selector(musicPlay:) forControlEvents:UIControlEventTouchUpInside];
    urlMusic.tag = 1;
    
    
    UIButton *myMusic = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 150, 50)];
    [myMusic setBackgroundColor:[UIColor redColor]];
    [myMusic setTitle:@"本地音乐" forState:UIControlStateNormal];
    [myMusic addTarget:self action:@selector(musicPlay:) forControlEvents:UIControlEventTouchUpInside];
    myMusic.tag = 2;
    
    [self.view addSubview:urlMusic];
    [self.view addSubview:myMusic];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)musicPlay:(UIButton *)sender{
    
    PlayViewController *playVC = [[PlayViewController alloc] init];
    switch (sender.tag) {
        case 1:
            playVC.tracks = [DSTrack remoteTracks];
            break;
        case 2:
            playVC.tracks = [DSTrack musicLibraryTracks];
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:playVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
