//
//  LDGFilterWorkItem.h
//  LogDigger
//
//  Created by Hongyu on 2019/1/13.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#ifndef LDGFilterWorkItem_h
#define LDGFilterWorkItem_h

#import <CoreFoundation/CoreFoundation.h>

namespace logdigger {
    
    /**
     The filter work description item, designed to be stored in a vector to
     improve random access performance.
     */
    struct filter_work_item {
        void *log_item;
        void *match;  /* Retained by this */
        
        /* The ownership of `match` can only be transferred. */
        filter_work_item(const filter_work_item &other) = delete;
        filter_work_item(filter_work_item &&other) {
            log_item = other.log_item;
            match = other.match;
            
            other.log_item = nullptr;
            other.match = nullptr;
        }
        
        filter_work_item(void *log_item, void *match)
        : log_item(log_item), match(match) {}
        
        ~filter_work_item() {
            if (match) {
                // Release once.
                CFBridgingRelease(match);
            }
        }
    };
    
}

#endif /* LDGFilterWorkItem_h */
