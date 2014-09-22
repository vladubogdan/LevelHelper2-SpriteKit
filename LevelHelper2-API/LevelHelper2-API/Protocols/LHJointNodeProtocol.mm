//
//  LHJointNodeProtocol.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 16/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHJointNodeProtocol.h"
#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHGameWorldNode.h"
#import "LHConfig.h"
#import "SKNode+Transforms.h"
#import "LHNode.h"

#if LH_USE_BOX2D
#include "Box2d/Box2D.h"
#else

#endif //LH_USE_BOX2D


@implementation LHJointNodeProtocolImp
{
    __unsafe_unretained SKNode<LHJointNodeProtocol>* _node;
    
    
#if LH_USE_BOX2D
    b2Joint* _joint;
#else
    __unsafe_unretained SKPhysicsJoint* _joint;
#endif
    
    CGPoint _relativePosA;
    CGPoint _relativePosB;
    
    NSString* _nodeAUUID;
    NSString* _nodeBUUID;
    
    __unsafe_unretained SKNode<LHNodePhysicsProtocol>* _nodeA;
    __unsafe_unretained SKNode<LHNodePhysicsProtocol>* _nodeB;

    BOOL _collideConnected;
}

-(void)dealloc{

#if LH_USE_BOX2D
    if(_joint && _node && [_node respondsToSelector:@selector(isB2WorldDirty)] && ![(LHNode*)_node isB2WorldDirty])
//    if(_joint &&
//       _joint->GetBodyA() &&
//       _joint->GetBodyA()->GetWorld() &&
//       _joint->GetBodyA()->GetWorld()->GetContactManager().m_contactListener != NULL)
    {
        //do not remove the joint if the scene is deallocing as the box2d world will be deleted
        //so we dont need to do this manualy
        //in some cases the nodes will be retained and removed after the box2d world is already deleted and we may have a crash
        [self removeJoint];
    }
#else
    [self removeJoint];
#endif
    
    
    _node = nil;
    
    _nodeA = nil;
    _nodeB = nil;
    
    LH_SAFE_RELEASE(_nodeAUUID);
    LH_SAFE_RELEASE(_nodeBUUID);
    
    LH_SUPER_DEALLOC();
    
}

+ (instancetype)jointProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode<LHJointNodeProtocol>*)nd{
    return LH_AUTORELEASED([[self alloc] initJointProtocolImpWithDictionary:dict node:nd]);
}
- (instancetype)initJointProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode<LHJointNodeProtocol>*)nd{
    
    if(self = [super init])
    {
        _joint = NULL;
        _node = nd;
        
        if([dict objectForKey:@"relativePosA"])//certain joints do not have an anchor (e.g. gear joint)
            _relativePosA = [dict pointForKey:@"relativePosA"];

        if([dict objectForKey:@"relativePosB"])//certain joints do not have a second anchor
            _relativePosB = [dict pointForKey:@"relativePosB"];
        
        if([dict objectForKey:@"spriteAUUID"]){//maybe its a dummy joint
            _nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        }
        else{
            NSLog(@"WARNING: Joint %@ is not connected to a node", [dict objectForKey:@"name"]);
        }
        
        if([dict objectForKey:@"spriteBUUID"]){//maybe its a dummy joint
            _nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        }
        else{
            NSLog(@"WARNING: Joint %@ is not connected to a node", [dict objectForKey:@"name"]);
        }

        _collideConnected = [dict boolForKey:@"collideConnected"];
    }
    return self;
}


#pragma mark - Common Physics Engines
-(void)findConnectedNodes
{
    if(!_nodeAUUID || !_nodeBUUID)
        return;
    
    LHScene* scene = (LHScene*)[_node scene];
    
    if([[_node parent] respondsToSelector:@selector(childNodeWithUUID:)])
    {
        _nodeA = (SKNode<LHNodePhysicsProtocol>*)[(id<LHNodeProtocol>)[_node parent] childNodeWithUUID:_nodeAUUID];
        _nodeB = (SKNode<LHNodePhysicsProtocol>*)[(id<LHNodeProtocol>)[_node parent] childNodeWithUUID:_nodeBUUID];
    }

    if(!_nodeA){
        _nodeA = (SKNode<LHNodePhysicsProtocol>*)[scene childNodeWithUUID:_nodeAUUID];
    }
    if(!_nodeB){
        _nodeB = (SKNode<LHNodePhysicsProtocol>*)[scene childNodeWithUUID:_nodeBUUID];
    }
}

-(SKNode<LHNodePhysicsProtocol>*)nodeA{
    return _nodeA;
}
-(SKNode<LHNodePhysicsProtocol>*)nodeB{
    return _nodeB;
}

-(CGPoint)localAnchorA{
    return CGPointMake( _relativePosA.x* [_nodeA xScale],
                       -_relativePosA.y* [_nodeA yScale]);
}
-(CGPoint)localAnchorB{
    return CGPointMake( _relativePosB.x* [_nodeB xScale],
                       -_relativePosB.y* [_nodeB yScale]);
}

-(CGPoint)anchorA{
    CGPoint pt =  [_nodeA convertToWorldSpaceAR:_relativePosA];
    return [_node convertToNodeSpace:pt];
}

-(CGPoint)anchorB{
    CGPoint pt = [_nodeB convertToWorldSpaceAR:_relativePosB];
    return [_node convertToNodeSpace:pt];
}

-(BOOL)collideConnected{
    return _collideConnected;
}

-(void)removeJoint{
    
    //if we dont have the scene it means the scene was changed so the box2d world will be deleted, deleting the joints also - safe
    //if we do have the scene it means the node was deleted so we need to delete the joint manually
#if LH_USE_BOX2D
    if(_joint){
        LHScene* scene = (LHScene*)[_node scene];
        
        if(scene)
        {
            LHGameWorldNode* pNode = [scene gameWorldNode];
            
            //if we dont have the scene it means
            b2World* world = [pNode box2dWorld];
            
            if(world){
                _joint->SetUserData(NULL);
                world->DestroyJoint(_joint);
                _joint = NULL;
            }
        }
    }
#else
    if(_joint){
        if(_node)
        {
            LHScene* scene = (LHScene*)[_node scene];
            if(scene){
                [[_node scene].physicsWorld removeJoint:_joint];
            }
        }
    }
    _joint = nil;
#endif
}

#pragma mark - Box2d Support
#if LH_USE_BOX2D
-(void)setJoint:(b2Joint*)val{
    _joint = val;
    _joint->SetUserData(LH_VOID_BRIDGE_CAST(_node));
}
-(b2Joint*)joint{
    return _joint;
}

#pragma mark - Sprite Kit
#else//spritekit

-(void)setJoint:(SKPhysicsJoint*)val{
    _joint = val;
}
-(SKPhysicsJoint*)joint{
    return _joint;
}

#endif//LH_USE_BOX2D

@end