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

    [self printDimensions];
}


- (void)updateAutolayoutWithHeight:(CGFloat)height withWidth:(CGFloat)width {
    // TODO: right now this sets dimensions to correct ratio but multiplied by a very small number, need to fix that
    NSLog(@"Track width: %f, Track height: %f", width, height);
    if (width != 0 && height != 0) {
        /*
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:self
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:self.superview
                             attribute:NSLayoutAttributeHeight
                             multiplier:2/3
                             constant:0]];
         */
        
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


-(void)printDimensions {
    NSLog(@"Width: %f, Height: %f", self.frame.size.width, self.frame.size.height);
    NSLog(@"Video width: %f, Video height: %f", [(AVPlayerLayer *)[self layer] videoRect].size.width, [(AVPlayerLayer *)[self layer] videoRect].size.height);
    NSLog(@"Player layer width: %f, Player layer height: %f", self.layer.frame.size.width, self.layer.frame.size.height);
}

@end
