classdef LimitedCapacity_Queue < Queue
 
properties 
    MaxCapacity
end

methods
% Constructor
    function obj = LimitedCapacity_Queue(MaxCapacity)
        obj.MaxCapacity = MaxCapacity;
        obj.clients = [];
    end

    % Enqueueing a client
    function EnqueueingClient(obj, clock)
        if length(obj.clients) < obj.MaxCapacity
            c = Client();
            c.when_he_got_in_the_line = clock;
            obj.clients(end+1) = c;
        end
    end

end
end