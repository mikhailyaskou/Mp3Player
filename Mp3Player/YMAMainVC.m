//
//  ViewController.m
//  Mp3Player
//
//  Created by Mikhail Yaskou on 07.08.17.
//  Copyright © 2017 Mikhail Yaskou. All rights reserved.
//

#import "YMAMainVC.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const YMAFileExtension = @"mp3";
static NSString *const YMAPauseTitleForPlayButton = @"Pause";
static NSString *const YMAPlayTitleForPlayButton = @"Play";
static const NSInteger YMASecondsInMinutes = 60;

@interface YMAMainVC () <AVAudioPlayerDelegate>


@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (assign, nonatomic) NSUInteger currentSongIndex;
@property (weak, nonatomic) IBOutlet UILabel *spendTime;
@property (weak, nonatomic) IBOutlet UILabel *remindTime;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *seekBarSlide;


@end

@implementation YMAMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playlist = @[@"johnny_cash1", @"johnny_cash2", @"johnny_cash3", @"johnny_cash4"];
    self.currentSongIndex = 0;
    [self configPlayer];
    self.seekBarSlide.minimumValue = 0;
}

- (void)configPlayer {
    NSString *audioPath =
        [[NSBundle mainBundle] pathForResource:self.playlist[self.currentSongIndex] ofType:YMAFileExtension];
    self.audioURL = [NSURL URLWithString:audioPath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioURL error:nil];
    [self.player prepareToPlay];
    [self updateDisplay];
    self.seekBarSlide.maximumValue = self.player.duration;
}

- (void)play {
    [self.player play];
    if (!self.timer) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)timerFired:(NSTimer*)timer {
    [self updateDisplay];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = NULL;
    }
}

#pragma mark - UIManagment

- (void)updateDisplay {
    self.seekBarSlide.value = self.player.currentTime;
    [self updateTitles];
}

- (void)updateTitles {
    NSTimeInterval currentTime = self.seekBarSlide.value;
    NSString *currentTimeString = [self stringFromTimeInterval: currentTime];
    self.spendTime.text = currentTimeString;
    self.remindTime.text = [self stringFromTimeInterval: self.player.duration - currentTime];
    NSString *playButtonTitle = self.player.playing ? YMAPauseTitleForPlayButton : YMAPlayTitleForPlayButton;
    [self.playButton setTitle:playButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)playTapped:(id)sender {
    if (self.player.playing) {
        [self.player pause];
        [self stopTimer];
    }
    else {
        [self play];
    }
    [self updateTitles];
}

- (IBAction)changeSongTapped:(UIButton *)sender {
    //get from button tag (1 in next or -1 in prev button)
    self.currentSongIndex += sender.tag;
    if (self.currentSongIndex < self.playlist.count) {
        [self configPlayer];
    } else
    {
        //if index not in array - cancel index changes
        self.currentSongIndex -= sender.tag;
    }
    [self play];
}

- (IBAction)seekBarSlideValueChanged:(id)sender {
    [self stopTimer];
    [self updateTitles];
}

- (IBAction)seekBarSliderTouchUpInside:(id)sender {
    self.player.currentTime = self.seekBarSlide.value;
    [self.player prepareToPlay];
    [self play];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopTimer];
    [self updateDisplay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self stopTimer];
    [self updateDisplay];
}

#pragma mark - Helper

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger timeInterval = (NSInteger)interval;
    NSInteger seconds = timeInterval % YMASecondsInMinutes;
    NSInteger minutes = (timeInterval / YMASecondsInMinutes) % YMASecondsInMinutes;
    return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

@end
