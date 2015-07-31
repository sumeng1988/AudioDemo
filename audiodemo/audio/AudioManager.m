//
//  AudioManager.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioManager.h"
#import "AudioAmrUtil.h"
#import "Category.h"

@interface AudioManager () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) NSString *tmpFile;

@end

@implementation AudioManager

+ (instancetype)shared {
    static id obj = nil;
    if (obj == nil) {
        obj = [[self alloc] init];
    }
    return obj;
}

- (void)play:(NSString *)file validator:(id)validator {
    [self stopPlay];
    [self stopRecord];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return;
    }
    NSError *err;
    NSURL *url = [NSURL fileURLWithPath:file isDirectory:NO];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (err) {
        if(_delegate && [_delegate respondsToSelector:@selector(didAudioPlay:err:)]) {
            [_delegate didAudioPlay:self err:err];
        }
        [self stopPlay];
        return;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 1.0f;
    _audioPlayer.meteringEnabled = YES;
    [_audioPlayer play];
    _validator = validator;
    _isPlaying = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didAudioPlayStarted:)]) {
        [_delegate didAudioPlayStarted:self];
    }
}

- (void)stopPlay {
    [self stopPlay:NO];
}

- (void)stopPlay:(BOOL)successfully {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    if (_isPlaying) {
        _isPlaying = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioPlayStoped:successfully:)]) {
            [_delegate didAudioPlayStoped:self successfully:successfully];
        }
    }
}

- (void)recordWithValidator:(id)validator {
    [self stopPlay];
    [self stopRecord];
    
    NSDictionary *settings = @{AVSampleRateKey:@8000,
                               AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                               AVNumberOfChannelsKey:@1,
                               AVLinearPCMBitDepthKey:@16,
                               AVLinearPCMIsNonInterleaved:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMIsBigEndianKey:@NO};
    
    _tmpFile = [[self class] tmpFile];
    NSError *err;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_tmpFile]
                                                 settings:settings
                                                    error:&err];
    if (err) {
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecord:err:)]) {
            [_delegate didAudioRecord:self err:err];
        }
        [self stopRecord];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder record];
    _validator = validator;
    _isRecording = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecordStarted:)]) {
        [_delegate didAudioRecordStarted:self];
    }
}

- (void)stopRecord {
    [self stopRecord:YES];
}

- (void)stopRecord:(BOOL)successfully {
    NSTimeInterval duration = 0;
    if (_audioRecorder) {
        duration = _audioRecorder.currentTime;
        [_audioRecorder stop];
        _audioRecorder = nil;
    }
    if (_isRecording) {
        _isRecording = NO;
        NSString *recordFile = [AudioAmrUtil encodeWaveToAmr:_tmpFile];
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecordStoped:file:duration:successfully:)]) {
            [_delegate didAudioRecordStoped:self file:recordFile duration:duration successfully:successfully];
        }
    }
}

#pragma mark - Dir

+ (NSString *)tmpFile {
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AudioRecord"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *file = [[dir stringByAppendingPathComponent:[NSString UUID]] stringByAppendingPathExtension:@"caf"];
    return file;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)vplayer successfully:(BOOL)flag {
    [self stopPlay:flag];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)vplayer error:(NSError *)error {
    [self stopPlay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)vplayer {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [self stopPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)vplayer withFlags:(NSUInteger)flags {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)vrecorder successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)vrecorder error:(NSError *)error {
    [self stopRecord:NO];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)vrecorder {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [self stopRecord:NO];
}

@end
