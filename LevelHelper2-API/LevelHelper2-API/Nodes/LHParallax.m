//
//  LHParallax.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHParallax.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHParallaxLayer.h"
#import "LHAnimation.h"
#import "SKNode+Transforms.h"
#import "LHCamera.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@interface LHCamera (LH_PARALLAX_FOLLOW_CAMERA_CHECK)
-(BOOL)wasUpdated;
@end

@implementation LHParallax
{
    CGPoint lastPosition;
    
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    NSString* _followedNodeUUID;
    SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
    

}

-(void)dealloc{

    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);

    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                     parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    
    
    if(self = [super init]){
                
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
                
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    
    return self;
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

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

-(void)transformLayerPositions
{
    CGPoint parallaxPos = [self position];
    SKNode* followed = [self followedNode];
    if(followed){
        if([followed isKindOfClass:[LHCamera class]]){
            if(![(LHCamera*)followed wasUpdated])return;
        }
        
        parallaxPos = [followed position];
        
        CGSize winSize = [(LHScene*)[self scene] designResolutionSize];
        
        parallaxPos.x = parallaxPos.x - winSize.width*0.5;
        parallaxPos.y = parallaxPos.y - winSize.height*0.5;
    }
    
    
    if(CGPointEqualToPoint(lastPosition, CGPointZero)){
        lastPosition = parallaxPos;
    }
    
    
    if(!CGPointEqualToPoint(lastPosition, parallaxPos))
    {
        CGPoint deltaPos = CGPointMake(parallaxPos.x - lastPosition.x,
                                       parallaxPos.y - lastPosition.y);
        
        for(LHParallaxLayer* nd in [self children])
        {
            if([nd isKindOfClass:[LHParallaxLayer class]])
            {
                
                CGPoint curPos = [nd position];
                
                CGPoint pt = CGPointMake(curPos.x - deltaPos.x*(nd.xRatio),
                                         curPos.y - deltaPos.y*(nd.yRatio));
                
                
                [nd setPosition:pt];
            }
        }
    }
    lastPosition = parallaxPos;
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{

    [_animationProtocolImp update:currentTime delta:dt];
 
    [self transformLayerPositions];
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
