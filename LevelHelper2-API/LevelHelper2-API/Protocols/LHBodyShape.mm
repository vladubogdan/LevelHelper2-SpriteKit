//
//  LHBodyShape.m
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 19/01/15.
//  Copyright (c) 2015 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHBodyShape.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"

#if LH_USE_BOX2D

#include "Box2d/Box2D.h"
#include <vector>

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(float)currentDeviceRatio;
@end




@implementation LHBodyShape
{
    NSString*   _shapeName;
    int         _shapeID;
}

static void LHSetupb2FixtureWithInfo(b2FixtureDef* fixture, NSDictionary* dict)
{
    fixture->density     = [[dict objectForKey:@"density"] floatValue];
    fixture->friction    = [[dict objectForKey:@"friction"] floatValue];
    fixture->restitution = [[dict objectForKey:@"restitution"] floatValue];
    fixture->isSensor    = [[dict objectForKey:@"sensor"] boolValue];
    
    fixture->filter.maskBits    = [[dict objectForKey:@"mask"] intValue];
    fixture->filter.categoryBits= [[dict objectForKey:@"category"] intValue];
}

static bool LHValidateCentroid(b2Vec2* vs, int count)
{
    if(count < 3 || count > b2_maxPolygonVertices)
        return false;
    
    int32 n = b2Min(count, b2_maxPolygonVertices);
    
    // Perform welding and copy vertices into local buffer.
    b2Vec2 ps[b2_maxPolygonVertices];
    int32 tempCount = 0;
    for (int32 i = 0; i < n; ++i)
    {
        b2Vec2 v = vs[i];
        
        bool unique = true;
        for (int32 j = 0; j < tempCount; ++j)
        {
            if (b2DistanceSquared(v, ps[j]) < 0.5f * b2_linearSlop)
            {
                unique = false;
                break;
            }
        }
        
        if (unique)
        {
            ps[tempCount++] = v;
        }
    }
    
    n = tempCount;
    if (n < 3)
    {
        return false;
    }
    
    return true;
}

+(id)createRectangleWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene size:(CGSize)size
{
    return LH_AUTORELEASED([[self alloc] initRectangleWithDictionary:dict body:body node:node scene:scene size:size]);
}

-(id)initRectangleWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene size:(CGSize)size
{
    if(self = [super init]){
    
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        b2PolygonShape* shape = new b2PolygonShape();
        shape->SetAsBox(size.width*0.5f, size.height*0.5f);
        
        b2FixtureDef fixture;
        LHSetupb2FixtureWithInfo(&fixture, dict);
        
        fixture.userData = LH_VOID_BRIDGE_CAST(self);
        fixture.shape = shape;
        body->CreateFixture(&fixture);
        
        delete shape;
        shape = NULL;
        
    }
    return self;
}

+(id)createCircleWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene size:(CGSize)size
{
    return LH_AUTORELEASED([[self alloc] initCircleWithDictionary:dict body:body node:node scene:scene size:size]);
}

-(id)initCircleWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene size:(CGSize)size
{
    if(self = [super init]){
        
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        b2CircleShape* shape = new b2CircleShape();
        shape->m_radius = size.width*0.5;
        
        b2FixtureDef fixture;
        LHSetupb2FixtureWithInfo(&fixture, dict);
        
        fixture.userData = LH_VOID_BRIDGE_CAST(self);
        fixture.shape = shape;
        body->CreateFixture(&fixture);
        
        delete shape;
        shape = NULL;
        
    }
    return self;
}


+(id)createWithDictionary:(NSDictionary*)dict shapePoints:(NSArray*)shapePoints body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict shapePoints:shapePoints body:body node:node scene:scene scale:scale]);
}

-(id)initWithDictionary:(NSDictionary*)dict shapePoints:(NSArray*)shapePoints body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    if(self = [super init]){
        
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        int flipx = scale.x < 0 ? -1 : 1;
        int flipy = scale.y < 0 ? -1 : 1;
        
        
        for(int f = 0; f < [shapePoints count]; ++f)
        {
            NSArray* fixPoints = [shapePoints objectAtIndex:f];

            int count = (int)[fixPoints count];
            if(count > 2)
            {
                b2Vec2 *verts = new b2Vec2[count];
                b2PolygonShape shapeDef;
                
                int i = 0;
                for(int j = count-1; j >=0; --j)
                {
                    const int idx = (flipx < 0 && flipy >= 0) || (flipx >= 0 && flipy < 0) ? count - i - 1 : i;
                    
                    NSString* pointStr = [fixPoints objectAtIndex:j];
                    CGPoint point = LHPointFromString(pointStr);
                    
                    point.x *= scale.x;
                    point.y *= scale.y;
                    
                    point.y = -point.y;
                    
                    b2Vec2 vec = [scene metersFromPoint:point];
                    
                    verts[idx] = vec;
                    ++i;
                }
                
                if(LHValidateCentroid(verts, count))
                {
                    shapeDef.Set(verts, count);
                    
                    b2FixtureDef fixture;
                    
                    LHSetupb2FixtureWithInfo(&fixture, dict);
                    
                    fixture.userData = LH_VOID_BRIDGE_CAST(self);
                    fixture.shape = &shapeDef;
                    body->CreateFixture(&fixture);
                }
                
                delete[] verts;
            }
        }
    }
    return self;
}

+(id)createChainWithDictionary:(NSDictionary*)dict shapePoints:(NSArray*)shapePoints close:(BOOL)close body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    return LH_AUTORELEASED([[self alloc] initChainWithDictionary:dict shapePoints:shapePoints close:close body:body node:node scene:scene scale:scale]);
}

-(id)initChainWithDictionary:(NSDictionary*)dict shapePoints:(NSArray*)shapePoints close:(BOOL)close body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    if(self = [super init]){
        
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
                
        std::vector< b2Vec2 > verts;
        
        NSValue* firstPt = nil;
        NSValue* lastPt = nil;
        
        for(NSValue* val in shapePoints){
            CGPoint pt = CGPointFromValue(val);
            
            pt.x *= scale.x;
            pt.y *= scale.y;
            
            b2Vec2 v2 = [scene metersFromPoint:pt];
            if(lastPt != nil)
            {
                CGPoint oldPt = CGPointFromValue(lastPt);
                b2Vec2 v1 = b2Vec2(oldPt.x, oldPt.y);
                
                if(b2DistanceSquared(v1, v2) > b2_linearSlop * b2_linearSlop)
                {
                    verts.push_back(v2);
                }
            }
            else{
                verts.push_back(v2);
            }
            
            lastPt = LHValueWithCGPoint(CGPointMake(v2.x, v2.y));
            
            if(firstPt == nil)
            {
                firstPt = LHValueWithCGPoint(CGPointMake(v2.x, v2.y));
            }
        }
                        
        if(firstPt && lastPt && close)
        {
            CGPoint lastPoint = CGPointFromValue(lastPt);
            b2Vec2 v1 = b2Vec2(lastPoint.x, lastPoint.y);
            
            CGPoint firstPoint = CGPointFromValue(firstPt);
            b2Vec2 v2 = b2Vec2(firstPoint.x, firstPoint.y);
            
            if(b2DistanceSquared(v1, v2) > b2_linearSlop * b2_linearSlop)
            {
                verts.push_back(v2);
            }
        }
        
        
        b2Shape* shape = new b2ChainShape();
        ((b2ChainShape*)shape)->CreateChain (&(verts.front()), (int)verts.size());
        
        b2FixtureDef fixture;
        
        LHSetupb2FixtureWithInfo(&fixture, dict);
        
        fixture.userData = LH_VOID_BRIDGE_CAST(self);
        fixture.shape = shape;
        body->CreateFixture(&fixture);
        
        delete shape;
        shape = NULL;
        
        
    }
    return self;
}

+(id)createWithDictionary:(NSDictionary*)dict triangles:(NSArray*)triangles body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict triangles:triangles body:body node:node scene:scene scale:scale]);
}

-(id)initWithDictionary:(NSDictionary*)dict triangles:(NSArray*)trianglePoints body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    if(self = [super init]){
        
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        
        for(int i = 0; i < [trianglePoints count]; i+=3)
        {
            NSDictionary* trDictA = [trianglePoints objectAtIndex:i];
            NSDictionary* trDictB = [trianglePoints objectAtIndex:i+1];
            NSDictionary* trDictC = [trianglePoints objectAtIndex:i+2];
            
            CGPoint ptA = [trDictA pointForKey:@"point"];
            ptA.y = -ptA.y;
            
            CGPoint ptB = [trDictB pointForKey:@"point"];
            ptB.y = -ptB.y;
            
            CGPoint ptC = [trDictC pointForKey:@"point"];
            ptC.y = -ptC.y;
            
//            ptA.x *= scaleX; ptA.y *= scaleY;
//            ptB.x *= scaleX; ptB.y *= scaleY;
//            ptC.x *= scaleX; ptC.y *= scaleY;
            
//            NSValue* valA = [trianglePoints objectAtIndex:i];
//            NSValue* valB = [trianglePoints objectAtIndex:i+1];
//            NSValue* valC = [trianglePoints objectAtIndex:i+2];
            
//            CGPoint ptA = CGPointFromValue(valA);
//            CGPoint ptB = CGPointFromValue(valB);
//            CGPoint ptC = CGPointFromValue(valC);
            
            ptA.x *= scale.x;
            ptA.y *= scale.y;
            
            ptB.x *= scale.x;
            ptB.y *= scale.y;
            
            ptC.x *= scale.x;
            ptC.y *= scale.y;
            
            b2Vec2 *verts = new b2Vec2[3];
            
            verts[2] = [scene metersFromPoint:ptA];
            verts[1] = [scene metersFromPoint:ptB];
            verts[0] = [scene metersFromPoint:ptC];
            
            b2PolygonShape shapeDef;
            
            shapeDef.Set(verts, 3);
            
            b2FixtureDef fixture;
            
            LHSetupb2FixtureWithInfo(&fixture, dict);
            
            fixture.userData = LH_VOID_BRIDGE_CAST(self);
            fixture.shape = &shapeDef;
            body->CreateFixture(&fixture);
            delete[] verts;
        }
    }
    return self;
}

+(id)createWithName:(NSString*)name pointA:(CGPoint)ptA pointB:(CGPoint)ptB node:(SKNode*)node scene:(LHScene*)scene
{
    return LH_AUTORELEASED([[self alloc] initWithName:name pointA:ptA pointB:ptB node:node scene:scene]);
}

-(id)initWithName:(NSString*)nm pointA:(CGPoint)ptA pointB:(CGPoint)ptB node:(SKNode*)node scene:(LHScene*)scene
{
    if(self = [super init]){
        
        _shapeID = 0;
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        // Define the ground body.
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0); // bottom-left corner
        
        b2Body* physicsBoundariesBody = [scene box2dWorld]->CreateBody(&groundBodyDef);
        physicsBoundariesBody->SetUserData(LH_VOID_BRIDGE_CAST(node));
        
        // Define the ground box shape.
        b2EdgeShape groundBox;
        
        b2Vec2 from = [scene metersFromPoint:ptA];
        b2Vec2 to = [scene metersFromPoint:ptB];
        
        // top
        groundBox.Set(from, to);
        b2Fixture* fixture = physicsBoundariesBody->CreateFixture(&groundBox,0);
        
        fixture->SetUserData(LH_VOID_BRIDGE_CAST(self));
    }
    return self;
}


+(id)createWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict body:body node:node scene:scene scale:scale]);
}

-(id)initWithDictionary:(NSDictionary*)dict body:(b2Body*)body node:(SKNode*)node scene:(LHScene*)scene scale:(CGPoint)scale
{
    if(self = [super init])
    {
        
        _shapeID = [[dict objectForKey:@"shapeID"] intValue];
        NSString* nm = [dict objectForKey:@"name"];
        if(nm){
            _shapeName = [[NSString alloc] initWithString:nm];
        }
        
        int flipx = scale.x < 0 ? -1 : 1;
        int flipy = scale.y < 0 ? -1 : 1;
        
        NSArray* fixtures = [dict objectForKey:@"points"];
        
        
        float ratio = [scene currentDeviceRatio];
                
        if(fixtures != nil)
        {
            for(NSArray* fixPoints in fixtures)
            {
                int count = (int)[fixPoints count];
                if(count > 2)
                {
                    b2Vec2 *verts = new b2Vec2[count];
                    b2PolygonShape shapeDef;
                    
                    int i = 0;
                    for(int j = count-1; j >=0; --j)
                    {
                        const int idx = (flipx < 0 && flipy >= 0) || (flipx >= 0 && flipy < 0) ? count - i - 1 : i;
                        
                        NSString* ptStr = [fixPoints objectAtIndex:j];
                        CGPoint point = LHPointFromString(ptStr);
                        
                        point.x /= ratio;
                        point.y /= ratio;
                        
                        point.x *= scale.x;
                        point.y *= scale.y;
                        
                        point.y = -point.y;
                        
                        b2Vec2 vec = [scene metersFromPoint:point];
                        
                        verts[idx] = vec;
                        ++i;
                    }
                    
                    if(LHValidateCentroid(verts, count))
                    {
                        shapeDef.Set(verts, count);
                        
                        b2FixtureDef fixture;
                        
                        LHSetupb2FixtureWithInfo(&fixture, dict);
                        
                        fixture.userData = LH_VOID_BRIDGE_CAST(self);
                        fixture.shape = &shapeDef;
                        body->CreateFixture(&fixture);
                    }
                    
                    delete[] verts;
                }
            }
        }
        else{
            
            float radius = [[dict objectForKey:@"radius"] floatValue];
            NSString* centerStr = [dict objectForKey:@"center"];
            CGPoint point = LHPointFromString(centerStr);
            
            radius /= ratio;
            
            point.x /= ratio;
            point.y /= ratio;
            
            point.x *= scale.x;
            point.y *= scale.y;
            
            point.y = -point.y;
            
            
            b2CircleShape* shape = new b2CircleShape();
            shape->m_radius = [scene metersFromValue:radius];
            shape->m_p = [scene metersFromPoint:point];
            
            b2FixtureDef fixture;
            LHSetupb2FixtureWithInfo(&fixture, dict);
            
            fixture.userData = LH_VOID_BRIDGE_CAST(self);
            fixture.shape = shape;
            body->CreateFixture(&fixture);
        }
    }
    return self;
}


-(void)dealloc{
    
    LH_SAFE_RELEASE(_shapeName);
    
    LH_SUPER_DEALLOC();
}

-(NSString*)shapeName{
    return _shapeName;
}
-(void)setShapeName:(NSString*)nm{
    
    LH_SAFE_RELEASE(_shapeName);
    if(nm){
        _shapeName = [[NSString alloc] initWithString:nm];
    }
}

-(int)shapeID{
    return _shapeID;
}
-(void)setShapeID:(int)val{
    _shapeID = val;
}

+(LHBodyShape*)shapeForB2Fixture:(b2Fixture*)fix{
    
    LHBodyShape* sp = (LHBodyShape*)LH_ID_BRIDGE_CAST(fix->GetUserData());
    
    if(sp && [sp isKindOfClass:[LHBodyShape class]]){
        return sp;
    }
    return nil;
}

@end

#endif //LH_USE_BOX2D
