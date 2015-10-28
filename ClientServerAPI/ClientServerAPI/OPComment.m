//
//  OPComment.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 21.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPComment.h"

#import "OPUser.h"
#import "OPGroup.h"

@implementation OPComment

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    //    self = [super init];
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.ID = [ [responseObject objectForKey:@"id"] integerValue];
        
        self.date = [ [responseObject objectForKey:@"date"] integerValue];
        
        self.text = [responseObject objectForKey:@"text"];
        
        self.ownerID = [ [responseObject objectForKey:@"from_id"] integerValue];
        
    }
    
    return self;
}

@end
