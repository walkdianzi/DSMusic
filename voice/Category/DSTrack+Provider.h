//
//  DSTrack+Provider.h
//  voice
//
//  Created by dasheng on 15/4/16.
//  Copyright (c) 2015年 dasheng. All rights reserved.
//

#import "DSTrack.h"

//歌曲来源的分类

@interface DSTrack (Provider)

/**
 *  得到后端传回来的歌曲信息数组
 *
 *  @return 歌曲信息数组
 */
+ (NSArray *)remoteTracks;

/**
 *  手机本地的歌曲信息数组
 *
 *  @return 歌曲信息数组
 */
+ (NSArray *)musicLibraryTracks;

@end
