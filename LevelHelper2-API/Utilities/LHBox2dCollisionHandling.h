//
//  LHBox2dCollisionHandling.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 06/07/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LHConfig.h"
#if LH_USE_BOX2D

@class LHScene;

@interface LHBox2dCollisionHandling : NSObject

- (instancetype)initWithScene:(LHScene*)scene;

@end

#endif
