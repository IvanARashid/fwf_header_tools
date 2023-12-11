function system = fwf_ge_systems(system_ID)
% Defines the different GE systems and their limits
%
% system.name: Name of the system
% system.g_max: max gradient amplitude per amplifier [mT/m]
% system.slew_max: max slew rate per amplifier [T/m/s]
% system.rf180_duration: The duration of the 180-pulse [ms]
%
% Ivan A. Rashid
% Lund University, 8th Dec 2023
% ivan.rashid@med.lu.se

switch system_ID
    case 1
        % Signa Premier
        system.name = "Premier";
        system.g_max = 70;
        system.slew_max = 80;
        system.rf180_duration = 6.5;
    
    case 2
        % MR750, MR450
        system.name = "MR750/MR450";
        system.g_max = 50;
        system.slew_max = 50;
        system.rf180_duration = 6.7;

    case 3
        % Signa Architect, MR750w, MR450w
        system.name = "Architect/MR750w/MR450w";
        system.g_max = 31;
        system.slew_max = 50;
        system.rf180_duration = 6.7;
        
    otherwise
        error();
end