//
//  PlayerView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import "PlayerView.h"

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
    
    [(AVPlayerLayer *)[self layer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [player.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem && [keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.delegate displayVideoThumbnail];
        } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            NSLog(@"%@", self.player.error.localizedDescription);
        }
    }
}


- (void)updateAutolayoutWithHeight:(CGFloat)height withWidth:(CGFloat)width {
    if (width != 0 && height != 0) {
        self.constraint = [NSLayoutConstraint
                           constraintWithItem:self
                           attribute:NSLayoutAttributeHeight
                           relatedBy:NSLayoutRelationEqual
                           toItem:self
                           attribute:NSLayoutAttributeWidth
                           multiplier:(height / width)
                           constant:0];
        [self.constraint setPriority:1000];
        [self addConstraint:self.constraint];
    }
}


@end
