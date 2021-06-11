//
//  U4DAlign.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 4/13/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#include "U4DAlign.h"
#include "U4DDynamicAction.h"
#include "U4DModel.h"

namespace U4DEngine {

    U4DAlign::U4DAlign():neighborDistance(20.0){
            
        }

    U4DAlign::~U4DAlign(){
        
    }


    U4DVector3n U4DAlign::getSteering(U4DDynamicAction *uPursuer, std::vector<U4DDynamicAction*> uNeighborsContainer){
        
        U4DVector3n avgDesiredVelocity;
        
        int count=0;
        
        for (const auto &n:uNeighborsContainer) {

            //distace to neigbhors
            float d=(uPursuer->model->getAbsolutePosition()-n->model->getAbsolutePosition()).magnitude();
            
            if((n!=uPursuer)&&(d<neighborDistance)){
                
                //get velocity from neighbhors
                avgDesiredVelocity+=n->getVelocity();
                
                count++;
                
            }
        }
        
        if(count>0){
            
            //compute average desired velocity
            avgDesiredVelocity/=count;
            
            //get the the direction of the vector only
            avgDesiredVelocity.normalize();
            
            //set the speed
            avgDesiredVelocity*=maxSpeed;
            
            return avgDesiredVelocity;
            
        }
        
        return U4DVector3n(0.0,0.0,0.0);
        
    }

    void U4DAlign::setNeighborDistance(float uNeighborDistance){
        neighborDistance=uNeighborDistance;
    }

}
