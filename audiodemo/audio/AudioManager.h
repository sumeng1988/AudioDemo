//
//  AudioManager.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioManagerDelegate;

@interface AudioManager : NSObject

@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) id<AudioManagerDelegate> delegate;
@property (nonatomic, strong) id validator;

+ (instancetype)shared;

- (void)play:(NSString *)file validator:(id)validator;
- (void)stopPlay;
- (void)recordWithValidator:(id)validator;
- (void)stopRecord;

@end


@protocol AudioManagerDelegate <NSObject>

@optional

- (void)didAudioPlayStarted:(AudioManager *)am;
- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully;
- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err;

- (void)didAudioRecordStarted:(AudioManager *)am;
- (void)didAudioRecordStoped:(AudioManager *)am file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully;
- (void)didAudioRecord:(AudioManager *)am err:(NSError *)err; 

@end