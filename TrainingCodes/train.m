format compact;
addpath('utilities');

sigmas = 2:2:50;
numSigma = length(sigmas);
%%%-------------------------------------------------------------------------
%%% Generate patches
%%%-------------------------------------------------------------------------
imdb = generatepatches;

for i = 1 : numSigma
    sigma = sigmas(i);
    %%%-------------------------------------------------------------------------
    %%% Configuration
    %%%-------------------------------------------------------------------------
    opts.modelName        = 'dilatedDCNN'; %%% model name
    opts.learningRate     = [logspace(-3,-3,50)];%%% you can change the learning rate
    opts.batchSize        = 128;
    opts.gpus             = [1]; %%% this code can only support one GPU!
    opts.numEpochs = numel(opts.learningRate);
    %%% solver
    opts.solver           = 'Adam';
    opts.expDir      = fullfile('Train', ['sigma_', num2str(sigma)]);
    opts.gradientClipping = false; %%% set 'true' to prevent exploding gradients in the beginning.
    %%% stopping criteria
    opts.tolerance = 5e-5;
    opts.toltEpochs = 5;
    %%%-------------------------------------------------------------------------
    %%%   Initialize model and load data
    %%%-------------------------------------------------------------------------
    %%%  model
    if i == 1
        net  = feval('dilatedDCNN_init');
    else
        modelPath = fullfile(preExpDir, sprintf([opts.modelName, '-epoch-%d.mat'], state.epoch));
        load(modelPath);
    end
    preExpDir = opts.expDir;
    %%%-------------------------------------------------------------------------
    %%%   Train 
    %%%-------------------------------------------------------------------------
    [net, state] = dilatedDCNN_train(net, sigma, imdb, ...
        'expDir', opts.expDir, ...
        'learningRate',opts.learningRate, ...
        'solver',opts.solver, ...
        'gradientClipping',opts.gradientClipping, ...
        'batchSize', opts.batchSize, ...
        'modelname', opts.modelName, ...
        'gpus', opts.gpus, ...
        'tolerance', opts.tolerance, ...
        'toltEpochs', opts.toltEpochs) ;
    % savel loss
    losses = state.losses;
    psnrs = state.psnrs;
    save(fullfile(opts.expDir, 'losses.mat'), 'losses');
    save(fullfile(opts.expDir, 'psnrs.mat'), 'psnrs');
    
end
    