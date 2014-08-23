//
//  LHBox2dCollisionHandling.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 06/07/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHBox2dCollisionHandling.h"
#import "LHScene.h"
#import "LHGameWorldNode.h"
#import "LHConfig.h"
#import "LHUtils.h"
#if LH_USE_BOX2D

#include "Box2d/Box2D.h"

class LHContactListenerPimpl : public b2ContactListener
{
public:
    void* nodeObject;
    void (*preSolveSelector)(void*,
                             b2Contact* contact,
                             const b2Manifold* oldManifold);
    
    void (*postSolveSelector)(void*,
                              b2Contact* contact,
                              const b2ContactImpulse* impulse);
    
    void (*beginSolveSelector)(void*,
                               b2Contact* contact);

    void (*endSolveSelector)(void*,
                             b2Contact* contact);

    
    LHContactListenerPimpl(){};
    ~LHContactListenerPimpl(){};
	
    /// Called when two fixtures begin to touch.
	virtual void BeginContact(b2Contact* contact);
	/// Called when two fixtures cease to touch.
	virtual void EndContact(b2Contact* contact);

	/// This is called after a contact is updated. This allows you to inspect a
	/// contact before it goes to the solver. If you are careful, you can modify the
	/// contact manifold (e.g. disable contact).
	/// A copy of the old manifold is provided so that you can detect changes.
	/// Note: this is called only for awake bodies.
	/// Note: this is called even when the number of contact points is zero.
	/// Note: this is not called for sensors.
	/// Note: if you set the number of contact points to zero, you will not
	/// get an EndContact callback. However, you may get a BeginContact callback
	/// the next step.
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    
	/// This lets you inspect a contact after the solver is finished. This is useful
	/// for inspecting impulses.
	/// Note: the contact manifold does not include time of impact impulses, which can be
	/// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
	/// in a separate data structure.
	/// Note: this is only called for contacts that are touching, solid, and awake.
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
    
};
void LHContactListenerPimpl::BeginContact(b2Contact* contact){
    if(contact->GetFixtureA() != NULL && contact->GetFixtureB() != NULL)
        (*beginSolveSelector)(nodeObject,contact);
}
void LHContactListenerPimpl::EndContact(b2Contact* contact){
    if(contact->GetFixtureA() != NULL && contact->GetFixtureB() != NULL)
        (*endSolveSelector)(nodeObject,contact);
}
void LHContactListenerPimpl::PreSolve(b2Contact* contact,
                                      const b2Manifold* oldManifold){
    if(contact->GetFixtureA() != NULL && contact->GetFixtureB() != NULL)
        (*preSolveSelector)( nodeObject, contact, oldManifold);
}
void LHContactListenerPimpl::PostSolve(b2Contact* contact,
                                       const b2ContactImpulse* impulse){
    if(contact->GetFixtureA() != NULL && contact->GetFixtureB() != NULL)
        (*postSolveSelector)(nodeObject, contact, impulse);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void lhContactPreSolveCaller(void* object,
                             b2Contact* contact,
                             const b2Manifold* oldManifold);
void lhContactPostSolveCaller(void* object,
                              b2Contact* contact,
                              const b2ContactImpulse* impulse);
void lhContactBeginContactCaller(void* object,
                                 b2Contact* contact);
void lhContactEndContactCaller(void* object,
                               b2Contact* contact);
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface LHGameWorldNode (LH_COLLISION_HANDLING)
-(void)scheduleDidBeginContactBetweenNodeA:(SKNode*)nodeA
                                  andNodeB:(SKNode*)nodeB
                                atLocation:(CGPoint)contactPoint
                               withImpulse:(float)impulse;

-(void)scheduleDidEndContactBetweenNodeA:(SKNode*)nodeA
                                andNodeB:(SKNode*)nodeB;
@end


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation LHBox2dCollisionHandling
{
    __unsafe_unretained LHScene* _scene;
    LHContactListenerPimpl* _b2Listener;
}

-(void)dealloc{
    [_scene box2dWorld]->SetContactListener(NULL);
    _scene = nil;
    LH_SAFE_DELETE(_b2Listener);
    LH_SUPER_DEALLOC();
}

- (instancetype)initWithScene:(LHScene*)scene
{
    if(self = [super init])
    {
        _scene = scene;
        
        _b2Listener = new LHContactListenerPimpl();
        _b2Listener->nodeObject = LH_VOID_BRIDGE_CAST(self);
        
        [_scene box2dWorld]->SetContactListener(_b2Listener);
        
        _b2Listener->preSolveSelector   = &lhContactPreSolveCaller;
        _b2Listener->postSolveSelector  = &lhContactPostSolveCaller;
        _b2Listener->beginSolveSelector = &lhContactBeginContactCaller;
        _b2Listener->endSolveSelector   = &lhContactEndContactCaller;
        
    }
    return self;
}

-(b2Fixture*)getFixtureAFromContact:(b2Contact*)contact{
    return contact->GetFixtureA();
}

-(b2Fixture*)getFixtureBFromContact:(b2Contact*)contact{
    return contact->GetFixtureB();
}

-(b2Body*)getBodyAFromContact:(b2Contact*)contact{
    b2Fixture* fixtureA = contact->GetFixtureA();
    if(!fixtureA)return NULL;
    return fixtureA->GetBody();
}

-(b2Body*)getBodyBFromContact:(b2Contact*)contact{
    b2Fixture* fixtureB = contact->GetFixtureB();
    if(!fixtureB)return NULL;
    return fixtureB->GetBody();
}

-(SKNode*)getNodeAFromContact:(b2Contact*)contact{
    b2Body* bodyA = [self getBodyAFromContact:contact];
    if(!bodyA || !bodyA->GetUserData())return nil;
    return LH_ID_BRIDGE_CAST(bodyA->GetUserData());
}

-(SKNode*)getNodeBFromContact:(b2Contact*)contact{
    b2Body* bodyB = [self getBodyBFromContact:contact];
    if(!bodyB || !bodyB->GetUserData())return nil;
    return LH_ID_BRIDGE_CAST(bodyB->GetUserData());
}
-(CGPoint)getPointFromContact:(b2Contact*)contact{
    b2WorldManifold worldManifold;
    contact->GetWorldManifold(&worldManifold);
    b2Vec2 worldPt = worldManifold.points[0];
    return [_scene pointFromMeters:worldPt];
}

-(void)preSolve:(b2Contact*)contact manifold:(const b2Manifold*)oldManifold
{
    SKNode* nodeA = [self getNodeAFromContact:contact];
    SKNode* nodeB = [self getNodeBFromContact:contact];
    if(!nodeA || !nodeB)return;
    
    //at this point ask the scene if we should disable this contact
    BOOL shouldDisable = [_scene shouldDisableContactBetweenNodeA:nodeA andNodeB:nodeB];

    if(shouldDisable){
        contact->SetEnabled(NO);
    }
    //cancel collision here - if needed
}
-(void)postSolve:(b2Contact*)contact impulse:(const b2ContactImpulse*)contactImpulse
{
    SKNode* nodeA = [self getNodeAFromContact:contact];
    SKNode* nodeB = [self getNodeBFromContact:contact];
    if(!nodeA || !nodeB)return;

    float impulse = 0;
    if(contactImpulse->count > 0)
    {
        impulse = contactImpulse->normalImpulses[0];
    }
    
    [[_scene gameWorldNode] scheduleDidBeginContactBetweenNodeA:nodeA
                                                       andNodeB:nodeB
                                                     atLocation:[self getPointFromContact:contact]
                                                    withImpulse:impulse];
}
-(void)beginContact:(b2Contact*)contact
{
    SKNode* nodeA = [self getNodeAFromContact:contact];
    SKNode* nodeB = [self getNodeBFromContact:contact];
    if(!nodeA || !nodeB)return;
    
    //call this for sensor objects
    [[_scene gameWorldNode] scheduleDidBeginContactBetweenNodeA:nodeA
                                                       andNodeB:nodeB
                                                     atLocation:[self getPointFromContact:contact]
                                                    withImpulse:0];
}
-(void)endContact:(b2Contact*)contact
{
    SKNode* nodeA = [self getNodeAFromContact:contact];
    SKNode* nodeB = [self getNodeBFromContact:contact];
    if(!nodeA || !nodeB)return;
    
    [[_scene gameWorldNode] scheduleDidEndContactBetweenNodeA:nodeA
                                                     andNodeB:nodeB];
}
@end

void lhContactPreSolveCaller(void* object,
                             b2Contact* contact,
                             const b2Manifold* oldManifold)
{
    LHBox2dCollisionHandling* collision = LH_ID_BRIDGE_CAST(object);
    [collision preSolve:contact manifold:oldManifold];
}

void lhContactPostSolveCaller(void* object,
                              b2Contact* contact,
                              const b2ContactImpulse* impulse)
{
    LHBox2dCollisionHandling* collision = LH_ID_BRIDGE_CAST(object);
    [collision postSolve:contact impulse:impulse];
}
void lhContactBeginContactCaller(void* object,
                               b2Contact* contact)
{
    LHBox2dCollisionHandling* collision = LH_ID_BRIDGE_CAST(object);
    [collision beginContact:contact];
}
void lhContactEndContactCaller(void* object,
                             b2Contact* contact)
{
    LHBox2dCollisionHandling* collision = LH_ID_BRIDGE_CAST(object);
    [collision endContact:contact];
}

#endif