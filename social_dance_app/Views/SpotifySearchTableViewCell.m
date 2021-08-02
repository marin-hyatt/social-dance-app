//
//  SpotifySearchTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import "SpotifySearchTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation SpotifySearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

- (void)updateAppearance {
    self.listenWithSpotifyButton.layer.cornerRadius = 5;
    self.listenWithSpotifyButton.layer.masksToBounds = true;
    
    self.trackNameLabel.text = self.song.title;
    self.artistNameLabel.text = self.song.artist;
    
    self.albumImageView.image = nil;
    
    if (self.song.albumImageURLString != nil) {
        [self.albumImageView setImageWithURL: [NSURL URLWithString:self.song.albumImageURLString]];
    }
}

- (IBAction)onListenButtonPressed:(UIButton *)sender {
    [self.delegate openSpotifyWithSong:self.song];
}

@end
