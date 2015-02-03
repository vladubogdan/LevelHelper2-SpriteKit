//
//  LHNodePhysicsProtocol.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHNodePhysicsProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "SKNode+Transforms.h"

#import "LHBezier.h"
#import "LHShape.h"
#import "LHSprite.h"
#import "LHConfig.h"

#import "SKNode+Transforms.h"

#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHBackUINode.h"

#import "LHAsset.h"
#import "LHNode.h"

#import "LHBodyShape.h"

#if LH_USE_BOX2D

#include "Box2d/Box2D.h"
#include <vector>

#else

#endif //LH_USE_BOX2D

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid;
-(NSDictionary*)getEditorBodyInfoForSpriteName:(NSString*)sprName
                                         atlas:(NSString*)atlasPlist;
@end

@interface LHGameWorldNode (LH_PHYSICS_PROTOCOL_CONTACT_REMOVAL)
-(void)removeScheduledContactsWithNode:(SKNode*)node;
@end

@interface LHAsset (LH_ASSET_NODES_PRIVATE_UTILS)
-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid;
@end

@interface LHShape (PHYSICS_TRIANGLES)
-(NSMutableArray*)shapeTriangles;
@end



@implementation LHNodePhysicsProtocolImp
{
    BOOL originallySensor;
    BOOL scheduledForRemoval;
    
#if LH_USE_BOX2D
    NSMutableArray* _subShapes;
    b2Body* _body;
    CGPoint previousScale;
#endif
    __unsafe_unretained SKNode* _node;
}

-(void)dealloc{
    
#if LH_USE_BOX2D

    if(_body && _node && [_node respondsToSelector:@selector(isB2WorldDirty)] && ![(LHNode*)_node isB2WorldDirty])
    {
        //node at this point may not have parent so no scene also
        LHBox2dWorld* world = (LHBox2dWorld*)_body->GetWorld();
        if(world){
            LHScene* scene = (LHScene*)LH_ID_BRIDGE_CAST(world->_scene);
            if(scene){
                LHGameWorldNode* gw = [scene gameWorldNode];
                if(gw){
                    [gw removeScheduledContactsWithNode:_node];
                }
            }
        }
        
        //do not remove the body if the scene is deallocing as the box2d world will be deleted
        //so we dont need to do this manualy
        //in some cases the nodes will be retained and removed after the box2d world is already deleted and we may have a crash
        [self removeBody];
    }
    LH_SAFE_RELEASE(_subShapes);
    
    _body = NULL;
#endif
    _node = nil;
    
    LH_SUPER_DEALLOC();
}

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd scale:(CGPoint)scale{
    return LH_AUTORELEASED([[self alloc] initPhysicsProtocolImpWithDictionary:dict node:nd scale:scale]);
}

-(SKNode*)node{
    return _node;
}

-(LHAsset*)assetParent{
    SKNode* p = _node;
    while(p && [p parent]){
        if([p isKindOfClass:[LHAsset class]])
            return (LHAsset*)p;
        p = [p parent];
    }
    return nil;
}

- (instancetype)initPhysicsProtocolWithNode:(SKNode*)nd
{
    if(self = [super init])
    {
        _node = nd;
        
        #if LH_USE_BOX2D
        _body = NULL;
        #endif
        
    }
    return self;
}

#if LH_USE_BOX2D

#pragma mark - BOX2D SUPPORT

-(void)setupFixture:(b2FixtureDef*)fixture withInfo:(NSDictionary*)fixInfo
{
    fixture->density     = [fixInfo floatForKey:@"density"];
    fixture->friction    = [fixInfo floatForKey:@"friction"];
    fixture->restitution = [fixInfo floatForKey:@"restitution"];
    fixture->isSensor    = [fixInfo boolForKey:@"sensor"];

    fixture->filter.maskBits = [fixInfo intForKey:@"mask"];
    fixture->filter.categoryBits = [fixInfo intForKey:@"category"];
}

- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd scale:(CGPoint)scl{
    
    if(self = [super init])
    {
        _node = nd;
        _body = NULL;
        
        [_node setXScale:scl.x];
        [_node setYScale:scl.y];

        if(!dict){
            return self;
        }
        
        int shapeType = 6;//editor
        if([dict objectForKey:@"shape"])
            shapeType = [dict intForKey:@"shape"];

        int type = [dict intForKey:@"type"];
        
        LHScene* scene = (LHScene*)[_node scene];
        b2World* world = [scene box2dWorld];
        

        b2BodyDef bodyDef;
        bodyDef.type = (b2BodyType)type;
        
        CGPoint position = [_node convertPoint:CGPointZero toNode:scene];
        
        b2Vec2 bodyPos = [scene metersFromPoint:position];
        bodyDef.position = bodyPos;

        float angle = [_node globalAngleFromLocalAngle:[_node zRotation]];
        bodyDef.angle = angle;

        bodyDef.userData = LH_VOID_BRIDGE_CAST(_node);
        
        _body = world->CreateBody(&bodyDef);
        _body->SetUserData(LH_VOID_BRIDGE_CAST(_node));

        _body->SetFixedRotation([dict boolForKey:@"fixedRotation"]);
        _body->SetGravityScale([dict floatForKey:@"gravityScale"]);

        _body->SetSleepingAllowed([dict boolForKey:@"allowSleep"]);
        _body->SetBullet([dict boolForKey:@"bullet"]);
        

        _body->SetAngularDamping([dict floatForKey:@"angularDamping"]);
        _body->SetAngularVelocity([dict floatForKey:@"angularVelocity" ]);//radians/second.
        _body->SetLinearDamping([dict floatForKey:@"linearDamping"]);
        CGPoint linearVel = [dict pointForKey:@"linearVelocity"];
        _body->SetLinearVelocity(b2Vec2(linearVel.x,linearVel.y));
        
        float scaleX = [_node xScale];
        float scaleY = [_node yScale];

        CGPoint worldScale = [_node convertToWorldScale:CGPointMake(scaleX, scaleY)];
        scaleX = worldScale.x;
        scaleY = worldScale.y;
        
        previousScale = worldScale;
        
        CGSize sizet = CGSizeMake(16, 16);
        if([_node respondsToSelector:@selector(size)]){
            sizet = [(SKSpriteNode*)_node size];//we cast so that we dont get a compiler error
        }
        
        if([_node isKindOfClass:[LHSprite class]])
        {
            CGPoint sizeWorldScale = [_node convertToWorldScale:CGPointMake(1, 1)];
            
            //CAREFUL - size is returned containing scale - so don't multiply scale to the size but do multiply the world scale
            sizet.width *= sizeWorldScale.x;
            sizet.height*= sizeWorldScale.y;
        }
        else{
            sizet.width *= worldScale.x;
            sizet.height*= worldScale.y;
        }

        
        sizet.width  = [scene metersFromValue:sizet.width];
        sizet.height = [scene metersFromValue:sizet.height];

        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];

        _subShapes = [[NSMutableArray alloc] init];
        
        if(shapeType == 0)//RECTANGLE
        {
            LHBodyShape* shape = [LHBodyShape createRectangleWithDictionary:fixInfo body:_body node:_node scene:scene size:sizet];
            
            if(shape){
                [_subShapes addObject:shape];
            }
        }
        
        else if(shapeType == 1)//CIRCLE
        {
            LHBodyShape* shape = [LHBodyShape createCircleWithDictionary:fixInfo body:_body node:_node scene:scene size:sizet];
            
            if(shape){
                [_subShapes addObject:shape];
            }
        }
        else if(shapeType == 2)//POLYGON
        {
            if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* trianglePoints = [(LHShape*)_node shapeTriangles];
                
                LHBodyShape* shape = [LHBodyShape createWithDictionary:fixInfo
                                                             triangles:trianglePoints
                                                                  body:_body
                                                                  node:_node
                                                                 scene:scene
                                                                 scale:worldScale];
                if(shape){
                    [_subShapes addObject:shape];
                }
            }
        }
        else if(shapeType == 3)//CHAIN
        {
            if([_node isKindOfClass:[LHBezier class]])
            {
                NSMutableArray* points = [(LHBezier*)_node linePoints];
                
                LHBodyShape* shape = [LHBodyShape createChainWithDictionary:fixInfo
                                                                shapePoints:points
                                                                      close:NO
                                                                       body:_body
                                                                       node:_node
                                                                      scene:scene
                                                                      scale:worldScale];
                
                if(shape){
                    [_subShapes addObject:shape];
                }
            }
            else if([_node isKindOfClass:[LHShape class]])
            {
                NSMutableArray* points = [(LHShape*)_node outlinePoints];
                
                LHBodyShape* shape = [LHBodyShape createChainWithDictionary:fixInfo
                                                                shapePoints:points
                                                                      close:YES
                                                                       body:_body
                                                                       node:_node
                                                                      scene:scene
                                                                      scale:worldScale];
                
                if(shape){
                    [_subShapes addObject:shape];
                }
            }
            else{

                
            }
        }
        else if(shapeType == 4)//OVAL
        {
            NSArray* shapePoints = [dict objectForKey:@"ovalShape"];
            if(shapePoints)
            {
                LHBodyShape* shape = [LHBodyShape createWithDictionary:fixInfo
                                                           shapePoints:shapePoints
                                                                  body:_body
                                                                  node:_node
                                                                 scene:scene
                                                                 scale:worldScale];
                if(shape){
                    [_subShapes addObject:shape];
                }
            }
        }
        else if(shapeType == 5)//TRACED
        {
            NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];
            LHScene* scene = (LHScene*)[_node scene];
            NSArray* shapePoints = [scene tracedFixturesWithUUID:fixUUID];
            if(!shapePoints){
                LHAsset* asset = [self assetParent];
                if(asset){
                    shapePoints = [asset tracedFixturesWithUUID:fixUUID];
                }
            }
            
            if(shapePoints)
            {
                LHBodyShape* shape = [LHBodyShape createWithDictionary:fixInfo
                                                           shapePoints:shapePoints
                                                                  body:_body
                                                                  node:_node
                                                                 scene:scene
                                                                 scale:worldScale];
                
                if(shape){
                    [_subShapes addObject:shape];
                }
            }
        }
        else if(shapeType == 6)//editor
        {
            //available only for sprites
            LHSprite* sprite = (LHSprite*)_node;
            if(sprite && [sprite isKindOfClass:[LHSprite class]])
            {
                NSDictionary* bodyInfo = [scene getEditorBodyInfoForSpriteName:[sprite spriteFrameName] atlas:[sprite imageFilePath]];
                
                if(bodyInfo){
                    NSArray* fixturesInfo = [bodyInfo objectForKey:@"shapes"];
                    
                    for(NSDictionary* shapeInfo in fixturesInfo)
                    {
                        LHBodyShape* shape = [LHBodyShape createWithDictionary:shapeInfo body:_body node:_node scene:scene scale:worldScale];
                        
                        if(shape){
                            [_subShapes addObject:shape];
                        }
                    }
                }
            }
        }
        
    }
    return self;
}

-(b2Body*)body{
    return _body;
}
-(void)setBody:(b2Body*)b{
    _body = b;
}
-(int)bodyType{
    if(_body){
        return (int)_body->GetType();
    }
    return (int)LH_NO_PHYSICS;
}
-(void)setBodyType:(int)type{
    if(_body){
        if(type != LH_NO_PHYSICS)
        {
            _body->SetActive(true);
            _body->SetType((b2BodyType)type);
        }
        else{
            _body->SetType((b2BodyType)0);
            _body->SetActive(false);
        }
        //for no physics - we should do something else
    }
}

-(NSArray*) jointList{
    NSMutableArray* array = [NSMutableArray array];
    if(_body != NULL){
        b2JointEdge* jtList = _body->GetJointList();
        while (jtList) {
            if(jtList->joint && jtList->joint->GetUserData())
            {
                SKNode* ourNode = (LHNode*)LH_ID_BRIDGE_CAST(jtList->joint->GetUserData());
                if(ourNode != NULL)
                    [array addObject:ourNode];
            }
            jtList = jtList->next;
        }
    }
    return array;
}
-(bool) removeAllAttachedJoints{
    NSArray* list = [self jointList];
    if(list){
        for(SKNode* jt in list){
            [jt removeFromParent];
        }
        return true;
    }
    return false;
}

-(void)removeBody{
    
    if(_body){
        b2World* world = _body->GetWorld();
        if(world){
            
            LH_SAFE_RELEASE(_subShapes);
            
            _body->SetUserData(NULL);
            if(!world->IsLocked()){
                [self removeAllAttachedJoints];
                world->DestroyBody(_body);
                _body = NULL;
                scheduledForRemoval = false;
            }
            else{
                scheduledForRemoval = true;
            }
        }
    }
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
    if(_body && scheduledForRemoval){
        [self removeBody];
    }
    
    if(_body){
        CGAffineTransform trans = b2BodyToParentTransform(_node, self);
        CGPoint localPos = CGPointApplyAffineTransform([_node anchorPointInPoints], trans);
        [((LHNode*)_node) updatePosition:localPos];
        [((LHNode*)_node) updateZRotation:[_node localAngleFromGlobalAngle:_body->GetAngle()]];
    }
}

static inline CGAffineTransform b2BodyToParentTransform(SKNode *node, LHNodePhysicsProtocolImp *physicsImp)
{
	return CGAffineTransformConcat(physicsImp.absoluteTransform, CGAffineTransformInvert(NodeToB2BodyTransform(node.parent)));
}
static inline CGAffineTransform NodeToB2BodyTransform(SKNode *node)
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	for(SKNode *n = node; n &&  ![n isKindOfClass:[LHGameWorldNode class]]&&
                                ![n isKindOfClass:[LHUINode class]] &&
                                ![n isKindOfClass:[LHBackUINode class]];
        n = n.parent){
		transform = CGAffineTransformConcat(transform, n.nodeToParentTransform);
	}
	return transform;
}

- (CGAffineTransform)nodeTransform
{
    if([self body]){
        CGAffineTransform rigidTransform = b2BodyToParentTransform(_node, self);
		return CGAffineTransformConcat(CGAffineTransformMakeScale([_node xScale], [_node yScale]), rigidTransform);
    }
    return CGAffineTransformIdentity;//should never get here
}

-(CGAffineTransform)absoluteTransform {
    CGAffineTransform transform = CGAffineTransformIdentity;
    LHScene* scene = (LHScene*)[_node scene];
    b2Vec2 b2Pos = [self body]->GetPosition();
    CGPoint globalPos = [scene pointFromMeters:b2Pos];
    
    transform = CGAffineTransformTranslate(transform, globalPos.x, globalPos.y);
    transform = CGAffineTransformRotate(transform, [self body]->GetAngle());
    
    transform = CGAffineTransformTranslate(transform, - ((SKSpriteNode*)_node).size.width*0.5, - ((SKSpriteNode*)_node).size.height*0.5);
    
	return transform;
}

-(void)updateTransform
{
    if([self body])
    {
        LHGameWorldNode* gWNode = [(LHScene*)[_node scene] gameWorldNode];
        
        CGPoint worldPos = [_node position];
        if(gWNode != [_node parent]){
            worldPos = [[_node parent] convertToWorldSpace:worldPos];
            worldPos = [gWNode convertToNodeSpace:worldPos];
        }
        
        b2Vec2 b2Pos = [(LHScene*)[_node scene] metersFromPoint:worldPos];
        _body->SetTransform(b2Pos, [_node globalAngleFromLocalAngle:[_node zRotation]]);
        _body->SetAwake(true);        
    }
}

-(float)rotation{
    if([self body]){
        return [self body]->GetAngle();
    }
    return 0.0f;//should never get here
}

-(BOOL) validCentroid:(b2Vec2*)vs count:(int)count
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

-(void)updateScale{
    
    if(_body){
        CGFloat scaleX = [_node xScale];
        CGFloat scaleY = [_node yScale];

        CGPoint globalScale = [_node convertToWorldScale:CGPointMake(scaleX, scaleY)];
        scaleX = globalScale.x;
        scaleY = globalScale.y;
        
        if(scaleX == previousScale.x && scaleY == previousScale.y){
            return;
        }

        if(scaleX < 0.01 && scaleX > -0.01){
            NSLog(@"WARNING - SCALE Y value CANNOT BE 0 - BODY WILL NOT GET SCALED.");
            return;
        }

        if(scaleY < 0.01 && scaleY > -0.01){
            NSLog(@"WARNING - SCALE X value CANNOT BE 0 - BODY WILL NOT GET SCALED.");
            return;
        }

        b2Fixture* fix = _body->GetFixtureList();
        while (fix) {
            
            b2Shape* shape = fix->GetShape();
            
            int flipx = scaleX < 0 ? -1 : 1;
            int flipy = scaleY < 0 ? -1 : 1;
                        
            if(shape->GetType() == b2Shape::e_polygon)
            {
                b2PolygonShape* polShape = (b2PolygonShape*)shape;
                int32 count = polShape->GetVertexCount();
                
                b2Vec2* newVertices = new b2Vec2[count];
                
                for(int i = 0; i < count; ++i)
                {
                    const int idx = (flipx < 0 && flipy >= 0) || (flipx >= 0 && flipy < 0) ? count - i - 1 : i;
                    
                    b2Vec2 pt = polShape->GetVertex(i);
                    
                    if(scaleX - previousScale.x != 0)
                    {
                        pt.x /= previousScale.x;
                        pt.x *= scaleX;
                    }

                    if(scaleY - previousScale.y)
                    {
                        pt.y /= previousScale.y;
                        pt.y *= scaleY;
                    }
                    
                    newVertices[idx] = pt;
                }
                
                BOOL valid = [self validCentroid:newVertices count:count];
                if(!valid) {
                    //flip
                    b2Vec2* flippedVertices = new b2Vec2[count];
                    for(int i = 0; i < count; ++i)
                    {
                        flippedVertices[i] = newVertices[count - i - 1];
                    }
                    delete[] newVertices;
                    newVertices = flippedVertices;
                }
                
                polShape->Set(newVertices, count);
                delete[] newVertices;
            }
            
            if(shape->GetType() == b2Shape::e_circle)
            {
                b2CircleShape* circleShape = (b2CircleShape*)shape;
                CGFloat radius = circleShape->m_radius;
                
                CGFloat newRadius = radius/previousScale.x*scaleX;
                circleShape->m_radius = newRadius;
            }
            
            
            if(shape->GetType() == b2Shape::e_edge)
            {
                b2EdgeShape* edgeShape = (b2EdgeShape*)shape;
#pragma unused (edgeShape)
                NSLog(@"EDGE SHAPE");
            }
            
            if(shape->GetType() == b2Shape::e_chain)
            {
                b2ChainShape* chainShape = (b2ChainShape*)shape;
                
                b2Vec2* vertices = chainShape->m_vertices;
                int32 count = chainShape->m_count;
                
                for(int i = 0; i < count; ++i)
                {
                    b2Vec2 pt = vertices[i];
                    b2Vec2 newPt = b2Vec2(pt.x/previousScale.x*scaleX, pt.y/previousScale.y*scaleY);
                    vertices[i] = newPt;
                }
            }
            
            
            fix = fix->GetNext();
        }
        
        previousScale = CGPointMake(scaleX, scaleY);
    }
}

+(b2Body*)LHGetBox2dBody:(SKNode*)_node_
{
    if([_node_ respondsToSelector:@selector(box2dBody)]){
        return [(id<LHNodePhysicsProtocol>)_node_ box2dBody];
    }
    return NULL;
}

#pragma mark - SPRITEKIT SUPPORT
////////////////////////////////////////////////////////////////////////////////
#else //chipmunk

-(int)bodyType{
//    if([_node physicsBody]){
//        if([[_node physicsBody] type] == CCPhysicsBodyTypeDynamic){
//            return (int)LH_DYNAMIC_BODY;
//        }
//        else{
//            return (int)LH_STATIC_BODY;
//        }
//    }
    NSLog(@"BODY TYPE NOT IMPLEMENTED");
    
    return (int)LH_NO_PHYSICS;
}
-(void)setBodyType:(int)type{
    if([_node physicsBody]){

        NSLog(@"BODY TYPE NOT IMPLEMENTED");
        
    }
}

-(void)removeBody{
    
    if([_node physicsBody])
    {
        [_node setPhysicsBody:nil];        
    }
}


- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dict node:(SKNode*)nd scale:(CGPoint)scl{
    
    if(self = [super init])
    {
        _node = nd;

        if(!dict){
            [_node setXScale:scl.x];
            [_node setYScale:scl.y];
            return self;
        }
        
        int shape = [dict intForKey:@"shape"];
        
        NSArray* fixturesInfo = nil;
        
#if LH_DEBUG
        NSMutableArray* debugShapeNodes = [NSMutableArray array];
#endif
        
        CGSize size = CGSizeMake(16, 16);
        
        if([_node respondsToSelector:@selector(size)]){
            size = [(SKSpriteNode*)_node size];//we cast so that we dont get a compiler error
        }
        
        float xScale =[_node xScale];
        float yScale = [_node yScale];
        
        size.width/=xScale;
        size.height/=yScale;
        
        
        if(shape == 0)//RECTANGLE
        {
            _node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
            
#if LH_DEBUG
                CGPoint offset = CGPointMake(0, 0);
                SKShapeNode* debugShapeNode = [SKShapeNode node];
                CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(-size.width*0.5  + offset.x,
                                                                -size.height*0.5 + offset.y,
                                                                size.width,
                                                                size.height),
                                                     nil);
                debugShapeNode.path = pathRef;
                CGPathRelease(pathRef);
            
                [debugShapeNodes addObject:debugShapeNode];
#endif
            
        }
        else if(shape == 1)//CIRCLE
        {
            _node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:size.width*0.5];
            
#if LH_DEBUG
                CGPoint offset = CGPointMake(0, 0);
                SKShapeNode* debugShapeNode = [SKShapeNode node];
                CGPathRef pathRef= CGPathCreateWithEllipseInRect(CGRectMake(-size.width*0.5 + offset.x,
                                                                        -size.width*0.5 + offset.y,
                                                                        size.width,
                                                                        size.width),
                                                             nil);
                debugShapeNode.path = pathRef;
                CGPathRelease(pathRef);
                [debugShapeNodes addObject:debugShapeNode];
#endif
        }
        else if(shape == 3)//CHAIN
        {
            if([_node isKindOfClass:[SKShapeNode class]])
            {
                _node.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:((SKShapeNode*)_node).path];
                
#if LH_DEBUG
                SKShapeNode* debugShapeNode = [SKShapeNode node];
                debugShapeNode.path = ((SKShapeNode*)_node).path;
                [debugShapeNodes addObject:debugShapeNode];
#endif
                
            }
            else
            {
                CGPoint offset = CGPointMake(0, 0);
                CGRect rect = CGRectMake(-size.width*0.5 + offset.x,
                                         -size.height*0.5 + offset.y,
                                         size.width,
                                         size.height);
                
                _node.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
    #if LH_DEBUG
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                
                    CGPathRef pathRef = CGPathCreateWithRect(rect, nil);
                    debugShapeNode.path = pathRef;
                    CGPathRelease(pathRef);
                    [debugShapeNodes addObject:debugShapeNode];
    #endif
            }
            
        }
        else if(shape == 4)//OVAL
        {
            fixturesInfo = [dict objectForKey:@"ovalShape"];
        }
        else if(shape == 5)//TRACED
        {
            NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];
            LHScene* scene = (LHScene*)[_node scene];
            fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
            if(!fixturesInfo){
                LHAsset* asset = [self assetParent];
                if(asset){
                    fixturesInfo = [asset tracedFixturesWithUUID:fixUUID];
                }
            }
        }
        else if(shape == 2)//POLYGON
        {
            if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* triangles = [(LHShape*)_node shapeTriangles];
                
                NSMutableArray* trianglebodies = [NSMutableArray array];
                
                CGMutablePathRef trianglePath = nil;
                int i = 0;
                for(NSDictionary* trDict in triangles)
                {
                    CGPoint vPoint = [trDict pointForKey:@"point"];
                    if(!trianglePath){
                        trianglePath = CGPathCreateMutable();
                        CGPathMoveToPoint(trianglePath, nil, vPoint.x, -vPoint.y);
                    }
                    else{
                        CGPathAddLineToPoint(trianglePath, nil, vPoint.x, -vPoint.y);
                    }
                    
                    ++i;
                    
                    if(trianglePath && i == 3){
                        CGPathCloseSubpath(trianglePath);
                        SKPhysicsBody* trBody = [SKPhysicsBody bodyWithPolygonFromPath:trianglePath];
                        [trianglebodies addObject:trBody];
                        
    #if LH_DEBUG
                        SKShapeNode* debugShapeNode = [SKShapeNode node];
                        debugShapeNode.path = trianglePath;
                        [debugShapeNodes addObject:debugShapeNode];
    #endif
                        
                        CGPathRelease(trianglePath);
                        trianglePath = nil;
                        i = 0;
                    }
                }
                
                
    #if TARGET_OS_IPHONE
                _node.physicsBody = [SKPhysicsBody bodyWithBodies:trianglebodies];
    #endif
            }
            
        }
        
        
        
        if(fixturesInfo)
        {
            NSMutableArray* fixBodies = [NSMutableArray array];
            
            for(NSArray* fixPoints in fixturesInfo)
            {
                int count = (int)[fixPoints count];
                CGPoint points[count];
                
                int i = count - 1;
                for(int j = 0; j< count; ++j)
                {
                    NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                    CGPoint point = LHPointFromString(pointStr);
                    
                    //flip y for sprite kit coordinate system
                    point.y = size.height - point.y;
                    point.y = point.y - size.height;
                    
                    
                    points[j] = point;
                    i = i-1;
                }
                
                CGMutablePathRef fixPath = CGPathCreateMutable();
                
                bool first = true;
                for(int k = 0; k < count; ++k)
                {
                    CGPoint point = points[k];
                    if(first){
                        CGPathMoveToPoint(fixPath, nil, point.x, point.y);
                    }
                    else{
                        CGPathAddLineToPoint(fixPath, nil, point.x, point.y);
                    }
                    first = false;
                }
                
                CGPathCloseSubpath(fixPath);
                
#if LH_DEBUG
                    SKShapeNode* debugShapeNode = [SKShapeNode node];
                    debugShapeNode.path = fixPath;
                    [debugShapeNodes addObject:debugShapeNode];
#endif
                
                SKPhysicsBody* bd = [SKPhysicsBody bodyWithPolygonFromPath:fixPath];
                if(bd)
                    [fixBodies addObject:bd];
                
                CGPathRelease(fixPath);
            }
#if TARGET_OS_IPHONE
            _node.physicsBody = [SKPhysicsBody bodyWithBodies:fixBodies];
#endif
            
        }
        
        
        int type = [dict intForKey:@"type"];
        if(type == 0)//static
        {
            [_node.physicsBody setDynamic:NO];
        }
        else if(type == 1)//kinematic
        {
        }
        else if(type == 2)//dynamic
        {
            [_node.physicsBody setDynamic:YES];
        }
        
        
        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
        if(fixInfo && _node.physicsBody)
        {
            _node.physicsBody.categoryBitMask = [fixInfo intForKey:@"category"];
            _node.physicsBody.collisionBitMask = [fixInfo intForKey:@"mask"];
            _node.physicsBody.contactTestBitMask = [fixInfo intForKey:@"category"];
            
            _node.physicsBody.density = [fixInfo floatForKey:@"density"];
            _node.physicsBody.friction = [fixInfo floatForKey:@"friction"];
            _node.physicsBody.restitution = [fixInfo floatForKey:@"restitution"];
            
            _node.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
            _node.physicsBody.usesPreciseCollisionDetection = [dict boolForKey:@"bullet"];
            
            if([dict intForKey:@"gravityScale"] == 0){
                _node.physicsBody.affectedByGravity = NO;
            }
            
            if([dict objectForKey:@"angularDamping"])//all this properties were added in the same moment
            {
                _node.physicsBody.angularDamping = [dict floatForKey:@"angularDamping"];
                _node.physicsBody.angularVelocity = [dict floatForKey:@"angularVelocity"];
                _node.physicsBody.linearDamping = [dict floatForKey:@"linearDamping"];
                CGPoint linearVel = [dict pointForKey:@"linearVelocity"];
                _node.physicsBody.velocity = CGVectorMake(linearVel.x, linearVel.y);
            }
        }
        
        
#if LH_DEBUG
            for(SKShapeNode* debugShapeNode in debugShapeNodes)
            {
                debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.5];
                if(shape != 3){//chain
                    debugShapeNode.fillColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.1];
                }
                debugShapeNode.lineWidth = 0.1;
                if(_node.physicsBody.isDynamic){
                    debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.5];
                    debugShapeNode.fillColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.1];
                }
                [_node addChild:debugShapeNode];
            }
#endif
        
        
        [_node setXScale:scl.x];
        [_node setYScale:scl.y];

        
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{
    //nothing for spritekit
}
#endif //LH_USE_BOX2D

@end
