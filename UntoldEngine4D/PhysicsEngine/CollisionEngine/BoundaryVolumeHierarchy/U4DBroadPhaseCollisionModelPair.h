//
//  BroadPhaseCollisionModelPair.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 3/9/16.
//  Copyright © 2016 Untold Engine Studios. All rights reserved.
//

#ifndef BroadPhaseCollisionModelPair_hpp
#define BroadPhaseCollisionModelPair_hpp

#include <stdio.h>

namespace U4DEngine {
    class U4DDynamicAction;
}


namespace U4DEngine {

    /**
     @ingroup physicsengine
     @brief The U4DBroadPhaseCollisionModelPair class contains collision entity pairs
     */
    class U4DBroadPhaseCollisionModelPair {
        
    private:
        
    public:
        
        /**
         @brief Constructor of the class
         */
        U4DBroadPhaseCollisionModelPair();
        
        /**
         @brief Destructor of the class
         */
        ~U4DBroadPhaseCollisionModelPair();
        
        /**
         @brief 3D model entity
         */
        U4DDynamicAction *model1;
        
        /**
         @brief 3D model entity
         */
        U4DDynamicAction *model2;
    };
    
}



#endif /* BroadPhaseCollisionModelPair_hpp */
