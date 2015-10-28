//
//  OPGroup.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 13.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPGroup.h"

@implementation OPGroup

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
//    self = [super init];
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.ID = [[responseObject objectForKey:@"gid"] integerValue];
        
        self.name = [responseObject objectForKey:@"name"];
        
        NSString *urlString = [responseObject objectForKey:@"photo"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    
    return self;
    
}

- (id)initGroupForPostProfileWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    
    if (self) {
        
        self.ID = [[responseObject objectForKey:@"id"] integerValue];
        
        self.name = [responseObject objectForKey:@"name"];
        
        NSString *urlString = [responseObject objectForKey:@"photo_50"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    
    return self;
    
}

@end
