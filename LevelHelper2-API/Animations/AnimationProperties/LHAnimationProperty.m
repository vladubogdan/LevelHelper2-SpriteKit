//
//  LHAnimationProperty.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAnimationProperty.h"

#import "LHNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "LHAnimation.h"
#import "LHFrame.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodeProtocol.h"

@implementation LHAnimationProperty
{
    NSMutableArray* _frames;
    __weak LHAnimation* _animation;
    
    __weak LHAnimationProperty* parentProperty;//nil in most cases, only set when this is a subproperty
    __weak id<LHNodeAnimationProtocol, LHNodeProtocol> subpropertyNode; //the node that is controlled by this subproperty
    NSMutableDictionary* subproperties;
}

-(void)dealloc
{
    parentProperty = nil;
    subpropertyNode = nil;
    _animation = nil;
    LH_SAFE_RELEASE(_frames);
    LH_SAFE_RELEASE(subproperties);
    LH_SUPER_DEALLOC();
}

+(instancetype)animationPropertyWithDictionary:(NSDictionary*)dict
                                     animation:(LHAnimation*)a
{
    Class animPropertyClass = NSClassFromString([dict objectForKey:@"type"]);
    
    NSAssert(animPropertyClass, @"ERROR: Could not create animation property class of type %@.", [dict objectForKey:@"type"]);

    return LH_AUTORELEASED([[animPropertyClass alloc] initAnimationPropertyWithDictionary:dict
                                                                                animation:a]);
}

-(instancetype)initAnimationPropertyWithDictionary:(NSDictionary*)dict
                                         animation:(LHAnimation*)a{
    
    if(self = [super init])
    {
        _animation = a;
        _frames = [[NSMutableArray alloc] init];
        [self loadDictionary:dict];
    }
    return self;
}

-(void)loadDictionary:(NSDictionary*)dict
{
    if(!dict)return;
    
    NSDictionary* subsInfo = [dict objectForKey:@"subproperties"];
    if(subsInfo)
    {
        NSArray* allKeys = [subsInfo allKeys];
        id<LHNodeAnimationProtocol, LHNodeProtocol> parentNode = [_animation node];
        
        for(NSString* subUUID in allKeys){
            
            NSDictionary* subInfo = [subsInfo objectForKey:subUUID];
            id<LHNodeAnimationProtocol, LHNodeProtocol> child = (id<LHNodeAnimationProtocol, LHNodeProtocol>)[parentNode childNodeWithUUID:subUUID];
            
            if(child && subInfo){
                
                if(!subproperties){
                    subproperties = [[NSMutableDictionary alloc] init];
                }
                
                LHAnimationProperty* subProp = [self newSubpropertyForNode:child];
                if(subProp){
                    [subProp setParentProperty:self];
                    [subProp setSubpropertyNode:child];
                    [subProp loadDictionary:subInfo];
                    [subproperties setObject:subProp forKey:[child uuid]];
                }
            }
        }
    }
}

-(void)addKeyFrame:(LHFrame*)frm{
    if(!frm)return;
    
    if(![_frames containsObject:frm]){
        [_frames addObject:frm];
    }
}

-(NSArray*)keyFrames{
    return _frames;
}

-(LHAnimation*)animation{
    return _animation;
}

#pragma mark - SUBPROPERTIES SUPPORT
-(BOOL)isSubproperty{
    return parentProperty != nil;
}
-(id<LHNodeAnimationProtocol, LHNodeProtocol>)subpropertyNode{
    return subpropertyNode;
}
-(void)setSubpropertyNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)val{
    subpropertyNode = val;
}
-(LHAnimationProperty*)parentProperty{
    return parentProperty;
}
-(void)setParentProperty:(LHAnimationProperty*)val{
    parentProperty = val;
}
-(BOOL)canHaveSubproperties{
    return NO;
}
-(void)addSubproperty:(LHAnimationProperty*)prop{
    if(!prop)return;
    
    NSString* subUuid = [[prop subpropertyNode] uuid];
    if(subUuid){
        if(!subproperties){
            subproperties = [[NSMutableDictionary alloc] init];
        }
        
        [prop setParentProperty:self];
        [subproperties setObject:prop forKey:subUuid];
    }
}
-(void)removeSubproperty:(LHAnimationProperty*)prop{
    if(!prop)return;
    
    NSArray* keys = [subproperties allKeys];
    for(NSString* key in keys){
        if([subproperties objectForKey:key] == prop){
            [subproperties removeObjectForKey:key];
            return;
        }
    }
}

-(LHAnimationProperty*)newSubpropertyForNode:(id<LHNodeAnimationProtocol, LHNodeProtocol>)node{
    NSLog(@"SUBCLASSERS NEED TO IMPLEMENT newSubpropertyForNode:");
    return nil;
}

-(NSArray*)allSubproperties{
    return [subproperties allValues];
}

-(LHAnimationProperty*)subpropertyForUUID:(NSString*)nodeUuid{
    return [subproperties objectForKey:nodeUuid];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"%@ subs %@", NSStringFromClass([self class]), subproperties];
}
@end
