classdef Node < handle
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        coda
        policy_coda
        servers
        numero_servers
        distribuzione_arrivi % distribuzione probabilistica degli arrivi esterni dal sistema
        distribuzione_servizi % questo sarà un vettore (eventualmente con tutte le componenti uguali)
    end
    
    methods
        function obj = Node(id, pol_coda , distr_arrivi, distr_servizi)
            %NODE Construct an instance of this class
            %   Detailed explanation goes here
            obj.id = id;
            obj.policy_coda = pol_coda;
            obj.distribuzione_arrivi = distr_arrivi;
            obj.distribuzione_servizi = distr_servizi;
            obj.coda = [];
            obj.numero_servers = size(distr_servizi,2);
            obj.servers = cell(1, obj.numero_servers);

            for i = 1:obj.numero_servers
                obj.servers{i} = Server();
            end
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

