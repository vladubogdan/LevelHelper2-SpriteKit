//
//  LHConfig.m
//  LevelHelper2API
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHConfig.h"
#import "LHUtils.h"
@implementation LHConfig
{
    BOOL _debug;
}

+(id)sharedInstance{
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[LHConfig alloc] init];
    });
    return _sharedObject;
}

-(id)init{
    self = [super init];
    if(self){
        _debug = NO;
    }
    return self;
}

-(void)dealloc{
    
    LH_SUPER_DEALLOC();
}

-(BOOL)isDebug{
    return _debug;
}

-(void)enableDebug{
    _debug = true;
}
-(void)disableDebug{
    _debug = false;
}

@end
