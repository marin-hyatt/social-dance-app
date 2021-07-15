//
//  SpotifySearchTableViewCell.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotifySearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@end

NS_ASSUME_NONNULL_END
