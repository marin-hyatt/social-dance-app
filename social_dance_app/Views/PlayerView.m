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
    
    [self updateAutolayoutWithHeight:[(AVPlayerLayer *)[self layer] videoRect].size.height withWidth:[(AVPlayerLayer *)[self layer] videoRect].size.width];
}


- (void)updateAutolayoutWithHeight:(CGFloat)height withWidth:(CGFloat)width {
    if (width != 0 && height != 0) {
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:self
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:self
                             attribute:NSLayoutAttributeWidth
                             multiplier:(height / width)
                             constant:0]];
        
    }
}

@end
