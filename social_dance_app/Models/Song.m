//
//  Song.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "Song.h"

@implementation Song

@dynamic  title;
@dynamic  artist;
@dynamic  uri;

+ (nonnull NSString *)parseClassName {
    return @"Song";
}

@end
