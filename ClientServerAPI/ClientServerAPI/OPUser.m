//
//  OPUser.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPUser.h"

@interface OPUser ()

@end

@implementation OPUser

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.ID = [[responseObject objectForKey:@"uid"] integerValue];
        self.userID = [[responseObject objectForKey:@"id"] integerValue]; 
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        
        NSString *urlString = [responseObject objectForKey:@"photo_50"];
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
        
    }
    return self;
}

@end
