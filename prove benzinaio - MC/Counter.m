classdef Counter < handle
 % This class describes the counter

 properties 
     isBusy
     LBUnifDistribution
     UBUnifDistribution
 end 

 methods 
     % Constructor
     function obj = Counter(lb, ub)
        obj.isBusy = False;
        obj.LBUnifDistribution = lb;
        obj.UBUnifDistribution = ub;
     end

     % Processing a client
     function ProcessingClient_Counter(obj, clock, SimManager)
         if not(obj.isBusy)
             obj.isBusy = 1;
             CompletionTime = clock + obj.LBUnifDistribution + (obj.UBUnifDistribution - obj.LBUnifDistribution)*rand(1);
             SimManager.myFutureEvents{3}.ClockTime = CompletionTime;
         end
     end

 end

end