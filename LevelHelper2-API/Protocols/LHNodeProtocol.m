//
//  LHNodeProtocol.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHNodeProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHUserPropertyProtocol.h"

#import "LHSprite.h"
#import "LHGameWorldNode.h"
#import "LHBackUINode.h"
#import "LHUINode.h"
#import "LHBezier.h"
#import "LHShape.h"
#import "LHNode.h"
#import "LHWater.h"
#import "LHGravityArea.h"
#import "LHParallax.h"
#import "LHParallaxLayer.h"
#import "LHAsset.h"
#import "LHWeldJointNode.h"
#import "LHRopeJointNode.h"
#import "LHCamera.h"
#import "LHRevoluteJointNode.h"
#import "LHDistanceJointNode.h"
#import "LHPrismaticJointNode.h"


@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(void)addLateLoadingNode:(SKNode*)node;
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end


@implementation LHNodeProtocolImpl
{
    __unsafe_unretained SKNode* _node;
    
    NSString*           _uuid;
    NSMutableArray*     _tags;
    id<LHUserPropertyProtocol> _userProperty;
}

-(void)dealloc{
    
    _node = nil;
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    LH_SUPER_DEALLOC();
}

+ (instancetype)nodeProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd{
    return LH_AUTORELEASED([[self alloc] initNodeProtocolImpWithDictionary:dict node:nd]);
}

- (instancetype)initNodeProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
        
        [_node setName:[dict objectForKey:@"name"]];
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        
        //tags loading
        {
            NSArray* loadedTags = [dict objectForKey:@"tags"];
            if(loadedTags){
                _tags = [[NSMutableArray alloc] initWithArray:loadedTags];
            }
        }

        //user properties loading
        {
            NSDictionary* userPropInfo  = [dict objectForKey:@"userPropertyInfo"];
            NSString* userPropClassName = [dict objectForKey:@"userPropertyName"];
            if(userPropInfo && userPropClassName)
            {
                Class userPropClass = NSClassFromString(userPropClassName);
                if(userPropClass){
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
                    _userProperty = [userPropClass performSelector:@selector(customClassInstanceWithNode:)
                                                        withObject:_node];
    #pragma clang diagnostic pop
                    if(_userProperty){
                        [_userProperty setPropertiesFromDictionary:userPropInfo];
                    }
                }
            }
        }
        
        
        
        if([dict objectForKey:@"generalPosition"])
        {
            CGPoint unitPos = [dict pointForKey:@"generalPosition"];
            CGPoint pos = [LHUtils positionForNode:_node
                                          fromUnit:unitPos];
            
            NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
            if(devPositions)
            {
                
    #if TARGET_OS_IPHONE
                NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                       forSize:LH_SCREEN_RESOLUTION];
    #else
                NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                       forSize:[_node scene].size];
    #endif
                
                if(unitPosStr){
                    CGPoint unitPos = LHPointFromString(unitPosStr);
                    pos = [LHUtils positionForNode:_node
                                          fromUnit:unitPos];
                }
            }
            
            if([dict objectForKey:@"anchor"] && [_node respondsToSelector:@selector(anchorPoint)]){
                CGPoint anchor = [dict pointForKey:@"anchor"];
                anchor.y = 1.0f - anchor.y;
                [(LHSprite*)_node setAnchorPoint:anchor];
            }

            SKNode* prnt = [_node parent];
            if([prnt isKindOfClass:[SKSpriteNode class]]){
                SKSpriteNode* p = (SKSpriteNode*)prnt;
                CGPoint anc = [p anchorPoint];
                pos.x -= p.size.width*(anc.x - 0.5f);
                pos.y -= p.size.height*(anc.y- 0.5f);
            }
            
            [_node setPosition:pos];
        }
        
        
        if([dict objectForKey:@"size"] && [_node respondsToSelector:@selector(setSize:)]){
            ((SKSpriteNode*)_node).size = [dict sizeForKey:@"size"];
        }
        
        if([dict objectForKey:@"alpha"])
            [_node setAlpha:[dict floatForKey:@"alpha"]/255.0f];
        
        if([dict objectForKey:@"rotation"])
            [_node setZRotation:LH_DEGREES_TO_RADIANS(-[dict floatForKey:@"rotation"])];
        
        if([dict objectForKey:@"zOrder"])
            [_node setZPosition:[dict floatForKey:@"zOrder"]];
        
    }
    return self;
}

- (instancetype)initNodeProtocolImpWithNode:(SKNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
    }
    return self;
}

+(void)loadChildrenForNode:(SKNode*)prntNode fromDictionary:(NSDictionary*)dict
{
    NSArray* childrenInfo = [dict objectForKey:@"children"];
    if(childrenInfo)
    {
        for(NSDictionary* childInfo in childrenInfo)
        {
            SKNode* node = [LHNodeProtocolImpl createLHNodeWithDictionary:childInfo
                                                                   parent:prntNode];
#pragma unused (node)
        }
    }
}

+(id)createLHNodeWithDictionary:(NSDictionary*)childInfo
                         parent:(SKNode*)prnt
{
    
    NSString* nodeType = [childInfo objectForKey:@"nodeType"];
    
    LHScene* scene = nil;
    if([prnt isKindOfClass:[LHScene class]]){
        scene = (LHScene*)prnt;
    }
    else if([[prnt scene] isKindOfClass:[LHScene class]]){
        scene = (LHScene*)[prnt scene];
    }
    
    if([nodeType isEqualToString:@"LHGameWorldNode"])
    {
        LHGameWorldNode* pNode = [LHGameWorldNode gameWorldNodeWithDictionary:childInfo
                                                                       parent:prnt];
        
        //[pNode setDebugDraw:YES];
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHUINode"])
    {
        LHUINode* pNode = [LHUINode uiNodeWithDictionary:childInfo
                                                  parent:prnt];
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHBackUINode"])
    {
        LHBackUINode* pNode = [LHBackUINode backUINodeWithDictionary:childInfo
                                                              parent:prnt];
        return pNode;
    }
    if([nodeType isEqualToString:@"LHSprite"])
    {
        LHSprite* spr = [LHSprite spriteNodeWithDictionary:childInfo
                                                    parent:prnt];
        return spr;
    }
    else if([nodeType isEqualToString:@"LHNode"])
    {
        LHNode* nd = [LHNode nodeWithDictionary:childInfo
                                         parent:prnt];
        return nd;
    }
    else if([nodeType isEqualToString:@"LHBezier"])
    {
        LHBezier* bez = [LHBezier bezierNodeWithDictionary:childInfo
                                                    parent:prnt];
        return bez;
    }
    else if([nodeType isEqualToString:@"LHTexturedShape"])
    {
        LHShape* sp = [LHShape shapeNodeWithDictionary:childInfo
                                                parent:prnt];
        return sp;
    }
    else if([nodeType isEqualToString:@"LHWaves"])
    {
        LHWater* wt = [LHWater waterNodeWithDictionary:childInfo
                                                parent:prnt];
        return wt;
    }
    else if([nodeType isEqualToString:@"LHAreaGravity"])
    {
        LHGravityArea* gv = [LHGravityArea gravityAreaWithDictionary:childInfo
                                                              parent:prnt];
        return gv;
    }
    else if([nodeType isEqualToString:@"LHParallax"])
    {
        LHParallax* pr = [LHParallax parallaxWithDictionary:childInfo
                                                     parent:prnt];
        return pr;
    }
    else if([nodeType isEqualToString:@"LHParallaxLayer"])
    {
        LHParallaxLayer* lh = [LHParallaxLayer parallaxLayerWithDictionary:childInfo
                                                                    parent:prnt];
        return lh;
    }
    else if([nodeType isEqualToString:@"LHAsset"])
    {
        LHAsset* as = [LHAsset assetWithDictionary:childInfo
                                            parent:prnt];
        return as;
    }
    else if([nodeType isEqualToString:@"LHCamera"])
    {
        LHCamera* cm = [LHCamera cameraWithDictionary:childInfo
                                                scene:prnt];
        return cm;
    }
    else if([nodeType isEqualToString:@"LHRopeJoint"])
    {
        if(scene)
        {
            LHRopeJointNode* jt = [LHRopeJointNode ropeJointNodeWithDictionary:childInfo
                                                                        parent:prnt];
            [scene addLateLoadingNode:jt];
        }
    }
    else if([nodeType isEqualToString:@"LHWeldJoint"])
    {
        LHWeldJointNode* jt = [LHWeldJointNode weldJointNodeWithDictionary:childInfo
                                                                    parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHRevoluteJoint"]){
        
        LHRevoluteJointNode* jt = [LHRevoluteJointNode revoluteJointNodeWithDictionary:childInfo
                                                                                parent:prnt];
        
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHDistanceJoint"]){
        
        LHDistanceJointNode* jt = [LHDistanceJointNode distanceJointNodeWithDictionary:childInfo
                                                                                parent:prnt];
        [scene addLateLoadingNode:jt];
        
    }
    else if([nodeType isEqualToString:@"LHPrismaticJoint"]){
        
        LHPrismaticJointNode* jt = [LHPrismaticJointNode prismaticJointNodeWithDictionary:childInfo
                                                                                   parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    
    
    else{
        //        NSLog(@"UNKNOWN NODE TYPE %@", nodeType);
    }
    
    return nil;
}

#pragma mark - PROPERTIES
-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(SKNode<LHNodeProtocol>*)childNodeWithName:(NSString*)name
{
    if([[_node name] isEqualToString:name]){
        return (SKNode<LHNodeProtocol>*)_node;
    }
    
    for(SKNode<LHNodeProtocol>* node in [_node children])
    {
        if([node respondsToSelector:@selector(childNodeWithName:)])
        {
            if([[node name] isEqualToString:name]){
                return node;
            }
            SKNode <LHNodeProtocol>* retNode = (SKNode <LHNodeProtocol>*)[node childNodeWithName:name];
            if(retNode){
                return retNode;
            }
        }
    }
    return nil;
}

-(SKNode<LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid;
{
    if([_node respondsToSelector:@selector(uuid)]){
        if([[(SKNode<LHNodeProtocol>*)_node uuid] isEqualToString:uuid]){
            return (SKNode<LHNodeProtocol>*)_node;
        }
    }
    
    for(SKNode<LHNodeProtocol>* node in [_node children])
    {
        if([node respondsToSelector:@selector(uuid)])
        {
            if([[node uuid] isEqualToString:uuid]){
                return node;
            }
            
            if([node respondsToSelector:@selector(childNodeWithUUID:)])
            {
                SKNode<LHNodeProtocol>* retNode = [node childNodeWithUUID:uuid];
                if(retNode){
                    return retNode;
                }
            }
        }
    }
    return nil;
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any
{
    NSMutableArray* temp = [NSMutableArray array];
    for(id<LHNodeProtocol> child in [_node children]){
        if([child conformsToProtocol:@protocol(LHNodeProtocol)])
        {
            NSArray* childTags =[child tags];
            
            int foundCount = 0;
            BOOL foundAtLeastOne = NO;
            for(NSString* tg in childTags)
            {
                for(NSString* st in tagValues){
                    if([st isEqualToString:tg])
                    {
                        ++foundCount;
                        foundAtLeastOne = YES;
                        if(any){
                            break;
                        }
                    }
                }
                
                if(any && foundAtLeastOne){
                    [temp addObject:child];
                    break;
                }
            }
            if(!any && foundAtLeastOne && foundCount == [tagValues count]){
                [temp addObject:child];
            }
            
            if([child respondsToSelector:@selector(childrenWithTags:containsAny:)])
            {
                NSMutableArray* childArray = [child childrenWithTags:tagValues containsAny:any];
                if(childArray){
                    [temp addObjectsFromArray:childArray];
                }
            }
        }
    }
    return temp;
}

-(NSMutableArray*)childrenOfType:(Class)type{
    
    NSMutableArray* temp = [NSMutableArray array];
    for(SKNode* child in [_node children]){

        if([child isKindOfClass:type]){
            [temp addObject:child];
        }
        
        if([child respondsToSelector:@selector(childrenOfType:)])
        {
            NSMutableArray* childArray = [child performSelector:@selector(childrenOfType:)
                                                     withObject:type];
            if(childArray){
                [temp addObjectsFromArray:childArray];
            }
        }
    }
    return temp;
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    for(SKNode<LHNodeProtocol>* n in [_node children]){
        if([n conformsToProtocol:@protocol(LHNodeProtocol)]){
            [n update:currentTime delta:dt];
        }
    }
}


@end
