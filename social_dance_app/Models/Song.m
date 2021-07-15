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

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self.uri = dictionary[@"uri"];
    self.title = dictionary[@"name"];
    self.artist = dictionary[@"artists"][0][@"name"];
    self.albumImageURL = dictionary[@"album"][@"images"][0][@"url"];
    
    NSLog(@"Song name: %@", self.title);
    NSLog(@"Song artist: %@", self.artist);
    NSLog(@"Album image url: %@", self.albumImageURL);
    
    return self;
}

+ (NSMutableArray *)songsWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *songArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in dictionaries) {
        [songArray addObject:[[Song alloc] initWithDictionary:dictionary]];
    }
    return songArray;
}

@end
