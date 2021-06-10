//
//  U4DDragForceGenerator.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 6/23/13.
//  Copyright (c) 2013 Untold Engine Studios. All rights reserved.
//

#include "U4DDragForceGenerator.h"

namespace U4DEngine {
    
    U4DDragForceGenerator::U4DDragForceGenerator(){
    
    }
    
    U4DDragForceGenerator::~U4DDragForceGenerator(){
    
    }
    
    void  U4DDragForceGenerator::updateForce(U4DDynamicAction *uAction, float dt){

        U4DVector2n dragCoefficient=uAction->getDragCoefficient();
        
        float k1=dragCoefficient.x;
        float k2=dragCoefficient.y;
        
        U4DVector3n linearDrag;
        float forceDragCoeff;
        
        linearDrag=uAction->getVelocity();
        forceDragCoeff=linearDrag.magnitude();
        
        forceDragCoeff=k1*forceDragCoeff+k2*forceDragCoeff*forceDragCoeff;
        
        //calculate the final force and apply it
        linearDrag.normalize();
        linearDrag*=-forceDragCoeff;
        
        uAction->addForce(linearDrag);
        
        //moment
        U4DVector3n angularDrag;
        float momentDragCoeff;
        
        angularDrag=uAction->getAngularVelocity();
        momentDragCoeff=angularDrag.magnitude();
        
        momentDragCoeff=k1*momentDragCoeff+k2*momentDragCoeff*momentDragCoeff;
        
        angularDrag.normalize();
        angularDrag*=-momentDragCoeff;
        uAction->addMoment(angularDrag);
        
    }

}
