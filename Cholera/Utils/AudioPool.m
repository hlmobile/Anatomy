//
//  AudioPool.m
//  iTourTheCaribbean
//
//  Created by champion on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioPool.h"


@implementation AudioPool


static AVAudioPlayer *shared = nil;
static AVPlayer *sharedFromiPod = nil;

+ (void)playSound:(NSURL *)url loop:(NSInteger)loop delegate:(id)delegate
{
	[AudioPool stopSound];
	
	if (url == nil)
		return;
	
	NSError *error = nil;
	shared = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (shared == nil) {
		NSLog(@"Audio play fail : %@", [error description]);
		return;
	}
	
	shared.delegate = delegate;
	
	[shared setVolume:1.0];
    shared.numberOfLoops = loop;
	// [shared prepareToPlay];
	[shared play];
}

+ (void)playSoundFromiPodLibrary:(NSURL *)url
{
    [AudioPool stopSound];
    
    if (url == nil)
        return;
	AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    sharedFromiPod = [[AVPlayer alloc] initWithPlayerItem:item];
    [sharedFromiPod play];
}

+ (void)pauseSound {
	if (shared && shared.playing) {
		[shared pause];
	}
    if (sharedFromiPod) {
        [sharedFromiPod pause];
    }
}

+ (void)stopSound {
	if (shared) {
		[shared stop];
        shared.delegate = nil;
		shared = nil;
	}
    if (sharedFromiPod) {
        [sharedFromiPod pause];
        sharedFromiPod = nil;
    }
}

+ (void)replaySound {
	if (shared && ! shared.playing) {
		[shared play];
	}
    if (sharedFromiPod) {
        [sharedFromiPod play];
    }
}

+ (NSTimeInterval)getDuration {
	return (shared) ? shared.duration : 0;
}

+ (NSTimeInterval)getCurrentTime {
	return (shared) ? shared.currentTime : 0;
}

+ (void)setCurrentTime:(NSTimeInterval)currTime {
    if (shared) {
        shared.currentTime = currTime;
    }
}

+ (void)setVolume:(float)volume
{
    if (shared) {
        shared.volume = volume;
    }
}


@end
