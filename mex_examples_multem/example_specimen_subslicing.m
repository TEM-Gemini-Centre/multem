% Copyright 2021 Ivan Lobato <Ivanlh20@gmail.com>

clear; clc;
addpath([fileparts(pwd) filesep 'mex_bin'])
addpath([fileparts(pwd) filesep 'crystalline_materials'])
addpath([fileparts(pwd) filesep 'matlab_functions'])

input_multem = multem_input.parameters;         % Load default values;

input_multem.pn_model = 1;                  % ePM_Still_Atom = 1, ePM_Absorptive = 2, ePM_Frozen_Phonon = 3
input_multem.interaction_model = 1;             % eESIM_Multislice = 1, eESIM_Phase_Object = 2, eESIM_Weak_Phase_Object = 3
input_multem.potential_slicing = 3;             % ePS_Planes = 1, ePS_dz_Proj = 2, ePS_dz_Sub = 3, ePS_Auto = 4
input_multem.pn_dim = 110; 
input_multem.pn_seed = 300183; 
input_multem.pn_nconf = 1;

input_multem.spec_rot_theta = 0;                     % final angle
input_multem.spec_rot_u0 = [0 1 1]; 					% unitary vector			
input_multem.spec_rot_center_type = 1; 			% 1: geometric center, 2: User define		
input_multem.spec_rot_center_p = [0 0 0];					% rotation point

input_multem.spec_lx = 10;
input_multem.spec_ly = 10;
input_multem.spec_lz = 10;
input_multem.spec_dz = 0.5;

occ = 1;
region = 0;
charge = 0;
input_multem.spec_atoms = [29, 2, 2, 0.0, 0.8, 1.0, charge; 29, 6, 2, 0.0, 0.8, 1.0, charge];
[input_multem.spec_atoms, input_multem.spec_lx, input_multem.spec_ly, lz] = graphene(1, 1.42, sqrt(0.5/(8*pi^2)));
input_multem.spec_dz = 0.5;

% get spec slicing
tic;
input_multem.pn_model = 1;
[atoms0, Slice0] = ilc_spec_slicing(input_multem.toStruct);
toc;

[nslice0, ~] = size(Slice0);

tic;
input_multem.pn_model = 3;
[atoms, Slice] = ilc_spec_slicing(input_multem.toStruct);
toc;

[nslice, ~] = size(Slice);

figure(1); clf;
plot(atoms(:, 2), atoms(:, 4), '*k');   
set(gca,'FontSize',12,'LineWidth',1,'PlotBoxAspectRatio',[1.25 1 1]);
title('Atomic positions');
ylabel('y','FontSize',14);
xlabel('x','FontSize',12);
axis equal;
axis([-2 input_multem.spec_lx+2 -5 input_multem.spec_lz + 5]);


for i = 1:nslice
    hold on;
    plot([-2 18], [Slice(i, 1) Slice(i, 1)], '-b', [-2 18], [Slice(i, 2) Slice(i, 2)], '-b');    
    axis equal;
    axis([-2 input_multem.spec_lx+2 -5 input_multem.spec_lz + 5]);
end

for i = 1:nslice0
    hold on;
    plot([-2 input_multem.spec_lx+2], [Slice0(i, 1) Slice0(i, 1)], '-r', [-2 input_multem.spec_lx+2], [Slice0(i, 2) Slice0(i, 2)], '-r');    
    axis equal;
    axis([-2 input_multem.spec_lx+2 -5 input_multem.spec_lz + 5]);
end