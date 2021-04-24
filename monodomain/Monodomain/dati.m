%=======================================================================================================
% This contain all the information for running main
% TEMPLATE OF THE STRUCT DATI
%=======================================================================================================
%
%  DATI= struct( 'name',              % set the name of the test  
%                'method',            % (string) e.g. 'SIP','NIP'or 'IIP'
%                'Domain',            % set the domain [x1,x2;y1,y2]
%                'exact_sol',         % set the exact solution
%                'source',            % set the forcing term
%                'grad_exact_1',      % set the first componenet of the gradient of the exact solution
%                'grad_exact_2',      % set the second componenet of the gradient of the exact solution
%                'fem',               % set finite element space (e.g.,
%                'P1', 'P2', 'P3')
%                'penalty_coeff'      % (real) penalty pearameter
%                'nqn',               % (integer) number of 1D Gauss-Ledendre quadrature nodes in 1 
%                       dimension [1,2,3,4,5,6,.....]
%                'nqn_2D',          % number of quadrature nodes for integrals over elements
%========================================================================================================

function [DATA] = dati(test)

if test=='Test1' % test evoluzione monodominio con parametri di Marco
    
DATA = struct( 'name',             test,...
               ... % Test name
               'method',           'SIP',...  
               ... % Set DG discretization
               'domain',           [0,0.4;0,0.4],...
               ... % Reaction term
                'T',              50, ...
               ... % Final time 
               'dt',            0.05, ...
               ... % Time step 
               'theta',             1, ...
               ... % Theta-method ...
               'initialcond',      '0.*x.*y', ...
               ... % Initial condition 
               'exact_sol',        '0.*x.*y.*t',...
               ... % Definition of exact solution
               'source',           '0.*x.*y.*t',...
               ... % Forcing term in time
               'Neumann',           '1000.*(abs(x-0.2)<0.01).*(y==0).*(t<=0.1)',...
               ... % Boundary condition
               'grad_exact_1',     '0.*x.*y.*t',... 
               ... % Definition of exact gradient (x comp) 
               'grad_exact_2',     '0.*x.*y.*t',...    
               ... % Definition of exact gradient (y comp)
               'ChiM',              1e5,...
               ... % Parameter monodomain equation
               'Sigma',             0.12,...
               ... % Diffusion scalar parameter
               'Cm',                1e-2,...
               ... % Membrane capacity in monodomain equation
               'kappa',             1.5*13,...
               ... % Factor for the nonlinear reaction in Fitzhug Nagumo model
               'epsilon',          0.012*100,...
               ... % Parameter ODE
               'gamma',            0.1,...
               ... % Parameter ODE
               'a',                13e-3,...
               ... % Parameter ODE 
               'initialw',         '0.*x.*y',...
               ... % Initial condition ODE
               'exact_w',          '0.*x.*y.*t',...
               ... % Exact solution of ODE 
               'fem',              'P1',...   
               ... % Finite element space (other choices 'P2', 'P3')'
               'penalty_coeff',     10,... 
               ... % Penalty coefficient
               'nqn',               4, ...
               ... % Number of 1d GL quadrature nodes
               'snapshot',          'Y',...
               ... % Snapshot of the solution
               'leap',               200 ...
               ... % Number of time steps between one snapshot and the successive
               );
elseif test=='Test2' % test per evoluzione monodominio con parametri di Marco 
DATA = struct( 'name',             test,...
               ... % Test name
               'method',           'SIP',...  
               ... % Set DG discretization
               'domain',           [0,0.4;0,0.4],...
               ... % Reaction term
                'T',               0.01, ...
               ... % Final time 
               'dt',            0.0001, ...
               ... % Time step 
               'theta',             1, ...
               ... % Theta-method ...
               'initialcond',      'sin(2*pi*x).*sin(2*pi*y)', ...
               ... % Initial condition 
               'exact_sol',        'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)',...
               ... % Definition of exact solution
               'source',           'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(-ChiM*Cm*5+8*pi^2-ChiM*kappa*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-a).*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-1)-ChiM*(epsilon/(epsilon*gamma-5)))',...
               ... % Forcing term in time
               'Neumann',           '-2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==0) + 2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==0.4) + 2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==0.4) -  2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==0)',...
               ... % Boundary condition
               'grad_exact_1',     '2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t)',... 
               ... % Definition of exact gradient (x comp) 
               'grad_exact_2',     '2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t)',...    
               ... % Definition of exact gradient (y comp)
               'ChiM',              1e5,...
               ... % Parameter monodomain equation
               'Sigma',             0.12,...
               ... % Diffusion scalar parameter
               'Cm',                1e-2,...
               ... % Membrane capacity in monodomain equation
               'kappa',             1.5*13,...
               ... % Factor for the nonlinear reaction in Fitzhug Nagumo model
               'epsilon',          0.012*100,...
               ... % Parameter ODE
               'gamma',            0.1,...
               ... % Parameter ODE
               'a',                13e-3,...
               ... % Parameter ODE 
               'initialw',         '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y)',...
               ... % Initial condition ODE
               'exact_w',          '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y).*exp((-5).*t)',...
               ... % Exact solution of ODE 
               'fem',              'P1',...   
               ... % Finite element space (other choices 'P2', 'P3')'
               'penalty_coeff',     10,... 
               ... % Penalty coefficient
               'nqn',               4, ...
               ... % Number of 1d GL quadrature nodes
               'snapshot',          'N',...
               ... % Snapshot of the solution
               'leap',               40 ...
               ... % Number of time steps between one snapshot and the successive
               );
elseif test=='Test3' % test convergenza monodominio (stabile)
DATA = struct( 'name',             test,...
               ... % Test name
               'method',           'SIP',...  
               ... % Set DG discretization
               'domain',           [0,1;0,1],...
               ... % Reaction term
                'T',               0.01, ...
               ... % Final time 
               'dt',            0.0001, ...
               ... % Time step 
               'theta',             1, ...
               ... % Theta-method ...
               'initialcond',      'sin(2*pi*x).*sin(2*pi*y)', ...
               ... % Initial condition 
               'exact_sol',        'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)',...
               ... % Definition of exact solution
               'source',           'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(-ChiM*Cm*5+sigma*8*pi^2-ChiM*kappa*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-a).*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-1)-ChiM*(epsilon/(epsilon*gamma-5)))',...
               ... % Forcing term in time
               'Neumann',           'sigma*(-2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==0) + 2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==1) + 2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==1) -  2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==0))',...
               ... % Boundary condition
               'grad_exact_1',     '2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t)',... 
               ... % Definition of exact gradient (x comp) 
               'grad_exact_2',     '2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t)',...    
               ... % Definition of exact gradient (y comp)
               'ChiM',              1,...
               ... % Parameter monodomain equation
               'Sigma',             1,...
               ... % Diffusion scalar parameter
               'Cm',                1,...
               ... % Membrane capacity in monodomain equation
               'kappa',             1.5*13,...
               ... % Factor for the nonlinear reaction in Fitzhug Nagumo model
               'epsilon',           0.012*100,...
               ... % Parameter ODE
               'gamma',             0.1,...
               ... % Parameter ODE
               'a',                13e-3,...
               ... % Parameter ODE 
               'initialw',         '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y)',...
               ... % Initial condition ODE
               'exact_w',          '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y).*exp((-5).*t)',...
               ... % Exact solution of ODE 
               'fem',              'P1',...   
               ... % Finite element space (other choices 'P2', 'P3')'
               'penalty_coeff',     10,... 
               ... % Penalty coefficient
               'nqn',               4, ...
               ... % Number of 1d GL quadrature nodes
               'snapshot',          'N',...
               ... % Snapshot of the solution
               'leap',               40 ...
               ... % Number of time steps between one snapshot and the successive
               );
elseif test=='Test4' % test convergenza monodominio (Cm = 1e-2, parametri fisiologici, instabile)
DATA = struct( 'name',             test,...
               ... % Test name
               'method',           'SIP',...  
               ... % Set DG discretization
               'domain',           [0,1;0,1],...
               ... % Reaction term
                'T',               0.01, ...
               ... % Final time 
               'dt',            0.0001, ...
               ... % Time step 
               'theta',             1, ...
               ... % Theta-method ...
               'initialcond',      'sin(2*pi*x).*sin(2*pi*y)', ...
               ... % Initial condition 
               'exact_sol',        'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)',...
               ... % Definition of exact solution
               'source',           'sin(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(-ChiM*Cm*5+sigma*8*pi^2-ChiM*kappa*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-a).*(sin(2*pi*x).*sin(2*pi*y).*exp(-5*t)-1)-ChiM*(epsilon/(epsilon*gamma-5)))',...
               ... % Forcing term in time
               'Neumann',           'sigma*(-2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==0) + 2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==1) + 2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t).*(y==1) -  2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t).*(x==0))',...
               ... % Boundary condition
               'grad_exact_1',     '2*pi*cos(2*pi*x).*sin(2*pi*y).*exp(-5*t)',... 
               ... % Definition of exact gradient (x comp) 
               'grad_exact_2',     '2*pi*sin(2*pi*x).*cos(2*pi*y).*exp(-5*t)',...    
               ... % Definition of exact gradient (y comp)
               'ChiM',              1,...
               ... % Parameter monodomain equation
               'Sigma',             1,...
               ... % Diffusion scalar parameter
               'Cm',                1e-2,...
               ... % Membrane capacity in monodomain equation
               'kappa',             1.5*13,...
               ... % Factor for the nonlinear reaction in Fitzhug Nagumo model
               'epsilon',           0.012*100,...
               ... % Parameter ODE
               'gamma',             0.1,...
               ... % Parameter ODE
               'a',                13e-3,...
               ... % Parameter ODE 
               'initialw',         '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y)',...
               ... % Initial condition ODE
               'exact_w',          '(epsilon/(epsilon*gamma-5))*sin(2*pi*x).*sin(2*pi*y).*exp((-5).*t)',...
               ... % Exact solution of ODE 
               'fem',              'P1',...   
               ... % Finite element space (other choices 'P2', 'P3')'
               'penalty_coeff',     10,... 
               ... % Penalty coefficient
               'nqn',               4, ...
               ... % Number of 1d GL quadrature nodes
               'snapshot',          'N',...
               ... % Snapshot of the solution
               'leap',               40 ...
               ... % Number of time steps between one snapshot and the successive
               );          
end
