//
//  TutorialViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialViewController.h"
#import "CacheManager.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "TutorialView.h"
#import "TutorialSettingViewController.h"

@interface TutorialViewController () <TutorialSettingDelegate>
@property (strong, nonatomic) IBOutlet TutorialView *tutorialView;
@property BOOL isMirrored;
@property float videoSpeedMultiplier;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMirrored = YES;
    self.videoSpeedMultiplier = 1;
    
    [self.tutorialView updateViewWithMirrorSetting:self.isMirrored];
    self.tutorialView.playbackSpeed = 1;
    [self updateVideo];
    
    
}

- (void)updateVideo {
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.tutorialView.player == nil) {
            self.tutorialView.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.tutorialView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.tutorialView.player currentItem]];
            [self.tutorialView.playerView setPlayer:self.tutorialView.player];
            [(AVPlayerLayer *)[self.tutorialView.playerView layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

- (IBAction)onSettingsButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"TutorialSettingViewController" sender:nil];
}

- (void)mirrorVideoChangedWithNewValue:(BOOL)isMirrored {
    self.isMirrored = isMirrored;
    [self.tutorialView mirrorViewWithSetting:self.isMirrored];
}

- (void)videoSpeedChangedWithNewMultiplier:(float)multiplier {
    self.videoSpeedMultiplier = multiplier;
    
    [self.tutorialView changePlaybackRateWithRate:self.videoSpeedMultiplier];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"TutorialSettingViewController"]) {
        TutorialSettingViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.isMirrored = self.isMirrored;
        vc.videoSpeedMutliplier = self.videoSpeedMultiplier;
    }
}


@end
