classdef SimulationManager < handle
 % In this class I am going to manage all the aspects linked to simulation

 properties (SetAccess = protected, GetAccess = protected)
     myStatManager
     myGasStation
     myQueueGS
     myCounter 
     myQueueC
     myFutureEvents
     rate_arrivals
 end

 methods
     % Constructor
     function obj = SimulationManager(StatManager, GasStation, Counter, QueueGS, QueueC)
         obj.myStatManager = StatManager;
         obj.myGasStation = GasStation;
         obj.myQueueGS = QueueGS; 
         obj.myCounter = Counter;
         obj.myQueueC = QueueC;
     end

     % Running a simulation
     function statistics = SimulateTheSystem(obj, TIMEORIZON, rate_arrivals) 
         obj.rate_arrivals = rate_arrivals;

        % initializing the clock simulation and the future events
        clock = 0;
        obj.myFutureEvents = EventiFuturiManager();

        % sorting the future events in ascending order
        obj.myFutureEvents.list = obj.myFutureEvents.SortFutureEvents();
        clock = clock + obj.myFutureEvents.list{1}.ClockTime;

        while clock < TIMEORIZON

            % Processing the event
            obj.myFutureEvents.list{1}.ProcessingEvent(obj, clock);

            % Trying to process the clients
            if obj.myQueueC.GetLenght() >= 1
                obj.myCounter.ProcessingClient_Counter(clock, obj);
            end

            if obj.myQueueGS.GetLenght() >= 1
                obj.myGasStation.ProcessingClient_GS(clock, obj);
            end

        end

     end
     
 end
end