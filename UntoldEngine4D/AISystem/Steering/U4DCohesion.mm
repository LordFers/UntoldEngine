//
//  U4DCohesion.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 4/14/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#include "U4DCohesion.h"
#include "U4DDynamicAction.h"
#include "U4DModel.h"

namespace U4DEngine {

    U4DCohesion::U4DCohesion():neighborDistance(20.0){
            
        }

    U4DCohesion::~U4DCohesion(){
        
    }


    U4DVector3n U4DCohesion::getSteering(U4DDynamicAction *uPursuer, std::vector<U4DDynamicAction*> uNeighborsContainer){
        
        U4DVector3n avgTargetPosition;
        
        int count=0;
        
        for (const auto &n:uNeighborsContainer) {

            //distace to neigbhors
            float d=(uPursuer->model->getAbsolutePosition()-n->model->getAbsolutePosition()).magnitude();
            
            if((n!=uPursuer)&&(d<neighborDistance)){
                
                //get avg position of neighbhors
                avgTargetPosition+=n->model->getAbsolutePosition();
                
                count++;
                
            }
        }
        
        if(count>0){
            
            //compute average desired target position
            avgTargetPosition/=count;
            
            return U4DArrive::getSteering(uPursuer, avgTargetPosition);
            
        }
        
        return U4DVector3n(0.0,0.0,0.0);
        
    }

    void U4DCohesion::setNeighborDistance(float uNeighborDistance){
        neighborDistance=uNeighborDistance;
    }

}
