//
//  BlueRobotSprite.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 25/08/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LevelHelper2API.h"

@interface BlueRobotSprite : LHSprite

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt;

@end
