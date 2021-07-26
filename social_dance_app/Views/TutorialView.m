//
//  TutorialView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialView.h"
#import "Post.h"

@implementation TutorialView

- (void)updateVideoWithPost:(Post *)post {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.playerView addGestureRecognizer:tapGestureRecognizer];
    [self.playerView setUserInteractionEnabled:YES];
    [self.playerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
}

- (void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
