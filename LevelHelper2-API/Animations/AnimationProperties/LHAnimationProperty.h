//
//  LHAnimationProperty.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LHAnimation;
@class LHFrame;
@protocol LHNodeAnimationProtocol;
@protocol LHNodeProtocol;

@interface LHAnimationProperty : NSObject

+(instancetype)animationPropertyWithDictionary:(NSDictionary*)dict
                                     animation:(LHAnimation*)a;

-(instancetype)initAnimationPropertyWithDictionary:(NSDictionary*)dict
                                         animation:(LHAnimation*)a;

-(void)loadDictionary:(NSDictionary*)dict;

-(void)addKeyFrame:(LHFrame*)frm;

-(NSArray*)keyFrames;

-(LHAnimation*)animation;

-(BOOL)isSubproperty;
-(id<LHNodeAnimationProtocol, LHNodeProtocol>)subpropertyNode;
-(void)setSubpropertyNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)val;
-(LHAnimationProperty*)subpropertyForUUID:(NSString*)nodeUuid;
-(NSArray*)allSubproperties;
@end
