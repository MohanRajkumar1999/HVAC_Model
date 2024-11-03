%%HVAC Parameter
%%% Environmental Temperature

%Tamb = 20; %Degree C

%Cabin 
M_a = 3.185; %Kg % Mass of air(Volume of cabin * Air density = 2.6*1.225
m_a = 0.4; %(Kg/m^3)Mass flow rate of AC/Heater 
c = 1350; %Specific heat capacity of air 
Tc = 23; %Required cabin temperature

%%Coefficient of performance
HCOP = 1; %Heater
ACCOP = 2.4; %AC

%Vehicle 
Av = 7.87; %Area of the vehicle without glass
R_solar = 0; %Solar Radiation
A_w = 1.73; %Area of glass in the vehicle
Trans = 0.4; %Surface element transmissivity
n = 1; %No of passengers and the driver
Height = 1.6; %%Average height of passengers
Weight = 70; %Average weight of passengers
AMH = 55; %Average metabolic load
m = 0.035; %mass flowrate of ventilation


%%Importing convective heat transfer coefficient 
data = readmatrix("BTC.xls");
%Segregating velocity data
h_v = data(1,2:7);
%Segregating convective heat transfer coefficient 
h_c = data(2,2:7);% Wh/mile


%%Importing the drive cycle data
Drive_Cycle =  readmatrix("DCData.csv");

Tsim = 1400; %Drive Cycle distance
Distance = 5.303; %km

%%Powertrain energy per km 
E_powertrain = readmatrix("EVPowertrainEnergyperkm-210430-095645.xlsx");

%%Importing nissan test data
values = readmatrix("Nissan leaf test data.xlsx");
NLT_E = values(:,2);%%Segregating nissan leaf Energy test data
NLT_tem_f = values(:,1); %%Segregating nissan leaf temperature test data


% Function to convert a series of Fahrenheit values to Celsius
% Convert to Celsius using the function
NLT_tem_c = fahrenheitToCelsius(NLT_tem_f);

%Creating an empty variables to store energy and error
Energy_Model = [];
error = [];

for i = 1:length(NLT_tem_c)
    Tamb = NLT_tem_c(i);
    Ti = NLT_tem_c(i);
    %Executing the simulation
    out = sim("HVAC.slx",Tsim);
    
    %Storing total energy wrt to model
    Energy_Model(i) = (out.HVAC_Energy.Data(end)+out.Powertrain_Energy.Data(end))*1.60934;
    
    %Calculating wrt to each and every test case the perentage of difference
    error(i) = abs(Energy_Model(i)- NLT_E(i))/NLT_E(i);
    
end

%Average error wrt to model & test data\
Avg_error = (sum(error)/length(error))*100; 
disp('Average error percentage');
disp(Avg_error);

%Plotting test data and the model data
scatter(NLT_tem_c,NLT_E,'red','*')
hold on
scatter(NLT_tem_c,Energy_Model,'Blue','*')
legend('Test data','Model data')
xlabel('Average temperature(C)')
ylabel("Energy consumed per mile(Wh/mile)")


% Function to convert a series of Fahrenheit values to Celsius
function NLT_tem_c = fahrenheitToCelsius(NLT_tem_f)
    % Convert Fahrenheit to Celsius using the formula
    NLT_tem_c = (NLT_tem_f - 32) * 5 / 9;
end

