% output_multislice = input_multem.ilc_multem perform TEM simulation
% Convergent beam electron diffraction (CBED) simulation
% All parameters of the input_multem structure are explained in ilm_dflt_input_multem()
% Copyright 2021 Ivan Lobato <Ivanlh20@gmail.com>

clear; clc;
addpath([fileparts(pwd) filesep 'mex_bin'])
addpath([fileparts(pwd) filesep 'crystalline_materials'])
addpath([fileparts(pwd) filesep 'matlab_functions'])

%%%%%%%%%%%%%%%%%% Load multem default parameter %%%%%%%%$$%%%%%%%%%
input_multem = multem_input.parameters;          % Load default values;

%%%%%%%%%%%%%%%%%%%%% Set system configuration %%%%%%%%%%%%%%%%%%%%%
input_multem.system_conf.precision = 1;                           % eP_Float = 1, eP_double = 2
input_multem.system_conf.device = 2;                              % eD_CPU = 1, eD_GPU = 2
input_multem.system_conf.cpu_nthread = 1;
input_multem.system_conf.gpu_device = 0;

%%%%%%%%%%%%%%%%%%%% Set simulation experiment %%%%%%%%%%%%%%%%%%%%%
% eTEMST_STEM=11, eTEMST_ISTEM=12, eTEMST_CBED=21, eTEMST_CBEI=22, eTEMST_ED=31, eTEMST_HRTEM=32, eTEMST_PED=41, eTEMST_HCTEM=42, eTEMST_EWFS=51, eTEMST_EWRS=52,
% eTEMST_EELS=61, eTEMST_EFTEM=62, eTEMST_ProbeFS=71, eTEMST_ProbeRS=72, eTEMST_PPFS=81, eTEMST_PPRS=82,eTEMST_TFFS=91, eTEMST_TFRS=92
input_multem.simulation_type = 21;

%%%%%%%%%%%%%% Electron-Specimen interaction model %%%%%%%%%%%%%%%%%
input_multem.interaction_model = 1;              % eESIM_Multislice = 1, eESIM_Phase_Object = 2, eESIM_Weak_Phase_Object = 3
input_multem.potential_type = 6;                 % ePT_Doyle_0_4 = 1, ePT_Peng_0_4 = 2, ePT_Peng_0_12 = 3, ePT_Kirkland_0_12 = 4, ePT_Weickenmeier_0_12 = 5, ePT_Lobato_0_12 = 6

%%%%%%%%%%%%%%%%%%%%%%% Potential slicing %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.potential_slicing = 1;              % ePS_Planes = 1, ePS_dz_Proj = 2, ePS_dz_Sub = 3, ePS_Auto = 4

%%%%%%%%%%%%%%% Electron-Phonon interaction model %%%%%%%%%%%%%%%%%%
input_multem.pn_model = 3;                       % ePM_Still_Atom = 1, ePM_Absorptive = 2, ePM_Frozen_Phonon = 3
input_multem.pn_coh_contrib = 0;
input_multem.pn_single_conf = 0;                 % 1: true, 0:false (extract single configuration)
input_multem.pn_nconf = 10;                      % true: specific phonon configuration, false: number of frozen phonon configurations
input_multem.pn_dim = 110;                       % phonon dimensions (xyz)
input_multem.pn_seed = 300183;                   % Random seed(frozen phonon)

%%%%%%%%%%%%%%%%%%%%%%% Specimen information %%%%%%%%%%%%%%%%%%%%%%%
na = 8; nb = 8; nc = 40; ncu = 2; rmsd_3d = 0.085;

[input_multem.spec_atoms, input_multem.spec_lx...
, input_multem.spec_ly, input_multem.spec_lz...
, a, b, c, input_multem.spec_dz] = Si001_xtl(na, nb, nc, ncu, rmsd_3d);

%%%%%%%%%%%%%%%%%%%%%% Specimen thickness %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.thick_type = 1;                     % eTT_Whole_Spec = 1, eTT_Through_Thick = 2, eTT_Through_Slices = 3
input_multem.thick = 0;   % Array of thickes (�)

%%%%%%%%%%%%%%%%%%%%%% x-y sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.nx = 1024;
input_multem.ny = 1024;
input_multem.bwl = 0;                            % Band-width limit, 1: true, 0:false

%%%%%%%%%%%%%%%%%%%% Microscope parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.E_0 = 100;                          % Acceleration Voltage (keV)
input_multem.theta = 0.0;                        % Till ilumination (�)
input_multem.phi = 0.0;                          % Till ilumination (�)

%%%%%%%%%%%%%%%%%%%%%% Illumination model %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.illumination_model = 4;             % 1: coherente mode, 4: Numerical integration
input_multem.temporal_spatial_incoh = 1;         % 1: Temporal and Spatial, 2: Temporal, 3: Spatial

%%%%%%%%%%%%%%%%%%%%%%%%%%% Incident wave %%%%%%%%%%%%%%%%%%%%%%%%%%
input_multem.iw_type = 4;                        % 1: Plane_Wave, 2: Convergent_wave, 3:User_Define, 4: auto
input_multem.iw_psi = read_psi_0_multem(input_multem.nx, input_multem.ny);    % user define incident wave
input_multem.iw_x = input_multem.spec_lx/2;  % x position
input_multem.iw_y = input_multem.spec_ly/2;  % y position

%%%%%%%%%%%%%%%%%%%%%%%% condenser lens %%%%%%%%%%%%%%%%%%%%%%%%
input_multem.cond_lens_m = 0;                   % Vortex momentum
input_multem.cond_lens_c_10 = 1110;             % Defocus (�)
input_multem.cond_lens_c_30 = 3.3;              % Third order spherical aberration (mm)
input_multem.cond_lens_c_50 = 0.00;             % Fifth order spherical aberration (mm)
input_multem.cond_lens_c_12 = 0.0;              % Twofold astigmatism (�)
input_multem.cond_lens_phi_12 = 0.0;            % Azimuthal angle of the twofold astigmatism (�)
input_multem.cond_lens_c_23 = 0.0;              % Threefold astigmatism (�)
input_multem.cond_lens_phi_23 = 0.0;            % Azimuthal angle of the threefold astigmatism (�)
input_multem.cond_lens_inner_aper_ang = 0.0;    % Inner aperture (mrad)
input_multem.cond_lens_outer_aper_ang = 7.50;   % Outer aperture (mrad)

%%%%%%%%% defocus spread function %%%%%%%%%%%%
dsf_sigma = ilc_iehwgd_2_sigma(32); % from defocus spread to standard deviation
input_multem.cond_lens_ti_a = 1.0;                          % Height proportion of a normalized Gaussian [0, 1]
input_multem.cond_lens_ti_sigma = dsf_sigma;                % Standard deviation of the defocus spread for the Gaussian component (�)
input_multem.cond_lens_ti_beta = 0.0;                 		% Standard deviation of the defocus spread for the Exponential component (�)
input_multem.cond_lens_ti_npts = 4;                         % Number of integration points. It will be only used if illumination_model=4

%%%%%%%%%% source spread function %%%%%%%%%%%%
ssf_sigma = ilc_hwhm_2_sigma(0.45); % half width at half maximum to standard deviation
input_multem.cond_lens_si_a = 1.0;                          % Height proportion of a normalized Gaussian [0, 1]
input_multem.cond_lens_si_sigma = ssf_sigma;                % Standard deviation of the source spread function for the Gaussian component: For parallel ilumination(�^-1); otherwise (�)
input_multem.cond_lens_si_beta = 0.0;                 		% Standard deviation of the source spread function for the Exponential component: For parallel ilumination(�^-1); otherwise (�)
input_multem.cond_lens_si_rad_npts = 4;                     % Number of radial integration points. It will be only used if illumination_model=4
input_multem.cond_lens_si_azm_npts = 4;                     % Number of radial integration points. It will be only used if illumination_model=4

%%%%%%%%% zero defocus reference %%%%%%%%%%%%
input_multem.cond_lens_zero_defocus_type = 4;   % eZDT_First = 1, eZDT_User_Define = 4
input_multem.cond_lens_zero_defocus_plane = 0;

clear ilc_multem;
tic;
output_multislice = input_multem.ilc_multem;
toc;

c = 1e5;
figure(1); clf;
for i=1:length(output_multislice.data)
    m2psi_tot = output_multislice.data(i).m2psi_tot;
    m2psi_tot = log(1+c*m2psi_tot/max(m2psi_tot(:)));

    I_min = min(m2psi_tot(:));
    I_max = max(m2psi_tot(:));

    imagesc(output_multislice.x, output_multislice.y, m2psi_tot, [I_min I_max]);
    title(strcat('Total intensity -  Thick = ', num2str(output_multislice.thick(i))));
    axis image;
    colormap hot;
    pause(0.5);
end