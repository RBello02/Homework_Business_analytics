classdef Queue < handle
% I am going to model a FIFO queue because it is the one I need

properties 
    clients
end

methods
    % Constructor
    function obj = Queue()
        obj.clients = [];
    end

    % Enqueueing a client
    function EnqueueingClient(obj, clock)
        c = Client();
        c.when_he_got_in_the_line = clock;
        obj.clients{end+1} = c;
    end

    % Dequeueing a client
    function client = DequeueingClient(obj)
        client = obj.clients(1);
        obj.clients(1) = [];
    end

    % Clearing the queue
    function obj = ClearState(obj)
        obj.clients = [];
    end

    % Getting the length of the line
    function len = GetLenght(obj)
        len = length(obj.clients);
    end
end


end