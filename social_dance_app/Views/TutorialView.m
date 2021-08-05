//
//  TutorialView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialView.h"
#import "Post.h"

@implementation TutorialView

- (void)updateViewWithMirrorSetting:(BOOL)isMirrored {
    [self mirrorViewWithSetting:isMirrored];
}

- (void)mirrorViewWithSetting:(BOOL)isMirrored {
    if (isMirrored) {
        self.playerView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    } else {
        self.playerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
}

- (void)changePlaybackRateWithRate:(float)playbackSpeed {
    self.playbackSpeed = playbackSpeed;
    [self.player setRate:self.playbackSpeed];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
