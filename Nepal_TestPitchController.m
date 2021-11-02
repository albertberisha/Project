% -----------------------------
% Script: Test Pitch Controller at different Operation Points
% Exercise 03 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% - Design Gain Scheduling in NREL5MWDefaultParameter_FBNREL_Ex3.m 
% - Update NREL5MW_FBNREL_SLOW1DOF_Ex3.mdl with PI controller
% ------------
% History:
% v01:	David Schlipf on 06-Oct-2019
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = NepalDefaultParameter_SLOW1DOF;
Parameter                       = NepalDefaultParameter_FBNREL_Ex3(Parameter);

% Time
dt                                          = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax         = 60;   % [s] simulation lenght

%% Loop over Operation Points

OPs = [12 16 20 24];
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time                  = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;   0.1; 0.1]+OP;    % [m/s]    wind speeds


    Parameter.IC.Omega          = Parameter.CPC.Omega_g_rated*Parameter.Turbine.i ; % interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1([12 16 20 24],[0.07583 0.213546 0.306793 0.39156],OP,'linear','extrap');

    % Noise
    f   = 50;
    a   = rpm2radPs(10);
    Disturbance.noise.time                	= [0:Parameter.Time.dt:Parameter.Time.TMax]';                
    Disturbance.noise.signals.values     	= a*sin(2*pi*f*Disturbance.noise.time); 

    % Initial Conditions from SteadyStates

%%% Parameter.IC.x_T                = interp1([12 16 20 24],SteadyStates.x_T ,OP,'linear','extrap');      %?????
%%
adsdas

    % Processing SLOW for this OP
    sim('Nepal_FBNREL_SLOW1DOF_Ex3.mdl')
    
    % collect simulation Data
    Omega(:,iOP) = logsout.get('y').Values.Omega.Data;

    
end


%% PostProcessing SLOW
figure


hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))
xlabel('time [s]')



