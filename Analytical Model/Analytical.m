% Define constants
Height_p = 5E-3;
Height_n = 5E-3;
Length_p = 5E-3;
Width_p = 5E-3;
Length_n = 5E-3;
Width_n = 5E-3;
Area_p = Length_p * Width_p;
Area_n = Length_n * Width_n;
Qc = 1;
SMP = 160E-6;
SMN = -160E-6;

RP = 1 / ((1.5E3) / 10^-2);
RN = 1 / ((1.5E3) / 10^-2);
KP = 1.5;
KN = 1.5;
h_air = 25000*(2E-4); % Update variable name to avoid conflict
ambient = 293.15;

% Define a range of current values
current_values = [0,5,10,15,20,25,30,35,40];

% Calculate SM, RM, and KM based on the new temperature values
SM = (SMP - SMN);
RM = (RP * Height_p / Area_p) + (RN * Height_n / Area_n);
KM = (KP * Area_p / Height_p) + (KN * Area_n / Height_n);

% Initialize arrays to store Tc and Th for each current value
Tc_values = zeros(size(current_values));
Th_values = zeros(size(current_values));

% Define a table to store I, Th, and Tc
IThTc_table = table(current_values', Th_values', Tc_values', 'VariableNames', {'I', 'Th', 'Tc'});

% Initialize initial_guess and options
initial_guess = [300, 310]; % Initial guess for Tc and Th
options = optimoptions('fsolve', 'Display', 'off');

% Loop through different current values
for i = 1:length(current_values)
    I = current_values(i); % Update the current value

    % Create a function that defines the equations for Qc and Qh
    eq1 = @(x) (SM * I * x(1) - 0.5 * I^2 * RM - KM * (x(2) - x(1))) - Qc;
    eq2 = @(x) (SM * I * x(2) + 0.5 * I^2 * RM - KM * (x(2) - x(1))) - h_air * (x(2) - ambient);

    % Use fsolve to solve the system of equations
    solution = fsolve(@(x) [eq1(x); eq2(x)], initial_guess, options);

    % Extract the values of Tc and Th from the solution
    Tc = solution(1);
    Th = solution(2);

    % Update the table
    IThTc_table{i, 'Th'} = Th;
    IThTc_table{i, 'Tc'} = Tc;

    % Update initial_guess for the next iteration
    initial_guess = solution;
end

% Display the table
disp('I, Th, and Tc Table:');
disp('-----------------------');
fprintf('%-5s %-15s %-15s\n', 'I', 'Th', 'Tc');
disp('-----------------------');

for i = 1:length(current_values)
    fprintf('%-5d %-15.8f %-15.8f\n', current_values(i), IThTc_table{i, 'Th'}, IThTc_table{i, 'Tc'});
end
disp('-----------------------');

% Write the table to a CSV file for Excel
writetable(IThTc_table, 'IThTc_table.csv');
disp('Data has been written to IThTc_table.csv for Excel.');
