//
//  CreateView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "CreateView.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@implementation CreateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    PFUser *currentUser = [PFUser currentUser];
    PFFileObject *file = currentUser[@"profilePicture"];
    NSLog(@"%@", file);
    
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:file];
    
    self.recordButton.layer.cornerRadius = 5;
    self.recordButton.layer.masksToBounds = true;
    
    self.chooseButton.layer.cornerRadius = 5;
    self.chooseButton.layer.masksToBounds = true;
    
    self.songButton.layer.cornerRadius = 5;
    self.songButton.layer.masksToBounds = true;
    
    self.songView.layer.cornerRadius = 5;
    self.songView.layer.masksToBounds = true;
    self.songView.layer.borderColor = [UIColor systemGreenColor].CGColor;
    self.songView.layer.borderWidth = 1.0f;
}

- (void)updateSongViewWithSong:(Song *)song {
    self.trackNameLabel.text = song.title;
    self.artistNameLabel.text = song.artist;
    
    self.albumImageView.image = nil;
    
    if (song.albumImageURLString != nil) {
        [self.albumImageView setImageWithURL: [NSURL URLWithString:song.albumImageURLString]];
    }
}

@end
