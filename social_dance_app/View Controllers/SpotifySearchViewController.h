//
//  SpotifySearchViewController.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpotifySearchDelegate <NSObject>

-(void)didPickSong:(Song *)song;

@end


@interface SpotifySearchViewController : UIViewController
@property (nonatomic, weak) id<SpotifySearchDelegate> delegate;

@end





NS_ASSUME_NONNULL_END
