//
//  ViewController.m
//  iosOpenCV
//
//  Created by mac on 2019/7/19.
//  Copyright © 2019 David Ji. All rights reserved.
//
#import "ViewController.h"
#import "ImageVC.h"
#import "VideoVC.h"
#import "CascadeVC.h"
#import "VideoioVC.h"
#import "Features2dVC.h"

@interface ViewController ()

@property(nonatomic,strong) UIButton * imageBtn;
@property(nonatomic,strong) UIButton * videoBtn;
@property(nonatomic,strong) UIButton * cascadeBtn;
@property(nonatomic,strong) UIButton * videoioBtn;
@property(nonatomic,strong) UIButton * features2dBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageBtn=[UIButton new];
    _imageBtn.backgroundColor=[UIColor greenColor];
    _imageBtn.frame=CGRectMake(30, 90, 145, 45);
    _imageBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _imageBtn.titleLabel.textColor=[UIColor whiteColor];
    [_imageBtn setTitle:@"Image" forState:UIControlStateNormal];
    [_imageBtn.layer setCornerRadius:10.0];
    [_imageBtn addTarget:self action:@selector(imageDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.imageBtn];
    
    _videoBtn=[UIButton new];
    _videoBtn.backgroundColor=[UIColor greenColor];
    _videoBtn.frame=CGRectMake(200, 90, 145, 45);
    _videoBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _videoBtn.titleLabel.textColor=[UIColor whiteColor];
    [_videoBtn setTitle:@"Video" forState:UIControlStateNormal];
    [_videoBtn.layer setCornerRadius:10.0];
    [_videoBtn addTarget:self action:@selector(videoDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoBtn];
    
    _cascadeBtn=[UIButton new];
    _cascadeBtn.backgroundColor=[UIColor blackColor];
    _cascadeBtn.frame=CGRectMake(30, 150, 145, 45);
    _cascadeBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _cascadeBtn.titleLabel.textColor=[UIColor whiteColor];
    [_cascadeBtn setTitle:@"对象检测" forState:UIControlStateNormal];
    [_cascadeBtn.layer setCornerRadius:10.0];
    [_cascadeBtn addTarget:self action:@selector(cascadeDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cascadeBtn];
    
    _videoioBtn=[UIButton new];
    _videoioBtn.backgroundColor=[UIColor blackColor];
    _videoioBtn.frame=CGRectMake(200, 150, 145, 45);
    _videoioBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _videoioBtn.titleLabel.textColor=[UIColor whiteColor];
    [_videoioBtn setTitle:@"Video I/O" forState:UIControlStateNormal];
    [_videoioBtn.layer setCornerRadius:10.0];
    [_videoioBtn addTarget:self action:@selector(videoioDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoioBtn];
    
    _features2dBtn=[UIButton new];
    _features2dBtn.backgroundColor=[UIColor brownColor];
    _features2dBtn.frame=CGRectMake(30, 210, 145, 45);
    _features2dBtn.titleLabel.font=[UIFont systemFontOfSize:20];
    _features2dBtn.titleLabel.textColor=[UIColor whiteColor];
    [_features2dBtn setTitle:@"Features2d" forState:UIControlStateNormal];
    [_features2dBtn.layer setCornerRadius:10.0];
    [_features2dBtn addTarget:self action:@selector(features2dDemo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_features2dBtn];
}

-(void)imageDemo:(UIButton*)sender{
    ImageVC * tableViewController=[[ImageVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)videoDemo:(UIButton*)sender{
    VideoVC * tableViewController=[[VideoVC alloc]init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

-(void)cascadeDemo:(UIButton*)sender{
    CascadeVC * vc=[[CascadeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)videoioDemo:(UIButton*)sender{
    VideoioVC * vc=[[VideoioVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)features2dDemo:(UIButton*)sender{
    Features2dVC * vc=[[Features2dVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
