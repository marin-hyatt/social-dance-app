//
//  SpotifySearchTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpotifySearchCellDelegate <NSObject>

-(void)openSpotifyWithSong:(Song *)song;

@end

@interface SpotifySearchTableViewCell : UITableViewCell
@property (nonatomic, strong) Song *song;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) id<SpotifySearchCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *listenWithSpotifyButton;
-(void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
