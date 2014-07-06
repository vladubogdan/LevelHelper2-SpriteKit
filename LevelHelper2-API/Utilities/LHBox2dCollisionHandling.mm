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

#include "Box2D.h"

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
	
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
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

@implementation LHBox2dCollisionHandling
{
    __unsafe_unretained LHScene* _scene;
    LHContactListenerPimpl* _b2Listener;
}

-(void)dealloc{
    [_scene box2dWorld]->SetContactListener(nil);
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

-(void)preSolve:(b2Contact*)contact manifold:(const b2Manifold*)oldManifold
{
    
}
-(void)postSolve:(b2Contact*)contact impulse:(const b2ContactImpulse*)impulse
{
    
}
-(void)beginContact:(b2Contact*)contact
{
    NSLog(@"BEGIN CONTACT");
}
-(void)endContact:(b2Contact*)contact
{
    NSLog(@"END CONTACT");
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