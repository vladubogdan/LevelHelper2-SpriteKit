//
//  LHConfig.h
//  LevelHelper2API
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHConfig : NSObject

+(id)sharedInstance;

-(void)enableDebug;
-(void)disableDebug;

-(BOOL)isDebug;
@end
