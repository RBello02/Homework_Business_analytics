classdef EventiFuturiManager < handle

 properties
     list
 end

 methods 
     % Constructor
     function obj = EventiFuturiManager()
         obj.list = [];

         % At the beggining, I will have an event for the clients arrivals
         ca = ClientArrival();
         ca.ClockTime = exprnd(6);
         obj.list{end+1} = ca;

         % I will have an event for the counter completion
         cc = CompletionCounter();
         cc.ClockTime = Inf;
         obj.list{end+1} = cc;

         % I will have tot events for the gas station completion as many
         % gast stations I have
         for id_gs = 1:4
            gsc = CompletionGas();
            gsc.ClockTime = Inf;
            obj.list{end+1} = gsc;
         end

     end % end constructor

     % Sorting the future events according to the one which has minor
     % completion time
     function sorted = SortFutureEvents(obj)
            tempi = cellfun(@(e) e.ClockTime, obj.list);
            [~, idx] = sort(tempi);
            sorted = obj.list(idx);
     end
 end

end