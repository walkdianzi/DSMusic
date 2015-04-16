//
//  DSTrack.h
//  voice
//
//  Created by dasheng on 15/4/16.
//  Copyright (c) 2015年 dasheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

//歌曲类

@interface DSTrack : NSObject<DOUAudioFile>

/**
 *  演唱者
 */
@property (nonatomic, strong) NSString *artist;

/**
 *  歌曲名
 */
@property (nonatomic, strong) NSString *title;

/**
 *  歌曲url地址或者本地歌曲文件地址
 */
@property (nonatomic, strong) NSURL *audioFileURL;

@end
