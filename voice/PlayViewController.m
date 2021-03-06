//
//  PlayViewController.m
//  voice
//
//  Created by dasheng on 15/4/16.
//  Copyright (c) 2015年 dasheng. All rights reserved.
//

#import "PlayViewController.h"
#import "DOUAudioStreamer.h"
#import "DSTrack+Provider.h"


static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface PlayViewController(){

    UILabel *_titleLabel;
    UILabel *_statusLabel;
    UILabel *_miscLabel;
    
    UIButton *_buttonPlayPause;
    UIButton *_buttonNext;
    UIButton *_buttonStop;
    
    UISlider *_progressSlider;
    
    UILabel *_volumeLabel;
    UISlider *_volumeSlider;
    
    NSUInteger _currentTrackIndex;
    NSTimer *_timer;

    DOUAudioStreamer *_streamer;
}

@end

@implementation PlayViewController

#pragma mark- 创建ui

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 64.0, CGRectGetWidth([view bounds]), 30.0)];
    [_titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_titleLabel];
    
    //当前播放状态
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_titleLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 30.0)];
    [_statusLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_statusLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0]];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_statusLabel];
    
    //加载进度等
    _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_statusLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 20.0)];
    [_miscLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_miscLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
    [_miscLabel setTextAlignment:NSTextAlignmentCenter];
    [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_miscLabel];
    
    //播放
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPlayPause setFrame:CGRectMake(80.0, CGRectGetMaxY([_miscLabel frame]) + 20.0, 60.0, 20.0)];
    [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPlayPause];
    
    //下一首
    _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 80.0 - 60.0, CGRectGetMinY([_buttonPlayPause frame]), 60.0, 20.0)];
    [_buttonNext setTitle:@"Next" forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonNext];
    
    //暂停
    _buttonStop = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonStop setFrame:CGRectMake(round((CGRectGetWidth([view bounds]) - 60.0) / 2.0), CGRectGetMaxY([_buttonNext frame]) + 20.0, 60.0, 20.0)];
    [_buttonStop setTitle:@"Stop" forState:UIControlStateNormal];
    [_buttonStop addTarget:self action:@selector(_actionStop:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonStop];
    
    //播放进度条
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonStop frame]) + 20.0, CGRectGetWidth([view bounds]) - 20.0 * 2.0, 40.0)];
    [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_progressSlider];
    
    //音量label
    _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame]) + 20.0, 80.0, 40.0)];
    [_volumeLabel setText:@"Volume:"];
    [view addSubview:_volumeLabel];
    
    //音量控制条
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX([_volumeLabel frame]) + 10.0, CGRectGetMinY([_volumeLabel frame]), CGRectGetWidth([view bounds]) - CGRectGetMaxX([_volumeLabel frame]) - 10.0 - 20.0, 40.0)];
    [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_volumeSlider];
    
    [self setView:view];
}

- (void)viewDidLoad{
    
    _currentTrackIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _resetStreamer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [_volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_timer invalidate];
    [_streamer stop];
    [self _cancelStreamer];
    
    [super viewWillDisappear:animated];
}

#pragma mark- 控制事件及点击事件

//暂停
- (void)_actionPlayPause:(id)sender
{
    if ([_streamer status] == DOUAudioStreamerPaused ||
        [_streamer status] == DOUAudioStreamerIdle) {
        [_streamer play];
    }
    else {
        [_streamer pause];
    }
}


//下一首歌
- (void)_actionNext:(id)sender
{
    if (++_currentTrackIndex >= [_tracks count]) {
        _currentTrackIndex = 0;
    }
    
    [self _resetStreamer];
}

//关闭音频流
- (void)_actionStop:(id)sender
{
    [_streamer stop];
}

//设置进度
- (void)_actionSliderProgress:(id)sender
{
    [_streamer setCurrentTime:[_streamer duration] * [_progressSlider value]];
}

//设置音量
- (void)_actionSliderVolume:(id)sender
{
    [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

#pragma mark- 辅助事件

//取消整个音频流
- (void)_cancelStreamer
{
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

//重置音频流
- (void)_resetStreamer
{
    [self _cancelStreamer];
    
    if (0 == [_tracks count])
    {
        [_miscLabel setText:@"(没有音乐)"];
    }
    else
    {
        DSTrack *track = [_tracks objectAtIndex:_currentTrackIndex];
        NSString *title = [NSString stringWithFormat:@"%@ - %@", track.artist, track.title];
        [_titleLabel setText:title];
        
        _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
        [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        [_streamer play];
        
        [self _updateBufferingStatus];
        [self _setupHintForStreamer];
    }
}

//更新缓冲状态
- (void)_updateBufferingStatus
{
    [_miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]];
    
    if ([_streamer bufferingRatio] >= 1.0) {
        NSLog(@"sha256: %@", [_streamer sha256]);
    }
}

//准备下一首歌曲
- (void)_setupHintForStreamer
{
    NSUInteger nextIndex = _currentTrackIndex + 1;
    if (nextIndex >= [_tracks count]) {
        nextIndex = 0;
    }
    
    [DOUAudioStreamer setHintWithAudioFile:[_tracks objectAtIndex:nextIndex]];
}

//设置进度条，每过一秒执行一次
- (void)_timerAction:(id)timer
{
    if ([_streamer duration] == 0.0) {
        [_progressSlider setValue:0.0f animated:NO];
    }
    else {
        [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
    }
}

//更新状态
- (void)_updateStatus
{
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"playing"];
            [_buttonPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"paused"];
            [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"idle"];
            [_buttonPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"finished"];
            [self _actionNext:nil];
            break;
            
        case DOUAudioStreamerBuffering:
            [_statusLabel setText:@"buffering"];
            break;
            
        case DOUAudioStreamerError:
            [_statusLabel setText:@"error"];
            break;
    }
}

#pragma mark- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
