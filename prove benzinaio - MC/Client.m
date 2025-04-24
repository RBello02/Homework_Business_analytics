classdef Client < handle
% This class allows me to have all the info of a client toghether (sort of a struct)

properties
    id_GasStation
    SidePreference
    when_he_got_in_the_line
end

methods
    % Constructor
    function obj = Client()
        obj.id_GasStation = NaN;
        obj.SidePreference = NaN;
        obj.when_he_got_in_the_line = NaN;
    end
end
end