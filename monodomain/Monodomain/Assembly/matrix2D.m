function [Matrices]= matrix2D(femregion,neighbour,Data,t)
%% [Matrices]= matrix2D(femregion,neighbour,Dati)
%==========================================================================
% Assembly of the stiffness matrix A and rhs f
%==========================================================================
%    called in main2D.m
%
%    INPUT:
%          Dati        : (struct)  see dati.m
%          femregion   : (struct)  see create_dof.m
%          neighbour   : (struct)  see neighbours.m
%    OUTPUT:
%          Matrices    : (struct)  stiffnes matrix A, load vector f and
%          mass matrix

addpath FESpace
addpath Assembly

fprintf('============================================================\n')
fprintf('--------Begin computing matrix for %s\n',Data.method);
fprintf('============================================================\n')

% shape functions
[shape_basis] = basis_lagrange(femregion.fem);

% quadrature nodes and weights for integrals
[nodes_1D, w_1D, nodes_2D, w_2D] = quadrature(Data.nqn);
nqn_1D = length(w_1D);

% evaluation of shape functions on quadrature poiint
[dphiq, Grad, B_edge, G_edge] = evalshape(shape_basis,nodes_2D,nodes_1D,femregion.nln);

% definition of penalty coefficient (note that is scaled only
% wrt the polynomial degree
penalty_coeff=Data.penalty_coeff.*(femregion.degree.^2);



% Assembly begin ...
V=sparse(femregion.ndof,femregion.ndof);  % \int_{\Omega} (grad(u) grad(v) dx
I=sparse(femregion.ndof,femregion.ndof);  % \int_{E_h} {grad v} . [u] ds
S=sparse(femregion.ndof,femregion.ndof);  % \int_{E_h} penalty  h_e^(-1) [v].[u] ds
f=sparse(femregion.ndof,1);               % \int_{\Omega} f . v dx + boundary conditions
M=sparse(femregion.ndof,femregion.ndof);  % \inr_{\Omega}

% Define parameters in order to evaluate the forcing term
a = Data.a;         
ChiM=Data.ChiM;
Cm=Data.Cm;
kappa=Data.kappa;
epsilon=Data.epsilon;
gamma=Data.gamma;
sigma = Data.Sigma;


% loop over elements
for ie = 1:femregion.ne
    
    % Local to global map --> To be used in the assembly phase
    index = (ie-1)*femregion.nln*ones(femregion.nln,1) + [1:femregion.nln]';
    
    % Index of the current edges
    index_element = femregion.nedges*(ie-1).*ones(femregion.nedges,1) + [1:1:femregion.nedges]';
    
    % Find neighbouring elements (through structure nieghbour)
    neigh_ie = neighbour.neigh(ie,:);
    neighedges_ie = neighbour.neighedges(ie,:);
    
    % Coordinates of the verteces of the current triangle
    coords_elem = femregion.coords_element(index_element, :);
    
    % BJ        = Jacobian of the elemental map
    % BJinv     = Inverse Jacobian of the elemental map
    % pphys_2D = vertex coordinates in the physical domain
    [BJ, BJinv, pphys_2D] = get_jacobian_physical_points(coords_elem, nodes_2D);
    
    % quadrature nodes on the edges (physical coordinates)
    [pphys_1D] = get_physical_points_faces(coords_elem, nodes_1D);
    
    % compute normals to the edges
    [normals,meshsize] = get_normals_meshsize_faces(coords_elem);
    
    % =====================================================================
    % Compute integrals over triangles
    % =====================================================================
    for k = 1:length(w_2D) % loop over 2D quadrature nodes
        
        % scaled weight for the quadrature formula
        dx = w_2D(k)*det(BJ);
 
        % evaluation of the load term       
        x = pphys_2D(k,1);
        y = pphys_2D(k,2);
     
        F = eval(Data.source);
       
        for i = 1 : femregion.nln
            % assembly load vector
            f(index(i)) = f(index(i)) + F*dphiq(1,k,i).*dx;
            
            for j = 1 : femregion.nln
                % assembly stiffness matrix
                V(index(i),index(j)) = V(index(i),index(j)) ...
                    + sigma*((Grad(k,:,i) * BJinv) * (Grad(k,:,j) * BJinv )') .*dx ;
                % assembly mass matrix---> is it right?
                M(index(i),index(j)) = M(index(i),index(j)) ...
                    + (dphiq(1,k,i))'*(dphiq(1,k,j))'.*dx;
            end
        end
    end
    
    % =====================================================================
    % Compute integrals over edges
    % =====================================================================
    IB=sparse(femregion.ndof,femregion.ndof);
    IN = zeros(femregion.nln,femregion.nln,neighbour.nedges);
    SN = zeros(femregion.nln,femregion.nln,neighbour.nedges);
    
    for iedg = 1 : neighbour.nedges % Loop over the triangle's  edges
        
        
        % index of neighbour edge
        neigedge = neighedges_ie(iedg);    
        
        % scaling of the penalty coefficient wrt the mesh size
        penalty_scaled = penalty_coeff./meshsize(iedg); 
        
        
        % assembly of interface matrices 
        for k = 1:nqn_1D   % loop over 1D quadrature nodes
            
            % scaled weight for the quadrature formula
            ds = meshsize(iedg)*w_1D(k);
            kk = nqn_1D+1-k;  % index of neighbouring quad point
            
            for i = 1:femregion.nln % loop over local dof              
                for j = 1 : femregion.nln % loop over local dof
                    % Internal faces                
                    if neigh_ie(iedg) ~= -1 
                        % S --> \int_{E_h} penalty  h_e^(-1) [v].[u] ds
                        S(index(i),index(j)) = S(index(i),index(j)) ...
                                        + penalty_scaled .* B_edge(i,k,iedg) .* B_edge(j,k,iedg) .* ds;
                        
                        % I --> \int_{E_h} {grad v} . [u] ds
                        I(index(i),index(j)) = I(index(i),index(j)) ...
                                        +  sigma*0.5 .* ((G_edge(k,:,i,iedg)*BJinv)*normals(:,iedg)) .* B_edge(j,k,iedg) .* ds;
                        
                        % IN --> I for Neighbouring elements
                        % IN --> I for Neighbouring elements
                        IN(i,j,iedg) = IN(i,j,iedg) ...
                                   - sigma* 0.5 .* ((G_edge(k,:,i,iedg)*BJinv)*normals(:,iedg)) .* B_edge(j,kk,neigedge) .* ds;
                        SN(i,j,iedg) = SN(i,j,iedg) ...
                                   - penalty_scaled .* B_edge(i,k,iedg) .* B_edge(j,kk,neigedge) .* ds;
                               
                    % Boundary faces   
                    elseif neigh_ie(iedg) == -1 
%                         %
%                         IB(index(i),index(j))  = IB(index(i),index(j)) ...
%                                    +  ((G_edge(k,:,i,iedg)*BJinv)*normals(:,iedg)) .* B_edge(j,k,iedg) .* ds;
                    end
                end
                
                
                if  neigh_ie(iedg) == -1 % Update the forcing term with boundary conditions
                    x=pphys_1D(k,1,iedg);
                    y=pphys_1D(k,2,iedg);
                    g=eval(Data.Neumann);
                    f(index(i)) = f(index(i)) + B_edge(i,k,iedg) .* g .* ds ;
                end
            end
        end
    end
    
    % Assembly phase
    [I] = assemble_neigh(I,index,neigh_ie,IN,femregion.nln,neighbour.nedges);
    [S] = assemble_neigh(S,index,neigh_ie,SN,femregion.nln,neighbour.nedges); 
end

fprintf('--------End computing matrix for %s \n',Data.method);

if(Data.method == 'SIP')
    teta = -1;
elseif(Data.method == 'NIP')
    teta = 1;
else
    teta = 0;
end

Matrices=struct('A',V -transpose(I) + teta*I +sigma git * S, 'f',f, 'S',S, 'M', M);



