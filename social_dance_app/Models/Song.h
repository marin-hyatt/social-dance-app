//
//  Song.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "PFObject.h"
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Song : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *uri;

@end

NS_ASSUME_NONNULL_END
