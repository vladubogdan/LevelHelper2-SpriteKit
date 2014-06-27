//
//  LHCamera.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHCamera.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"
#import "LHGameWorldNode.h"

@implementation LHCamera
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    
    BOOL _active;
    BOOL _restricted;
    
    NSString* _followedNodeUUID;
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);

    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    

    LH_SUPER_DEALLOC();
}


+ (instancetype)cameraWithDictionary:(NSDictionary*)dict
                               scene:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initCameraWithDictionary:dict
                                                            scene:prnt]);
}

- (instancetype)initCameraWithDictionary:(NSDictionary*)dict
                                   scene:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        
        
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _active = [dict boolForKey:@"activeCamera"];
        _restricted = [dict boolForKey:@"restrictToGameWorld"];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    
    return self;
}

-(BOOL)isActive{
    return _active;
}
-(void)resetActiveState{
    _active = NO;
}
-(void)setActive:(BOOL)value{
    
    NSMutableArray* cameras = [(LHScene*)[self scene] childrenOfType:[LHCamera class]];
    
    for(LHCamera* cam in cameras){
        [cam resetActiveState];
    }
    _active = value;
    [self setSceneView];
}

-(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode{
    if(_followedNodeUUID && _followedNode == nil){
        _followedNode = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(LHScene*)[self scene] childNodeWithUUID:_followedNodeUUID];
        if(_followedNode){
            LH_SAFE_RELEASE(_followedNodeUUID);
        }
    }
    return _followedNode;
}
-(void)followNode:(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node{
    _followedNode = node;
}

-(BOOL)restrictedToGameWorld{
    return _restricted;
}
-(void)setRestrictedToGameWorld:(BOOL)val{
    _restricted = val;
}

-(void)setPosition:(CGPoint)position{
    [super setPosition:[self transformToRestrictivePosition:position]];
}

-(void)setSceneView{
    if(_active)
    {
        CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
        [[[self scene] gameWorldNode] setPosition:transPoint];
    }
}

-(CGPoint)transformToRestrictivePosition:(CGPoint)position
{
    SKNode* followed = [self followedNode];
    if(followed){
        position = [followed position];
    }

    CGSize winSize = [(LHScene*)[self scene] size];
    CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];
    
    CGPoint offset = [[(LHScene*)self scene] designOffset];
    
    float x = position.x;
    float y = position.y;
    
    if(!CGRectEqualToRect(CGRectZero, worldRect) && [self restrictedToGameWorld]){
        
        if(x > (worldRect.origin.x + worldRect.size.width)*0.5){
            x = MIN(x, worldRect.origin.x + worldRect.size.width - winSize.width *0.5);
        }
        else{
            x = MAX(x, worldRect.origin.x + winSize.width *0.5);
        }
        
        y = MAX(y, worldRect.origin.y + worldRect.size.height + winSize.height*0.5);
        y = MIN(y, worldRect.origin.y - winSize.height*0.5);
    }
    CGPoint pt = CGPointMake(winSize.width*0.5  - x + offset.x,
                             winSize.height*0.5 - y+ offset.y);
    
    return pt;
}

#pragma mark LHNodeProtocol Required

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{

    [_animationProtocolImp update:currentTime delta:dt];
    
    if([self followedNode]){
        CGPoint pt = [self transformToRestrictivePosition:[[self followedNode] position]];
        [self setPosition:pt];
    }
    [self setSceneView];
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
