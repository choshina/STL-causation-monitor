#include "stdafx.h"
#include <transducer.h>
#include <algorithm>
#include <math.h>

namespace CPSGrader {

    /* Interval robustness */

    // default (static): interval robustness is the same as normal robustness, with TOPs and BOTTOMs at
    // the ends 
    double transducer::compute_lower_rob(){
#ifdef DEBUG__
        printf(">  transducer:computer_lower_rob              IN.\n");
#endif
        compute_robustness();
        if (z.endTime < start_time) {
            z_low.appendSample(start_time, BOTTOM); 
        }
        else
            z_low = z;

         
        //if(trace_data_ptr->back().front() == 28){
        //    cout<<z<<endl;
        //}
#ifdef DEBUG__
        printf( "<  transducer:computer_lower_rob              OUT.\n");
#endif
        return z_low.front().value;
    };

    double transducer::compute_upper_rob(){
#ifdef DEBUG__
        printf( ">  transducer:computer_upper_rob              IN.\n");
#endif
        compute_robustness();
        if (z.endTime < start_time) {
            z_up.appendSample(start_time, BOTTOM); 
        }
        else
            z_up = z;
#ifdef DEBUG__
        printf( "<  transducer:computer_upper_rob              OUT.\n");
#endif
        return z_up.front().value;
    };

    
    double and_transducer::compute_lower_rob(){
#ifdef DEBUG__
        printf( ">  and_transducer:computer_lower_rob           IN.\n");
#endif
        childL->compute_lower_rob();  
        childR->compute_lower_rob();
        z_low.compute_and(childL->z_low,childR->z_low);
        z_low.resize(start_time, min(childL->z_low.endTime,childR->z_low.endTime),BOTTOM);
        if (z_low.empty())
            z_low.appendSample(start_time, BOTTOM);
#ifdef DEBUG__
        printf( "<  and_transducer:computer_lower_rob           OUT.\n");
#endif
        return z_low.front().value;
    };

    double and_transducer::compute_upper_rob(){
#ifdef DEBUG__
        printf( ">  and_transducer:computer_upper_rob           IN.\n");
#endif
        childL->compute_upper_rob();
        childR->compute_upper_rob();
        z_up.compute_and(childL->z_up,childR->z_up);
        z_up.resize(start_time,z_up.endTime,TOP);
        if (z_up.empty())
            z_up.appendSample(start_time,TOP);
#ifdef DEBUG__
        printf( "<  and_transducer:computer_upper_rob           OUT.\n");
#endif
        return z_up.front().value;
    };

    void and_transducer::collect_vio_epoch(vector<double>& vset, double t, double b){
        if (get_zup(t) < 0){
            if(childL->get_zup(t) < 0){
                childL->collect_vio_epoch(vset, t, b);
            }

            if(childR->get_zup(t) < 0){
                childR->collect_vio_epoch(vset, t, b);
            }
        }
    }

    void and_transducer::collect_sat_epoch(vector<double>& sset, double t, double b){
        if (get_zlow(t) > 0){
            if(childL->get_zlow(t) > 0){
                childL->collect_sat_epoch(sset, t, b);
            }

            if(childR->get_zlow(t) > 0){
                childR->collect_sat_epoch(sset, t, b);
            }
        }
    }

    double and_transducer::min_shift_vio(double t){
        //double a = - Signal::BigM;
        //double b = - Signal::BigM;
        double a = - Signal::MaxLength;
        double b = - Signal::MaxLength;
        if (childL->get_zup(t)<0 ){
            a = childL->min_shift_vio(t);
        }
        if (childR->get_zup(t)<0){
            b = childR->min_shift_vio(t);
        }
        return a>b?a:b;
    }

    double and_transducer::min_shift_sat(double t){
        //double a = Signal::BigM;
        //double b = Signal::BigM;
        double a = Signal::MaxLength;
        double b = Signal::MaxLength;
        if (childL->get_zlow(t)>0){
            a = childL->min_shift_sat(t);
        }
        if(childR->get_zlow(t)>0){
            b = childR->min_shift_sat(t);
        }
        return a<b?a:b;
    }

    double and_transducer::compute_qnmono_upper(double tau, double b){
        double x = childL->compute_qnmono_upper(tau, b);
        double y = childR->compute_qnmono_upper(tau, b);
        return x<y?x:y;
    }

    double and_transducer::compute_qnmono_lower(double tau, double b){
        double x1 = childL->compute_qnmono_lower(tau, b);
        double x2 = childR->get_zlow(tau);
        double x = x1<x2?x1:x2;
        double y1 = childL->get_zlow(tau);
        double y2 = childR->compute_qnmono_lower(tau, b);
        double y = y1<y2?y1:y2;
        return x>y?x:y;
    }

    double and_transducer::improved_qnmono_upper(double tau, double b){
        return compute_qnmono_upper(tau, b);
    }
    
    double and_transducer::improved_qnmono_lower(double tau, double b){
        return compute_qnmono_lower(tau, b);
    }
    
    double or_transducer::compute_lower_rob(){
        childL->compute_lower_rob();
        childR->compute_lower_rob();
        z_low.compute_or(childL->z_low,childR->z_low);
        z_low.resize(start_time,z_low.endTime,BOTTOM);
        if (z_low.empty())
            z_low.appendSample(start_time, BOTTOM);
        return z_low.front().value;
    };

    double or_transducer::compute_upper_rob(){
        childL->compute_upper_rob();
        childR->compute_upper_rob();
        z_up.compute_or(childL->z_up,childR->z_up);
        z_up.resize(start_time,min(childL->z_up.endTime,childR->z_up.endTime),TOP);
        if (z_up.empty())
            z_up.appendSample(start_time,TOP);
		
        return z_up.front().value;
    };

    void or_transducer::collect_vio_epoch(vector<double>& vset, double t, double b){
        if (get_zup(t) < 0){
            if(childL->get_zup(t) < 0){
                childL->collect_vio_epoch(vset, t, b);
            }

            if(childR->get_zup(t) < 0){
                childR->collect_vio_epoch(vset, t, b);
            }

        }
    }

    void or_transducer::collect_sat_epoch(vector<double>& sset, double t, double b){
        if (get_zlow(t) > 0){
            if(childL->get_zlow(t) > 0){
                childL->collect_sat_epoch(sset, t, b);
            }

            if(childR->get_zlow(t) > 0){
                childR->collect_sat_epoch(sset, t, b);
            }
        }
    }

    double or_transducer::min_shift_vio(double t){
        //double a = Signal::BigM;
        //double b = Signal::BigM;
        double a = Signal::MaxLength;
        double b = Signal::MaxLength;

        if (childL->get_zup(t)<0 ){
            a = childL->min_shift_vio(t);
        }
        if (childR->get_zup(t)<0){
            b = childR->min_shift_vio(t);
        }
//         if(get_zup(t) > -3.0646867 && get_zup(t) < -3.0646865){
//             cout<< "a: " <<a <<" b: "<<b << " t: "<< t << " childrzup: " << childR->get_zup(t) << endl;
//         }
        return a<b?a:b;
    }

    double or_transducer::min_shift_sat(double t){
        //double a = - Signal::BigM;
        //double b = - Signal::BigM;
        double a = - Signal::MaxLength;
        double b = - Signal::MaxLength;
        if (childL->get_zlow(t)>0){
            a = childL->min_shift_sat(t);
        }
        if(childR->get_zlow(t)>0){
            b = childR->min_shift_sat(t);
        }
        return a>b?a:b;
    }

    double or_transducer::compute_qnmono_upper(double tau, double b){
        double x1 = childL->compute_qnmono_upper(tau, b);
        double x2 = childR->get_zup(tau);
        double x = x1>x2?x1:x2;
        double y1 = childL->get_zup(tau);
        double y2 = childR->compute_qnmono_upper(tau, b);
        double y = y1>y2?y1:y2;
//         if(tau > 12.398 && b == 14.4){
//             cout<<"x1: "<<x1 <<" x2: "<<x2<< " y1: "<<y1 <<" y2: "<<y2<<endl;
//         }
        return x<y?x:y;

        
    }

    double or_transducer::compute_qnmono_lower(double tau, double b){
        double x = childL->compute_qnmono_lower(tau, b);
        double y = childR->compute_qnmono_lower(tau, b);
        return x>y?x:y;
    }

    double or_transducer::improved_qnmono_upper(double tau, double b){
        return compute_qnmono_upper(tau, b);
    }

    double or_transducer::improved_qnmono_lower(double tau, double b){
        return compute_qnmono_lower(tau, b);
    }

// IMPLIES transducer
    double implies_transducer::compute_lower_rob(){
        childL->compute_upper_rob();
        childR->compute_lower_rob();

        Signal z1;
        z1.compute_not(childL->z_up);
        z_low.compute_or(z1,childR->z_low);
        z_low.resize(start_time,z_low.endTime,BOTTOM);

        if (z_low.empty())
            z_low.appendSample(start_time, BOTTOM);
        return z_low.front().value;
    };

    double implies_transducer::compute_upper_rob(){
        childL->compute_lower_rob();
        childR->compute_upper_rob();

        Signal z1;
        z1.compute_not(childL->z_low);
        z_up.compute_or(z1,childR->z_up);
        
        z_up.resize(start_time,min(z1.endTime,childR->z_up.endTime),TOP);
        if (z_up.empty())
            z_up.appendSample(start_time,TOP);
        return z_up.front().value;
    };
    
    // NOT transducer: swap upper and lower
    double not_transducer::compute_upper_rob(){
        child->compute_lower_rob();
        if (child->z_low.empty()) {
            z_up.appendSample(start_time,TOP);
            return TOP;
        }
        z_up.compute_not(child->z_low);
        return z_up.front().value;
    }

    double not_transducer::compute_lower_rob(){
        child->compute_upper_rob();
        if (child->z_up.empty()) {
            z_low.appendSample(start_time,BOTTOM);
            return BOTTOM;
        }
        z_low.compute_not(child->z_up);
        return z_low.front().value;
    }

    void not_transducer::collect_vio_epoch(vector<double>& vset, double t, double b){
        child->collect_sat_epoch(vset, t, b);
    }

    void not_transducer::collect_sat_epoch(vector<double>& sset, double t, double b){
        child->collect_vio_epoch(sset, t, b);
    }

    double not_transducer::min_shift_vio(double t){
        return child->min_shift_sat(t);
    }

    double not_transducer::min_shift_sat(double t){
        return child->min_shift_vio(t);
    }

    double not_transducer::compute_qnmono_upper(double tau, double b){
        double dis = child->compute_qnmono_lower(tau, b);
        return -dis;
    }

    double not_transducer::compute_qnmono_lower(double tau, double b){
        double dis = child->compute_qnmono_upper(tau, b);
        return -dis;
    }

    double not_transducer::improved_qnmono_upper(double tau, double b){
        return compute_qnmono_upper(tau, b);
    }

    double not_transducer::improved_qnmono_lower(double tau, double b){
        return compute_qnmono_lower(tau, b);
    }

    // EVENTUALLY
    double ev_transducer::compute_lower_rob() {
        // lower robustness for a max operator. Partial information gives a lower bound for max, so we keep it. 

#ifdef DEBUG__
        printf( ">  ev_transducer:computer_lower_rob           IN.\n");
        cout << "   I->a: " << I->begin << "   I->b: " << I->end << endl;
        cout << "   start_time:" << start_time << " end_time:" << end_time << endl;
#endif

        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        child->compute_lower_rob();
        if (child->z_low.endTime < a) {
            z_low.appendSample(start_time, BOTTOM); 
            return BOTTOM;
        }
    
        z_low.compute_timed_eventually(child->z_low, a, b);
        double et =min(z_low.endTime,end_time);
        z_low.resize(start_time,max(start_time,et), 0.);

        if (z_low.empty()) 
            z_low.appendSample(start_time, BOTTOM); 

#ifdef DEBUG__
        cout << "OUT: z_low:"<< z_low << endl;
        printf( "<  ev_transducer:computer_lower_rob           OUT.\n");
#endif
        return z_low.front().value;
    }

    double ev_transducer::compute_upper_rob() {
        // upper bound on max. Partial info can always be beaten by new samples, so can't say anything. 

#ifdef DEBUG__
        printf( ">  ev_transducer:computer_upper_rob           IN.\n");
        cout << "   I->a: " << I->begin << "   I->b: " << I->end << endl;
        cout << "   start_time:" << start_time << " end_time:" << end_time << endl;
#endif

        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        child->compute_upper_rob();

        if (child->z_up.endTime < a) {
            z_up.appendSample(start_time, TOP); 
            return TOP;
        }

        z_up.compute_timed_eventually(child->z_up, a, b);

        // Here we remove values computed with partial data 
        double et =min(z_up.endTime-b+a,end_time);
        z_up.resize(start_time,et, 0.);

        if (z_up.empty()) 
            z_up.appendSample(start_time, TOP); 

#ifdef DEBUG__
        cout << "OUT: z_up:"<< z_up << endl;
        printf( "<  ev_transducer:computer_upper_rob           OUT.\n");
#endif
        return z_up.front().value;
    }

    void ev_transducer::collect_vio_epoch(vector<double>& vset, double t, double b){
        if(get_zup(t) < 0){
            for(auto i = child->z_up.begin(); i!= child->z_up.end() && (*i).time <= t + duration ; i ++){
//                 if((*i).time < t + child->start_time){
//                     continue;
//                 }
                if((*i).time < t-0.001 + I->begin){
                    continue;
                }
                if(child->get_zup((*i).time) < 0){
                    child->collect_vio_epoch(vset, (*i).time, b);
                }
            }
        }
    }

    void ev_transducer::collect_sat_epoch(vector<double>& sset, double t, double b){
        if(get_zlow(t) > 0){
            for(auto i = child->z_low.begin(); i!= child->z_low.end() && (*i).time <= t + duration; i ++){
                if((*i).time < t-0.001 + I->begin){
                    continue;
                }
                if(child->get_zlow((*i).time) > 0){
                    child->collect_sat_epoch(sset, (*i).time, b);
                }
            }

        }
    }

    double ev_transducer::min_shift_vio(double t){
        //double a = Signal::BigM;
        double a = Signal::MaxLength;
        for(auto i = child->z_up.begin(); i!=child->z_up.end() && (*i).time <= t + duration; i ++){
            if((*i).time < t-0.001 + I->begin){
                continue;
            }
            if(child->get_zup((*i).time) < 0){
                double b = child->min_shift_vio((*i).time);
                if(b<a){
                    a = b;
                }
            }
        }
        return a;
    }

    double ev_transducer::min_shift_sat(double t){
        //double a = - Signal::BigM;
        double a = - Signal::MaxLength;
        for(auto i = child->z_low.begin();i!=child->z_low.end() && (*i).time <= t + duration ;i ++){
            if((*i).time < t-0.001 + I->begin){
                continue;
            }
            if(child->get_zlow((*i).time)>0){
                double b = child->min_shift_sat((*i).time);
                if(b>a){
                    a = b;
                }
            }
        }
        return a;
    }

    double ev_transducer::compute_qnmono_upper(double tau, double b){
        //double y = get_zup(tau);
        //return y;
//         if(b == 15.4){
//             cout<<  "bran: " << (b - (tau + duration)) <<endl;
//             cout<<"zup: "<<get_zup(tau)<<endl;
// 
//         }
        if(b - 0.001 > tau + duration){ //handle numerical issue
            return Signal::BigM;
        }else{
            return get_zup(tau);
        }
    }

    double ev_transducer::compute_qnmono_lower(double tau, double b){
        double x = - Signal::BigM;
        child->z_up.simplify();

        for(auto i = child->z_low.begin(); i!=child->z_low.end();i ++){
            double y = child->compute_qnmono_lower((*i).time, b);
            if(y>x){
                x = y;
            }
        }
        return x;
    }

    double ev_transducer::improved_qnmono_upper(double tau, double b){
        return compute_qnmono_upper(tau, b);
    }

    double ev_transducer::improved_qnmono_lower(double tau, double b){
        //TODO
        double x = - Signal::BigM;
        for(auto i = child->z_low.begin(); i!=child->z_low.end();i ++){
            double t = (*i).time;
            if(t< b - child->duration){
                continue;
            }else if(t > b){
                break;
            }else{
                double y = child->compute_qnmono_lower(t, b);
                if(y>x){
                    x = y;
                }
            }
        }
        return x;
    }

    // ALWAYS
    double alw_transducer::compute_lower_rob() {
        // lower bound on a min operator. Partial info cannot help here. 

#ifdef DEBUG__
        printf( ">  alw_transducer:computer_lower_rob          IN.\n");
        cout << "   I->a: " << I->begin << "   I->b: " << I->end << endl;
        cout << "   start_time:" << start_time << " end_time:" << end_time << endl;
#endif

        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        child->compute_lower_rob();

        if (child->z_low.endTime < a) {
            z_low.appendSample(start_time,BOTTOM);        
            return BOTTOM;
        }
    
        z_low.compute_timed_globally(child->z_low, a, b);

        // Here we remove values computed with partial data 
        double et =min(z_low.endTime-b+a,end_time);
        z_low.resize(start_time,et, 0.);
	
        if (z_low.empty()) 
            z_low.appendSample(start_time,BOTTOM);        

#ifdef DEBUG__
        printf( "OUT: z_low:");
        cout << "<  alw_transducer:computer_lower_rob           OUT."<< endl;
#endif

        return z_low.front().value;
    }

    double alw_transducer::compute_upper_rob() {
#ifdef DEBUG__
        printf( ">  alw_transducer:computer_upper_rob          IN.\n");
        cout << "   I->a: " << I->begin << "   I->b: " << I->end << endl;
        cout << "   start_time:" << start_time << " end_time:" << end_time << endl;
#endif

        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        child->compute_upper_rob();
        if (child->z_up.endTime < a) {
            z_up.appendSample(start_time, TOP); 
            return TOP;
        }

        z_up.compute_timed_globally(child->z_up, a, b);
        double et =min(z_up.endTime,end_time);
        z_up.resize(start_time,max(start_time,et), 0.);

        if (z_up.empty()) 
            z_up.appendSample(start_time, TOP); 

#ifdef DEBUG__
        cout << "OUT: z_up:"<< z_up << endl;
        printf( "<  alw_transducer:computer_upper_rob          OUT.\n");
#endif
        return z_up.front().value;

    }


    void alw_transducer::collect_vio_epoch(vector<double>& vset, double t, double b){
//         if(b == 15.3){
//             cout<<"zup15.3 : "<<child->z_up <<endl;
//         }
        if(get_zup(t) < 0){ 
            for(auto i = child->z_up.begin(); i!= child->z_up.end() && (*i).time <= t + duration; i ++){
//                 if((*i).time < t + child->start_time){
//                     continue;
//                 }
                if((*i).time < t-0.001 + I->begin){
                    continue;
                }
                if(child->get_zup((*i).time)<0){
                    child->collect_vio_epoch(vset, (*i).time, b);
                }
            }
        }
    }

    void alw_transducer::collect_sat_epoch(vector<double>& sset, double t, double b){
        if(get_zlow(t) > 0){
            for(auto i = child->z_low.begin(); i!= child->z_low.end() && (*i).time <= t + duration ; i ++){
                if((*i).time < t-0.001 + I->begin){
                    continue;
                }
                if(child->get_zlow((*i).time) > 0){
                    child->collect_sat_epoch(sset, (*i).time, b);
                }
            }
        }
    }

    double alw_transducer::min_shift_vio(double t){
        //double a = - Signal::BigM;
        double a = - Signal::MaxLength;
        for(auto i = child->z_up.begin(); i!=child->z_up.end() && (*i).time <= t + duration; i ++){
            //cout<< " zup: " <<child->get_zup((*i).time) << " ";
            if((*i).time < t-0.001 + I->begin){
                continue;
            }
            if(child->get_zup((*i).time) < 0){
                double b = child->min_shift_vio((*i).time);
                //cout<< " childzup: " << child->get_zup((*i).time) <<" b " << b<<" a: "<<a <<endl;
                if(b>a){
                    a = b;
                }
            }
        }
        return a;
    }

    double alw_transducer::min_shift_sat(double t){
        //double a = Signal::BigM;
        double a = Signal::MaxLength;
        for(auto i = child->z_low.begin();i!=child->z_low.end() && (*i).time <= t + duration;i ++){
            if((*i).time < t-0.001 + I->begin){
                continue;
            }
            if(child->get_zlow((*i).time)>0){
                double b = child->min_shift_sat((*i).time);
                if(b<a){
                    a = b;
                }
            }
        }
        return a;
    }

    double alw_transducer::compute_qnmono_upper(double tau, double b){
        double x = Signal::BigM;
        child->z_up.simplify();
        
        for(auto i = child->z_up.begin();i!=child->z_up.end();i ++){
             double y = child->compute_qnmono_upper((*i).time, b);
             if(y<x){
                 x = y;
             }
//              if(b == 14.4){
//                 cout<<"b: "<< b<<endl;
//                 cout<< "t: "<<(*i).time <<  "y: "  << y<<endl;
// //                  cout << child->z_up <<endl;
// //                  cout<<"back: "<<child->z_up.back().time <<endl;
// //                  cout <<"endtime: " << child->z_up.endTime <<endl;
//              }
         }        
        
//         if(b == 15.3|| b == 15.4 || b == 15.5){
// //             cout<<"b: "<<b <<" x: "<<x <<endl;
// //         }
        return x;

    }

    double alw_transducer::compute_qnmono_lower(double tau, double b){
        //return get_zlow(tau);
        if(b - 0.001 > tau + duration){
            return -Signal::BigM;
        }else{
            return get_zlow(tau);
        }
    }

    double alw_transducer::improved_qnmono_upper(double tau, double b){
        //TODO
        double x = Signal::BigM;
        for(auto i = child->z_up.begin();i!=child->z_up.end();i ++){
            double t = (*i).time;
            if(t< b - child->duration){
                continue;
            }else if(t > b){
                break;
            }else{
                double y = child->compute_qnmono_upper(t, b);
                if(y<x){
                    x = y;
                }
            }
        }
        return x;
    }

    double alw_transducer::improved_qnmono_lower(double tau, double b){
        return compute_qnmono_lower(tau, b);
    }

    // TODO the following is a super conservative implementation - (how) can we do better ?
    double until_transducer::compute_lower_rob() {

        //	cout << "Getting into until_transducer::compute_lower_rob" << endl;
        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        if (childL->compute_lower_rob()==BOTTOM) return BOTTOM;
        if (childR->compute_lower_rob()==BOTTOM) return BOTTOM;

        z_low.compute_timed_until(childL->z_low,childR->z_low, a, b);
        double et =min(z_up.endTime,end_time);
        z_low.resize(start_time,max(start_time,et),0.);

        if (z_low.empty())
            return BOTTOM;
        else
            return z_low.front().value;

    }

    double until_transducer::compute_upper_rob() {

        double a,b;
        if (!get_param(I->begin_str,a)) a = I->begin;
        if (!get_param(I->end_str,b)) b = I->end;

        if (childL->compute_upper_rob()==TOP) return TOP;
        if (childR->compute_upper_rob()==TOP) return TOP;

        z_up.compute_timed_until(childL->z_up,childR->z_up, a, b);
        double et =min(z_up.endTime-b,end_time);
        z_up.resize(start_time,max(start_time,et),0.);

        if (z_up.empty())
            return TOP;
        else
            return z_up.front().value;
    }

}
